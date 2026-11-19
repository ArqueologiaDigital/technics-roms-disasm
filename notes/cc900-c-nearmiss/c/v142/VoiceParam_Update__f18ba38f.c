/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AL_33b.c (2026-11-19-54-sub-r33a)
   sha256 f18ba38f2960c7daeff0cdf0ae1214d864d1490efeb3f37ad22ccd9134324666 (name+funcs); compiled at -Xr
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
#define SLOT(p, k)      (*(unsigned char **)&((char *)&ram_41368[(p) * 0x11f])[(int)(k) * 37 + 0x6e])
#define DEFAULT_SLOT    (ToneDB_RootPtr[43] + (unsigned char *)ToneDB_RelBase)
void VoiceParam_Update(unsigned char part, unsigned int b, unsigned int d)
{
    unsigned char p;
    unsigned char s;

    if (WORD(ram_41368, part) & 1) {
        if (d == 0x40 || d == 0x41 || d == 0x50) {
            PATCH(part) = ram_4531c + 18816;
        } else {
            PATCH(part) = &ram_44fce[0];
            for (p = 0; p < 4; p++)
                SLOT(part, p) = PATCH(part) + ((int)p * 0x51 + 0x66);
        }
    } else if (WORD(ram_41368, part) & 2) {
        if (part <= 0x0f)
            PATCH(part) = ToneDB_Find_ToneRecord(b, d);
        else
            PATCH(part) = ToneDB_Find_PatchRecord(b, d);
        for (p = 0; p < 4; p++) {
            s = VoiceBuf_TypeSelector_MatchEpilogue(part, p);
            if (s == 0xff)
                SLOT(part, p) = DEFAULT_SLOT;
            else
                SLOT(part, p) = PATCH(part) + ((int)s * 0x51 + 0x66);
        }
    } else {
        if (part <= 0x0f)
            PATCH(part) = ToneDB_Find_ToneRecord(b, d);
        else
            PATCH(part) = ToneDB_Find_PatchRecord(b, d);
        for (p = 0; p < 4; p++) {
            s = VoiceBuf_TypeSelector_MatchEpilogue(part, p);
            if (s == 0xff)
                SLOT(part, p) = DEFAULT_SLOT;
            else
                SLOT(part, p) = PATCH(part) + ((int)s * 0x51 + 0x66);
        }
    }
}
