import itertools

load('custom_simplex.sage')


class HomogeneousComplex:
    """
    A collection of simplices of the same dimension.
    Handles singular simplexes.
    """

    def __init__(self, facets):
        self.facets = [CustomSimplex(facet) for facet in facets]
        self.facettos = self._compute_facettos()

        self.balancing_matrix = self._compute_balancing_matrix()

    def __str__(self):
        return f'HomogeneousComplex with facets: {self.facets}'

    def __repr__(self):
        return str(self)

    @classmethod
    def complete_complex(cls, n, d, is_singular=False):
        """
        Generates a complete 'd'-complex on 'n' vertices
        If 'is_singular' is True, repeated vertices are allowed in faces.
        """

        if is_singular:
            relevant_combinations = itertools.combinations_with_replacement
        else:
            relevant_combinations = itertools.combinations

        facets = []
        for comb in relevant_combinations(range(n), d+1):
            facets.append(CustomSimplex(comb))

        return HomogeneousComplex(facets)

    def facet_variables(self):
        # Create SageMath variables for each facet.
        variables = []

        for facet in self.facets:
            # E.g. (2,2,3,5,5,5) --> x_2_2_3_5_5_5
            var_name = 'x_' + '_'.join(str(v) for v in facet)
            variables.append(var(var_name)) 

        return variables

    def all_balancings_naive(self, weight_limit):
        legal_weights = range(-weight_limit, weight_limit + 1)
        num_facets = len(self.facets)

        for comb in itertools.product(legal_weights, repeat=num_facets):
            weights = Matrix(comb).transpose()
            facetto_sums = self.balancing_matrix * weights
            if facetto_sums.is_zero():
                yield weights.transpose()

    def _compute_facettos(self):
        # Precompute and store faces one dimension lower.
        facettos = set()

        for facet in self.facets:
            for facetto in itertools.combinations(facet, len(facet) - 1):
                facettos.add(CustomSimplex(facetto))

        return facettos
             
    def _compute_balancing_matrix(self):
        num_facets = len(self.facets)
        num_facettos = len(self.facettos)

        # One row per facetto and one column for facet.
        M = Matrix(QQ, num_facettos, num_facets)

        for facetto_index, facetto in enumerate(self.facettos):
            for facet_index, facet in enumerate(self.facets):
                M[facetto_index, facet_index] = facetto.multiplicity(facet)

        return M

