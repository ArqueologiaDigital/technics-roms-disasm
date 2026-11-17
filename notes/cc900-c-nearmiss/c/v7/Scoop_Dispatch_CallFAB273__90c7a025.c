/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/scoop_display_xr.c (2026-11-16-55-p6-r10)
   sha256 90c7a025cd4ac8377bfe8488998b0d69ccd735c31844298afb0eca5cd9ca9440 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
struct rect { int x0; int y0; int x1; int y1; };
struct dsrc { unsigned char pad[2]; int a2; int a4; int a6; int a8; };
void Scoop_Dispatch_CallFAB273(struct dsrc *s)
{
    struct rect r;
    r.x0 = s->a2;
    r.y0 = s->a4;
    r.x1 = s->a6;
    r.y1 = s->a8;
    DrawBox(&r, 0xf5);
}
