/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_14m129b.c (2026-11-16-100-p6-r19)
   sha256 0a758bc52ebe3ab0507a93d6632a2813c8b65e775a413f6cfc4a2c01fd775d79 (tar-sha256); compiled at -O3 -XS -Xr */
extern void SeMenu_ValidatePartNumber(unsigned char *part);
void SeMenu_InitObjEntry(unsigned char *e)
{
    unsigned char p;
    SeMenu_ValidatePartNumber(&p);
    *e = p;
    *e <<= 4;
    ++*e;
}
