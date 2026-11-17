/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_2c.c (2026-11-16-47-sub-r2)
   sha256 675d49d3eeeea79e327148ffdc5c5179606a08452f10204af09a37e964ae4c72 (name+funcs); compiled at -Xr */
extern unsigned char ram_4424e[][27];
void NoteState_ClearRecord(unsigned char i, unsigned char j)
{
    unsigned char *p;
    p = &ram_4424e[j][i * 9];
    p[1] = 0;
    p[2] = 0;
    p[3] = 0;
    p[4] = 0;
    p[0] = 0;
    p[5] = 0;
    p[7] = 0;
}
