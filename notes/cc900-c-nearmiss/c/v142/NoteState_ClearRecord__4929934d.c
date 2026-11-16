/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_2b.c (2026-11-16-47-sub-r2)
   sha256 4929934d1be3b922f61146a30935689ade1baf0354878540871355a4884bb871 (name+funcs); compiled at -Xr */
extern unsigned char ram_4424e[][27];
void NoteState_ClearRecord(unsigned char i, unsigned char j)
{
    unsigned char *p;
    p = ram_4424e[j] + i * 9;
    p[1] = 0;
    p[2] = 0;
    p[3] = 0;
    p[4] = 0;
    p[0] = 0;
    p[5] = 0;
    p[7] = 0;
}
