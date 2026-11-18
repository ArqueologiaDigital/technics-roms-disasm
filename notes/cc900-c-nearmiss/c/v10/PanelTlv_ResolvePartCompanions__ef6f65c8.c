/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_K_5m277b.c (2026-11-18-33-p6-r37)
   sha256 ef6f65c8e99992dc4c69b2202e6ea6f7f99c81710d7741101a1e70ffae6a05d6 (tar-sha256); compiled at -O3 -Xr */
struct pvoice { unsigned char off; unsigned char val; unsigned char tag; unsigned char p0; unsigned char p1;
	unsigned char pad; };
extern unsigned char PanelTlv_CompanionPartTags[];
extern unsigned char *PanelTlv_PayloadOfTag(unsigned int);
extern unsigned char *PanelTlv_CompanionOfPart(unsigned int);
extern void SndParam_ResolveVoiceEntry(struct pvoice *);
void PanelTlv_ResolvePartCompanions(void)
{
	unsigned char *comp;
	unsigned char tag;
	unsigned int i;
	struct pvoice e;
	unsigned char *pl;

	i = 0;
	do {
		tag = PanelTlv_CompanionPartTags[i];
		pl = PanelTlv_PayloadOfTag(tag);
		if (pl != (unsigned char *)0xffffffffUL) {
			comp = PanelTlv_CompanionOfPart(tag);
			if (comp != (unsigned char *)0xffffffffUL) {
				e.p0 = pl[0];
				e.p1 = pl[1];
				e.tag = tag;
				SndParam_ResolveVoiceEntry(&e);
				comp[e.off] = e.val;
			}
		}
	} while (++i < 23);
}
