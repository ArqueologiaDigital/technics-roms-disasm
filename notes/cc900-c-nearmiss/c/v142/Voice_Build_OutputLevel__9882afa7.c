/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_H_15c.c (2026-11-16-106-sub-r15)
   sha256 9882afa7f896ea4195aabe306b21db718bacce0972ccd5e0cd19826ec002366e (name+funcs); compiled at -Xr */
#define W(p, o) (*(unsigned int *)((p) + (o)))
#define SW(p, o) (*(int *)((p) + (o)))
#define P(p, o) (*(unsigned char **)((p) + (o)))
extern unsigned int ram_451d0;
extern unsigned char Voice_OutputLevel_Table[];
extern unsigned int Voice_Reg080_NoteField_Table[];
int Voice_Clamp_Byte_WA(int a);
void Voice_Build_OutputLevel(unsigned char *v, int b)
{
    unsigned int w;
    b += SW(P(v, 35), 12);
    b += SW(P(v, 35), 16);
    b += SW(v, 51);
    b = Voice_Clamp_Byte_WA(b);
    b = W(Voice_OutputLevel_Table, b * 2) << 1;
    if (P(v, 15)[2] & 0x80) w = ((unsigned int)P(v, 15)[2] & 0x70) << 8;
    else w = Voice_Reg080_NoteField_Table[W(v, 6) >> 8];
    b |= w;
    b |= 0x8000;
    ram_451d0 = b;
}
