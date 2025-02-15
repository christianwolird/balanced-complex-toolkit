import itertools

load('homogeneous_complex.sage')


class WeightedComplex:
    """
    An extension of HomogeneousComplex that assigns weights to facets.
    
    This class contains a HomogeneousComplex and a weight dictionary.
    These weights are used to check balancing conditions.
    """

    def __init__(self, comp, weights=None):
        """
        Initializes a WeighedComplex.

        Parameters:
            comp (HomogeneousComplex): The underlying simplicial complex.
            weights (dict, optional): A dictionary mapping each facet to a weight.
        """
        self.comp = comp

        if weights is None:
            # Populate the weights with "None" if no dictionary was provided.
            self.weights = {facet: None for facet in comp.facets}
        else:
            self.weights = weights

    def copy(self):
        """
        Creates a copy of the WeightedComplex with a copy of the weight dictionary.

        Returns:
            WeighedComplex: A new instance with the same underlying complex and a
                            copied weight dictionary.

        Note: The underlying HomogeneousComplex is not copied. It is treated as
        immutable from the perspective of WeightedComplex.
        """
        return WeightedComplex(self.comp, dict(self.weights))

    def __str__(self):
        """ Returns the weight dictionary as a string representation. """
        return f'WeightedComplex:{self.weights}'

    def __repr__(self):
        """ Returns a string representation. """
        return str(self)

    def weight_vector(self):
        """ 
        Returns this complex's weights as a vector compatible with the multiplicity
        matrix in the corresponding HomogeneousComplex.
        """
        weight_list = []
        for facet in self.comp.facets:
            if self.weights[facet] is None:
                weight_list.append(0)
            else:
                weight_list.append(self.weights[facet])
        return vector(weight_list)
        
    def weight_vec_to_dict(self, weight_vec):
        """
        Converts a weight vector into a dictionary mapping facets to weights.

        The resulting vector is compatible with the multiplicity matrix of the 
        underlying HomogeneousComplex.
        """
        weight_dict = dict()

        # Iterate over facets and their corresponding indices in the weight vector.
        for facet_idx, facet in enumerate(self.comp.facets):
            # Assign each facet its corresponding weight from the vector.
            weight_dict[facet] = weight_vec[facet_idx]

        return weight_dict

    def all_balancings_naive(self, weight_limit):
        """
        Generate all weightings for the facets that satisfy the balancing condition.
        
        The weights are drawn from the range [-weight_limit, weight_limit]. 
        For all possible combinations of weights, we check if the complex is balanced.

        Yields (as generator):
            dict: Of facet weights. Format: {<facet>: <weight>}
        """
        legal_weights = range(-weight_limit, weight_limit + 1)  # Legal weight range.
        num_facets = len(self.comp.facets)  # Number of facets in the complex.
        
        # Iterate over all possible combinations of weights for the facets.
        for comb in itertools.product(legal_weights, repeat=num_facets):
            # Create a column matrix for the weights.
            weight_vec = vector(comb)
            
            # Compute the sum of weighted facettos using the balancing matrix.
            facetto_sums = self.comp.multiplicity_matrix * weight_vec

            # If the sum is zero (balancing condition satisfied), yield the weights.
            if facetto_sums.is_zero():
                weight_dict = self.weight_vec_to_dict(weight_vec)
                yield WeightedComplex(self.comp, weight_dict)

    def all_balancings_sudoku(self, weight_limit):
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
        if all(weight is not None for weight in self.weights.values()):
            if self.is_balanced():
                yield self # Yield this WeightedComplex.
            return

        # Recursive case: Find the first unspecified facet and try all weight values.
        for facet in self.comp.facets:
            if self.weights[facet] is not None:
                continue # Skip facets that already have a specified weight.

            # Try all weight values from -weight_limit to +weight_limit.
            for weight in range(-weight_limit, weight_limit + 1):
                child = self.copy()
                child.weights[facet] = weight # Assign a weight to the selected facet.

                # Check if the new weight-set can potentially still be balanced.
                if not child.is_balanced_at(facet):
                    continue

                # Recursively continue filling in the weights.
                for person in child.all_balancings_sudoku(weight_limit):
                    yield person

            break # Only handle one unspecified facet per method call.

    def is_balanced(self):
        """
        Determines if this complex is balanced.

        If the weight-set is only partially defined, then the balancing conditions
        are only checked where they are fully defined.

        Returns:
            bool: True if the weight-set is balanced where defined, False oth.
        """
        # Return True only if all facets satisfy the balancing condition.
        return all(self.is_balanced_at(facet) for facet in self.comp.facets)

    def is_balanced_at(self, facet):
        """ 
        Check if the balance conditions involving a particular facet are satisfied.

        For every balancing condition (each row in the multiplicity matrix) involving
        the specified facet, this function computes the weighted sum of multiplicities.
        We only check a balancing condition if all the facets required for that
        condition are defined. If any fully defined condition has a nonzero sum, the 
        function returns False.
        
        Parameters:
            facet: The facet for which to check the balancing conditions.

        Returns:
            bool: True if all relevant conditions are balanced (or aren't fully 
                  defined due to missing weights); False if any fully defined 
                  condition is unbalanced.
        """

        # Get the index of the facet of interest.
        target_index = self.comp.facets.index(facet)
        
        # Iterate over each balancing condition (row) in the matrix.
        for row in self.comp.multiplicity_matrix:
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
                if self.weights[self.comp.facets[i]] is None:
                    condition_fully_defined = False
                    break
                
                # Accumulate the contribution of this facet.
                weight_total += multiplicity * self.weights[self.comp.facets[i]]
            
            # If the condition is both fully defined and unbalanced, return False.
            if condition_fully_defined and weight_total != 0:
                return False

        # All relevant conditions are balanced (or not fully defined), so return True.
        return True

