/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AI_21b.c (2026-11-18-19-sub-r21b-staged)
   sha256 437b0277b604534e4eb01e5e25460ffc90f4a907064a53fd5e2fa9768fec0eca (tar-sha256); compiled at -Xr */
extern unsigned char ram_4136e[];
extern unsigned char ram_41382[];
extern unsigned int VoiceChanScan_SlotEnableMask[];
#define PART_PATCH(p)   (*(unsigned char **)(ram_4136e + (p) * 0x11f))
unsigned char VoiceBuf_TypeSelector_MatchEpilogue(unsigned char part, unsigned char c)
{
    unsigned char w;
    unsigned char b;

    if (ram_41382[part * 0x11f] < 0x10 || c == 0) {
        if (PART_PATCH(part)[17] & VoiceChanScan_SlotEnableMask[c]) {
            w = 0;
            for (b = 1; b < (unsigned char)(c + 1); b++)
                if (PART_PATCH(part)[17] & VoiceChanScan_SlotEnableMask[b]) w++;
            c = w;
        } else c = 0xff;
    }
    return c;
}
