/* lane_p6 helper L, round 28r1, form a: module 303 (audio/note_voice_mapping.s), the read-only-mode switches
   SndParam_CheckAndApplyMode / SndParam_ComputeVoiceIndex (families28_L, 2 x 30 B): ask
   SndParam_LookupReadOnly(192) (a long argument: the ROM loads XWA) whether the sound is read-only (1), and hand
   the parameter record (XWA, kept in XIZ) to one of two module-local workers.
   Also families28_L's ApplyProgramChange_LoadReg / ApplyProgramChangeAs_LoadReg (2 x 10 B): tail calls of the
   DRAM loaders with (record, 24 / 16 as a long, 0x400), the twins of the built SndParam_InitBufferConverge /
   ApplyProgramChangeAs_LoadReg2 (cc900/note_voice_mapping_m303_b.c), written the same way.
   Form a: if / else, the record a pointer parameter as in the built SndParam_ApplyVoiceValue.
   cc900-options: -O3 -Xr
*/
/* cc900-module: ApplyProgramChangeAs_LoadDRAM2 ApplyProgramChange_LoadDRAM ApplyProgramChange_LoadReg SndParam_ApplyVoiceValue SndParam_InitBufferConverge SndParam_LookupOscEnvelope */   /* scripts/analysis/cc900/module_calls.py v10 */

extern void ApplyProgramChangeAs_LoadDRAM2(unsigned char *, long, unsigned int);
extern void ApplyProgramChange_LoadDRAM(unsigned char *, long, unsigned int);

void ApplyProgramChangeAs_LoadReg(unsigned char *p)
{
	ApplyProgramChangeAs_LoadDRAM2(p, 0x10L, 0x400);
}

void ApplyProgramChange_LoadReg(unsigned char *p)
{
	ApplyProgramChange_LoadDRAM(p, 0x18L, 0x400);
}

extern int SndParam_LookupReadOnly(long);
extern void SndParam_ApplyVoiceValue(unsigned char *);
extern void SndParam_LookupOscEnvelope(unsigned char *);
extern void SndParam_InitBufferConverge(unsigned char *);
extern void ApplyProgramChange_LoadReg(unsigned char *);

void SndParam_ComputeVoiceIndex(unsigned char *r)
{
	if (SndParam_LookupReadOnly(192L) == 1)
		SndParam_InitBufferConverge(r);
	else
		ApplyProgramChange_LoadReg(r);
}

void SndParam_CheckAndApplyMode(unsigned char *r)
{
	if (SndParam_LookupReadOnly(192L) == 1)
		SndParam_ApplyVoiceValue(r);
	else
		SndParam_LookupOscEnvelope(r);
}
