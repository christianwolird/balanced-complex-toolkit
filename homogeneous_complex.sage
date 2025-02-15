import itertools

load('custom_simplex.sage')


class HomogeneousComplex:
    """
    A collection of simplices of the same dimension.
    Handles singular simplexes.
    """

    def __init__(self, facets):
        """
        Initialize a HomogeneousComplex with a list of CustomSimplex instances.
        """
        self.facets = facets
        self.facettos = self._compute_facettos()
        self.multiplicity_matrix = self._compute_multiplicity_matrix()

    def __str__(self):
        return f'HomogeneousComplex:{self.facets}'

    def __repr__(self):
        return str(self)

    def print_info(self):
        """ Prints information about the structure of this complex. """
        print(f"Facets: {K.facets}\n")
        print(f"Facettos: {K.facettos}\n")

        print("Balancing matrix:")
        print(K.multiplicity_matrix)
        print()

    @classmethod
    def complete_complex(cls, n, d, is_singular=False):
        """
        Generate a complete 'd'-dimensional simplicial complex on 'n' vertices.

        A complete 'd'-complex includes all possible d-dimensional faces.

        Parameters:
            n (int): The number of vertices. Must be non-negative.
            d (int): The dimension of the simplices to generate.
            is_singular (bool, optional): If True, allows repeated vertices in faces
                (resulting in "singular" simplices). Defaults to False.

        Returns:
            HomogeneousComplex: Containing all d-dimensional faces.
        """

        # Choose the appropriate combinatorial method.
        if is_singular:
            # Allow repeated vertices. E.g. (1, 1, 2).
            relevant_combinations = itertools.combinations_with_replacement
        else:
            # Only unique vertices on each facet. E.g. (1, 2, 3).
            relevant_combinations = itertools.combinations

        facets = [] # List to store all facets (i.e. maximal faces) of the complex.

        # Iterate over all combinations of 'd+1' vertices.
        for comb in relevant_combinations(range(n), d + 1):
            # Create a CustomSimplex from the current combination; add it to 'facets'.
            facets.append(CustomSimplex(comb))

        # Return a HomogeneousComplex built from the generated facets.
        return HomogeneousComplex(facets)

    def _compute_facettos(self):
        """
        Precompute and store all codimension=1 faces (facettos) from the facets.

        A "facetto" is essentially a lower-dimensional simplex (facet with one vertex 
        removed). This method generates and stores all (d-1)-dimensional faces 
        (facettos) from the given d-dimensional facets.

        Returns:
            list: Containing all facettos as CustomSimplex objects.
        """
        facettos = set()  # Initialize an empty set to store the facettos.

        # Iterate through each facet and compute all its facettos.
        for facet in self.facets:
            # Generate all (d-1)-dimensional faces (combinations of facet vertices).
            for facetto in itertools.combinations(facet, len(facet) - 1):
                # Store each facetto as a CustomSimplex.
                facettos.add(CustomSimplex(facetto))

        return list(facettos)  # Return a list of facettos.

    def _compute_multiplicity_matrix(self):
        """
        Compute the multiplicty matrix representing inclusions of facettos in facets.
        
        Each row corresponds to a facetto, and each column corresponds to a facet.
        The entries are the multiplicity of the facettos inside the facets.
        
        Returns a SageMath Matrix of size #facettos x #facets.
        """
        num_facets = len(self.facets)  # Number of facets.
        num_facettos = len(self.facettos)  # Number of facettos.

        # Initialize an empty matrix of size 'num_facettos' x 'num_facets'.
        M = Matrix(QQ, num_facettos, num_facets)

        # Iterate over all facettos and facets to compute the inclusion multiplicity.
        for facetto_index, facetto in enumerate(self.facettos):
            for facet_index, facet in enumerate(self.facets):
                # Set matrix entry.
                M[facetto_index, facet_index] = facetto.multiplicity(facet)  

        return M  # Return the computed multiplicty matrix.

