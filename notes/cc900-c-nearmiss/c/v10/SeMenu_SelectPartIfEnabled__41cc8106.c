/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_17m129b.c (2026-11-16-107-p6-r21)
   sha256 41cc8106ac2042a106a57c77c689c80099e3c1a76c55fe5a5fca2be6397f0f3d (tar-sha256); compiled at -O3 -Xr */
extern void SeMenu_ValidatePartNumber(unsigned char *part);
extern int SeMenu_IsPartEnabled(unsigned char a);
extern void SeMenu_SetCurrentPart(unsigned char part);
unsigned char SeMenu_SelectPartIfEnabled(unsigned char p)
{
    unsigned char cur;
    unsigned char r;
    SeMenu_ValidatePartNumber(&cur);
    if (cur != p && SeMenu_IsPartEnabled(p) != 0) {
        SeMenu_SetCurrentPart(p);
        r = 1;
    } else
        r = 0;
    return r;
}
