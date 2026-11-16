/* Functions of audio/audio_control_engine.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: PanelInput_DrainRxQueue PanelInput_QueueCpuAdcChanges PanelInput_ScanPedalPorts */   /* scripts/analysis/cc900/module_calls.py v10 */

extern void PanelInput_DrainRxQueue(void);
extern void PanelInput_ScanPedalPorts(void);
extern void PanelInput_QueueCpuAdcChanges(void);
extern unsigned int __near ram_8ec2;
extern unsigned int __near SYSTEM_TIMESTAMP;
extern unsigned char __near CURRENT_TITLE;
extern void PanelInput_Poll(void);
struct pvoice { unsigned char pad[2]; unsigned char part; unsigned char v3; unsigned char v4; unsigned char v5; };
extern unsigned char SndParam_LookupViaEncode(unsigned int, unsigned int);
extern void SndParam_ResolveVoiceEntry(struct pvoice *);
extern unsigned char __near PART_SELECT;
extern struct pvoice *SndParam_ResolveSelectedPartVoice(void);

void PanelInput_Poll(void)
{
	ram_8ec2 = SYSTEM_TIMESTAMP;
	if (CURRENT_TITLE != 247) {
		PanelInput_DrainRxQueue();
		PanelInput_ScanPedalPorts();
		PanelInput_QueueCpuAdcChanges();
	}
}

struct pvoice *SndParam_ResolveSelectedPartVoice(void)
{
	struct pvoice r;

	r.v3 = SndParam_LookupViaEncode(PART_SELECT, 0);
	r.v4 = SndParam_LookupViaEncode(PART_SELECT, 32);
	r.part = PART_SELECT;
	SndParam_ResolveVoiceEntry(&r);
	return &r;
}
