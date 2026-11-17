/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_m18b.c (2026-11-16-32-p6-m18-olevels)
   sha256 eb303ec5127e47666ab97d35e68f8abeabe607c7fcd3d14f128c71c8edc90edb (tar-sha256); compiled at -O3 -XS -Xr */
extern unsigned int ram_272cc, ram_272ce;
void FileIO_FormatName_Copy(unsigned char a) { if (a < 10) { unsigned int m = 1; m <<= a; ram_272cc &= ~m; } }
