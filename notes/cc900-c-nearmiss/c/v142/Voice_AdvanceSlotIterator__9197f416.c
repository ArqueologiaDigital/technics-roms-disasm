/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_11b.c (2026-11-16-94-sub-r11)
   sha256 9197f416d974ad58622bfc51c68d59c34234d0da0be1106191b5db14e126891d (name+funcs); compiled at -Xr */
extern unsigned char __near ram_2128[];
extern unsigned char __near ram_212a[];
unsigned char Quad_Decode_A_To_L(int a);
void VoiceSlot_UpdateNoteSource(int a, int c, int e);
void Voice_AdvanceSlotIterator(unsigned char a)
{
    unsigned int i, end, j;
    i = (unsigned char)0x30 * a;
    end = i;
    end += 0x30;
    for (; i < end; i++) {
        if (ram_212a[i * 5] > 0x40 && ram_2128[i * 5] != 0x1a) {
            j = (unsigned char)i;
            VoiceSlot_UpdateNoteSource(j, 0x1a, Quad_Decode_A_To_L((unsigned char)i));
        }
    }
}
