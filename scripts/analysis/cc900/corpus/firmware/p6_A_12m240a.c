/* cc900-module: FileIO_ReadNextDirEntry FileIO_ValidateHandle */
/* Phase 6, lane_p6 helper A, round 12, form a: module 240 of modules_v10.tsv (sequencer/smf_event_processor.s),
   FindFirst_SndTable: opens the directory handle at 0x2272c and returns it, or 0xffffffff when no entry matches.
   The first argument is not used. */
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
