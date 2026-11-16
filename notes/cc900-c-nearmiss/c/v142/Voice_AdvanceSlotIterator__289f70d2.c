/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_11c.c (2026-11-16-94-sub-r11)
   sha256 289f70d23c2e7948707c019c386ce0ddb32ebe52b97624c696c04b7ae0fbf151 (name+funcs); compiled at -Xr */
extern unsigned char __near ram_2128[];
extern unsigned char __near ram_212a[];
unsigned char Quad_Decode_A_To_L(int a);
void VoiceSlot_UpdateNoteSource(int a, int c, int e);
void Voice_AdvanceSlotIterator(unsigned char a)
{
    unsigned int i, end, j;
    i = a;
    i *= 0x30;
    end = i;
    end += 0x30;
    for (; i < end; i++) {
        if (ram_212a[i * 5] > 0x40 && ram_2128[i * 5] != 0x1a) {
            j = (unsigned char)i;
            VoiceSlot_UpdateNoteSource(j, 0x1a, Quad_Decode_A_To_L((unsigned char)i));
        }
    }
}
