/* Functions of core/10_dsp_voice_params.s.
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
extern unsigned char ram_41376[];
void EnvTranspose_UpdateLoop(unsigned char part);
unsigned int Partial_GetBaseKey(unsigned char part, unsigned char partial);
int SignedClamp_Zero(int a);

/* cc900-module: Partial_GetBaseKey SignedClamp_Zero */
void EnvTranspose_UpdateLoop(unsigned char part)
{
    unsigned char *rec;
    int t;
    int k[4];
    unsigned char p;
    unsigned int lo;
    int hi;
    rec = (unsigned char *)(unsigned long)(ram_41368 + part * 0x11f);
    t = (signed char)(ram_41376[part * 0x11f] - 0x40);
    for (p = 0; p < 4; p++) {
        if ((k[p] = Partial_GetBaseKey(part, p)) != 0x80)
            k[p] = SignedClamp_Zero(k[p] + t);
        ((unsigned char *)(unsigned long)(rec + ((int)p * 37 + 0x6e)))[35] = (unsigned char)k[p];
        ((unsigned char *)(unsigned long)(rec + ((int)p * 37 + 0x6e)))[36] = (unsigned char)k[p];
    }
    p = (*(unsigned char **)(ram_4136e + part * 0x11f))[93];
    if ((*(unsigned int *)(rec + 10) & 0x8000L) && (p & 0x40) && k[0] == k[1] && k[0] != 0x80) {
        lo = k[0];
        if ((int)lo < 0x40) {
            lo = SignedClamp_Zero(lo - 0x10);
            hi = SignedClamp_Zero(lo + 0x28);
        } else {
            lo = SignedClamp_Zero(lo + 0x10);
            hi = SignedClamp_Zero(lo - 0x28);
        }
        if ((p & 0xf) == 9) {
            rec[145] = lo;
            rec[182] = lo;
            rec[146] = hi;
            rec[183] = hi;
        } else if ((p & 0xf) < 10) {
            rec[145] = lo;
            rec[182] = hi;
        }
    }
}
