/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/file_demo_proc.c (2026-11-16-40-p6-r8)
   sha256 f4ed9da277e24e64306884a95600b23c803b7dfd373294d8db253a401358a39c (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
struct frec { unsigned int w[6]; };
extern unsigned int ram_25db8[];
unsigned int FileIO_GetRecordFlags(unsigned int i)
{
    if (i >= 20) return 0;
    return ((struct frec *)ram_25db8)[i].w[0];
}
