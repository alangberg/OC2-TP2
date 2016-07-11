make clean 
make

	rm CROPFLIP_C_O3
    for (( i = 512; i < 2049; i += 256 )); do
      echo "corriendo filtro para una matriz de $i x $i"
	  rm ./CROPFLIP_C_O3.${i}x${i}
	  # printf '%i   ' $(($i*$i)) >> SEPIA_C
	  #  ./build/tp2 sepia -i asm ./imagenes_exp/lena.${i}x${i}.bmp -t 100 >>SEPIA_C

	  # printf '%i %i %i %i \n' $(($i/2)) $(($i/2)) $(($i/4)) $(($i/4))

	  ./build/tp2 cropflip -i c ./imagenes_exp/lena.${i}x${i}.bmp -t 1000 $(($i/2)) $(($i/2)) $(($i/4)) $(($i/4)) >> CROPFLIP_C_O3.${i}x${i}

	  python error.py CROPFLIP_C_O3.${i}x${i} 1000 $i >> CROPFLIP_C_O3

	  rm ./lena.${i}x${i}.bmp.cropflip.C.bmp
	  rm ./CROPFLIP_C_O3.${i}x${i}

	  # printf '%i   ' $(($i*$i)) >> SEPIA_C_O3
	  # ./build/tp2 sepia -i c ./imagenes_exp/lena.${i}x${i}.bmp -t 100 >>SEPIA_C_O3	  

done