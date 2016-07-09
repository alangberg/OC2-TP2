make clean 
make

	rm LDR_C
    for (( i = 512; i < 2049; i += 256 )); do
      echo "corriendo filtro para una matriz de $i x $i"
	  rm ./LDR_C.${i}x${i}
	  # printf '%i   ' $(($i*$i)) >> LDR_C
	  #  ./build/tp2 sepia -i asm ./imagenes_exp/lena.${i}x${i}.bmp -t 100 >>LDR_C

	  # printf '%i %i %i %i \n' $(($i/2)) $(($i/2)) $(($i/4)) $(($i/4))

	  ./build/tp2 ldr -i c ./imagenes_exp/lena.${i}x${i}.bmp -t 1000 255 >> LDR_C.${i}x${i}
	  python error.py LDR_C.${i}x${i} 1000 $i >> LDR_C

	  rm ./lena.${i}x${i}.bmp.ldr.C.bmp
	  rm ./LDR_C.${i}x${i}

	  # printf '%i   ' $(($i*$i)) >> LDR_C_O3
	  # ./build/tp2 sepia -i c ./imagenes_exp/lena.${i}x${i}.bmp -t 100 >>LDR_C_O3	  

done