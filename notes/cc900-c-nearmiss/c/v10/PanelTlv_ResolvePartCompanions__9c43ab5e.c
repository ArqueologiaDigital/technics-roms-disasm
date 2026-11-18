/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_K_5m277a.c (2026-11-18-33-p6-r37)
   sha256 9c43ab5e4ae72109c249be3612cae2ffd5287cbc1149137e800c09cdabfdfd87 (tar-sha256); compiled at -O3 -Xr */
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

	for (i = 0; i < 23; i++) {
		tag = PanelTlv_CompanionPartTags[i];
		pl = PanelTlv_PayloadOfTag(tag);
		if (pl == (unsigned char *)0xffffffffUL)
			continue;
		comp = PanelTlv_CompanionOfPart(tag);
		if (comp == (unsigned char *)0xffffffffUL)
			continue;
		e.p0 = pl[0];
		e.p1 = pl[1];
		e.tag = tag;
		SndParam_ResolveVoiceEntry(&e);
		comp[e.off] = e.val;
	}
}
