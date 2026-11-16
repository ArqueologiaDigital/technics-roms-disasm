/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_12m240a.c (2026-11-16-88-p6-r16)
   sha256 e440988d6beee5fe62c3f16049cc347170578740bc54dc2eaa08b639039abe44 (tar-sha256); compiled at -O3 -Xr */
extern unsigned int ram_2272c;
extern void FileIO_ReadAllDirEntries(void *h);
extern int FileIO_ReadNextDirEntry(void *h, void *name);
extern void FileIO_ValidateHandle(void *h);
void *FindFirst_SndTable(void *unused, void *name)
{
    void *h;
    ram_2272c = 0;
    h = &ram_2272c;
    FileIO_ReadAllDirEntries(h);
    if (FileIO_ReadNextDirEntry(h, name) == 0)
        return h;
    FileIO_ValidateHandle(h);
    return (void *)0xffffffffUL;
}
