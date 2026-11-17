/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/file_demo_proc.c (2026-11-16-45-p6-r9)
   sha256 85726bbc6b8710e4c2174cf99a3fe9c343a73ab032e9d1fd0520a3263df9591b (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
void Demo_ParseSlideHeader(unsigned char i)
{
    long v;
    if ((v = ((long *)0x9c4000)[i]) != 0) SLIDE_Parse_Header(v, (unsigned char *)0x69800);
}
