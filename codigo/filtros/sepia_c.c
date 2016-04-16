#include "../tp2.h"

float min(float a, float b) {
    if (a < b) return a;
    else return b;
}

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

    for (int i = 0; i < filas; i++){
        for (int j = 0; j < cols; j++){
            float suma = src_matrix[i][j*4+0] + src_matrix[i][j*4+1] + src_matrix[i][j*4+2];
            
            dst_matrix[i][j*4+2] = (unsigned char) min(255.0f, suma * 0.5f);
            dst_matrix[i][j*4+1] = (unsigned char) min(255.0f, suma * 0.3f);
            dst_matrix[i][j*4+0] = (unsigned char) min(255.0f, suma * 0.2f);
        }
    }
}


