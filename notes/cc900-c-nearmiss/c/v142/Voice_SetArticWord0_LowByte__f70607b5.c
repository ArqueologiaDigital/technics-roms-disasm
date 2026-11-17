/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_7a.c (2026-11-16-79-sub-r7)
   sha256 f70607b5111b1b73ae470351c728e34d55ce40ce7a9d878e58e34960dca5e443 (name+funcs); compiled at -Xr */
extern unsigned char ram_41368[];
void Voice_UpdateFlagsFromSlot(int part);
void Voice_Selector_ComputeMixWeights(int part);
void Voice_SetArticWord0_LowByte(unsigned char part, unsigned char b)
{
    unsigned char *q;
    q = &ram_41368[(int)part * 287];
    q += 258;
    (*(unsigned int *)((q) + (0))) &= 0xff00;
    (*(unsigned int *)((q) + (0))) |= b;
    Voice_UpdateFlagsFromSlot(part);
    Voice_Selector_ComputeMixWeights(part);
}
