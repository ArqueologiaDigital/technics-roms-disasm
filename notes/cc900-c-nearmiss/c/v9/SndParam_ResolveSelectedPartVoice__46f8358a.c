/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/audio_control_engine_m277.c (2026-11-16-103-p6-r20-staged)
   sha256 46f8358a09a0164aa3b6088928048accac6db5b173e0c234f24f6f310161aac5 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
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
