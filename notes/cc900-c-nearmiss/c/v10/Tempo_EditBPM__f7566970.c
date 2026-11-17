/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_7a.c (2026-11-16-45-p6-r9)
   sha256 f75669701267b77dffaa5335c29cabf57bf854482b882bba194a9f14b1c82c30 (tar-sha256); compiled at -O3 -Xr */
extern unsigned char __near ram_8d88;
extern unsigned char __near ram_3988;
extern unsigned char __near ram_34cd;
extern unsigned char Tempo_DisplayParamReturn(void);
extern void Tempo_DisplayParamSkipClear(int);
extern void MIDI_SendSysExCmd(int);
void Tempo_EditBPM(unsigned char a)
{
    unsigned char r;
    if (a != 0) return;
    ram_8d88 |= 1;
    r = Tempo_DisplayParamReturn();
    ram_3988 = r;
    switch (r) {
    case 0:
        Tempo_DisplayParamSkipClear(0x23);
        break;
    case 1:
        Tempo_DisplayParamSkipClear(0xf);
        MIDI_SendSysExCmd(8);
        break;
    }
    ram_34cd |= 0x80;
    ram_34cd |= 0x80;
}
