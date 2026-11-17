/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_m9c.c (2026-11-16-23-p6-m9c)
   sha256 15b8ac491fb89a1b217c4daa40f4ae850c4779a3946e4cc55d2f0513de61d79e (name+funcs); compiled at (no flags) */
extern unsigned int ram_272cc, ram_272ce;
void FileIO_BuildRecordPath_Done(unsigned char a) { if (a < 10) ram_272ce |= 1U << a; }
