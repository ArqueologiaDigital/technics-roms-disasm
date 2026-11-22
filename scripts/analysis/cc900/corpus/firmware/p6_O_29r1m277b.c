/* lane_p6 helper O, round 29r1, form b: module 277 (audio/tonegen_fileio_handlers.s), PanelTlv_ValidateBlock0
   (141 B, singletons29_O).  Form a with the effect record's address spelled as one left-to-right long sum
   (record address - 0xf9a0 + base), the ROM's lda / sub / add order.
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
	DSPCfg_WriteAllSlots_Combined(0, (unsigned char *)((long)PANEL_DSP_EFFECT - 0xf9a0L + (long)base));
	DSPCfg_WriteAllSlots_Combined(1, (unsigned char *)((long)PANEL_DIGITAL_REVERB - 0xf9a0L + (long)base));
	DSPCfg_WriteAllSlots_Combined(2, (unsigned char *)((long)PANEL_ACOUSTIC_ILLUSION - 0xf9a0L + (long)base));
	DSPCfg_WriteAllSlots_Combined(3, (unsigned char *)((long)PANEL_MIC_REVERB - 0xf9a0L + (long)base));
	DSPCfg_WriteAllSlots_Combined(4, (unsigned char *)((long)PANEL_EQUALIZER - 0xf9a0L + (long)base));
}
