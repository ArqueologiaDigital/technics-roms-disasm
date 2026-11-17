/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/file_demo_proc.c (2026-11-16-55-p6-r10)
   sha256 7472fd7aac5942733077a1738f4bddd3fb3bf69803cd91dfb1af6a633889b28f (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
void Demo_ParseSlideHeader(unsigned char i)
{
    long v;
    if ((v = ((long *)0x9c4000)[i]) != 0) SLIDE_Parse_Header(v, (unsigned char *)0x69800);
}
