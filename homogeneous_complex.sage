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

        self.balancing_matrix = self._compute_balancing_matrix()

    def __str__(self):
        return f'HomogeneousComplex with facets: {self.facets}'

    def __repr__(self):
        return str(self)

    def print_info(self):
        """ Prints information about the structure of this complex. """
        print(f"# vertices: {num_vertices}\n")
        print(f"Facets: {K.facets}\n")
        print(f"Facettos: {K.facettos}\n")

        print("Balancing matrix:")
        print(K.balancing_matrix)
        print()

        print("Kernel basis:")
        for v in K.balancing_matrix.right_kernel().basis():
            print(v)
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

    def all_balancings_naive(self, weight_limit):
        """
        Generate all weightings for the facets that satisfy the balancing condition.
        
        The weights are drawn from the range [-weight_limit, weight_limit]. 
        For all possible combinations of weights, we check if the complex is balanced.

        Yields (as generator):
            dict: Of facet weights. Format: {<facet>: <weight>}
        """
        legal_weights = range(-weight_limit, weight_limit + 1)  # Legal weight range.
        num_facets = len(self.facets)  # Number of facets in the complex.
        
        # Iterate over all possible combinations of weights for the facets.
        for comb in itertools.product(legal_weights, repeat=num_facets):
            # Create a column matrix for the weights.
            weights = vector(comb)
            
            # Compute the sum of weighted facettos using the balancing matrix.
            facetto_sums = self.balancing_matrix * weights

            # If the sum is zero (balancing condition satisfied), yield the weights.
            if facetto_sums.is_zero():

                weight_dict = dict()

                for facet_idx, facet in enumerate(self.facets):
                    weight_dict[facet] = weights[facet_idx]

                yield weight_dict  # Yield the weights as a dictionary.

    def all_balancings_sudoku(self, weight_limit, initial_weights=dict()):
        """
        Generate all weightings for the facets that satisfy the balancing condition.
        Use a recursive smart search inspired by solving Sudoku puzzles.
        
        Parameters:
            weight_limit: The weights are chosen from [-weight_limit, weight_limit]. 
            initial_weights (dict, optional): 
                A collection of pre-specified facet weights. If used, this will
                return only the balanced weight-sets matching these initial weights.
                Format: {<facet>: <weight>}

        Instead of a brute-force search, we fill in the weights strategically like
        doing a Sudoku or crossword puzzle. The method is recursive.

        Yields (as generator):
            SageMath Matrix: Column vectors of facet-weights balancing the complex.
        """
        
        # Base case: All facets have a specified weight.
        if len(initial_weights) == len(self.facets):
            if self.is_balanced(initial_weights):
                yield initial_weights # Yield the balanced weight-set.
            return

        # Recursive case: Find the first unspecified facet and try all weight values.
        for facet in self.facets:
            if facet in initial_weights:
                continue # Skip facets that already have a specified weight.

            # Try all weight values from -weight_limit to +weight_limit.
            for val in range(-weight_limit, weight_limit + 1):
                new_weights = dict(initial_weights) # Create a new weight dictionary.
                new_weights[facet] = val # Assign current value to the selected facet.

                # Check if the new weight-set can potentially still be balanced.
                if not self.is_balanced_at(facet, new_weights):
                    continue

                # Recursively continue filling in the weights.
                for weights in self.all_balancings_sudoku(weight_limit, new_weights):
                    yield weights

            break # Only handle one unspecified facet at a time.

    def is_balanced(self, weight_dict):
        """
        Determines if the given weight-set balances this complex.

        If the weight-set is only partially defined, then the balancing conditions
        are only checked where they are fully defined.

        Parameters:
            weight_dict (dict):
                The weights of the facets; possibly only partially defined.
                Format: {<facet>: <weight>}

        Returns:
            bool: True if the weight-set is balanced where defined, False oth.
        """
        # Return True only if all facets satisfy the balancing condition.
        return all(self.is_balanced_at(facet, weight_dict) for facet in self.facets)

    def is_balanced_at(self, facet, weight_dict):
        """ 
        Check if the balance conditions involving a particular facet are satisfied.

        For every balancing condition (each row in the balancing matrix) that involves
        the specified facet, this function computes the weighted sum of facetto
        multiplicities using the provided weights. We only check a balancing condition
        if all the facets required for that condition are defined. If any fully
        defined condition has a nonzero sum, the function returns False.
        
        Parameters:
        facet: The facet for which to check the balancing conditions.
        weight_dict (dict): A dictionary mapping facets to their weight.

        Returns:
            bool: True if all relevant conditions are balanced (or aren't fully 
                  defined due to missing weights); False if any fully defined 
                  condition is unbalanced.
        """

        # Get the index of the facet of interest.
        target_index = self.facets.index(facet)
        
        # Iterate over each balancing condition (row) in the matrix.
        for row in self.balancing_matrix:
            # If this condition does not involve the target facet, skip it.
            if row[target_index] == 0:
                continue

            weight_total = 0

            # Flag to track if all required weights are available.
            condition_fully_defined = True  
            
            # Evaluate the weighted sum for this balancing condition.
            for i, multiplicity in enumerate(row):
                if multiplicity == 0:
                    continue  # Skip facets with no contribution in this condition.
                
                # If this facet's weight isn't provided, we can't check this condition.
                if self.facets[i] not in weight_dict:
                    condition_fully_defined = False
                    break
                
                # Accumulate the contribution of this facet.
                weight_total += multiplicity * weight_dict[self.facets[i]]
            
            # If the condition is both fully defined and unbalanced, return False.
            if condition_fully_defined and weight_total != 0:
                return False

        # All relevant conditions are balanced (or not fully defined), so return True.
        return True

    def trivial_weight_dict(self):
        """ Makes a dictionary with a key for each facet and all values are zero. """
        return {facet:0 for facet in self.facets}

    def weight_dict_to_vector(self, weight_dict):
        """ 
        Converts a Python dictionary of facet weights into a column vector. 
        Assigns a weight of zero to any facets omitted from the dictionary.
        """
        weight_list = []

        for facet in self.facets:
            if facet in weight_dict:
                weight_list.append(weight_dict[facet])
            else:
                weight_list.append(0)

        return vector(weight_list)
        

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
