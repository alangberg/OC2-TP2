#!/usr/bin/env python

from libtest import *
import subprocess
import sys

# Este script crea las multiples imagenes de prueba a partir de unas
# pocas imagenes base.

IMAGENES=["lena.bmp"]

assure_dirs()

sizes = []
for i in range(5, 11):
	val = str(2**i)
	sizes.append(val + 'x' + val)
	val = str(2**i + 2**(i-1))
	sizes.append(val + 'x' + val)

for filename in IMAGENES:
	print(filename)

	# sizes = [sizes[10]]
	for size in sizes:
		sys.stdout.write("  " + size)
		name = filename.split('.')
		file_in  = DATADIR + "/" + filename
		file_out = "./" + name[0] + "." + size + "." + name[1]
		resize = "convert -resize " + size + "! " + file_in + " " + file_out
		subprocess.call(resize, shell=True)

print("")
