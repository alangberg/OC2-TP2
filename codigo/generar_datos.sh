make clean 
make
	

    for (( i = 200; i < 209; i=i+4 )); do
     	echo "corriendo filtro para una matriz de $i x $i"
	  printf '%i   ' $(($i*$i)) >> LDRLENTO
	  ./build/tp2 sepia -i asm ./imagenes_exp/lena.${i}x${i}.bmp 100 -t 100 >>LDRLENTO
	 done