/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_I_3m268b.c (2026-11-18-28-p6-r36)
   sha256 8d98181527624492ac0b21d0fbf0b520db085e7c0faeae3eddd2d9351f3464dc (tar-sha256); compiled at -O3 -Xr */
extern signed char ram_27412;
extern signed char ram_27414;
extern char ram_27312[];
extern int FileIO_Search_SkipEntry(char *, char *, int);
void FileIO_BuildFileIndex(char *s)
{
    int i;
    int j;
    char c;

    ram_27412 = 0;
    ram_27414 = 0;
    for (i = 0; i < 128; i++) {
        if (FileIO_Search_SkipEntry(&s[i], "***", 3) == 0)
            return;
        j = 0;
        goto test;
        do {
            ram_27312[ram_27412 * 32 + j] = c;
            if (FileIO_Search_SkipEntry(&s[i], "***", 3) == 0)
                break;
            j++;
            i++;
test:       ;
        } while ((c = s[i]) != ',' && c != 0 && j < 32);
        ram_27312[ram_27412 * 32 + j] = 0;
        ram_27412++;
    }
}
