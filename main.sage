load('homogeneous_complex.sage')

num_vertices = 3
dimension = 2
weight_limit = 1

K = HomogeneousComplex.complete_complex(num_vertices, dimension, is_singular=True)

K.print_info()

print('All balancings:')
for weight_dict in K.all_balancings_sudoku(1):
    print(K.weight_dict_to_vector(weight_dict))
