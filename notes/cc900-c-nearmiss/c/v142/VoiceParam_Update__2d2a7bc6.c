/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AL_31c.c (2026-11-19-50-sub-r31a)
   sha256 2d2a7bc65a1f7ca6d228da3bd0e0359f82739bcd72ba95286e8501307f8281e8 (name+funcs); compiled at -Xr
   cc900-options: -Xr */
extern unsigned long ToneDB_RelBase;
extern unsigned long *ToneDB_RootPtr;
extern unsigned char ram_41368[];
extern unsigned char ram_4136e[];
extern unsigned char ram_44fce[];
extern unsigned char *ram_4531c;
extern unsigned char *ToneDB_Find_ToneRecord(unsigned int a, unsigned int b);
extern unsigned char *ToneDB_Find_PatchRecord(unsigned int a, unsigned int b);
unsigned char VoiceBuf_TypeSelector_MatchEpilogue(unsigned char part, unsigned char c);
#define PATCH(p)        (*(unsigned char **)(ram_4136e + (p) * 0x11f))
#define WORD(r, p)      (*(unsigned int *)&(r)[(p) * 0x11f])
#define SLOT(p, k)      (*(unsigned char **)(&ram_41368[(p) * 0x11f] + ((int)(k) * 37 + 0x6e)))
void VoiceParam_Update(unsigned char part, unsigned int b, unsigned int d)
{
    unsigned char p;
    unsigned char s;

    if (WORD(ram_41368, part) & 1) {
        if (d == 0x40 || d == 0x41 || d == 0x50) {
            PATCH(part) = ram_4531c + 18816;
        } else {
            PATCH(part) = ram_44fce;
            for (p = 0; p < 4; p++)
                SLOT(part, p) = PATCH(part) + ((int)p * 0x51 + 0x66);
        }
    } else if (WORD(ram_41368, part) & 2) {
        if (part <= 0x0f)
            PATCH(part) = ToneDB_Find_ToneRecord(b, d);
        else
            PATCH(part) = ToneDB_Find_PatchRecord(b, d);
        for (p = 0; p < 4; p++) {
            if ((s = VoiceBuf_TypeSelector_MatchEpilogue(part, p)) == 0xff)
                SLOT(part, p) = (unsigned char *)(ToneDB_RootPtr[43] + ToneDB_RelBase);
            else
                SLOT(part, p) = PATCH(part) + ((int)s * 0x51 + 0x66);
        }
    } else {
        if (part <= 0x0f)
            PATCH(part) = ToneDB_Find_ToneRecord(b, d);
        else
            PATCH(part) = ToneDB_Find_PatchRecord(b, d);
        for (p = 0; p < 4; p++) {
            if ((s = VoiceBuf_TypeSelector_MatchEpilogue(part, p)) == 0xff)
                SLOT(part, p) = (unsigned char *)(ToneDB_RootPtr[43] + ToneDB_RelBase);
            else
                SLOT(part, p) = PATCH(part) + ((int)s * 0x51 + 0x66);
        }
    }
}
