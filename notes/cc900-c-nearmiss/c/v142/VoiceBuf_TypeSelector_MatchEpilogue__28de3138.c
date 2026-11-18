/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AI_21a.c (2026-11-18-19-sub-r21b-staged)
   sha256 28de3138f83f8ba5dc56f6b6558142886ccd9667bf1bc62fdaa02e6a4566ee82 (tar-sha256); compiled at -Xr */
extern unsigned char ram_4136e[];
extern unsigned char ram_41382[];
extern unsigned int VoiceChanScan_SlotEnableMask[];
#define PART_PATCH(p)   (*(unsigned char **)(ram_4136e + (p) * 0x11f))
unsigned char VoiceBuf_TypeSelector_MatchEpilogue(unsigned char part, unsigned char c)
{
    unsigned char w;
    unsigned char b;

    if (ram_41382[part * 0x11f] < 0x10 || c == 0) {
        if (VoiceChanScan_SlotEnableMask[c] & PART_PATCH(part)[17]) {
            w = 0;
            for (b = 1; b < c + 1; b++)
                if (VoiceChanScan_SlotEnableMask[b] & PART_PATCH(part)[17]) w++;
            c = w;
        } else c = 0xff;
    }
    return c;
}
