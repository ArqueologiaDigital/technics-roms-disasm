/* Functions of ui/bitmap_out_routines.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

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
