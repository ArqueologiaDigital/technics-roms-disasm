/* cc900-module: FileIO_ReadNextDirEntry FileIO_ValidateHandle */
/* Phase 6, lane_p6 helper A, round 12, form b: module 240 of modules_v10.tsv (sequencer/smf_event_processor.s),
   FindFirst_SndTable (a result variable and one return). */
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
