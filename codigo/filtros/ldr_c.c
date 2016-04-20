
#include "../tp2.h"

#define MIN(x,y) ( x < y ? x : y )
#define MAX(x,y) ( x > y ? x : y )

#define P 2


void ldr_c    (
    unsigned char *src,
    unsigned char *dst,
    int cols,
    int filas,
    int src_row_size,
    int dst_row_size,
    int alpha)
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
    }
    int max  = 5*5*255*3*255;
    for (int i = 2; i < filas-2; i++){
        for (int j = 2; j < cols-2; j++){
            
            float sumaRGB = 0;
            for(int k = 0; k < 5 ; k++){
                for(int l = 0; l < 5; l++){
                    int fila = i-2+k;
                    int col = (j-2+l)*4;
                   sumaRGB += src_matrix[fila][col+0] + src_matrix[fila][col+1] + src_matrix[fila][col+2];
                 }
            }

            if (i == 2 && j == 2) printf("%f\n", sumaRGB);
            


            float ldrB = src_matrix[i][j*4 + 0] + alpha * sumaRGB * src_matrix[i][j*4 + 0] / max;
            float ldrG = src_matrix[i][j*4 + 1] + alpha * sumaRGB * src_matrix[i][j*4 + 1] / max;
            float ldrR = src_matrix[i][j*4 + 2] + alpha * sumaRGB * src_matrix[i][j*4 + 2] / max;

            dst_matrix[i][j*4 + 0] = (unsigned char) MIN(MAX(ldrB , 0) , 255);
            dst_matrix[i][j*4 + 1] = (unsigned char) MIN(MAX(ldrG , 0) , 255);
            dst_matrix[i][j*4 + 2] = (unsigned char) MIN(MAX(ldrR , 0) , 255);
        }
    }
}



/*


8450.000000


PIXELES = 2279


*/





