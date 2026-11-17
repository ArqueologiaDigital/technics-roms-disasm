/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_U_18a.c (2026-11-17-7-sub-r18)
   sha256 28995d12564daee79c182a1ebc86ab804043dda38b11687ee466a817e53c36e2 (name+funcs); compiled at -Xr */
extern unsigned char __near ram_2126[];
extern unsigned char __near ram_24e6[];
unsigned char Quad_Decode_A_To_L(int a);
void VoiceSlot_UpdateNoteSource(int a, int c, int e);
void VoiceState_SwapSlot_DE_BC(int a, int c);
void Voice_ScanSlots_ReassignSources(unsigned char a)
{
    unsigned char *r;
    unsigned char i;
    unsigned char *q;
    unsigned char s;
    int j;
    r = ram_24e6 + (int)a * 12;
    for (i = 0; i < 4; i++) {
        s = r[(int)i + 8];
        if (s < 0xc0) {
            q = &ram_2126[(int)s * 5];
            if (q[4] == a) {
                if (r[i] != a) q[4] = r[i];
                else {
                    q[4] = 0xff;
                    j = s;
                    VoiceSlot_UpdateNoteSource(j, 0x1a, Quad_Decode_A_To_L(s));
                }
            }
            VoiceState_SwapSlot_DE_BC(a, i);
            r[(int)i + 8] = 0xff;
        }
    }
}
