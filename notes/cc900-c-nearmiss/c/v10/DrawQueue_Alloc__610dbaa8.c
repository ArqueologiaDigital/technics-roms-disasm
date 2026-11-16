/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_7b.c (2026-11-16-45-p6-r9)
   sha256 610dbaa80fee86b3fc7b51cb71c48d05736a0a61496faada5af95b573292fca3 (tar-sha256); compiled at -O3 -Xr */
extern unsigned char DRAW_QUEUE[];
extern unsigned char *DRAW_QUEUE_WRITE_PTR;
extern void Kernel_SemaWait(int);
extern void Kernel_SemaSignal(int);
unsigned char *DrawQueue_Alloc(unsigned int n)
{
    unsigned char *p;
    Kernel_SemaWait(4);
    if ((long)(DRAW_QUEUE_WRITE_PTR - DRAW_QUEUE) + n < 0x2000L) {
        p = DRAW_QUEUE_WRITE_PTR;
        DRAW_QUEUE_WRITE_PTR = p + n;
    } else {
        p = DRAW_QUEUE;
        DRAW_QUEUE_WRITE_PTR = DRAW_QUEUE + n;
    }
    Kernel_SemaSignal(4);
    return p;
}
