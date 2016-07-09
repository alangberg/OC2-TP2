import sys
import numpy as np
import math

sys.argv.pop(0)
file = sys.argv.pop(0)
cant_corridas = int(sys.argv.pop(0))
cant_pixeles = int(sys.argv.pop(0))

cant_pixeles *= cant_pixeles

arr = np.genfromtxt(file)

prom = 0
for row in arr:
	prom += row
	pass

prom = prom / cant_corridas

desvio = 0
for row in arr:
	desvio += (row - prom) ** 2
	pass

desvio /= (cant_corridas - 1)
desvio = math.sqrt(desvio)
print str(cant_pixeles) + " " + str(prom) + " " + str(desvio)