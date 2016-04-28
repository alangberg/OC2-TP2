make clean 
make
	

    for (( i = 512; i < 2049; i += 256 )); do
     	echo "corriendo filtro para una matriz de $i x $i"
	  printf '%i   ' $(($i*$i)) >> SEPIA_ASM
	  ./build/tp2 sepia -i asm ./imagenes_exp/lena.${i}x${i}.bmp -t 100 >>SEPIA_ASM
	  printf '%i   ' $(($i*$i)) >> SEPIA_C
	  ./build/tp2 sepia -i c ./imagenes_exp/lena.${i}x${i}.bmp -t 100 >>SEPIA_C	  
	 done