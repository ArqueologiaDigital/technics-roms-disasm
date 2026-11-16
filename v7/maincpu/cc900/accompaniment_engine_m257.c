/* Functions of sequencer/accompaniment_engine.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: Tempo_DisplayParamReturn Tempo_DisplayParamSkipClear */   /* staged module names, repair_module_lines.py */

extern unsigned char __near ram_e31c;
extern unsigned char __near ram_e31e;
extern unsigned char __near ram_e320;
extern unsigned char __near GLOBAL_ERROR_CODE;
extern void UI_InterruptTitleByIndex(int);

void Tempo_DisplayParamCommon(unsigned char a, unsigned char c)
{
    ram_e31c |= 9;
    ram_e31e = a;
    ram_e320 = c;
}

void Tempo_DisplayParamSkipClear(unsigned char a)
{
    GLOBAL_ERROR_CODE = a;
    UI_InterruptTitleByIndex(0xee);
}

extern unsigned char __near ram_8cec;
extern unsigned char __near ram_38ec;
extern unsigned char __near ram_3431;
extern unsigned char Tempo_DisplayParamReturn(void);
extern void Tempo_DisplayParamSkipClear(int);
extern void MIDI_SendSysExCmd(int);
extern void Tempo_EditBPM(unsigned char a);

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
