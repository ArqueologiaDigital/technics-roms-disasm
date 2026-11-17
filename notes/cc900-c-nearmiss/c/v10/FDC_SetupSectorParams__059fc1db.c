/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_8a.c (2026-11-16-53-p6-r11)
   sha256 059fc1dbc74e38faafb386fe8d5405b2a2d3d26241e37ac23ba5310d1dcc5b81 (tar-sha256); compiled at -Xr */
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
