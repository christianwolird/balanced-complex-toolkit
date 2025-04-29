import itertools

load('homogeneous_complex.sage')


class WeightedComplex:
    """
    An extension of HomogeneousComplex that assigns weights to facets.
    
    This class contains a HomogeneousComplex and a weight dictionary.
    These weights are used to check balancing conditions.

    This weight dictionary can be only partially defined, leaving some
    weights as the 'None' data type. Such weight-sets are NOT considered
    balanced, even if they are potentially balanceable.
    """

    def __init__(self, complex, weights=None):
        """
        Initializes a WeighedComplex.

        Parameters:
            complex (HomogeneousComplex): The underlying simplicial complex.
            weights (dict, optional): A dictionary mapping each facet to a weight.
        """
        self.complex = complex

        if weights is None:
            # Populate the weights with "None" if no dictionary was provided.
            self.weights = {facet: None for facet in complex.facets}
        else:
            self.weights = weights

    def copy(self):
        """
        Creates a copy of the WeightedComplex. 
        The weight dictionary is copied, but the underlying complex is not.
        """
        return WeightedComplex(self.complex, dict(self.weights))

    def __str__(self):
        """Returns the weight dictionary as a string representation."""
        return f'WeightedComplex:{self.weights}'

    def __repr__(self):
        """Returns a string representation."""
        return str(self)

    def get_weight_vector(self):
        """ 
        Returns this complex's weights as a vector compatible with the
        multiplicity matrix in the corresponding HomogeneousComplex.
        """
        weight_list = []
        for facet in self.complex.facets:
            if self.weights[facet] is None:
                weight_list.append(0)
            else:
                weight_list.append(self.weights[facet])
        return vector(weight_list)
        
    def is_balanced(self):
        """Determines if this complex is balanced."""
        if None in self.weights.values():
            # The complx is NOT balanced if any weights are undefined.
            return False
        M = self.complex.multiplicity_matrix
        v = self.get_weight_vector()
        return (M * v).is_zero()

    def is_balanceable(self):
        """
        Determines if a partially defined complex is balanced so far.
        In other words, check the balancing conditions where fully defined.
        """
        return False # TODO
