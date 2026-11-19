/* Phase 6, lane_p6 helper M, round 2, module 265 (demo/fdemotext_routines.s), form a.
   FDemoText_ProbeVoiceType / FDemoText_ByteData_ProbeHelper: look up the voice's two-byte table entry, build a 6-byte
   oscillator request {?, ?, v, e0, e1, ?} and return byte 0 (ProbeVoiceType) or byte 1 (ProbeHelper) of the reply.
   The parameter is spilled and reloaded at once (-Xr); the request pointer taken after the lookup (idiom: the frame
   address assigned to a variable before the call). */
/* cc900-module: FDemoText_LookupTableEntry */

extern unsigned char *FDemoText_LookupTableEntry(unsigned int);
extern void SndParam_FetchOscTableEntry(unsigned char *);
extern unsigned char FDemoText_ProbeVoiceType(unsigned char v);
extern unsigned char FDemoText_ByteData_ProbeHelper(unsigned char v);

unsigned char FDemoText_ProbeVoiceType(unsigned char v)
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
	return rec[0];
}

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
