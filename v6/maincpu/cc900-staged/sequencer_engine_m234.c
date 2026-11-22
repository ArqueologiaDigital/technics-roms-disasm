/* Functions of sequencer/sequencer_engine.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: Part_WriteByte_Indexed Part_WriteWord_Indexed */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned int __near ram_2861;
extern unsigned char SEQ_CURRENT_SONG;
extern void Part_WriteWord_Indexed(unsigned int, unsigned int, unsigned int);
extern void Part_WriteByte_Indexed(unsigned int, unsigned int, unsigned int);
extern void Part_WriteWordAndByte(unsigned int, unsigned char);
extern void Part_WriteWordAndByte(register unsigned int w, unsigned char b);

void Part_WriteWordAndByte(register unsigned int w, unsigned char b)
{
    Part_WriteWord_Indexed(0, (unsigned char)ram_2861, w);
    Part_WriteByte_Indexed(0, (unsigned char)ram_2861, b);
    Part_WriteWord_Indexed((unsigned char)(SEQ_CURRENT_SONG + 1), (unsigned char)ram_2861, w);
    Part_WriteByte_Indexed((unsigned char)(SEQ_CURRENT_SONG + 1), (unsigned char)ram_2861, b);
}
