load('homogeneous_complex.sage')


K = HomogeneousComplex.complete_complex(5, 1, is_singular=False)

print(K)
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

#K.all_balancings_naive(1)
