/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_R_31r1m280a.c (2026-11-22-15-p6-r82)
   sha256 3d03bc199778095051726515d855a831710b5cec041f798a245641f05ae1b99b (tar-sha256); compiled at -O3 -Xr */
extern unsigned char *PanelTlv_PayloadOfTag(unsigned int);
extern unsigned char __near ram_90fb[];
extern unsigned char __near ram_917e;
extern unsigned char __near ram_917f;
extern unsigned char __near ram_9180;
extern unsigned char __near ram_9181;
extern unsigned char __near PANEL_FOOT_CONTROLLERS[];
extern void MIDI_LoadParamsAndDispatchCC(void);
extern void AddswbWr(unsigned int, unsigned int, unsigned int, unsigned int);
void Audio_SendExpressionToParts(unsigned char v)
{
    unsigned int i;
    unsigned char t;

    if (PANEL_FOOT_CONTROLLERS[2] == 183) {
        i = 0;
        do {
            t = ram_90fb[i];
            if (t == 255) break;
            if (PanelTlv_PayloadOfTag(t)[4] & 0x20) {
                ram_917e = 179;
                ram_917f = ram_90fb[i];
                ram_9180 = v;
                ram_9181 = 127;
                MIDI_LoadParamsAndDispatchCC();
                if (!(PanelTlv_PayloadOfTag(ram_90fb[i])[13] & 0x20))
                    AddswbWr(ram_917e, ram_917f, ram_9180, ram_9181);
            }
        } while (++i < 32);
    }
}
