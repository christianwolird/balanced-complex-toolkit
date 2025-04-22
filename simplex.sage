class Simplex:
    """
    Wrapper for a tuple representing a simplex. Has a multiplicity function.
    """

    def __init__(self, vertices):
        """Initialize a Simplex with sorted vertices."""
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
        """Return a string representation of the Simplex."""
        return str(self)

    def __len__(self):
        """Return the number of vertices."""
        return len(self.vertices)

    def __iter__(self):
        """Iterate over the vertices."""
        for v in self.vertices:
            yield v

    def __eq__(self, other):
        """Check equality with another Simplex."""
        if isinstance(other, Simplex):
            return self.vertices == other.vertices
        return False

    def __hash__(self):
        """Return a hash value for the Simplex."""
        return hash(self.vertices)

