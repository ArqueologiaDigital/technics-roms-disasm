/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_9a.c (2026-11-16-86-sub-r9)
   sha256 88eb9f6250e886eb73d0ea17657ceaba2c1d96ee178a9e302b394fec469d7fa4 (name+funcs); compiled at -Xr */
extern unsigned int ram_451d0;
extern unsigned int Voice_OutputLevel_Table[];
extern unsigned int Voice_Reg080_NoteField_Table[];
int Voice_Clamp_Byte_WA(int a);
void Voice_Build_OutputLevel(unsigned char *v, int b)
{
    unsigned int w;
    b += (*(int *)(((*(unsigned char **)((v) + (35)))) + (12)));
    b += (*(int *)(((*(unsigned char **)((v) + (35)))) + (16)));
    b += (*(int *)((v) + (51)));
    b = Voice_Clamp_Byte_WA(b);
    b = Voice_OutputLevel_Table[b] * 2;
    if ((*(unsigned char **)((v) + (15)))[2] & 0x80) w = ((unsigned int)(*(unsigned char **)((v) + (15)))[2] & 0x70) << 8;
    else w = Voice_Reg080_NoteField_Table[(*(unsigned int *)((v) + (6))) >> 8];
    ram_451d0 = b | w | 0x8000;
}
