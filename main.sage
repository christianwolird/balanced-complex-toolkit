load('homogeneous_complex.sage')


K = HomogeneousComplex.complete_complex(4, 1, is_singular=False)

print('Facets:', K.facets)
print(' ')

print('Facettos:', K.facettos)
print(' ')

print('Balancing matrix:')
M = K.balancing_matrix
print(M)
print(' ')

print('Kernal basis:')
for v in M.right_kernel().basis():
    print(v)
print(' ')

print('All balancings with |weight| <= 1')
for weights in K.all_balancings_naive(1):
    print(weights)
