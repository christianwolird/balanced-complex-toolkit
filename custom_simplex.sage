
class CustomSimplex:
    """
    Essentially a wrapper for tuples with a multiplicity function.
    """

    def __init__(self, vertices):
        self.vertices = tuple(sorted(vertices))

    def multiplicity(self, other):
        mult = 1
        for i in self.vertices:
            mult *= self.vertices.count(i) * other.vertices.count(i)
        return mult

    def __str__(self):
        return str(self.vertices) 

    def __repr__(self):
        return str(self)

    def __len__(self):
        return len(self.vertices)

    def __iter__(self):
        for v in self.vertices:
            yield v

    def __eq__(self, other):
        if isinstance(other, CustomSimplex):
            return self.vertices == other.vertices
        return False

    def __hash__(self):
        return hash(self.vertices)

