/* Functions of audio/note_voice_mapping.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: ApplyProgramChangeAs_LoadDRAM2 ApplyProgramChange_LoadDRAM ApplyProgramChange_LoadReg SndParam_ApplyVoiceValue SndParam_InitBufferConverge SndParam_LookupOscEnvelope */   /* scripts/analysis/cc900/module_calls.py v10 */

extern int SndParam_LookupReadOnly(long);
extern void SndParam_InitBufferConverge(unsigned char *);
extern void ApplyProgramChange_LoadReg(unsigned char *);
extern void ApplyProgramChange_LoadReg(unsigned char *p);
extern void SndParam_ComputeVoiceIndex(unsigned char *r);

void SndParam_ComputeVoiceIndex(unsigned char *r)
{
	if (SndParam_LookupReadOnly(192L) == 1)
		SndParam_InitBufferConverge(r);
	else
		ApplyProgramChange_LoadReg(r);
}
