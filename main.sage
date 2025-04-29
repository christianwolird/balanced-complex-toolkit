import time

load('weighted_complex.sage')

num_vertices = 4
dimension = 2
weight_limit = 1


K = HomogeneousComplex.complete_complex(num_vertices, dimension, is_singular=False)

print(f'# vertices = {num_vertices}')
print(f'dimension = {dimension}\n')

K.print_info()

parent = WeightedComplex(K)

print('All balancings:')

start_time = time.perf_counter()

for child in parent.all_balancings_sudoku(weight_limit):
    print(child.weight_vector())

end_time = time.perf_counter()
total_time = end_time - start_time

print(f'\nCalculation time: {total_time}')
