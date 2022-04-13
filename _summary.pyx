__all__ = ['summary']

range8 = range(8)
range64 = range(64)
def summary_1(bytes input) -> bytes:
    sum: bytearray
    res: bytes
    mi1: bytearray
    mi2: bytearray
    mi3: bytearray
    cdef unsigned long long lm1
    cdef int lm2
    tri: bytes
    tri = input + bytes(61 - len(input)%64)
    mi1 = bytearray(len(tri) + 2)
    for lm2 in range8:
        for lm1 in range(len(tri)):
            mi1[lm1    ] = (mi1[lm1 + 2] + tri[lm1]) % 256
            mi1[lm1 + 1] = (mi1[lm1 + 1] + tri[lm1]) % 256
            mi1[lm1 + 2] = (mi1[lm1    ] + tri[lm1]) % 256
    mi2 = mi1.copy()
    mi2.append(0)
    for lm2 in range8:
        for lm1 in range(len(mi1)):
            mi2[lm1], mi2[lm1 + 1] = (mi2[lm1] + mi2[lm1 + 1]) % 256, abs(mi2[lm1 + 1] - mi2[lm1])
        mi2.reverse()
    mi3 = bytearray(64)
    for lm1 in range(len(mi2) // 64):
        for lm2 in range64:
            mi3[lm2] = (mi3[lm2] + mi2[lm1 * 64 + lm2]) % 256
    res = bytes(mi3)
    return res

plus_12 = [18, 89, 86, 192, 81, 223, 70, 190, 109, 186, 31, 182, 254, 92, 151, 6]
plus_34 = [44, 69, 241, 77, 96, 83, 2, 176, 193, 200, 152, 134, 227, 62, 155, 37]
def summary_2(bytes input) -> bytes:
    cpy: bytearray
    eax: bytearray
    ebx: bytearray
    ecx: bytearray
    edx: bytearray
