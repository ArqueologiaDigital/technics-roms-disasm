/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/accompaniment_engine_m257.c (2026-11-16-92-p6-r18)
   sha256 4f3afab2a077d1a44298eb36ea0e107ddb0674434d4cf6f725f0f4bfe3f15ea6 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ram_8cec;
extern unsigned char __near ram_38ec;
extern unsigned char __near ram_3431;
extern unsigned char Tempo_DisplayParamReturn(void);
extern void Tempo_DisplayParamSkipClear(int);
extern void MIDI_SendSysExCmd(int);
void Tempo_EditBPM(unsigned char a)
{
    unsigned char r;
    if (a != 0) return;
    ram_8cec |= 1;
    r = Tempo_DisplayParamReturn();
    ram_38ec = r;
    switch (r) {
    case 0:
        Tempo_DisplayParamSkipClear(0x23);
        break;
    case 1:
        Tempo_DisplayParamSkipClear(0xf);
        MIDI_SendSysExCmd(8);
        break;
    }
    ram_3431 |= 0x80;
    ram_3431 |= 0x80;
}
