import itertools

load('custom_simplex.sage')


class HomogeneousComplex:
    """
    A collection of simplices of the same dimension.
    Handles singular simplexes.
    """

    def __init__(self, facet_tuples):
        self.facets = [CustomSimplex(facet) for facet in facet_tuples]
        self.facettos = self._compute_facettos()

        self.balancing_matrix = self._compute_balancing_matrix()

    def __str__(self):
        return f'HomogeneousComplex with facets: {self.facets}'

    def __repr__(self):
        return str(self)

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

    def all_balancings_naive(self, weight_limit):
        """
        Generate all weightings for the facets that satisfy the balancing condition.
        
        The weights are drawn from the range [-weight_limit, weight_limit]. 
        For all possible combinations of weights, we check if the complex is balanced.

        Yields (as generator):
            SageMath Matrices: Column vectors of facet-weights balancing the complex.
        """
        legal_weights = range(-weight_limit, weight_limit + 1)  # Legal weight range
        num_facets = len(self.facets)  # Number of facets in the complex
        
        # Iterate over all possible combinations of weights for the facets
        for comb in itertools.product(legal_weights, repeat=num_facets):
            # Create a column matrix for the weights
            weights = Matrix(comb).transpose()  
            
            # Compute the sum of weighted facettos using the balancing matrix
            facetto_sums = self.balancing_matrix * weights

            # If the sum is zero (balancing condition satisfied), yield the weights
            if facetto_sums.is_zero():
                yield weights.transpose()  # Yield the weights as a column vector.

    def all_balancings_sudoku(self, weight_limit):
        """
        Generate all weightings for the facets that satisfy the balancing condition.
        
        The weights are drawn from the range [-weight_limit, weight_limit]. 
        Instead of a brute-force search, we fill in the weights strategically like
        doing a Sudoku or crossword puzzle.

        Yields (as generator):
            SageMath Matrices: Column vectors of facet-weights balancing the complex.
        """
        pass # TODO

    def _compute_facettos(self):
        """
        Precompute and store all codimension=1 faces (facettos) from the facets.

        A "facetto" is essentially a lower-dimensional simplex (facet with one vertex 
        removed). This method generates and stores all (d-1)-dimensional faces 
        (facettos) from the given d-dimensional facets.

        Returns a Python set containing all facettos as CustomSimplex objects.
        """
        facettos = set()  # Initialize an empty set to store the facettos

        # Iterate through each facet and compute all its facettos
        for facet in self.facets:
            # Generate all (d-1)-dimensional faces (combinations of facet vertices).
            for facetto in itertools.combinations(facet, len(facet) - 1):
                # Store each facetto as a CustomSimplex.
                facettos.add(CustomSimplex(facetto))

        return facettos  # Return the set of facettos

    def _compute_balancing_matrix(self):
        """
        Compute the balancing matrix representing inclusions of facettos in facets.
        
        Each row corresponds to a facetto, and each column corresponds to a facet.
        The entries in the matrix represent the multiplicity of the intersection
        between each facetto and each facet.
        
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

        return M  # Return the computed balancing matrix.
