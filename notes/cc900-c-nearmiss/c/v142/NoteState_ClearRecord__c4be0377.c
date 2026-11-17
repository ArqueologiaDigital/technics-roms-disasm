/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_3c.c (2026-11-16-58-sub-r3)
   sha256 c4be0377121c92aaf4310ff02e0d53aa962b80a276e1426001d4bcb998399cbf (name+funcs); compiled at -Xr */
extern unsigned char ram_4424e[][27];
void NoteState_ClearRecord(unsigned char i, unsigned char j)
{
    unsigned char *p;
    p = &ram_4424e[j][(int)i * 9];
    p[1] = 0;
    p[2] = 0;
    p[3] = 0;
    p[4] = 0;
    p[0] = 0;
    p[5] = 0;
    p[7] = 0;
}
