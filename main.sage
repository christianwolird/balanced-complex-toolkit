load('homogeneous_complex.sage')

num_vertices = 4
dimension = 1
weight_limit = 1

K = HomogeneousComplex.complete_complex(num_vertices, dimension, is_singular=False)

print(f'# vertices: {num_vertices}')

print(f'Facets: {K.facets}')
print(' ')

print(f'Facettos: {K.facettos}')
print(' ')

print('Balancing matrix:')
M = K.balancing_matrix
print(M)
print(' ')

print('Kernal basis:')
for v in M.right_kernel().basis():
    print(v)
print(' ')

print(f'All balancings with |weight| <= {weight_limit}')
for weights in K.all_balancings_naive(weight_limit):
    print(weights)
