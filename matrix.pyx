class Array:

    def __init__(self, int length, list data) -> None:
        if length <= 0: raise TypeError("Array length cannot be equal to or less than zero")
        if len(data) != length: raise ValueError("Array elements not enough or too much")
        self.length: int = length
        self.data: list = []
        for i in data:
            try: i + 0
            except TypeError: raise TypeError("Array element must be a number") from None
            self.data.append(i)
    
    def __iter__(self) -> _array_iter:
        return _array_iter(self)

    def __eq__(self, value) -> bool:
        if not isinstance(value, Array): return False
        if value.length != self.length: return False
        for i in range(self.length):
            if value[i] != self[i]: return False
        return True
    
    def __getitem__(self, int index):
        if index >= self.length or index < 0: raise IndexError("Array index out of range")
        return self.data[index]
    
    def __setitem__(self, int index, value) -> None:
        try: value + 0
        except TypeError: raise ValueError("Array element can only be a number") from None
        if index >= self.length or index < 0: raise IndexError("Array index out of range")
        self.data[index] = value
    
    def __ne__(self, value) -> bool:
        return not self==value
    
    def __neg__(self) -> Array:
        return self._copy(-1)
    
    def __mul__(self, int mul) -> Array:
        return self._copy(mul)
    
    def __len__(self) -> int:
        return self.length
    
    def _copy(self, int mul) -> Array:
        new: list = [None] * self.length
        cdef int i
        for i in range(self.linc):
            new[i] = self.data[i] * mul
        return Array(self.length, new)
    
    def copy(self) -> Array:
        new: list = [None] * self.length
        cdef int i
        for i in range(self.linc):
            new[i] = self.data[i]
        return Array(self.length, new)
    
    def deepcopy(self) -> Array:
        return self._copy(1)

    def reverse(self) -> None:
        self.data.reverse()
    
    def reversed(self) -> Array:
        return Array(self.length, list(reversed(self.data)))

class _array_iter():

    def __init__(self, arr):
        self.index: int = 0
        self.data: Array = arr
    
    def __next__(self):
        if self.index == self.data.length: raise StopIteration
        self.index += 1
        return self.data[self.index - 1]

class Matrix:

    def __init__(self, int lines, int columns, list data) -> None:
        if lines <= 0 or columns <= 0: raise TypeError("Matrix lines or columns cannot be equal to or less than zero")
        self.linc: int = lines
        self.colc: int = columns
        self.data: list = [[None] * columns] * lines
        cdef int i, j
        for i in range(self.linc):
            for j in range(self.colc):
                try: data[i][j] + 0
                except TypeError: raise TypeError("Matrix element can only be a number") from None
                except IndexError: raise ValueError("List elements not enough") from None
                self.data[i][j] = data[i][j]
    
    def __eq__(self, value) -> bool:
        if not isinstance(value, Matrix): return False
        if self.linc != value.linc: return False
        if self.colc != value.colc: return False
        cdef int i, j
        for i in range(self.linc):
            for j in range(self.colc):
                if self.data[i][j] != value.data[i][j]:
                    return False
        return True
    
    def __ne__(self, value) -> bool:
        return not self==value
    
    def __neg__(self) -> Matrix:
        return self._copy(-1)

    def __add__(self, value: Matrix) -> Matrix:
        if self.linc != value.linc or self.colc != value.colc: raise ValueError("Matrix object can only be added to a Matrix in the same size")
        new: Matrix = self.deepcopy()
        cdef int i, j
        for i in range(self.linc):
            for j in range(self.colc):
                new.add(i, j, value.data[i][j])
        return new
    
    def __sub__(self, value: Matrix) -> Matrix:
        return self + (-value)
    
    def __mul__(self, value) -> Matrix:
        if not isinstance(value, Matrix):
            try: value + 0
            except TypeError: raise TypeError("the second value must be a number or a Matrix") from None
            return self._copy(value)
        if self.colc != value.linc: raise ValueError("the second Matrix must have the same lines as the first's columns")
        new = [[None] * value.colc] * self.linc
        cdef int i, j, k
        for i in range(self.linc):
            for j in range(value.colc):
                new[i][j] = 0
                for k in range(self.colc):
                    new[i][j] += self[i][k] * value[k][j]
        return Matrix(self.linc, value.colc, new)
    
    def __getitem__(self, int index) -> Array:
        if index >= self.linc or index < 0: raise IndexError("Matrix index out of range")
        return Array(self.data[index])
    
    def __setitem__(self, int index, element: Array):
        if index >= self.linc or index < 0: raise IndexError("Matrix index out of range")
        self.data[index] = element.data
    
    def __iter__(self):
        return _matrix_iter(self)

    def _copy(self, int mul) -> Matrix:
        new: list = [[None] * self.colc] * self.linc
        cdef int i, j
        for i in range(self.linc):
            for j in range(self.colc):
                new[i][j] = self.data[i][j] * mul
        return Matrix(self.linc, self.colc, new)
    
    def copy(self) -> Matrix:
        new: list = [[None] * self.colc] * self.linc
        cdef int i, j
        for i in range(self.linc):
            for j in range(self.colc):
                new[i][j] = self.data[i][j]
        return Matrix(self.linc, self.colc, new)
    
    def deepcopy(self) -> Matrix:
        return self._copy(1)
    
    def add(self, int line, int coln, num) -> None:
        try: num + 0
        except TypeError: raise TypeError("Can only add a number to a Matrix element") from None
        if line >= self.linc or coln >= self.coln: raise IndexError('Matrix index out of range')
        self.data[line][coln] += num
    
    def sub(self, int line, int coln, num) -> None:
        self.add(line, coln, -num)
    
    def set(self, int line, int coln, num) -> None:
        try: num + 0
        except TypeError: raise TypeError("Can only add a number to a Matrix element") from None
        if line >= self.linc or coln >= self.coln: raise IndexError('Matrix index out of range')
        self.data[line][coln] = num
    
    def rotate(self, int rotation=1) -> Matrix:
        cdef int i, j
        if not 0 <= rotation <= 3: raise ValueError("rotation must be 0, 1, 2 or 3")
        if rotation == 0: return self.copy()
        elif rotation == 1:
            new: list = [[None] * self.linc] * self.colc
            for i in range(self.linc):
                for j in range(self.colc):
                    new[j][i] = self[i][j]
            return Matrix(self.colc, self.linc, new)
        elif rotation == 2:
            new = self.copy()
            for i in range(new.linc):
                new[i] = self[self.linc - i - 1].reversed()
            return new
        else:
            return self.rotate(1).rotate(2)
    
class _matrix_iter:

    def __init__(self, itering: Matrix):
        self.index = 0
        self.data = itering
    
    def __next__(self):
        if self.index == self.itering.linc: raise StopIteration
        self.index += 1
        return self.itering[self.index - 1]
