/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_7a.c (2026-11-16-79-sub-r7)
   sha256 f70607b5111b1b73ae470351c728e34d55ce40ce7a9d878e58e34960dca5e443 (name+funcs); compiled at -Xr */
extern unsigned char ram_41368[];
void Voice_UpdateFlagsFromSlot(int part);
void Voice_Selector_ComputeMixWeights(int part);
void Voice_Artic_SetWord2Word1_Nibble0(unsigned char part, unsigned char b)
{
    unsigned char *q;
    q = &ram_41368[(int)part * 287];
    q += 258;
    (*(unsigned int *)((q) + (4))) &= 0xfff0;
    (*(unsigned int *)((q) + (4))) |= b & 0xf;
    (*(unsigned int *)((q) + (2))) &= 0xfff0;
    b >>= 4;
    (*(unsigned int *)((q) + (2))) |= b;
    Voice_UpdateFlagsFromSlot(part);
    Voice_Selector_ComputeMixWeights(part);
}
