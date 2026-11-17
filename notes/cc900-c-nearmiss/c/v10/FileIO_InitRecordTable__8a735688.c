/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_1b.c (2026-11-16-30-p6-r1)
   sha256 8a7356886e18f7ab911e798723ccf50ecdd2436ab818c9ee86a2ecf0d3209eb9 (tar-sha256); compiled at -O3 -XS -Xr */
struct diskinfo { unsigned int w[38]; };
struct frec { unsigned int flags; unsigned int w[5]; };
struct dirent82 { unsigned char name; unsigned char rest[81]; };
extern struct diskinfo FileIO_DiskInfoInit, ram_25d6c;
extern struct frec FileIO_EmptyFileRecord, ram_25db8[];
extern struct dirent82 FileIO_DirListEntryTemplate, ram_25eb2[];
extern int ram_25ea8, ram_271ea, ram_271ec, ram_271ee, FILE_LIST_LAST, ram_272c8, ram_272ca;
void FileIO_InitRecordTable(void)
{
    struct frec *p, *e;
    struct dirent82 *q, *f;
    ram_25d6c = FileIO_DiskInfoInit;
    for (p = ram_25db8, e = p + 20; p < e; p++) *p = FileIO_EmptyFileRecord;
    for (q = ram_25eb2, f = q + 60; q < f; q++) *q = FileIO_DirListEntryTemplate;
    ram_25ea8 = 0;
    ram_271ea = 0;
    ram_271ec = 0;
    ram_271ee = 0;
    FILE_LIST_LAST = 0;
    ram_272c8 = 0;
    ram_272ca = 0;
}
