/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_C_8b.c (2026-11-16-82-sub-r8)
   sha256 09f3a845bbb5aa4e74311adad2cc93f6921ff52351e467e9009b30eedd2a75fa (name+funcs); compiled at -Xr */
extern unsigned char ram_41368[];
extern unsigned char ram_41382[];
extern void DSP_FlushAllSlots_ForPart();
void VoiceAlloc_CheckAndInit_FromRecord(unsigned char *m)
{
    unsigned char e;
    unsigned char t;
    e = m[1];
    if (e > 2 && (*(unsigned int *)(ram_41368 + e * 0x11f) & 3) != 3) return;
    if (*(unsigned int *)(ram_41368 + e * 0x11f) & 1) {
        *(unsigned int *)(ram_41368 + e * 0x11f) |= 1;
        return;
    }
    *(unsigned int *)(ram_41368 + e * 0x11f) |= 1;
    t = ram_41382[e * 0x11f];
    if (t < 64) return;
    if (t >= 80) return;
    DSP_FlushAllSlots_ForPart(e);
}
