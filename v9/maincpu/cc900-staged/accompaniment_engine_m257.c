/* Functions of sequencer/accompaniment_engine.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern unsigned char __near ram_e3e2;
extern unsigned char __near ram_e3e4;
extern unsigned char __near ram_e3e6;
extern unsigned char __near GLOBAL_ERROR_CODE;
extern void UI_InterruptTitleByIndex(int);

void Tempo_DisplayParamCommon(unsigned char a, unsigned char c)
{
    ram_e3e2 |= 9;
    ram_e3e4 = a;
    ram_e3e6 = c;
}

void Tempo_DisplayParamSkipClear(unsigned char a)
{
    GLOBAL_ERROR_CODE = a;
    UI_InterruptTitleByIndex(0xee);
}
