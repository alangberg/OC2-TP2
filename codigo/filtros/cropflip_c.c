
#include "../tp2.h"

void copiarPixeles(bgra_t* p_s, bgra_t* p_d) {
	p_d->b = p_s->b;
	p_d->g = p_s->g;
	p_d->r = p_s->r;
	p_d->a = p_s->a;
}

void cropflip_c    (
	unsigned char *src,
	unsigned char *dst,
	int cols,
	int filas,
	int src_row_size,
	int dst_row_size,
	int tamx,
	int tamy,
	int offsetx,
	int offsety)
{
	unsigned char (*src_matrix)[src_row_size] = (unsigned char (*)[src_row_size]) src;
	unsigned char (*dst_matrix)[dst_row_size] = (unsigned char (*)[dst_row_size]) dst;

	for (int i = 0; i < tamy; i++) {
		for (int j = 0; j < tamx; j++) {
			bgra_t* p_d1 = (bgra_t*) &dst_matrix[i][j * 4];
			bgra_t* p_d2 = (bgra_t*) &dst_matrix[tamy - i - 1][j * 4];

            bgra_t* p_s1 = (bgra_t*) &src_matrix[i + offsety][(j + offsetx) * 4];
			bgra_t* p_s2 = (bgra_t*) &src_matrix[(tamy + offsety) - 1 - i][(j + offsetx) * 4];

			copiarPixeles(p_s2, p_d1);
			copiarPixeles(p_s1, p_d2);
		}
	}
}