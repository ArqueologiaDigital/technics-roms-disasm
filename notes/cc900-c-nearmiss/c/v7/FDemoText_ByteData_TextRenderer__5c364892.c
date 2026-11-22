/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/fdemotext_routines_m265.c (2026-11-22-26-p6-r93)
   sha256 5c364892dc60cedb6f1350e443396c774f3b7069cf0e99259d42e796ec9b91c0 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned int __cdecl Strlen(char *);
extern char *__cdecl Malloc(unsigned int);
extern char *__cdecl Strcpy(char *, char *);
extern char *__cdecl Strncpy(char *, char *, unsigned int);
extern void __cdecl Free(void *);
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
