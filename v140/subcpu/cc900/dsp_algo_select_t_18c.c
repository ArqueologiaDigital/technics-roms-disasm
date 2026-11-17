/* Functions of core/09_dsp_algo_select.s.
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
extern unsigned char ram_451c4[];
extern unsigned char ram_4131c[];

void DSP_VoiceCoeffRoute2(unsigned char part, unsigned char sel)
{
    unsigned int n;
    unsigned int d;
    unsigned char *tbl;
    unsigned char s;
    unsigned char z;
    unsigned int x;
    unsigned int y;
    unsigned int i;
    unsigned long t;
    s = sel;
    s &= 15;
    z = (sel & 0xf0) >> 4;
    x = (*(unsigned char **)((unsigned long)&((unsigned char *)(unsigned long)(ram_4131c + (part) * 0x11f))[(int)(s) * 37 + 110] + 4))[(int)z * 2 + 3];
    x &= 127;
    y = *(unsigned char *)((unsigned long)&(*(unsigned char **)((unsigned long)&((unsigned char *)(unsigned long)(ram_4131c + (part) * 0x11f))[(int)(s) * 37 + 110] + 4))[(int)z * 2 + 3] + 1);
    y &= 15;
    switch ((int)*(unsigned char *)((unsigned long)&(*(unsigned char **)((unsigned long)&((unsigned char *)(unsigned long)(ram_4131c + (part) * 0x11f))[(int)(s) * 37 + 110] + 4))[(int)z * 2 + 3] + 1) & 192) {
    case 0x00:
        tbl = (unsigned char *)ToneDB_RootPtr[22];
        break;
    case 0x40:
        tbl = (unsigned char *)ToneDB_RootPtr[24];
        break;
    case 0x80:
        tbl = (unsigned char *)ToneDB_RootPtr[23];
        break;
    case 0xc0:
        tbl = (unsigned char *)ToneDB_RootPtr[22];
        break;
    }
    d = *(unsigned long *)((unsigned long)(((y << 7) + x) * 2) + (unsigned long)tbl + ToneDB_RelBase);
    tbl = (unsigned char *)ToneDB_RootPtr[25];
    t = ToneDB_RelBase;
    t += (unsigned long)tbl;
    tbl = (unsigned char *)t;
    n = 13;
    for (i = 0; i < n; i++)
        ram_451c4[i + 6] = tbl[(unsigned long)d * 16 + i];
    ram_451c4[n + 6] = ((struct r16 *)(tbl + (unsigned long)d * 16))->b[13];
    n++;
    ram_451c4[n + 6] = (unsigned char)(d & 0xff);
    n++;
    ram_451c4[n + 6] = (unsigned char)(d >> 8);
    n++;
}
