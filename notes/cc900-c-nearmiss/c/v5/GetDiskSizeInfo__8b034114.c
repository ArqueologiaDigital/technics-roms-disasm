/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/file_demo_proc_m268.c (2026-11-16-92-p6-r18)
   sha256 8b034114cb45a5a4796319c6f4a6578534c52e0af3faf3c92ded7426f45b9b2a (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
extern unsigned char ram_25db6;
extern unsigned char FileIO_DiskInfoInit_MediaType;
extern unsigned char GetMediaType(void);
unsigned char GetDiskSizeInfo(void)
{
    if (FileIO_DiskInfoInit_MediaType == ram_25db6) ram_25db6 = GetMediaType();
    return ram_25db6;
}
