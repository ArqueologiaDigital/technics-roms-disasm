/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_2a.c (2026-11-16-47-sub-r2)
   sha256 53d7a593968fb87f84af530bceae3e1c306174f47db7d2c6980e60b72454f307 (name+funcs); compiled at -Xr */
unsigned char ExtVoice_Fold_SlotNumber(unsigned char a, unsigned char g)
{
    unsigned char r;
    switch (g & 3) {
    case 0:
    case 1: r = a & 0x3f; break;
    case 2: r = a - 0x40; r &= 0x7f; break;
    case 3: r = a; r &= 0x7f; break;
    }
    return r;
}
