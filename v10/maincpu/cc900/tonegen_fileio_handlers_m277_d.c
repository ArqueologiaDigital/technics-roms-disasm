/* Functions of audio/tonegen_fileio_handlers.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: PanelTlv_ValidateRecord */   /* scripts/analysis/cc900/module_calls.py v10 */

struct tlvrec { unsigned long off; unsigned char *rules; unsigned char tag; unsigned char len; };
extern struct tlvrec PanelTlv_Block0_Layout[];
extern void PanelTlv_ValidateRecord(unsigned char *base, struct tlvrec *l);
extern int DSPCfg_WriteAllSlots_Combined(int slot, unsigned char *p);
extern unsigned char __near PANEL_DSP_EFFECT[];
extern unsigned char __near PANEL_DIGITAL_REVERB[];
extern unsigned char __near PANEL_ACOUSTIC_ILLUSION[];
extern unsigned char __near PANEL_MIC_REVERB[];
extern unsigned char __near PANEL_EQUALIZER[];
extern void PanelTlv_ValidateBlock0(unsigned char *base);

void PanelTlv_ValidateBlock0(unsigned char *base)
{
	unsigned int i;

	for (i = 0; i < 46; i++)
		PanelTlv_ValidateRecord(base, &PanelTlv_Block0_Layout[i]);
	DSPCfg_WriteAllSlots_Combined(0, base + ((unsigned long)PANEL_DSP_EFFECT - 0xf9a0));
	DSPCfg_WriteAllSlots_Combined(1, base + ((unsigned long)PANEL_DIGITAL_REVERB - 0xf9a0));
	DSPCfg_WriteAllSlots_Combined(2, base + ((unsigned long)PANEL_ACOUSTIC_ILLUSION - 0xf9a0));
	DSPCfg_WriteAllSlots_Combined(3, base + ((unsigned long)PANEL_MIC_REVERB - 0xf9a0));
	DSPCfg_WriteAllSlots_Combined(4, base + ((unsigned long)PANEL_EQUALIZER - 0xf9a0));
}
