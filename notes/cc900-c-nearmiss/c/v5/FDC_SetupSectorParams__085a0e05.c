/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/system_handlers_m5.c (2026-11-16-68-p6-r12)
   sha256 085a0e05eabb47549084b1b16929336fe46ee96956e247d45dbd3c4f70d0ba7a (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
struct fdcp { unsigned int w0; unsigned int head; unsigned int side; unsigned int cyl; unsigned int sec; unsigned int n; long p; };
extern struct fdcp __near ram_62e;
extern unsigned long Math_DivideU32(unsigned long, unsigned long);
extern unsigned long Math_RemainderU32(unsigned long, unsigned long);
void FDC_SetupSectorParams(unsigned long lba, unsigned int n, long p)
{
    struct fdcp *f;
    unsigned int *sp;
    unsigned int t;
    t = Math_DivideU32(lba, 18);
    f = &ram_62e;
    f->head = 0;
    f->cyl = t >> 1;
    f->side = t & 1;
    sp = &f->sec;
    *sp = Math_RemainderU32(lba, 18) + 1;
    f->n = n;
    f->p = p;
}
