import subprocess
import sys
import time
import copy
import math
import numpy

BUILD_PATH = "../CDouble"
PATH_TO_TEST_IMAGES_FOLDER = "../data/"


def mean(data):
	return sum(data) / len(data)

def stdev(data):
	_data = copy.copy(data)
	_mean = mean(data)
	_data = [(x-_mean)**2 for x in _data]

	return math.sqrt(sum(_data) / len(_data))

def get_run_time(_string):
	_string = _string.split("\n")
	end = 0
	start = 0
	for i in _string:
		if i.startswith("  Comienzo"):
			i = i.split(': ')[1]
			start = int(i)
		if i.startswith("  Fin"):
			i = i.split(': ')[1]
			end = int(i)

	return (end-start)

def corrida(llamado_a_filtro, cant_corridas):
	tiempos_individuales = []

	for i in range(0, cant_corridas):
		p = subprocess.Popen(llamado_a_filtro, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
		out, err = p.communicate()
		tiempos_individuales.append(get_run_time(out))

	_mean =  numpy.mean(tiempos_individuales)
	_stdev = numpy.std(tiempos_individuales)

	tiempos_individuales_filtrados = []
	los_que_volaron = []
	for x in tiempos_individuales:
		if (_mean - 2 * _stdev) <= x or x <= (_mean + 2 * _stdev):
			tiempos_individuales_filtrados.append(x)

	#promedio_sin_outliers = mean(tiempos_individuales_filtrados)

	return tiempos_individuales_filtrados

def dispatch_corrida(filtro, implementacion, cant_corridas, image_path, extras, size):
	llamado_a_filtro = [BUILD_PATH, filtro, "-i", implementacion, image_path]

	if filtro == "cropflip":
		if len(extras) == 4:
			llamado_a_filtro = llamado_a_filtro + [extras[0], extras[1], extras[2], extras[3]]
		else:
			llamado_a_filtro = llamado_a_filtro + [str(size/2), str(size/2), str(0), str(0)]
	if filtro == "sepia":
		pass
	if filtro == "ldr":
		alpha = int(extras[0])
		llamado_a_filtro = llamado_a_filtro + (["--"] if alpha < 0 else []) + [str(alpha)]

	return corrida(llamado_a_filtro, cant_corridas)


sys.argv.pop(0)
filtro = sys.argv.pop(0)
implementacion = sys.argv.pop(0)
cant_corridas = int(sys.argv.pop(0))
extras = sys.argv


image_paths = []
sizes = []
for i in range(5, 11):
	val = str(2**i)
	image_paths.append(PATH_TO_TEST_IMAGES_FOLDER + 'lena.' + val + 'x' + val + '.bmp')
	sizes.append(val)
	val = str(2**i + 2**(i-1))
	image_paths.append(PATH_TO_TEST_IMAGES_FOLDER + 'lena.' + val + 'x' + val + '.bmp')
	sizes.append(val)

#print("Corriendo con tamanos : ")
run_times = []
run_stdev = []
for size, image_path in zip(sizes, image_paths):
	#print str(size) 
	times =  dispatch_corrida(filtro=filtro, 
							 implementacion=implementacion, 
							 cant_corridas=cant_corridas, 
							 image_path=image_path, 
							 extras=extras, 
							 size=int(size))
	run_times.append( numpy.mean(times) )
	run_stdev.append( numpy.std(times) )

for i in range(0,len(sizes)):
	print sizes[i] + ' ' + str(run_times[i]) + ' ' + str(run_stdev[i])

#print "Tamanos: " + str(sizes)
#print "Tiempos promedio : " + str(run_times)
#print "Desvio estandar : " + str(run_stdev)