/* Functions of ui/ui_mode_handlers.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: EffectMode_MidiSetLEDs */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned char __near ram_8cac[];
extern int PanelInput_ReadRxRecord(unsigned char *rec);
extern void EffectMode_MidiSetLEDs(unsigned char *rec);
extern void EffectMode_MidiParseLoop(void);

void EffectMode_MidiParseLoop(void)
{
	unsigned char *p;

	p = ram_8cac;
	while (PanelInput_ReadRxRecord(p) != -1)
		EffectMode_MidiSetLEDs(p);
}
