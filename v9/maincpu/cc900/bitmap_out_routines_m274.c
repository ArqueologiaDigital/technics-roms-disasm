/* Functions of ui/bitmap_out_routines.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern void *__cdecl Mem_Copy(void *, void *, unsigned int);
extern char BmoUpdWidget_Str_NonPanelMem;
extern unsigned char *PanelMemory_SlotAddresses[];
extern unsigned char __near PANEL_STYLIST_NAME;
extern unsigned char __near LIVE_PANEL_BLOCK;
extern void BitMapOut_UpdateDisplayWidget(unsigned char n, char *d);

/* cc900-name: BmoUpdWidget_Str_NonPanelMem=BitMapOut_UpdateDisplayWidget_Str_Non_Panel_Memory */
void BitMapOut_UpdateDisplayWidget(unsigned char n, char *d)
{
	unsigned char *s;

	if (n == 0)
		Mem_Copy(d, &BmoUpdWidget_Str_NonPanelMem, 16);
	else {
		s = PanelMemory_SlotAddresses[n - 1];
		Mem_Copy(d, (&PANEL_STYLIST_NAME - &LIVE_PANEL_BLOCK - 0x20) + s, 16);
	}
	d[16] = 0;
}

/* cc900-module: SetDialFocus */
extern void PanelMem_InitFromFactory(unsigned int);
extern void PanelTlv_ValidatePanelMemory(unsigned int);
extern void PanelMemory_PostSlotLoad(unsigned char n, int r);

void PanelMemory_PostSlotLoad(unsigned char n, int r)
{
  if (r < 0)
    PanelMem_InitFromFactory(n);
  else
    PanelTlv_ValidatePanelMemory(n);
}

extern unsigned char __near ram_f9a0[];
extern unsigned char ram_3c8e4[];
extern void PanelMemory_BackupLivePanel(void);

void PanelMemory_BackupLivePanel(void)
{
	Mem_Copy(ram_3c8e4, ram_f9a0, 960);
}

struct resolve_ent { unsigned char *p0; unsigned char *p4; unsigned char b8; unsigned char b9; unsigned char *col; };
struct voice_ent { unsigned char idx; unsigned char val; unsigned char b2; unsigned char b3; unsigned char b4; };
extern struct resolve_ent PanelMemory_PartResolveTable[];
extern void SndParam_ResolveVoiceEntry(struct voice_ent *);
extern void BmoDelta_Type90Return(void);

/* cc900-name: BmoDelta_Type90Return=BitMapOut_DeltaEncode_Type90Return */
void BmoDelta_Type90Return(void)
{
	struct voice_ent v;
	unsigned int i;

	for (i = 0; i < 23; i++) {
		v.b3 = *PanelMemory_PartResolveTable[i].p0 & 0xff;
		v.b4 = *PanelMemory_PartResolveTable[i].p4 & 0x7f;
		v.b2 = PanelMemory_PartResolveTable[i].b8;
		SndParam_ResolveVoiceEntry(&v);
		PanelMemory_PartResolveTable[i].col[v.idx] = v.val;
	}
}
