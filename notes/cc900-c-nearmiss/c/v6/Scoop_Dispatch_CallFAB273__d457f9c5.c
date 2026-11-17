/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/scoop_display_m0_xr.c (2026-11-16-68-p6-r12)
   sha256 d457f9c548ae984af37ce61bc75e7eecb360fd5b532fb0f3207b1e7583ea2fe4 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
struct rect { int x0; int y0; int x1; int y1; };
struct dsrc { unsigned char pad[2]; int a2; int a4; int a6; int a8; };
extern void DrawBox(struct rect *, int);
void Scoop_Dispatch_CallFAB273(struct dsrc *s)
{
    struct rect r;
    r.x0 = s->a2;
    r.y0 = s->a4;
    r.x1 = s->a6;
    r.y1 = s->a8;
    DrawBox(&r, 0xf5);
}
