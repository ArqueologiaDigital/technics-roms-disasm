/* Functions of audio/note_voice_mapping.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: ApplyProgramChangeAs_LoadDRAM2 ApplyProgramChange_LoadDRAM ApplyProgramChange_LoadReg SndParam_ApplyVoiceValue SndParam_InitBufferConverge SndParam_LookupOscEnvelope */   /* scripts/analysis/cc900/module_calls.py v10 */

extern void ApplyProgramChangeAs_LoadDRAM2(unsigned char *, long, unsigned int);
extern void ApplyProgramChangeAs_LoadReg(unsigned char *p);
extern void ApplyProgramChange_LoadDRAM(unsigned char *, long, unsigned int);
extern void ApplyProgramChange_LoadReg(unsigned char *);
extern void ApplyProgramChange_LoadReg(unsigned char *p);
extern int SndParam_LookupReadOnly(long);
extern void SndParam_ApplyVoiceValue(unsigned char *);
extern void SndParam_LookupOscEnvelope(unsigned char *);
extern void SndParam_CheckAndApplyMode(unsigned char *r);

void ApplyProgramChangeAs_LoadReg(unsigned char *p)
{
	ApplyProgramChangeAs_LoadDRAM2(p, 0x10L, 0x400);
}

void ApplyProgramChange_LoadReg(unsigned char *p)
{
	ApplyProgramChange_LoadDRAM(p, 0x18L, 0x400);
}

void SndParam_CheckAndApplyMode(unsigned char *r)
{
	if (SndParam_LookupReadOnly(192L) == 1)
		SndParam_ApplyVoiceValue(r);
	else
		SndParam_LookupOscEnvelope(r);
}
