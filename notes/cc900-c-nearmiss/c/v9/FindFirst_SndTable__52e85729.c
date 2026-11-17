/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/smf_event_processor_m240_xr.c (2026-11-16-92-p6-r18)
   sha256 52e8572951ac34c02be964d0a88a65fa15f1b0701ab8f4fff3abc657bd70e6aa (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -Xr */
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
