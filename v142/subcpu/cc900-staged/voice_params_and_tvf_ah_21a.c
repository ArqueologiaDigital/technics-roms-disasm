/* Functions of core/05_voice_params_and_tvf.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern unsigned char ram_41368[];
extern unsigned char ram_4136e[];
extern unsigned char ram_451a7;
extern unsigned char ram_4424e[][27];
unsigned int Voice_MakePartHandle(unsigned char a, unsigned char c);
void ExtVoice_Alloc_StreamSlot(unsigned char a, unsigned char c, unsigned char e);
int ClampS16_WA_Short(int a, int hi, int lo);
void Voice_OpSlot_WriteParams(unsigned char part, unsigned char *v, unsigned char op, unsigned char s1, unsigned char s2);
void Voice_Part_Assign(unsigned char a, unsigned char c, unsigned char e, unsigned char s);

/* cc900-module: ClampS16_WA_Short ExtVoice_Alloc_StreamSlot Voice_MakePartHandle */
void Voice_OpSlot_WriteParams(unsigned char part, unsigned char *v, unsigned char op, unsigned char s1, unsigned char s2)
{
    unsigned char *p1;
    unsigned char *p2;
    unsigned char *w;
    unsigned char t;
    p1 = &(*(unsigned char **)&ram_4136e[part * 0x11f])[(int)s1 * 16 + (int)op * 4];
    p1 += 0x2b;
    w = (unsigned char *)(ram_4424e + s2) + (int)s1 * 9;
    p2 = &((unsigned char *)(unsigned long)(ram_41368 + part * 0x11f))[(int)s1 * 16 + (int)op * 4];
    p2 += 0x27;
    if (s1 != 2 && op == 0 && ram_451a7 != 0xf5) {
        w[1] = ClampS16_WA_Short((int)p1[0] + (int)(char)v[104], 0x7f, 0);
        w[3] = ClampS16_WA_Short((int)p1[1] + (int)(char)v[105], 0x7f, 0);
        w[7] = ClampS16_WA_Short((int)(p1[3] & 0x3f) + (int)(char)v[106], 0x1e, 0);
    } else {
        w[1] = p1[0];
        w[3] = p1[1];
        w[7] = p1[3] & 0x3f;
    }
    if (p2[0] & 2) {
        w[2] = p2[3];
        w[7] = 0;
    } else w[2] = 0x80;
    if (p2[0] & 8) {
        w[4] = p2[2];
        w[7] = 0;
    } else w[4] = 0x80;
    if (p1[2] & 0x80) w[0] |= 0x20;
    else w[0] &= ~0x20;
    t = (unsigned int)(p1[3] & 0xc0) >> 6;
    w[0] &= 0xfc;
    w[0] |= t;
    w[5] = p1[2] & 0x7f;
}

void Voice_Part_Assign(unsigned char a, unsigned char c, unsigned char e, unsigned char s)
{
    Voice_MakePartHandle(c, e);
    ExtVoice_Alloc_StreamSlot(a, c, s);
}
