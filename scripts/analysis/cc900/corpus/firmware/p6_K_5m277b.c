/* Phase 6, lane_p6 helper K, round 5, module 277, form b of p6_K_5m277a.c: PanelTlv_ResolvePartCompanions as a
   do/while loop with the two existence tests nested instead of continue. */

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
