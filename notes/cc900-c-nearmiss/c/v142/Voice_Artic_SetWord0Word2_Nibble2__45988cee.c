/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_8a.c (2026-11-16-82-sub-r8)
   sha256 45988cee248268643a64a4f7c2c639e4eeefbcdc285480358c8ff1adf1d94b44 (name+funcs); compiled at -Xr */
#define W(p, o) (*(unsigned int *)((p) + (o)))
extern unsigned char ram_41368[];
void Voice_UpdateFlagsFromSlot(int part);
void Voice_Selector_ComputeMixWeights(int part);
void Voice_Artic_SetWord0Word2_Nibble2(unsigned char part, unsigned char b)
{
    unsigned char *q;
    q = &ram_41368[(int)part * 287];
    q += 258;
    W(q, 0) &= 0xf0ff;
    W(q, 0) |= (unsigned int)(b & 0xf) << 8;
    W(q, 4) &= 0xf0ff;
    b &= 0xf0;
    W(q, 4) |= (unsigned int)b << 4;
    Voice_UpdateFlagsFromSlot(part);
    Voice_Selector_ComputeMixWeights(part);
}
