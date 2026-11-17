/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_5b.c (2026-11-16-40-p6-r8)
   sha256 0925ac3d7624e564a79643524eac0977811cc2828328dc740296e5ffc2f35240 (tar-sha256); compiled at -Xr */
extern void SLIDE_Parse_Header(long, unsigned char *);
void Demo_ParseSlideHeader(unsigned char i)
{
    long v;
    if ((v = ((long *)0x9c4000)[i]) != 0) SLIDE_Parse_Header(v, (unsigned char *)0x69800);
}
