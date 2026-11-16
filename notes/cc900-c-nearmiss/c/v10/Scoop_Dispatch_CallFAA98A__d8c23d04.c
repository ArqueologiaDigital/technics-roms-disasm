/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_6b.c (2026-11-16-45-p6-r9)
   sha256 d8c23d04522aec171aa28df55c10e94ff12aceb37e57c0c9258fc07955f44d2f (tar-sha256); compiled at -Xr */
struct pt { int x; int y; };
struct dsrc { unsigned char pad[2]; int a2; int a4; int a6; int a8; };
extern void DrawLine(struct pt *, struct pt *, int);
void Scoop_Dispatch_CallFAA98A(struct dsrc *s)
{
    struct pt a, b;
    a.x = s->a2;
    a.y = s->a4;
    b.x = s->a6;
    b.y = s->a8;
    DrawLine(&a, &b, 0xff);
}
