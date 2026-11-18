/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_I_5m268b.c (2026-11-18-33-p6-r37)
   sha256 cb01dd60a2c9143b10373cf45375274f7bad936205c057a7547a69e468bed153 (tar-sha256); compiled at -O3 -Xr */
struct ffblk { unsigned char b[6]; char name[260]; };
struct dirrec { unsigned char f0[14]; char name[68]; };
extern struct dirrec ram_25eb2[60];
extern struct dirrec FileIO_DirListEntryTemplate;
extern int ram_271ee;
extern int FILE_LIST_LAST;
extern long _findfirst(char *, struct ffblk *);
extern int _findnext(long, struct ffblk *);
extern void _findclose(long);
extern void FileIO_CopyString(char *, char *);
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
    if (n >= ram_271ee && n <= FILE_LIST_LAST)
        FileIO_CopyString(ram_25eb2[n - ram_271ee].name, name);
    n = 1;
    while (_findnext(h, &ff) == 0) {
        if (n >= ram_271ee && n <= FILE_LIST_LAST)
            FileIO_CopyString(ram_25eb2[n - ram_271ee].name, name);
        n++;
    }
    _findclose(h);
    return n;
}
