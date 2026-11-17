/* Functions of core/05_voice_params_and_tvf.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern char TVF_KeyFollow_Curves[][128];
extern char PitchBend_ScaleCoeff_Table[];
extern unsigned char Voice_DepthMirror_Table[];
extern unsigned char __near ram_132b[];
extern unsigned char __near ram_1481[];
int TVF_Clamp_Cutoff(int a);
void Voice_List_MoveToPool(unsigned char *n, unsigned char *list, int k);
void Voice_List_MoveToPartList(unsigned char *n, unsigned char *list, int k);
void DList_Unlink_SelfLink_Offsets16(unsigned char *n);
int PBend_Scale(char a, unsigned char b, unsigned char e);
int TVF_Calc_Cutoff(unsigned char *v, int c, int d, char s);
void Voice_Retire_ToFreePool(unsigned char *v);

/* cc900-name: PBend_Scale=PitchBend_Scale */
/* cc900-module: DList_Unlink_SelfLink_Offsets16 PitchBend_Scale TVF_Clamp_Cutoff Voice_List_MoveToPartList Voice_List_MoveToPool */
int PBend_Scale(char a, unsigned char b, unsigned char e)
{
    int k;
    int r;
    b &= 0x7f;
    if (a < 0) {
        b = (unsigned int)Voice_DepthMirror_Table[b];
        a = ~a + 1;
    }
    k = a;
    r = PitchBend_ScaleCoeff_Table[b];
    r = r * k;
    r >>= e;
    return r;
}

int TVF_Calc_Cutoff(unsigned char *v, int c, int d, char s)
{
    unsigned char *t;
    int k;
    unsigned int w;
    t = (*(unsigned char **)((v) + (23)));
    if (d != 0) {
        k = TVF_KeyFollow_Curves[(t[54] & 0xe0) >> 5][(unsigned int)v[12] & 0x7f];
        d = d * k >> 5;
        c += d;
    }
    if (s != 0) {
        w = ((*(unsigned int *)((v) + (8))) & 0x7f00) >> 8;
        if (w > t[59]) w = t[59];
        else if (w < t[58]) w = t[58];
        w -= t[57];
        c += (s * (int)w) >> 5;
    }
    return TVF_Clamp_Cutoff(c + 0x18);
}

void Voice_Retire_ToFreePool(unsigned char *v)
{
    unsigned char *q;
    unsigned char *u;
    if (!(v[34] & 1)) {
        if ((*(unsigned char **)((v) + (29)))[1] != 0) (*(unsigned char **)((v) + (29)))[1]--;
        Voice_List_MoveToPool(v, (unsigned char *)(void *)ram_132b, 6);
        Voice_List_MoveToPartList(v, (unsigned char *)(void *)ram_1481, 1);
        DList_Unlink_SelfLink_Offsets16(v);
        v[34] = 1;
        v[37] = 0;
        u = (*(unsigned char **)((v) + (29)));
        q = u;
        if (u[1] < *q) (*(unsigned char **)((v) + (29)))[1]++;
    }
}
