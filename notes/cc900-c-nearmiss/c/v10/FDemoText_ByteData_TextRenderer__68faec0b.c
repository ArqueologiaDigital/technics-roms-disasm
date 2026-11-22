/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_36r1m265a.c (2026-11-22-25-p6-r92)
   sha256 68faec0bf7dff88cc74a4a536400ccff52367fa1ee332d5781b756b30ced2170 (tar-sha256); compiled at -O3 -Xr */
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
    while (buf[n] != 0) {
        if (buf[n] == '=') {
            buf[n] = 0;
            Strcpy(name, buf);
            n++;
            if (buf[n] == '"') {
                n++;
                Strcpy(value, &buf[n]);
                value[Strlen(value) - 1] = 0;
            } else
                Strcpy(value, &buf[n]);
            break;
        }
        n++;
    }
    Free(buf);
}
