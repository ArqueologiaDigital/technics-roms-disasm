/* Functions of demo/fdemotext_routines.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: FDemoText_LookupTableEntry */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned char __near SWBTWR_PAYLOAD_1;
extern unsigned char __near SWBTWR_PAYLOAD_3;
extern unsigned char __near SWBTWR_EVENT_TYPE;
extern unsigned char ram_247ec;
extern unsigned char FDemoText_FullSendBitByPart[];
extern unsigned char FDemoText_PartialResendBit[];
extern void FDemoText_ByteData_VoiceProbeC(void);

/* cc900-data: FDemoText_ByteData_VoiceProbeC 1 = FDemoText_ByteData_VoiceProbeC_CaseTable */
void FDemoText_ByteData_VoiceProbeC(void)
{
    unsigned char e;
    e = SWBTWR_EVENT_TYPE - 0x44;
    switch (SWBTWR_PAYLOAD_1) {
    case 1:
    case 2:
        ram_247ec |= 0x40;
        break;
    case 3:
    case 4:
    case 5:
    case 6:
        ram_247ec |= FDemoText_FullSendBitByPart[e];
        break;
    case 7:
        if (SWBTWR_PAYLOAD_3 & 0x0f) ram_247ec |= FDemoText_FullSendBitByPart[e];
        if (SWBTWR_PAYLOAD_3 & 0x30) ram_247ec |= FDemoText_PartialResendBit[e];
        break;
    }
}

extern unsigned char *FDemoText_LookupTableEntry(unsigned int);
extern void SndParam_FetchOscTableEntry(unsigned char *);
extern unsigned char FDemoText_ByteData_ProbeHelper(unsigned char v);

unsigned char FDemoText_ByteData_ProbeHelper(unsigned char v)
{
	unsigned char rec[6];
	unsigned char *t;
	unsigned char *p;

	t = FDemoText_LookupTableEntry(v);
	p = rec;
	p[3] = *t++;
	p[4] = *t;
	p[2] = v;
	SndParam_FetchOscTableEntry(p);
	return rec[1];
}

/* cc900-module: FDemoText_NotifyUIChange FDemoText_ProbeVoiceType FDemoText_ReadTaggedBlock */
extern void AddswbWr(int, int, int, int);
extern unsigned char ram_247ee;
extern unsigned char __near PANEL_DSP_EFFECT[];
extern unsigned char __near PANEL_DRAWBAR_RIGHT1[];
extern void FDemoText_NotifyUIChange(int a, unsigned char v);
extern void FDemoText_UpdateVoiceDisplay(unsigned char ch);

void FDemoText_UpdateVoiceDisplay(unsigned char ch)
{
	unsigned char *e;
	unsigned char *f;

	e = FDemoText_LookupTableEntry(ch);
	e += 5;
	if (*e != 0) {
		*e = 0;
		AddswbWr(ch, 5, 0, 0x7f);
		f = e + 2;
		if (*f == 0) {
			*f = 0x5a;
			AddswbWr(ch, 7, 0x5a, 0x7f);
		}
	}
	if ((ram_247ee & 0x38) == 0 && PANEL_DRAWBAR_RIGHT1[0] != PANEL_DSP_EFFECT[0])
		FDemoText_NotifyUIChange(0x61, PANEL_DRAWBAR_RIGHT1[0]);
}
