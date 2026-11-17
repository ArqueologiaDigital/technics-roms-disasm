/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/file_demo_proc_m266.c (2026-11-16-68-p6-r12)
   sha256 a2b7375184f6dfe24c5caf7137098511a5df716d30ac6f43c5d420d3e8fce430 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern void SLIDE_Parse_Header(long, unsigned char *);
void Demo_ParseSlideHeader(unsigned char i)
{
    long v;
    if ((v = ((long *)0x9c4000)[i]) != 0) SLIDE_Parse_Header(v, (unsigned char *)0x69800);
}
