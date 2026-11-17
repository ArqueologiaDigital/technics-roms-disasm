/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/file_demo_proc.c (2026-11-16-55-p6-r10)
   sha256 7472fd7aac5942733077a1738f4bddd3fb3bf69803cd91dfb1af6a633889b28f (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
int FileIO_ReadHeaderAtF(void)
{
    int ok = 1;
    int c;
    FileIO_SeekAndReadBlock(15, 0);
    c = FileIO_ReadByte();
    if (c < 0 || (unsigned char)c != 8) ok = 0;
    FileIO_SeekRead_ExtReturn();
    return ok;
}
