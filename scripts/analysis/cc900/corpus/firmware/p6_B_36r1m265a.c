/* Probe round 36r1, helper B, form a: demo/fdemotext_routines.s (module 265), the xr_screen.py shape.
   FDemoText_ByteData_TextRenderer(n, tbl, name, value): copy tbl[n] into a fresh heap buffer, copy its first 64
   characters into name (terminated at 64) and empty value; then scan the buffer for '=': the part before it is
   the name, the part after it the value (a leading '"' is skipped and the last character, the closing quote,
   dropped).  The buffer is freed.  The parameter n is a `register` int (IZ, the one pushed register) and is
   reused as the scan index; the buffer pointer and the two register-passed pointer parameters stay on the frame
   (buffer at +2, name at +6, tbl at +10 after the push).  The second compare loads the byte into A: here an `if`
   (form b: a switch). */

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
