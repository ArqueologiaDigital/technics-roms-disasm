/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AL_31a.c (2026-11-19-50-sub-r31a)
   sha256 f55a6ada62964d6a9cee648e8acb94c8d794da84d1e8c31ec593ed402a0afbe3 (name+funcs); compiled at -Xr
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
void VoiceParam_Update(unsigned char part, unsigned int b, unsigned int d)
{
    unsigned char p;
    unsigned char s;
    if ((*(unsigned int *)&(ram_41368)[(part) * 0x11f]) & 1) {
        if (d == 0x40 || d == 0x41 || d == 0x50) {
            (*(unsigned char **)(ram_4136e + (part) * 0x11f)) = ram_4531c + 18816;
        } else {
            (*(unsigned char **)(ram_4136e + (part) * 0x11f)) = ram_44fce;
            for (p = 0; p < 4; p++)
                (*(unsigned char **)(&ram_41368[(part) * 0x11f] + ((int)(p) * 37 + 0x6e))) = (*(unsigned char **)(ram_4136e + (part) * 0x11f)) + ((int)p * 0x51 + 0x66);
        }
    } else if ((*(unsigned int *)&(ram_41368)[(part) * 0x11f]) & 2) {
        if (part <= 0x0f)
            (*(unsigned char **)(ram_4136e + (part) * 0x11f)) = ToneDB_Find_ToneRecord(b, d);
        else
            (*(unsigned char **)(ram_4136e + (part) * 0x11f)) = ToneDB_Find_PatchRecord(b, d);
        for (p = 0; p < 4; p++) {
            if ((s = VoiceBuf_TypeSelector_MatchEpilogue(part, p)) == 0xff)
                (*(unsigned char **)(&ram_41368[(part) * 0x11f] + ((int)(p) * 37 + 0x6e))) = (unsigned char *)(ToneDB_RelBase + ToneDB_RootPtr[43]);
            else
                (*(unsigned char **)(&ram_41368[(part) * 0x11f] + ((int)(p) * 37 + 0x6e))) = (*(unsigned char **)(ram_4136e + (part) * 0x11f)) + ((int)s * 0x51 + 0x66);
        }
    } else {
        if (part <= 0x0f)
            (*(unsigned char **)(ram_4136e + (part) * 0x11f)) = ToneDB_Find_ToneRecord(b, d);
        else
            (*(unsigned char **)(ram_4136e + (part) * 0x11f)) = ToneDB_Find_PatchRecord(b, d);
        for (p = 0; p < 4; p++) {
            if ((s = VoiceBuf_TypeSelector_MatchEpilogue(part, p)) == 0xff)
                (*(unsigned char **)(&ram_41368[(part) * 0x11f] + ((int)(p) * 37 + 0x6e))) = (unsigned char *)(ToneDB_RelBase + ToneDB_RootPtr[43]);
            else
                (*(unsigned char **)(&ram_41368[(part) * 0x11f] + ((int)(p) * 37 + 0x6e))) = (*(unsigned char **)(ram_4136e + (part) * 0x11f)) + ((int)s * 0x51 + 0x66);
        }
    }
}
