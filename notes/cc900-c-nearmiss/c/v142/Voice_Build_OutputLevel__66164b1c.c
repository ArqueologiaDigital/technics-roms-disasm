/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_H_15b.c (2026-11-16-106-sub-r15)
   sha256 66164b1cba1f65710cc1f15e377a49a501d9d6208ea26ea566d807fd9a7b9891 (name+funcs); compiled at -Xr */
extern unsigned int ram_451d0;
extern unsigned char Voice_OutputLevel_Table[];
extern unsigned int Voice_Reg080_NoteField_Table[];
int Voice_Clamp_Byte_WA(int a);
void Voice_Build_OutputLevel(unsigned char *v, int b)
{
    unsigned int w;
    b += (*(int *)(((*(unsigned char **)((v) + (35)))) + (12)));
    b += (*(int *)(((*(unsigned char **)((v) + (35)))) + (16)));
    b += (*(int *)((v) + (51)));
    b = Voice_Clamp_Byte_WA(b);
    b = (*(unsigned int *)((Voice_OutputLevel_Table) + (b * 2))) * 2;
    if ((*(unsigned char **)((v) + (15)))[2] & 0x80) w = ((unsigned int)(*(unsigned char **)((v) + (15)))[2] & 0x70) << 8;
    else w = Voice_Reg080_NoteField_Table[(*(unsigned int *)((v) + (6))) >> 8];
    b |= w;
    b |= 0x8000;
    ram_451d0 = b;
}
