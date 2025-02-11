load('simplex_tools.sage')


K = HomogeneousComplex.complete_complex(6, 2, is_singular=False)

print(K)
print(' ')

print('Facettos:', K.facettos)
print(' ')

print('Balancing matrix:')
M = K.balancing_matrix
print(M.transpose())
print(' ')

print('Kernal:')
print(M.kernel())
