load('darmonpoints.sage')
from sage.misc.misc import alarm,cancel_alarm
from sage.parallel.decorate import parallel,fork
######################
# Parameters         #
######################

x = QQ['x'].gen()
Nrange = range(1,1000) # Conductors to explore
max_P_norm = 100 # Maximum allowed conductor
max_F_disc = None # Maximum size of discriminant of base field
max_waiting_time = 2 * 60 # Amount of patience (in seconds)
chunk_length = 20
outfile_base = 'candidates'


data = [\
[x^3 - x^2 + 1, -23, 2, []],\
[x^3 + x - 1, -31, 2, []],\
[x^3 - x^2 + x + 1, -44, 2, []],\
[x^3 + 2*x - 1, -59, 2, []],\
[x^3 - 2*x - 2, -76, 2, []],\
[x^3 - x^2 + x - 2, -83, 2, []],\
[x^3 - x^2 + 2*x + 1, -87, 2, []],\
[x^3 - x - 2, -104, 2, []],\
[x^3 - x^2 + 3*x - 2, -107, 2, []],\
[x^3 - 2, -108, 2, []],\
[x^3 - x^2 - 2, -116, 2, []],\
[x^3 + 3*x - 1, -135, 2, []],\
[x^3 - x^2 + x + 2, -139, 2, []],\
[x^3 + 2*x - 2, -140, 2, []],\
[x^3 - x^2 - 2*x - 2, -152, 2, []],\
[x^3 - x^2 - x + 3, -172, 2, []],\
[x^3 - x^2 + 2*x - 3, -175, 2, []],\
[x^3 - x^2 + 4*x - 1, -199, 2, []],\
[x^3 - x^2 + 2*x + 2, -200, 2, []],\
[x^3 - x^2 + x - 3, -204, 2, []],\
[x^3 - 2*x - 3, -211, 2, []],\
[x^3 - x^2 + 4*x - 2, -212, 2, []],\
[x^3 + 3*x - 2, -216, 2, []],\
[x^3 - x^2 + 3, -231, 2, []],\
[x^3 - x - 3, -239, 2, []],\
[x^3 - 3, -243, 2, []],\
[x^3 + x - 6, -244, 2, []],\
[x^3 + x - 3, -247, 2, []],\
[x^3 - x^2 - 3, -255, 2, []],\
[x^3 - x^2 - 3*x + 5, -268, 2, []],\
[x^3 - x^2 - 3*x - 3, -300, 2, []],\
[x^3 - x^2 + 3*x + 2, -307, 2, []],\
[x^3 - 3*x - 4, -324, 2, []],\
[x^3 - x^2 - 2*x - 3, -327, 2, []],\
[x^3 - x^2 + 4*x + 1, -335, 2, []],\
[x^3 - x^2 - x + 4, -339, 2, []],\
[x^3 + 3*x - 3, -351, 2, []],\
[x^3 - x^2 + x + 7, -356, 2, []],\
[x^3 + 4*x - 2, -364, 2, []],\
[x^3 - x^2 + 2*x + 3, -367, 2, []],\
[x^3 - x^2 + x - 4, -379, 2, []],\
[x^3 - x^2 + 5*x - 2, -411, 2, []],\
[x^3 - 4*x - 5, -419, 2, []],\
[x^3 - x^2 + 8, -424, 2, []],\
[x^3 - x - 8, -431, 2, []],\
[x^3 + x - 4, -436, 2, []],\
[x^3 - x^2 - 2*x + 5, -439, 2, []],\
[x^3 + 2*x - 8, -440, 2, []],\
[x^3 - x^2 - 5*x + 8, -451, 2, []],\
[x^3 + 3*x - 8, -459, 2, []],\
[x^3 - x^2 + 5*x - 3, -460, 2, []],\
[x^3 - 5*x - 6, -472, 2, []],\
[x^3 - x^2 + 4*x + 2, -484, 2, []],\
[x^3 - x^2 + 3*x + 3, -492, 2, []],\
[x^3 + 4*x - 3, -499, 2, []],\
[x^3 - x^2 + 2*x + 8, -503, 2, []],\
[x^3 - x^2 - x - 4, -515, 2, []],\
[x^3 - x^2 + x - 9, -516, 2, []],\
[x^3 - x^2 - 4*x + 7, -519, 2, []],\
[x^3 - x^2 + 3*x - 5, -524, 2, []],\
[x^3 + 5*x - 1, -527, 2, []],\
[x^3 - x^2 + 2*x - 5, -543, 2, []],\
[x^3 - x^2 - 3*x - 4, -547, 2, []],\
[x^3 - 3*x - 5, -567, 2, []],\
[x^3 - x^2 - 5*x - 5, -620, 2, []],\
[x^3 - x^2 + 4*x + 8, -628, 2, []],\
[x^3 - x^2 + 7*x + 5, -652, 2, []],\
[x^3 - x^2 + 5, -655, 2, []],\
[x^3 - x - 5, -671, 2, []],\
[x^3 - 5, -675, 2, []],\
[x^3 + x - 5, -679, 2, []],\
[x^3 - x^2 - 6*x + 10, -680, 2, []],\
[x^3 - x^2 + 4*x + 3, -687, 2, []],\
[x^3 - x^2 - 5, -695, 2, []],\
[x^3 - x^2 - 2*x + 6, -696, 2, []],\
[x^3 + 2*x - 5, -707, 2, []],\
[x^3 - 4*x - 6, -716, 2, []],\
[x^3 - x^2 + 6*x - 2, -728, 2, []],\
[x^3 + 5*x - 3, -743, 2, []],\
[x^3 - x^2 - 6*x - 6, -744, 2, []],\
[x^3 - x^2 + x + 5, -748, 2, []],\
[x^3 - x^2 + 5*x + 2, -755, 2, []],\
[x^3 - 6*x - 12, -756, 2, []],\
[x^3 - x^2 + 6*x - 3, -759, 2, []],\
[x^3 - x^2 + 3*x - 6, -771, 2, []],\
[x^3 - x^2 - x - 5, -780, 2, []],\
[x^3 - x^2 + 4*x - 6, -804, 2, []],\
[x^3 - x^2 + 2*x - 6, -808, 2, []],\
[x^3 - x^2 - 7*x - 7, -812, 2, []],\
[x^3 - 7*x - 9, -815, 2, []],\
[x^3 - 5*x - 7, -823, 2, []],\
[x^3 - x^2 - x + 6, -835, 2, []],\
[x^3 - x^2 - 2*x - 5, -839, 2, []],\
[x^3 - x^2 - 2*x + 12, -843, 2, []],\
[x^3 - x^2 + x + 11, -856, 2, []],\
[x^3 - x^2 + 2*x + 5, -863, 2, []],\
[x^3 - x^2 + 6*x - 12, -867, 2, []],\
[x^3 - x^2 - x - 11, -876, 2, []],\
[x^3 - x^2 + 2*x - 12, -883, 2, []],\
[x^3 - x^2 + 9*x + 3, -888, 2, []],\
[x^3 - x^2 - 7*x + 12, -907, 2, []],\
[x^3 - 4*x - 12, -908, 2, []],\
[x^3 + 5*x - 4, -932, 2, []],\
[x^3 - 2*x - 6, -940, 2, []],\
[x^3 - x^2 + 6, -948, 2, []],\
[x^3 - x^2 + 6*x + 1, -959, 2, []],\
[x^3 - 2*x - 12, -964, 2, []],\
[x^3 - x - 12, -971, 2, []],\
[x^3 - 12, -972, 2, []],\
[x^3 - 6, -972, 2, []],\
[x^3 - x^2 + 6*x - 5, -983, 2, []],\
[x^3 - x^2 - 12, -984, 2, []],\
[x^3 - x^2 - 6, -996, 2, []],\
[x^3 + 3*x - 12, -999, 2, []],\
[x^4 - x^3 + 2*x - 1, -275, 3, []],\
[x^4 - x - 1, -283, 5, []],\
[x^4 - x^3 + x^2 + x - 1, -331, 5, []],\
[x^4 - x^2 - 1, -400, 3, []],\
[x^4 - 2*x^3 + x^2 - 2*x + 1, -448, 3, []],\
[x^4 - 2*x^3 + 2*x^2 - x - 1, -475, 3, []],\
[x^4 - x^3 - x^2 + 3*x - 1, -491, 5, []],\
[x^4 - x^3 - x^2 - x + 1, -507, 3, []],\
[x^4 - x^3 + x^2 - x - 1, -563, 5, []],\
[x^4 - x^3 - 2*x + 1, -643, 5, []],\
[x^4 - 2*x - 1, -688, 5, []],\
[x^4 - x^3 + 2*x^2 - 1, -731, 5, []],\
[x^4 - 2*x^3 + x^2 - x - 1, -751, 5, []],\
[x^4 - x^3 - 3*x - 1, -775, 3, []],\
[x^4 - x^2 - 2*x + 1, -848, 5, []],\
[x^4 - 2*x^3 + 3*x^2 - 1, -976, 5, []],\
[x^4 - 2*x^2 - 1, -1024, 3, []],\
[x^4 - x^3 + x^2 - 3*x + 1, -1099, 5, []],\
[x^4 - x^3 - 2*x - 1, -1107, 5, []],\
[x^4 - x^3 - 2*x^2 - x + 1, -1156, 3, []],\
[x^4 - x^3 + 2*x^2 + x - 1, -1192, 5, []],\
[x^4 - x^2 - 3*x - 1, -1255, 5, []],\
[x^4 - x^3 - 3*x^2 - x + 1, -1323, 3, []],\
[x^4 - 3*x^2 - 2*x + 1, -1328, 5, []],\
[x^4 + 2*x^2 - x - 1, -1371, 5, []],\
[x^4 - x^3 + x^2 + 4*x - 4, -1375, 3, []],\
[x^4 - x^3 + x - 2, -1399, 5, []],\
[x^4 - x^3 + x^2 - 2*x - 1, -1423, 5, []],\
[x^4 + x^2 - 2*x - 1, -1424, 5, []],\
[x^4 - 2*x^2 - 2*x + 1, -1456, 5, []],\
[x^4 - 2*x^3 + 2*x^2 - 2, -1472, 5, []],\
[x^4 - 2*x^3 + 3*x^2 - 2*x - 1, -1472, 3, []],\
[x^4 - x^3 - x^2 + 5*x - 5, -1475, 3, []],\
[x^4 - x^3 - 3*x^2 + 2, -1588, 5, []],\
[x^4 - 2*x^2 - 4, -1600, 3, []],\
[x^4 - 2*x^3 - 2*x + 1, -1728, 3, []],\
[x^4 - x^3 + 3*x - 1, -1732, 5, []],\
[x^4 - 2*x^3 + 3*x^2 - 2*x - 4, -1775, 3, []],\
[x^4 - x^3 - x^2 - 2*x + 1, -1791, 5, []],\
[x^4 - 2*x^2 - 4*x - 2, -1792, 3, []],\
[x^4 - x^3 + 3*x - 2, -1823, 5, []],\
[x^4 - 2*x^3 + x^2 - 2*x - 1, -1856, 5, []],\
[x^4 - x^3 - 2*x^2 - 3*x + 1, -1879, 5, []],\
[x^4 - 2*x^3 + x^2 - 3*x + 1, -1927, 5, []],\
[x^4 - 3*x + 1, -1931, 5, []],\
[x^4 - x^3 + 2*x^2 - 2*x - 1, -1963, 5, []],\
[x^4 - 4*x^2 - 2*x + 2, -1968, 5, []],\
[x^4 - 2*x^3 + x^2 - 5, -1975, 3, []],\
[x^4 - 2*x^3 + x^2 - 2, -1984, 3, []],\
[x^4 - 2*x^3 + 2*x^2 + 2*x - 1, -1984, 5, []],\
[x^4 - 5, -2000, 3, []],\
[x^4 - 2, -2048, 3, []],\
[x^4 - x^3 - x^2 + 3*x + 1, -2051, 5, []],\
[x^4 - x^3 - 2*x^2 + 3*x + 1, -2068, 5, []],\
[x^4 - x^3 + x^2 - 3*x - 2, -2092, 5, []],\
[x^4 - 2*x^2 - 2*x + 2, -2096, 5, []],\
[x^4 - x^3 + x^2 - 2, -2116, 5, []],\
[x^4 - x^2 - 3*x - 2, -2151, 5, []],\
[x^4 - 2*x^3 + 3*x^2 + x - 1, -2183, 5, []],\
[x^4 - x^3 + 3*x^2 - 1, -2191, 5, []],\
[x^4 - x^3 + 3*x^2 - x - 1, -2219, 5, []],\
[x^4 - x^3 - x^2 - 3*x - 1, -2243, 5, []],\
[x^4 - 2*x^3 + 2*x^2 + 2*x - 4, -2284, 5, []],\
[x^4 - 3*x^2 - 2, -2312, 3, []],\
[x^4 - x^3 - 2*x^2 + 3*x + 2, -2319, 5, []],\
[x^4 - x^2 - x - 2, -2327, 5, []],\
[x^4 - x^3 + x^2 - 6*x - 4, -2375, 3, []],\
[x^4 - x^3 - x^2 + x - 2, -2412, 5, []],\
[x^4 - 3*x - 1, -2443, 5, []],\
[x^4 - x^3 - x^2 - 5*x - 5, -2475, 3, []],\
[x^4 - 2*x - 2, -2480, 5, []],\
[x^4 - x^3 + x^2 + 2*x - 2, -2488, 5, []],\
[x^4 - 2*x^3 + 4*x^2 - x - 1, -2563, 5, []],\
[x^4 - 2*x^2 - 2*x - 2, -2608, 5, []],\
[x^4 - x^3 - 3*x^2 + 3*x + 3, -2619, 5, []],\
[x^4 - 3*x^2 - 3*x - 2, -2687, 5, []],\
[x^4 - x^3 - 3*x + 1, -2696, 5, []],\
[x^4 - 3*x^2 - 1, -2704, 3, []],\
[x^4 - 2*x^3 + 2*x^2 + 2*x - 2, -2736, 5, []],\
[x^4 - 4*x^2 - 3*x + 1, -2763, 5, []],\
[x^4 - x^3 - 3*x^2 + x - 2, -2764, 5, []],\
[x^4 - x^3 - 3*x + 2, -2767, 5, []],\
[x^4 - x^3 - x^2 - 5*x - 3, -2787, 5, []],\
[x^4 - 2*x^2 - 4*x - 1, -2816, 5, []],\
[x^4 - x^3 - x^2 - 2*x + 2, -2824, 5, []],\
[x^4 - x^3 + 2*x^2 + 2*x - 1, -2843, 5, []],\
[x^4 - x^3 - x^2 + 3*x - 3, -2859, 5, []],\
[x^4 + x^2 - x - 2, -2911, 5, []],\
[x^4 - x^3 - x - 2, -2943, 5, []],\
[x^4 - 2*x^3 + 3*x^2 + 4*x - 4, -3008, 3, []],\
[x^4 - x^3 + x^2 - x - 2, -3052, 5, []],\
[x^4 - x^3 - 2*x^2 - 3*x - 4, -3119, 5, []],\
[x^4 - x^3 - 2*x^2 - 2*x + 1, -3163, 5, []],\
[x^4 - x^2 - 3*x + 2, -3175, 5, []],\
[x^4 - x^3 + x^2 - 4*x + 2, -3188, 5, []],\
[x^4 - 2*x^3 - x^2 + 3, -3216, 5, []],\
[x^4 - x^3 - x^2 + 4*x - 1, -3223, 5, []],\
[x^4 - x^3 + 3*x^2 + x - 1, -3267, 5, []],\
[x^4 + 3*x^2 - x - 1, -3271, 5, []],\
[x^4 - x^3 + 2*x^2 + 6*x - 9, -3275, 3, []],\
[x^4 - x^3 - x^2 - 2, -3284, 5, []],\
[x^4 - x^2 - 3*x + 1, -3303, 5, []],\
[x^4 - 2*x^3 - x^2 + 2*x - 2, -3312, 3, []],\
[x^4 + x^2 - 6*x + 1, -3312, 3, []],\
[x^4 - 2*x^3 + x^2 + 4*x + 1, -3376, 5, []],\
[x^4 - x^3 - 2*x^2 + x - 3, -3407, 5, []],\
[x^4 - x^3 - 4*x^2 - 2*x + 1, -3411, 5, []],\
[x^4 - 3*x^2 - 2*x + 2, -3424, 5, []],\
[x^4 - x^3 + x^2 + 2*x - 4, -3431, 5, []],\
[x^4 - x^3 - 2*x^2 + 2*x - 2, -3436, 5, []],\
[x^4 - x^3 - 2*x^2 + 8*x - 11, -3475, 3, []],\
[x^4 - 2*x^3 + 4*x^2 - 1, -3504, 5, []],\
[x^4 + x^2 - 4*x - 2, -3544, 5, []],\
[x^4 - 2*x^3 + 3*x^2 - x - 2, -3559, 5, []],\
[x^4 - x^3 - 5*x^2 + 5*x + 3, -3571, 5, []],\
[x^4 - 3*x^2 - 9, -3600, 3, []],\
[x^4 - 2*x^3 - 2*x + 2, -3632, 5, []],\
[x^4 - x^3 + x^2 + 3*x - 1, -3723, 5, []],\
[x^4 - x^3 + x^2 - 3*x - 1, -3747, 5, []],\
[x^4 - x^3 - 2*x^2 - 3*x - 2, -3751, 5, []],\
[x^4 - x^3 + 7*x - 11, -3775, 3, []],\
[x^4 - 2*x^3 - 2, -3776, 5, []],\
[x^4 - 2*x^3 - 3*x^2 + 2*x + 3, -3776, 5, []],\
[x^4 - x^3 - x^2 - 2*x - 2, -3816, 5, []],\
[x^4 - 2*x^3 + 4*x^2 - 3*x - 9, -3875, 3, []],\
[x^4 - x^3 + 5*x - 1, -3887, 3, []],\
[x^4 - 2*x^3 - 6*x + 3, -3888, 5, []],\
[x^4 - x^3 - 4*x^2 + 3, -3891, 5, []],\
[x^4 - 2*x^3 + 2*x^2 + x - 3, -3899, 5, []],\
[x^4 + x^2 - 3*x - 1, -3919, 5, []],\
[x^4 - x^3 + 2*x^2 + x - 2, -3951, 5, []],\
[x^4 - x^3 - 2*x^2 + 5*x + 1, -3967, 5, []],\
[x^4 - 2*x^3 + 2*x^2 + 6*x - 3, -3984, 5, []],\
[x^4 - 2*x^2 - x - 2, -4027, 5, []],\
[x^4 - x^3 + 2*x - 3, -4027, 5, []],\
[x^4 - 2*x^3 - x^2 - 4*x - 2, -4032, 3, []],\
[x^4 - x^3 - 3*x^2 - 2*x + 1, -4063, 5, []],\
[x^4 - x^3 - 2*x^2 + 5*x - 4, -4103, 5, []],\
[x^4 + 5*x^2 - 3, -4107, 3, []],\
[x^4 - x^3 - 2*x - 2, -4108, 5, []],\
[x^4 - x^3 + x^2 - 4, -4152, 5, []],\
[x^4 + x^2 - 2*x - 2, -4192, 5, []],\
[x^4 - 2*x - 4, -4204, 5, []],\
[x^4 - 2*x^3 + x - 11, -4275, 3, []],\
[x^4 - x^3 + 2*x^2 - x - 2, -4287, 5, []],\
[x^4 - x^3 - 4*x^2 - x + 2, -4319, 5, []],\
[x^4 - 2*x^3 + 3*x^2 - 4, -4384, 5, []],\
[x^4 - x^2 - 11, -4400, 3, []],\
[x^4 - x^3 - 3*x^2 + 4*x + 1, -4423, 5, []],\
[x^4 - 2*x^3 - x^2 - 4*x + 3, -4432, 5, []],\
[x^4 - 2*x^3 + 2*x^2 - x - 11, -4475, 3, []],\
[x^4 - 2*x^2 - 3*x + 1, -4491, 5, []],\
[x^4 - x^3 - x^2 + x - 4, -4492, 5, []],\
[x^4 - 2*x^3 + x^2 - 3*x - 1, -4503, 5, []],\
[x^4 - 2*x^3 + x^2 - 6*x - 1, -4544, 3, []],\
[x^4 - x^3 - 5*x + 1, -4564, 5, []],\
[x^4 - x^3 + 2*x^2 - 3*x - 1, -4568, 5, []],\
[x^4 - 2*x^3 - 3*x + 1, -4595, 5, []],\
[x^4 - 2*x^2 - 2, -4608, 3, []],\
[x^4 + 2*x^2 - 2, -4608, 3, []],\
[x^4 - x^3 + x^2 - 4*x + 1, -4615, 5, []],\
[x^4 + x^2 - 6*x - 4, -4648, 5, []],\
[x^4 - x^3 - 3*x^2 + 5*x + 2, -4652, 5, []],\
[x^4 - x^3 + 2*x^2 - 5*x + 2, -4663, 5, []],\
[x^4 - 2*x^3 + 3*x^2 + x - 2, -4671, 5, []],\
[x^4 - 2*x^3 - 3*x - 1, -4675, 5, []],\
[x^4 - 3*x^2 - 3*x + 1, -4703, 5, []],\
[x^4 - 3*x^2 - 4*x + 2, -4744, 5, []],\
[x^4 - x^3 - 3*x^2 - x + 2, -4748, 5, []],\
[x^4 - 3*x^2 - 2*x + 3, -4752, 5, []],\
[x^4 - x^3 + 2*x^2 - 9*x - 9, -4775, 3, []],\
[x^4 - x^3 - 3*x^2 - 3*x + 2, -4780, 5, []],\
[x^4 - x^3 - 4*x^2 + 5*x + 3, -4799, 5, []],\
[x^4 - x^2 - 4*x - 2, -4832, 5, []],\
[x^4 - 4*x + 2, -4864, 5, []],\
[x^4 - x^3 - 2*x^2 - 4*x - 1, -4907, 5, []],\
[x^4 - x^2 - 4*x - 1, -4944, 5, []],\
[x^4 - x^3 - 2*x^2 - 7*x - 11, -4975, 3, []],\
[x^4 - x^3 - x^2 - 3*x + 1, -4979, 5, []],\
[x^4 - 2*x^3 - x^2 - x + 2, -4999, 5, []]]

