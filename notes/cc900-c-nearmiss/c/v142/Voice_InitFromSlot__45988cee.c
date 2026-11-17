/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_8a.c (2026-11-16-82-sub-r8)
   sha256 45988cee248268643a64a4f7c2c639e4eeefbcdc285480358c8ff1adf1d94b44 (name+funcs); compiled at -Xr */
extern unsigned char ram_41472[];
extern unsigned char ram_41473[];
extern unsigned char ram_41474[];
extern unsigned char ram_41475[];
void Voice_UpdateFlagsFromSlot(int part);
void Voice_Selector_ComputeMixWeights(int part);
void Voice_InitFromSlot(unsigned char part)
{
    Voice_UpdateFlagsFromSlot(part);
    Voice_Selector_ComputeMixWeights(part);
    ram_41472[(int)part * 287] = 0;
    ram_41473[(int)part * 287] = 0;
    ram_41474[(int)part * 287] = 0;
    ram_41475[(int)part * 287] = 0;
}
