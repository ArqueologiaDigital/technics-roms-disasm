/* Functions of midi/midi_dispatch_handlers.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern unsigned char __near ram_bc5c;
extern unsigned char __near ram_bc58;
extern unsigned char __near ram_bc40;
extern unsigned char __near ram_bc44;
extern unsigned char __near ram_bc48;
extern unsigned char __near ram_bc4c;
extern unsigned char __near ram_bc50;
extern unsigned char __near ram_bc54;
extern void ParaLoadOpt_AudioFlagCheck(unsigned char a, unsigned char c, unsigned char e);
extern void ParaLoadOpt_AudioFlagCheck_B(unsigned char a, unsigned char c, unsigned char e);
extern void MidiSeq_ApplyPendingParams(void);

void MidiSeq_ApplyPendingParams(void)
{
	if (!(ram_bc5c & 0x40))
		return;
	if (ram_bc58 & 0x40)
		ParaLoadOpt_AudioFlagCheck(ram_bc40 & 0x7f, ram_bc44 & 0x7f, ram_bc48 & 0x7f);
	else
		ParaLoadOpt_AudioFlagCheck_B(ram_bc4c & 0x7f, ram_bc50 & 0x7f, ram_bc54 & 0x7f);
	ram_bc5c &= ~0x40;
}
