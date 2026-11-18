/* Phase 6, lane_p6 helper K, round 5, module 277 (audio/tonegen_fileio_handlers.s; -Xr style: frame variables
   reloaded), form a: PanelTlv_ResolvePartCompanions.  For each of the 23 part tags in PanelTlv_CompanionPartTags
   whose panel record (PanelTlv_PayloadOfTag) and companion record (PanelTlv_CompanionOfPart) both exist (not -1):
   fills a 6-byte voice entry {offset, value, tag, payload byte 0, payload byte 1} with the tag and the payload,
   resolves it (SndParam_ResolveVoiceEntry) and stores the value at that offset in the companion record.  Frame:
   companion pointer, tag, index (plain, in declaration order) below the address-taken entry; the payload pointer in
   XIZ.  The loop has no entry test in the ROM: form a writes for, form b do/while. */

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