@fork(timeout = max_waiting_time)
def find_abelianization(F,D,level):
    abtuple = quaternion_algebra_from_discriminant(F,D,[-1 for o in F.real_embeddings()]).invariants()
    G = ArithGroup(F,D,abtuple,level = level)
    ngens = len(G.abelianization().free_gens())
    return ngens


@parallel
def find_candidates(data,Nrange,max_P_norm,max_F_disc,max_waiting_time,outfile):
    from sarithgroup import ArithGroup
    try:
        page_path = ROOT + '/KleinianGroups-1.0/klngpspec'
    except NameError:
        ROOT = os.getcwd()
        page_path = ROOT + '/KleinianGroups-1.0/klngpspec'

    magma.attach_spec(page_path)

    sys.setrecursionlimit(10**6)
    from sage.misc.misc import alarm,cancel_alarm
    from sage.parallel.decorate import parallel
    x = QQ['x'].gen()
    fwrite('data = [\\',outfile)
    for N in Nrange:
        #print 'Field_disc = %s'%datum[1]
        print 'N = %s'%N
        for datum in data:
            if max_F_disc is not None and ZZ(datum[1]).abs() > max_F_disc:
                break
            pol = datum[0]
            F.<r> = NumberField(pol)
            if gcd(F.discriminant(),N) != 1:
                continue
            if len(F.narrow_class_group()) > 1:
                continue
            for a in F.elements_of_norm(N):
                print 'pol = %s'%pol
                facts = F.ideal(a).factor()
                nfactors = len(facts)
                for j,Pe in enumerate(facts):
                    P,e = Pe
                    if e > 1:
                        continue
                    if not ZZ(P.norm()).is_prime():
                        verbose('f > 1')
                        continue
                    if ZZ(P.norm()).abs() > max_P_norm:
                        verbose('large P')
                        continue
                    for v in enumerate_words([0,1],[0 for o in facts],nfactors):
                        if v[j] == 0:
                            continue
                        if any([v[k] == 1 and facts[k][1] > 1 for k in range(nfactors)]):
                            continue
                        D = F.ideal(1)
                        Np = F.ideal(1)
                        n_ramified_places = F.signature()[0]
                        for i in range(nfactors):
                            if i == j:
                                continue
                            if v[i] == 1:
                                assert facts[i][1] == 1
                                n_ramified_places +=1
                                D *= facts[i][0]
                            else:
                                Np *= facts[i][0]**facts[i][1]
                        if n_ramified_places % 2 != 0:
                            continue
                        NE = P * D * Np
                        assert NE == F.ideal(a)
                        try:
                            ngens = ZZ(find_abelianization(F,D,P*Np))
                            if ngens > 0:
                                print 'Found, p = %s, F = %s, length %s'%(P.norm(),F,ngens)
                                fwrite('[%s,%s,%s,%s,%s,%s],\\'%(F.defining_polynomial(),P.gens_reduced()[0],D.gens_reduced()[0],Np.gens_reduced()[0],P.norm(),(P*D*Np).norm()),outfile)

                        except TypeError:
                            print 'Skipping, Magma takes too long (p = %s, F = %s, NE = %s)'%(P.norm(),F,NE.norm())
                        except RuntimeError as e:
                            print 'Skipping, might be a bug (%s)'%e

    fwrite(']',outfile)

# find_candidates([[x^3-x^2+1,-23]],Nrange,max_P_norm,max_F_disc,max_waiting_time,outfile_base + "%s-%s.sage"%(0,0))

nfields = len(data)
nchunks = (QQ(nfields)/QQ(chunk_length)).ceil()
inp_vec = []
for tt in range(nchunks):
    i0 = tt * chunk_length
    i1 = min((tt+1) * chunk_length,nfields)
    inp_vec.append((data[i0:i1],Nrange,max_P_norm,max_F_disc,max_waiting_time,outfile_base + "%s-%s.sage"%(i0,i1)))
for inp,oup in find_candidates(inp_vec):
    print '...'

    
