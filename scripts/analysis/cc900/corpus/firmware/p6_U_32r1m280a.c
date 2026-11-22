/* lane_p6 helper U, round 32r1: roots of audio/audio_control_engine.s, module 280 (-O3 -Xr). */
/* cc900-module: PanelTlv_PayloadOfTag SwbtWr_WriteParamBlock */

extern unsigned int __near SWBTWR_WRITE_INDEX;
extern unsigned char __near SWBTWR_EVENT_QUEUE[];
extern unsigned char __near MIDI_MSG_STATUS;
extern unsigned char __near MIDI_MSG_DATA1;
extern unsigned char __near MIDI_MSG_DATA2;
extern unsigned char __near MIDI_MSG_DATA3;
extern unsigned char __near ram_917e;
extern unsigned char __near ram_917f;
extern unsigned char __near ram_9180;
extern unsigned char __near ram_9181;
extern unsigned char __near ram_90fb[];
extern void SwbtWr_WriteParamBlock(void);
extern void MIDI_WriteVoiceParamFromBuffer(void);
extern void MIDI_LoadParamsAndDispatchCC(void);
extern unsigned char *PanelTlv_PayloadOfTag(unsigned int);
extern void AddswbWr(unsigned int, unsigned int, unsigned int, unsigned int);

void SwbtWr_AppendFixedParamBlock(void)
{
	SWBTWR_EVENT_QUEUE[SWBTWR_WRITE_INDEX++] = MIDI_MSG_STATUS;
	SWBTWR_EVENT_QUEUE[SWBTWR_WRITE_INDEX++] = MIDI_MSG_DATA1;
	SWBTWR_EVENT_QUEUE[SWBTWR_WRITE_INDEX++] = MIDI_MSG_DATA2;
	SWBTWR_EVENT_QUEUE[SWBTWR_WRITE_INDEX++] = MIDI_MSG_DATA3;
	SWBTWR_EVENT_QUEUE[SWBTWR_WRITE_INDEX] = 0xff;
	MIDI_MSG_DATA3 = 0;
}

void Audio_InitSingleChannelParams(unsigned char a)
{
	MIDI_MSG_STATUS = 177;
	MIDI_MSG_DATA1 = a;
	MIDI_MSG_DATA2 = 0;
	MIDI_MSG_DATA3 = 64;
	SwbtWr_WriteParamBlock();
	MIDI_MSG_STATUS = 178;
	MIDI_MSG_DATA1 = a;
	MIDI_MSG_DATA2 = 0;
	MIDI_MSG_DATA3 = 127;
	SwbtWr_WriteParamBlock();
	MIDI_MSG_STATUS = 179;
	MIDI_MSG_DATA1 = a;
	MIDI_MSG_DATA2 = 127;
	MIDI_MSG_DATA3 = 127;
	SwbtWr_WriteParamBlock();
	ram_917e = a;
	ram_917f = 4;
	ram_9180 = 0;
	ram_9181 = 8;
	MIDI_WriteVoiceParamFromBuffer();
	MIDI_MSG_STATUS = a;
	MIDI_MSG_DATA1 = 4;
	MIDI_MSG_DATA2 = 0;
	MIDI_MSG_DATA3 = 8;
	SwbtWr_WriteParamBlock();
}

void Audio_SendModulationToParts(unsigned char a, unsigned char c)
{
	unsigned int i;
	unsigned char t;

	for (i = 0; i < 0x20; i++) {
		t = ram_90fb[i];
		if (t == 0xff) break;
		if (t == 2 && c != 2) continue;
		ram_917e = 178;
		ram_917f = ram_90fb[i];
		ram_9180 = a;
		ram_9181 = 127;
		MIDI_LoadParamsAndDispatchCC();
		if (PanelTlv_PayloadOfTag(ram_90fb[i])[13] & 0x20) continue;
		AddswbWr(ram_917e, ram_917f, ram_9180, ram_9181);
	}
}
