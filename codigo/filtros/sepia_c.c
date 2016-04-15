
#include "../tp2.h"


void sepia_c    (
    unsigned char *src,
    unsigned char *dst,
    int cols,
    int filas,
    int src_row_size,
    int dst_row_size)
{
    unsigned char (*src_matrix)[src_row_size] = (unsigned char (*)[src_row_size]) src;
    unsigned char (*dst_matrix)[dst_row_size] = (unsigned char (*)[dst_row_size]) dst;

    for (int i = 0; i < filas; i++)
    {
        for (int j = 0; j < cols; j++)
        {
            bgra_t *p_d = (bgra_t*) &dst_matrix[i][j * 4];
            bgra_t *p_s = (bgra_t*) &src_matrix[i][j * 4];
            *p_d = *p_s;
        }
    }	//COMPLETAR
    for (int k = 0; k < filas; k++){
        for (int n = 0; n < cols; n++){
            unsigned char suma = 0;
            suma += dst_matrix[k][n*4+0];
            suma += dst_matrix[k][n*4+1];
            suma += dst_matrix[k][n*4+2];
            dst_matrix[k][n*4+0] = suma*0.5;
            dst_matrix[k][n*4+1] = suma*0.3;
            dst_matrix[k][n*4+2] = suma*0.2;
        }
    }
}



