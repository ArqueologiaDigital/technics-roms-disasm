/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_m18a.c (2026-11-16-32-p6-m18-olevels)
   sha256 d0971740f6ffeb0fadb913c68cfc98a693a67627ba14ef36929c7a9a1fe37822 (tar-sha256); compiled at -O3 -XS -Xr */
extern unsigned int ram_272cc, ram_272ce;
void FileIO_FormatName_Copy(unsigned char a) { if (a < 10) ram_272cc &= ~((unsigned int)1 << a); }
