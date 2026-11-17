/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_m17b.c (2026-11-16-30-p6-r1)
   sha256 6a38718f6b18d9e47c48879c226f2366390c0d8c002d28c6f6cd3bce8510a3b2 (tar-sha256); compiled at -O3 -XS -Xr */
extern unsigned int ram_272cc, ram_272ce;
void FileIO_BuildRecordPath_Done(unsigned char a) { unsigned int m = 1; if (a < 10) { m <<= a; ram_272ce |= m; } }
