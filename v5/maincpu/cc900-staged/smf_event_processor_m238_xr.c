/* Functions of sequencer/smf_event_processor.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/
/* cc900-module: Fat_MapFilePosToSector SeqStep_FileBufferSetup SeqStep_FileIoCheck SeqStep_FileSectorProcess SeqStep_FileSectorRead SeqStep_FileSectorReturn */   /* scripts/analysis/cc900/module_calls.py v10 */

extern void *__cdecl Mem_Copy(void *, void *, int);
extern unsigned int __cdecl SeqStep_FileSectorRead(unsigned char **pp);
extern unsigned long __cdecl SeqStep_FileSectorProcess(unsigned char **pp);
extern void __cdecl SeqStep_FileSectorComplete(unsigned char *e, unsigned char *raw);

void __cdecl SeqStep_FileSectorComplete(unsigned char *e, unsigned char *raw)
{
	unsigned char *p;

	p = raw + 22;
	Mem_Copy(e, raw, 11);
	e[11] = 0;
	e[12] = raw[11];
	*(unsigned int *)(e + 13) = SeqStep_FileSectorRead(&p);
	*(unsigned int *)(e + 15) = SeqStep_FileSectorRead(&p);
	*(unsigned int *)(e + 17) = SeqStep_FileSectorRead(&p);
	*(unsigned long *)(e + 19) = SeqStep_FileSectorProcess(&p);
}
