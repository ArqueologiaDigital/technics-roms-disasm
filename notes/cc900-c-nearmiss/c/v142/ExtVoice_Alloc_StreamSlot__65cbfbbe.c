/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AK_23c.c (2026-11-19-11-sub-r23h-helpers)
   sha256 65cbfbbe65fa282d080e419a18a57186237b2fde7a8580acbb4d99f475fc1845 (name+funcs); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char __near ram_24e6[][12];
extern unsigned char __near ram_2126[][5];
extern unsigned char __near ram_1e4d[][27];
extern unsigned char Voice_PolyphonyLimits_Table[];
extern unsigned char Voice_IndexMapping_Table[];
unsigned char ExtVoice_Fold_SlotNumber(unsigned char s, unsigned char lim);
unsigned char ExtVoice_Lookup_SlotFallback(unsigned char lim);
void VoiceSlot_UpdateNoteSource(unsigned char s, unsigned char a, unsigned char idx);
void VoiceState_SwapSlot_Guarded(unsigned char c, unsigned char lim, unsigned char s);
unsigned int ExtVoice_Alloc_StreamSlot(unsigned char a, unsigned char c, unsigned char e)
{
    unsigned char s;
    unsigned char lim;
    unsigned char idx;
    unsigned char r;
    unsigned char *q;

    (void *)&idx;
    e &= 0x3f;
    if (c >= 0x40 || a >= 0x1a) return (unsigned int)e << 8 | 0xff;
    lim = Voice_PolyphonyLimits_Table[e & 0x1f];
    idx = Voice_IndexMapping_Table[e];
    s = ram_24e6[c][(int)lim + 8];
    if (s < 0xc0) {
        q = ram_2126[s];
        if (q[2] == a && q[3] == idx)
            return (unsigned int)(unsigned char)(e | 0x80) << 8 | ExtVoice_Fold_SlotNumber(s, lim);
    }
    if (e & 0x20) {
        if ((s = ExtVoice_Lookup_SlotFallback(lim)) < 0xc0) {
            VoiceSlot_UpdateNoteSource(s, a, idx);
            VoiceState_SwapSlot_Guarded(c, lim, s);
            r = ExtVoice_Fold_SlotNumber(s, lim);
        } else r = 0xff;
    } else {
        s = ram_1e4d[a][idx];
        if (s < 0xc0) {
            VoiceState_SwapSlot_Guarded(c, lim, s);
            r = ExtVoice_Fold_SlotNumber(s, lim);
            e |= 0x80;
        } else if ((s = ExtVoice_Lookup_SlotFallback(lim)) < 0xc0) {
            VoiceSlot_UpdateNoteSource(s, a, idx);
            VoiceState_SwapSlot_Guarded(c, lim, s);
            r = ExtVoice_Fold_SlotNumber(s, lim);
        } else r = 0xff;
    }
    return (unsigned int)e << 8 | r;
}
