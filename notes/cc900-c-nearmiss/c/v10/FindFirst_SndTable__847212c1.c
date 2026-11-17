/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_12m240b.c (2026-11-16-88-p6-r16)
   sha256 847212c1fddbd5608b779821d3ba9b6b940c9037ec3194cfc7430ee417f264aa (tar-sha256); compiled at -O3 -Xr */
extern unsigned int ram_2272c;
extern void FileIO_ReadAllDirEntries(void *h);
extern int FileIO_ReadNextDirEntry(void *h, void *name);
extern void FileIO_ValidateHandle(void *h);
void *FindFirst_SndTable(void *unused, void *name)
{
    void *h;
    void *r;
    ram_2272c = 0;
    h = &ram_2272c;
    FileIO_ReadAllDirEntries(h);
    if (FileIO_ReadNextDirEntry(h, name) != 0) {
        FileIO_ValidateHandle(h);
        r = (void *)0xffffffffUL;
    } else
        r = h;
    return r;
}
