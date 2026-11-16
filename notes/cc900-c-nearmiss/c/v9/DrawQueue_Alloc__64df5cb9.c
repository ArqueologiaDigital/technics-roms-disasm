/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/ui_widget_defs_m273.c (2026-11-16-68-p6-r12)
   sha256 64df5cb9a289be32e163c37caa5768e0fbc9ed75408d02153f61b77bf4f175c2 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char DRAW_QUEUE[];
extern unsigned char *DRAW_QUEUE_WRITE_PTR;
extern void Kernel_SemaWait(int);
extern void Kernel_SemaSignal(int);
unsigned char *DrawQueue_Alloc(unsigned int n)
{
    unsigned char *p;
    Kernel_SemaWait(4);
    if (DRAW_QUEUE_WRITE_PTR - DRAW_QUEUE + (long)n < 0x2000) {
        p = DRAW_QUEUE_WRITE_PTR;
        DRAW_QUEUE_WRITE_PTR += n;
    } else {
        p = DRAW_QUEUE;
        DRAW_QUEUE_WRITE_PTR = DRAW_QUEUE + n;
    }
    Kernel_SemaSignal(4);
    return p;
}
