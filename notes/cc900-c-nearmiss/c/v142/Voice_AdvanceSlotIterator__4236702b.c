/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_P_17a.c (2026-11-16-126-sub-r17)
   sha256 4236702b3d6d2cd4a34bd2c4b4787b866c2680f5404a1df78ec1c7768ec2066d (name+funcs); compiled at -Xr */
extern unsigned char __near ram_2128[];
extern unsigned char __near ram_212a[];
unsigned char Quad_Decode_A_To_L(int a);
void VoiceSlot_UpdateNoteSource(int a, int c, int e);
void Voice_AdvanceSlotIterator(unsigned char a)
{
    unsigned int i, end, j;
    unsigned char k = 0x30;
    i = k * a;
    end = i;
    end += 0x30;
    for (; i < end; i++) {
        if (ram_212a[i * 5] > 0x40 && ram_2128[i * 5] != 0x1a) {
            j = (unsigned char)i;
            VoiceSlot_UpdateNoteSource(j, 0x1a, Quad_Decode_A_To_L((unsigned char)i));
        }
    }
}
