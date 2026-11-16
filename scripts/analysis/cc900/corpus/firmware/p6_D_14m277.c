/* Phase 6, lane_p6 helper D, round 14, module 277 (v10 audio/audio_control_engine.s): PanelInput_Poll (a timestamp
   moved memory to memory, then three pollers unless the title is 247) and SndParam_ResolveSelectedPartVoice (fills a
   6-byte record on its stack, passes it to SndParam_ResolveVoiceEntry and returns its address, as the ROM does). */
/* cc900-module: PanelInput_DrainRxQueue PanelInput_QueueCpuAdcChanges PanelInput_ScanPedalPorts */   /* from scripts/analysis/cc900/module_calls.py v10 */

struct pvoice { unsigned char pad[2]; unsigned char part; unsigned char v3; unsigned char v4; unsigned char v5; };

extern void PanelInput_DrainRxQueue(void);
extern void PanelInput_ScanPedalPorts(void);
extern void PanelInput_QueueCpuAdcChanges(void);
extern unsigned char SndParam_LookupViaEncode(unsigned int, unsigned int);
extern void SndParam_ResolveVoiceEntry(struct pvoice *);

extern unsigned int __near ram_8ec2;
extern unsigned int __near SYSTEM_TIMESTAMP;
extern unsigned char __near CURRENT_TITLE;
extern unsigned char __near PART_SELECT;

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
