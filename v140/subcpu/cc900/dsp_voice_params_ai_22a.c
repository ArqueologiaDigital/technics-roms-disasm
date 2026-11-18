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
extern unsigned char ram_4131c[];
extern unsigned char ram_41322[];
extern unsigned char ram_44f82[];
extern unsigned char ram_451c4[];
extern unsigned char *ram_452d0;
extern unsigned char DSP_VOICEPARAM_DEFAULT_TABLE[];
void DSP_SetCoeff_RouteComplex(unsigned char part, unsigned char sel);
int DSP_VoiceParamReadWrite(unsigned int part, unsigned int idx, unsigned char *out);

void DSP_SetCoeff_RouteComplex(unsigned char part, unsigned char sel)
{
    unsigned int n;
    unsigned int d;
    unsigned char *tbl;
    unsigned char *rec;
    unsigned int x;
    unsigned int y;
    unsigned int f;
    unsigned int i;
    unsigned long off;
    register unsigned char *q;
    rec = (*(unsigned char **)(ram_41322 + (part) * 0x11f));
    x = rec[(int)sel * 2 + 39];
    x &= 127;
    y = *(unsigned char *)((unsigned long)&rec[(int)sel * 2 + 39] + 1);
    y &= 31;
    f = *(unsigned char *)((unsigned long)&rec[(int)sel * 2 + 39] + 1);
    f &= 32;
    off = ToneDB_RootPtr[31];
    d = *(unsigned long *)((unsigned long)(((y << 7) + x) * 2) + off + ToneDB_RelBase);
    off = ToneDB_RootPtr[32];
    tbl = (unsigned char *)(ToneDB_RelBase + off);
    n = 13;
    switch (f) {
    case 0:
        for (i = 0; i < n; i++)
            ram_451c4[i + 6] = tbl[(unsigned long)d * 16 + i];
        break;
    case 0x20:
        for (i = 0; i < n; i++) {
            q = &ram_452d0[(int)sel * 80 + 19111];
            ram_451c4[i + 6] = q[i];
        }
        break;
    }
    ram_451c4[n + 6] = ((struct r16 *)(tbl + (unsigned long)d * 16))->b[13];
    n++;
    ram_451c4[n + 6] = (unsigned char)(d & 0xff);
    n++;
    ram_451c4[n + 6] = (unsigned char)(d >> 8);
    n++;
}

int DSP_VoiceParamReadWrite(unsigned int part, unsigned int idx, unsigned char *out)
{
    int r;
    unsigned int k;
    unsigned int cnt;
    cnt = 0;
    if (*(unsigned int *)(ram_4131c + (unsigned long)part * 0x11f) & 1) {
        *out = ram_44f82[(unsigned long)idx + 0x1d8];
    } else {
        for (k = 0; k < 4; k++) {
            if (((*(unsigned char **)((unsigned long)(ram_4131c + (unsigned long)part * 0x11f) + ((unsigned long)k * 37 + 0x6e)))[6] & 0xc0) == 0) {
                if (!((*(unsigned char **)((unsigned long)(ram_4131c + (unsigned long)part * 0x11f) + ((unsigned long)k * 37 + 0x6e)))[6] & 0x20))
                    cnt++;
            }
        }
        *out = cnt == 4 ? DSP_VOICEPARAM_DEFAULT_TABLE[(unsigned long)idx] : 0;
    }
    return r;
}
