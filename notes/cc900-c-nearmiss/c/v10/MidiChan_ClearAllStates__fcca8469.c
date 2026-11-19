/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_L_2m285a.c (2026-11-19-19-p6-r43)
   sha256 fcca8469cecb63b3f882481aa1f25c3516e315c8798391df7e9061b302d64482 (tar-sha256); compiled at -O3 -XS -Xr */
extern unsigned char __near ram_bd00;
extern unsigned char __near ram_bd02;
extern unsigned char __near ram_bd04;
extern unsigned char __near ram_bd06;
extern unsigned char __near ram_bd08;
extern unsigned char __near ram_bd0a;
extern unsigned char __near ram_bd0c;
extern unsigned char __near ram_bd0e;
extern unsigned char __near ram_bd10;
extern unsigned char __near ram_bd12;
extern unsigned char __near ram_bd14;
extern unsigned char __near ram_bd16;
extern unsigned char __near ram_bd36;
extern unsigned char __near ram_bd38;
extern void MidiChan_SetStateMode(void);
extern void MidiChan_SetVoiceBaseState(void);
extern void MidiSeq_ApplyPendingParams(void);
void MidiChan_ClearAllStates(void)
{
	ram_bd00 = 0;
	ram_bd02 = 0;
	ram_bd04 = 0;
	ram_bd06 = 0;
	ram_bd08 = 0;
	ram_bd0a = 0;
	ram_bd0c = 0;
	ram_bd0e = 0;
	ram_bd10 = 0;
	ram_bd12 = 0;
	ram_bd14 = 0;
	ram_bd16 = 0;
	ram_bd36 = 0;
	ram_bd38 = 0;
	MidiChan_SetStateMode();
	MidiChan_SetVoiceBaseState();
	MidiSeq_ApplyPendingParams();
}
