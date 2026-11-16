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

extern unsigned char ram_1ed400[];
extern void PanelTlv_ValidateBlock0(unsigned char *mem);
extern void PanelTlv_ValidatePanelMemory(unsigned int n);
extern void PanelTlv_ValidatePanelMemories(void);
extern void PanelTlv_WriteBlock0Headers(unsigned char *mem);
extern void PanelTlv_WritePanelMemoryHeaders(void);

void PanelTlv_ValidatePanelMemory(unsigned int n)
{
    unsigned char *p;
    if (n < 80) {
        p = ram_1ed400 + (unsigned long)n * 960;
        PanelTlv_ValidateBlock0(p);
    }
}
void PanelTlv_ValidatePanelMemories(void)
{
    unsigned int i;
    unsigned char *p;
    for (i = 0, p = ram_1ed400; i < 80; i++, p += 960)
        PanelTlv_ValidateBlock0(p);
}
void PanelTlv_WritePanelMemoryHeaders(void)
{
    unsigned int i;
    unsigned char *p;
    for (i = 0, p = ram_1ed400; i < 80; i++, p += 960)
        PanelTlv_WriteBlock0Headers(p);
}

/* cc900-module: SndParamBank_WriteFlashDefaults */
extern void SndParamBank_WriteFlashDefaults(void);
extern unsigned char SndParamBank_DefaultHeader[];
extern void SndParamBank_CheckFlash(void);

void SndParamBank_CheckFlash(void)
{
	unsigned char *s, *d;
	unsigned int i;

	s = SndParamBank_DefaultHeader;
	d = (unsigned char *)0x3d3000L;
	for (i = 0; i < 3; i++)
		if (*d++ != *s++) {
			SndParamBank_WriteFlashDefaults();
			return;
		}
}
