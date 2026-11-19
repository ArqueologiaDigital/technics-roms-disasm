/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/fdemotext_routines_m265.c (2026-11-19-73-p6-r53)
   sha256 5dd1a349d75c5d494c090ac999f346ed1cff1721431a373680a1647a27c66fcd (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern void sendCOMM(int, int, unsigned char *);
extern unsigned char *FDemoText_LookupTableEntry(unsigned int);
extern unsigned char FDemoText_ProbeVoiceType(unsigned int);
extern void VoiceEvent_FlushAndReturn(int, int);
void FDemoText_SendVoiceParams(unsigned char part)
{
	unsigned char msg[6];
	unsigned char *p;
	unsigned char k;

	if (FDemoText_ProbeVoiceType(part) != 12)
		return;
	msg[0] = 0xb0;
	msg[1] = part;
	msg[2] = 0x78;
	msg[3] = 0;
	sendCOMM(0, 4, msg);
	msg[0] = 0x88;
	msg[1] = part;
	msg[3] = 0;
	msg[5] = 0;
	p = FDemoText_LookupTableEntry(0x44);
	p += 1;
	for (k = 11; k <= 12; k++) {
		msg[2] = k;
		msg[4] = *p;
		sendCOMM(0, 6, msg);
		p++;
	}
	p = FDemoText_LookupTableEntry((unsigned char)(part + 0x44));
	p += 3;
	for (k = 4; k <= 8; k++) {
		msg[2] = k;
		msg[4] = *p;
		sendCOMM(0, 6, msg);
		p++;
	}
	VoiceEvent_FlushAndReturn(0xff, part);
}
