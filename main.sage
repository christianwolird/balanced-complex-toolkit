load('weighted_complex.sage')

num_vertices = 3
dimension = 2
weight_limit = 1

K = HomogeneousComplex.complete_complex(num_vertices, dimension, is_singular=True)
K.print_info()

parent = WeightedComplex(K)

print('All balancings:')
for child in parent.all_balancings_sudoku(weight_limit):
    print(child.weight_vector())
