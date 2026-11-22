/* lane_p6 helper O, round 29r1, form a: module 277 (audio/tonegen_fileio_handlers.s), PanelTlv_ValidateBlock0
   (141 B, singletons29_O): the built PanelTlv_ValidateBlock1's loop over the 46 PanelTlv_Block0_Layout records
   (v10/maincpu/cc900/tonegen_fileio_handlers_m277_c.c), then the five effect records to
   DSPCfg_WriteAllSlots_Combined as slots 0..4, each at base + (record address - 0xf9a0).
   Form a: the record offset as `base + ((unsigned long)RECORD - 0xf9a0)`.
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
