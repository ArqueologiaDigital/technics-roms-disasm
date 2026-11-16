/* Functions of sequencer/seq_step_routines.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: SeqStep_FindAndCompact SeqStep_MeasureRead SeqStep_WalkWithCallback */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned int __near ram_2722;
extern unsigned int __near ram_2724;
extern unsigned char __near ram_2706;
extern unsigned int __near ram_270c;
extern unsigned char __near ram_2648;
extern unsigned int PartCtrl_ReadWord_Off1(unsigned int);
extern void SeqStep_DecrementPos(void);

void SeqStep_DecrementPos(void)
{
    unsigned int w, r;
    w = ram_2724;
    if (w != 5) {
        w--;
        ram_2706 = w;
        ram_270c = ram_2722;
    } else {
        r = PartCtrl_ReadWord_Off1(ram_2722);
        if (r == 0) return;
        ram_270c = r;
        ram_2706 = 0xff;
    }
    ram_2648 = 1;
}
