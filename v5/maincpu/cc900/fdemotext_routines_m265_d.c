/* Functions of demo/fdemotext_routines.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern unsigned int __cdecl Strlen(char *);
extern char *__cdecl Malloc(unsigned int);
extern char *__cdecl Strcpy(char *, char *);
extern char *__cdecl Strncpy(char *, char *, unsigned int);
extern void __cdecl Free(void *);
extern void FDemoText_ByteData_TextRenderer(int, char **, char *, char *);
extern void FDemoText_ByteData_TextRenderer(register int n, char **tbl, char *name, char *value);

void FDemoText_ByteData_TextRenderer(register int n, char **tbl, char *name, char *value)
{
    char *buf;

    buf = Malloc(Strlen(tbl[n]) + 1);
    Strcpy(buf, tbl[n]);
    n = 0;
    Strncpy(name, buf, 64);
    name[64] = 0;
    *value = 0;
    if (*buf != 0) {
        do {
            if (buf[n] == '=') {
                buf[n] = 0;
                Strcpy(name, buf);
                n++;
                switch (buf[n]) {
                case '"':
                    n++;
                    Strcpy(value, &buf[n]);
                    value[Strlen(value) - 1] = 0;
                    break;
                default:
                    Strcpy(value, &buf[n]);
                    break;
                }
                break;
            }
            n++;
        } while (buf[n] != 0);
    }
    Free(buf);
}
