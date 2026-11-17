/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_m17a.c (2026-11-16-30-p6-r1)
   sha256 4108bbf0bdcc17ce8617a11b94614744679f91da164a15ae5e06c1b358cbc962 (tar-sha256); compiled at -O3 -XS -Xr */
extern unsigned int ram_272cc, ram_272ce;
void FileIO_BuildRecordPath_Return(unsigned char a) { if (a < 10) ram_272ce &= ((unsigned int)1 << (unsigned int)a) ^ 0xffff; }
