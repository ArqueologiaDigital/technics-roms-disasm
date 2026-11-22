/* Probe round 36r1, helper B, form b: demo/fdemotext_routines.s (module 265), the xr_screen.py shape.
   FDemoText_ByteData_TextRenderer: form a's function (see there) with the scan written as a guarded do-while
   (the ROM tests *buf once, then buf[n] at the bottom) and the quote test as a one-case switch (the ROM loads
   that byte into A before the compare, unlike the '=' compare on memory). */

extern unsigned int __cdecl Strlen(char *);
extern char *__cdecl Malloc(unsigned int);
extern char *__cdecl Strcpy(char *, char *);
extern char *__cdecl Strncpy(char *, char *, unsigned int);
extern void __cdecl Free(void *);
extern void FDemoText_ByteData_TextRenderer(int, char **, char *, char *);

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
