/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_10a.c (2026-11-16-90-sub-r10)
   sha256 bb499c121aaefa01b0c094dc81af9c38404b55775ff87425d47cbe4ef107bd5d (name+funcs); compiled at -Xr */
extern unsigned int Voice_Part_Trim_Table_A[];
extern unsigned int Voice_Part_Trim_Table_B[];
extern unsigned int Voice_Part_Trim_Base[];
extern unsigned int Voice_Part_Trim_Addend_1[];
extern unsigned int Voice_Part_Trim_Addend_2[];
extern unsigned char ram_4146a[];
extern unsigned char ram_41476[];
extern unsigned char ram_41478[];
extern unsigned char ram_4147a[];
void Voice_Selector_FindBestSlot(unsigned char *w, unsigned char *cnt, unsigned char *idx, unsigned char *val);
void Voice_Selector_ComputeMixWeights(unsigned char part)
{
    unsigned char g2, g1, g0;
    unsigned int x;
    Voice_Selector_FindBestSlot(&ram_4146a[(int)part * 287], &g2, &g1, &g0);
    *(unsigned int *)&ram_41476[(int)part * 287] = Voice_Part_Trim_Table_A[g2];
    *(unsigned int *)&ram_4147a[(int)part * 287] = Voice_Part_Trim_Table_B[g1];
    x = Voice_Part_Trim_Base[g2];
    x += Voice_Part_Trim_Addend_1[g1];
    x += Voice_Part_Trim_Addend_2[g0];
    *(unsigned int *)&ram_41478[(int)part * 287] = x;
}
