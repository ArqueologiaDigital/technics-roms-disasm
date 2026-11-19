/* Functions of core/10_dsp_voice_params.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

struct r16 { unsigned char b[16]; };
extern unsigned long ToneDB_RelBase;
extern unsigned long *ToneDB_RootPtr;
extern unsigned char ram_4136e[];
extern unsigned char ram_45210[];
extern unsigned char *ToneDB_Find_SubToneRecord(unsigned char *rec, unsigned char k, unsigned char e);
extern unsigned char *WaveSel_StageA1_FromToneSlot(unsigned char a, unsigned char *p, unsigned char e, unsigned char s);
void DSP_SetCoeff_FullPipeline(unsigned char part, unsigned char c, char e);

void DSP_SetCoeff_FullPipeline(unsigned char part, unsigned char c, char e)
{
    unsigned long off;
    unsigned char j;
    unsigned char k;
    unsigned int n;
    unsigned int d;
    unsigned char *tbl;
    unsigned char *p;
    unsigned int x;
    unsigned int y;
    unsigned int i;
    k = e;
    k &= 15;
    j = ((unsigned char)e & 0xf0) >> 4;
    p = ToneDB_Find_SubToneRecord((unsigned char *)*(unsigned long *)(ram_4136e + (int)part * 287), c, part);
    p += (int)k * 21 + 16;
    p = WaveSel_StageA1_FromToneSlot(k, p, c, part);
    x = p[(int)j * 2 + 3];
    x &= 127;
    y = *(unsigned char *)((unsigned long)&p[(int)j * 2 + 3] + 1);
    y &= 15;
    switch ((int)*(unsigned char *)((unsigned long)&p[(int)j * 2 + 3] + 1) & 0xc0) {
    case 0:
    case 0x40:
    case 0x80:
    case 0xc0:
        off = ToneDB_RootPtr[24];
    }
    d = *(unsigned long *)((unsigned long)(((y << 7) + x) * 2) + off + ToneDB_RelBase);
    off = ToneDB_RootPtr[37];
    tbl = (unsigned char *)(ToneDB_RelBase + off);
    n = 13;
    for (i = 0; i < n; i++)
        ram_45210[i + 6] = tbl[(unsigned long)d * 16 + i];
    ram_45210[n + 6] = ((struct r16 *)(tbl + (unsigned long)d * 16))->b[13];
    n++;
    ram_45210[n + 6] = (unsigned char)(d & 0xff);
    n++;
    ram_45210[n + 6] = (unsigned char)(d >> 8);
    n++;
}
