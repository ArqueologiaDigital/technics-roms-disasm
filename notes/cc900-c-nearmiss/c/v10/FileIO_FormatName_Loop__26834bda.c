/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_m17c.c (2026-11-16-30-p6-r1)
   sha256 26834bdafa64fa092691633e44bd4c9260e99cbee53eaf2178a64d3ca92b3811 (tar-sha256); compiled at -O3 -XS -Xr */
extern unsigned int ram_272cc, ram_272ce;
void FileIO_FormatName_Loop(unsigned char a) { unsigned int b = a; if (b < 10) ram_272cc |= (unsigned int)1 << b; }
