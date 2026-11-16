/* Functions of sequencer/seq_step_routines.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: SeqStep_FindAndCompact SeqStep_MeasureRead SeqStep_WalkWithCallback */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned int __near ram_273c;
extern unsigned int __near ram_273e;
extern unsigned char __near ram_2720;
extern unsigned int __near ram_2726;
extern unsigned char __near ram_2662;
extern unsigned int PartCtrl_ReadWord_Off1(unsigned int);
extern void SeqStep_DecrementPos(void);

void SeqStep_DecrementPos(void)
{
    unsigned int w, r;
    w = ram_273e;
    if (w != 5) {
        w--;
        ram_2720 = w;
        ram_2726 = ram_273c;
    } else {
        r = PartCtrl_ReadWord_Off1(ram_273c);
        if (r == 0) return;
        ram_2726 = r;
        ram_2720 = 0xff;
    }
    ram_2662 = 1;
}
