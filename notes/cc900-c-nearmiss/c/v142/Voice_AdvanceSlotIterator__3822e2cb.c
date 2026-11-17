/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_10b.c (2026-11-16-90-sub-r10)
   sha256 3822e2cb2ce90751ba3b6e2d55140937eedf30d25aefbddf19d18781c7307d1b (name+funcs); compiled at -Xr */
extern unsigned char __near ram_2128[];
extern unsigned char __near ram_212a[];
unsigned char Quad_Decode_A_To_L(int a);
void VoiceSlot_UpdateNoteSource(int a, int c, int e);
void Voice_AdvanceSlotIterator(unsigned char a)
{
    unsigned int i, end, j;
    i = a * 0x30;
    end = i;
    end += 0x30;
    for (; i < end; i++) {
        if (ram_212a[i * 5] > 0x40 && ram_2128[i * 5] != 0x1a) {
            j = (unsigned char)i;
            VoiceSlot_UpdateNoteSource(j, 0x1a, Quad_Decode_A_To_L((unsigned char)i));
        }
    }
}
