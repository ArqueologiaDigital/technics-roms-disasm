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

