/* Functions of audio/audio_control_engine.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: MIDI_WriteCommandToBuffer PanelTlv_PayloadOfTag SwbtWr_WriteParamBlock */   /* scripts/analysis/cc900/module_calls.py v10 */

extern void MIDI_WriteCommandToBuffer(int, int, int, int);
extern void MIDI_WriteMultiByteWithHeader(unsigned char *);
extern void MIDI_WriteMultiByteWithHeader(unsigned char *s);
extern unsigned char __near MIDI_MSG_STATUS;
extern unsigned char __near MIDI_MSG_DATA1;
extern unsigned char __near MIDI_MSG_DATA2;
extern unsigned char __near MIDI_MSG_DATA3;
extern unsigned char __near ram_917e;
extern unsigned char __near ram_917f;
extern unsigned char __near ram_9180;
extern unsigned char __near ram_9181;
extern void SwbtWr_WriteParamBlock(void);
extern void MIDI_WriteVoiceParamFromBuffer(void);
extern void Audio_InitSingleChannelParams(unsigned char a);
extern unsigned char __near ram_90fb[];
extern void MIDI_LoadParamsAndDispatchCC(void);
extern unsigned char *PanelTlv_PayloadOfTag(unsigned int);
extern void AddswbWr(unsigned int, unsigned int, unsigned int, unsigned int);
extern void Audio_SendModulationToParts(unsigned char a, unsigned char c);
extern unsigned int __near SWBTWR_WRITE_INDEX;
extern unsigned char __near SWBTWR_EVENT_QUEUE[];
extern void SwbtWr_AppendFixedParamBlock(void);

void MIDI_WriteMultiByteWithHeader(unsigned char *s)
{
    unsigned char ch;
    unsigned char n;
    unsigned char i;

    ch = *s++;
    n = *s++;
    MIDI_WriteCommandToBuffer(ch, 1, s[1], 0xff);
    MIDI_WriteCommandToBuffer(ch, 0, s[0], 0xff);
    n -= 2;
    i = 2;
    s += 2;
    while (n != 0) {
        MIDI_WriteCommandToBuffer(ch, i, *s, 0xff);
        n--;
        i++;
        s++;
    }
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

void SwbtWr_AppendFixedParamBlock(void)
{
	SWBTWR_EVENT_QUEUE[SWBTWR_WRITE_INDEX++] = MIDI_MSG_STATUS;
	SWBTWR_EVENT_QUEUE[SWBTWR_WRITE_INDEX++] = MIDI_MSG_DATA1;
	SWBTWR_EVENT_QUEUE[SWBTWR_WRITE_INDEX++] = MIDI_MSG_DATA2;
	SWBTWR_EVENT_QUEUE[SWBTWR_WRITE_INDEX++] = MIDI_MSG_DATA3;
	SWBTWR_EVENT_QUEUE[SWBTWR_WRITE_INDEX] = 0xff;
	MIDI_MSG_DATA3 = 0;
}
