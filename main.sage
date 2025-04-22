import time

"""
Refactorization scratch work:

Goals:
-Split OBJECTS and OPTIMIZTIONS into different files.
-Find better file names.
-Switch to NumPy arrays for faster matrix/vector operations.

Object Files:
simplex.sage
complex.sage
weighted_complex.sage

Optimization Files:
weightset_probe.sage
subcomplex_probe.sage
"""

load('weighted_complex.sage')

num_vertices = 4
dimension = 2

K = Complex.complete_complex(num_vertices, dimension, is_singular=True)

print(f'# vertices = {num_vertices}')
print(f'dimension = {dimension}\n')

K.print_info()

