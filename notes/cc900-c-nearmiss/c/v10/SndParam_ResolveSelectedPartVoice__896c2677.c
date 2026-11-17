/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_14m277.c (2026-11-16-100-p6-r19)
   sha256 896c267752ee5b9a9d413d2490830bed1f63c329ac15f9e062c54bcbaf01aff6 (tar-sha256); compiled at -Xr */
struct pvoice { unsigned char pad[2]; unsigned char part; unsigned char v3; unsigned char v4; unsigned char v5; };
extern unsigned char SndParam_LookupViaEncode(unsigned int, unsigned int);
extern void SndParam_ResolveVoiceEntry(struct pvoice *);
extern unsigned char __near PART_SELECT;
struct pvoice *SndParam_ResolveSelectedPartVoice(void)
{
	struct pvoice r;

	r.v3 = SndParam_LookupViaEncode(PART_SELECT, 0);
	r.v4 = SndParam_LookupViaEncode(PART_SELECT, 32);
	r.part = PART_SELECT;
	SndParam_ResolveVoiceEntry(&r);
	return &r;
}
