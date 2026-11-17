/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/semenu_routines_m129.c (2026-11-16-111-p6-r22-staged)
   sha256 e8e54ecf7f562beef010be3aa4cf15cfc9811abb7ea644b41fbd0a9d48c045ad (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern void SeMenu_ValidatePartNumber(unsigned char *part);
void SeMenu_InitObjEntry(unsigned char *e)
{
    unsigned char p;
    SeMenu_ValidatePartNumber(&p);
    *e = p;
    *e <<= 4;
    ++*e;
}
