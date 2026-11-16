/* Functions of audio/tonegen_fileio_handlers.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: PanelTlv_ApplyFieldRule PanelTlv_ValidateBlock0 PanelTlv_WriteBlock0Headers */   /* scripts/analysis/cc900/module_calls.py v10 */

struct tlvlay { unsigned long off; unsigned char *rules; };
extern unsigned int PanelTlv_ApplyFieldRule(unsigned char *base, unsigned char *rule);
extern void PanelTlv_ValidateRecord(unsigned char *base, struct tlvlay *l);
extern int PanelTlv_Rule_ClearBits(unsigned char *rec, unsigned char *r);
extern void PanelTlv_WriteRecordHeader(unsigned char *buf, unsigned char *rec);
extern void FlashWrite(int, unsigned char *, unsigned int, long);
extern unsigned char *__cdecl Malloc(unsigned int);
extern void __cdecl Free(void *);
extern void *__cdecl Memset(void *, int, unsigned int);
extern void *__cdecl Mem_Copy(void *, void *, unsigned int);
extern void Gfx_ClearFrameBuffers(void);
extern unsigned char SndParamBank_OptionDefault_00[], SndParamBank_OptionDefault_10[], SndParamBank_OptionDefault_20[];
extern unsigned char SndParamBank_OptionDefault_30[], SndParamBank_OptionDefault_40[];
extern void SndParamBank_RestoreOptionBlock(void);

void PanelTlv_ValidateRecord(unsigned char *base, struct tlvlay *l)
{
    unsigned char *r;
    base += l->off + 2;
    r = l->rules;
    while (*r != 0xff)
        r += PanelTlv_ApplyFieldRule(base, r);
}

int PanelTlv_Rule_ClearBits(unsigned char *rec, unsigned char *r)
{
	rec[r[1]] &= ~r[2];
	return 3;
}

void PanelTlv_WriteRecordHeader(unsigned char *buf, unsigned char *rec)
{
	buf += *(long *)rec;
	buf[0] = rec[8];
	buf[1] = rec[9];
}

void SndParamBank_RestoreOptionBlock(void)
{
	unsigned char *b;

	b = Malloc(0x50);
	if (b == 0) return;
	Memset(b, 0x50, 0);
	Mem_Copy(b, (void *)0x3d3400L, 2);
	Mem_Copy(b + 16, SndParamBank_OptionDefault_10, 12);
	Mem_Copy(b + 32, SndParamBank_OptionDefault_20, 4);
	Mem_Copy(b + 48, SndParamBank_OptionDefault_30, 4);
	Mem_Copy(b + 64, SndParamBank_OptionDefault_40, 6);
	FlashWrite(1, b, 0x50, 0x3d3400L);
	Free(b);
	Gfx_ClearFrameBuffers();
}
