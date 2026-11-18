/* Phase 6, lane_p6 helper I, round 5, module 268 (demo/file_demo_proc.s, -O3 -Xr), form a.  New.
   Two twins that fill a file-list page from a directory search (_findfirst / _findnext / _findclose):
   - BuildPageRecords(): resets the 60 82-byte entries at 0x25eb2 from FileIO_DirListEntryTemplate (82 bytes:
     the 14-byte template and the 68 zero bytes after it, an ldirw struct copy), then copies the name of every
     match of "*" whose index lies in [ram_271ee, FILE_LIST_LAST] into entry index - ram_271ee (+14);
   - FileIO_ScanDirEntries(): the same for "*.BMP" into the 10 14-byte entries at 0x2723c (+0), from
     FileIO_ScanDir_EmptyNameSlot.
   Both return the number of matches.  Read from the hand assembly: the handle (+2), the name pointer (+6) and the
   find block (+10, 266 bytes, the name at +6) in the frame, the count in IZ; the entry address as
   base-of-the-name-field + (long)(index * size) (muls, exts, add); the first match's test uses the constant index
   0 (folded: neg); the _findnext loop test copied to the entry (-O3).  The literals are cc900-data 1.
   Form b: the first match's test written with the count (n, still 0) like the loop's. */
/* cc900-module: FileIO_CopyString */
/* cc900-data: BuildPageRecords 1 = BuildRecords_CopyLoop_Str_Star */
/* cc900-data: FileIO_ScanDirEntries 1 = ScanDir_CopyEntryLoop_Str_BMP */

struct ffblk { unsigned char b[6]; char name[260]; };
struct dirrec { unsigned char f0[14]; char name[68]; };
struct bmprec { char name[14]; };

extern struct dirrec ram_25eb2[60];
extern struct dirrec FileIO_DirListEntryTemplate;
extern struct bmprec ram_2723c[10];
extern struct bmprec FileIO_ScanDir_EmptyNameSlot;
extern int ram_271ee;
extern int FILE_LIST_LAST;
extern long _findfirst(char *, struct ffblk *);
extern int _findnext(long, struct ffblk *);
extern void _findclose(long);
extern void FileIO_CopyString(char *, char *);
extern int BuildPageRecords(void);
extern int FileIO_ScanDirEntries(void);

int BuildPageRecords(void)
{
    long h;
    char *name;
    struct ffblk ff;
    struct dirrec *p;
    int n;

    for (p = ram_25eb2; p < ram_25eb2 + 60; p++)
        *p = FileIO_DirListEntryTemplate;
    n = 0;
    h = _findfirst("*", &ff);
    if (h < 0)
        return n;
    name = ff.name;
    if (ram_271ee <= 0 && FILE_LIST_LAST >= 0)
        FileIO_CopyString(ram_25eb2[-ram_271ee].name, name);
    n = 1;
    while (_findnext(h, &ff) == 0) {
        if (n >= ram_271ee && n <= FILE_LIST_LAST)
            FileIO_CopyString(ram_25eb2[n - ram_271ee].name, name);
        n++;
    }
    _findclose(h);
    return n;
}

int FileIO_ScanDirEntries(void)
{
    long h;
    char *name;
    struct ffblk ff;
    struct bmprec *p;
    int n;

    for (p = ram_2723c; p < ram_2723c + 10; p++)
        *p = FileIO_ScanDir_EmptyNameSlot;
    n = 0;
    h = _findfirst("*.BMP", &ff);
    if (h < 0)
        return n;
    name = ff.name;
    if (ram_271ee <= 0 && FILE_LIST_LAST >= 0)
        FileIO_CopyString(ram_2723c[-ram_271ee].name, name);
    n = 1;
    while (_findnext(h, &ff) == 0) {
        if (n >= ram_271ee && n <= FILE_LIST_LAST)
            FileIO_CopyString(ram_2723c[n - ram_271ee].name, name);
        n++;
    }
    _findclose(h);
    return n;
}
