class BCTSimplex:
    """
    Wrapper for a tuple representing a simplex. Has a multiplicity function.

    SageMath already had a built-in Simplex class but it seemed faulty.
    The built-in Simplex exhibited different behaviors when running the same code.
    """

    def __init__(self, vertices):
        """Initialize a CustomSimplex with sorted vertices."""
        self.vertices = tuple(sorted(vertices))

    def multiplicity(self, other):
        """Compute the multiplicity of this simplex inside another."""
        mult = 1
        for i in self.vertices:
            mult *= self.vertices.count(i) * other.vertices.count(i)
        return mult

    # Wrapper dunders.
    def __str__(self):
        """Return a string representation of the vertices."""
        return str(self.vertices)

    def __repr__(self):
        """Return a string representation of the CustomSimplex."""
        return str(self)

    def __len__(self):
        """Return the number of vertices."""
        return len(self.vertices)

    def __iter__(self):
        """Iterate over the vertices."""
        for v in self.vertices:
            yield v

    def __eq__(self, other):
        """Check equality with another CustomSimplex."""
        if isinstance(other, CustomSimplex):
            return self.vertices == other.vertices
        return False

    def __hash__(self):
        """Return a hash value for the CustomSimplex."""
        return hash(self.vertices)

    def __lt__(self, other):
        """Use '<' as slang for multiplicity. """
        return self.multiplicity(other)

