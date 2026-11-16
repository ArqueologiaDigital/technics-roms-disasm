/* Functions of core/12_dsp2_init.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

struct slot { unsigned int type; unsigned int a[1]; int param[17]; int idx; int q[1]; int r42[6]; int on; };
struct cfg { unsigned int f0, f2, f4, f6; struct slot s[5]; };
struct ring2k { unsigned int w, r, n; unsigned char buf[2048]; };
extern unsigned char __near ram_436d;
extern unsigned char __near ram_436e;
extern int DSP_RingBuf_Read(struct ring2k *);
extern void DSP_RingBuf_Skip(struct ring2k *);
extern struct cfg *DSP_GetConfigBuffer(void);
extern struct slot *EFF_GetSlotBuffer(unsigned int);

/* cc900-module: DSP_RingBuf_Read DSP_RingBuf_Skip */
int DSP_Cmd_LoadEffectPreset(struct ring2k *r)
{
    unsigned int n;
    unsigned int i;
    unsigned int s;
    unsigned char *d;
    unsigned int t;

    t = (unsigned int)ram_436d + 0;
    t <<= 7;
    if (ram_436e + t == 0x122) {
        d = (unsigned char *)DSP_GetConfigBuffer();
        n = 8;
        for (i = 0; i < n; i++)
            *d++ = DSP_RingBuf_Read(r);
        n = 0x38;
        for (s = 0; s < 5; s++) {
            d = (unsigned char *)EFF_GetSlotBuffer(s);
            for (i = 0; i < n; i++)
                *d++ = DSP_RingBuf_Read(r);
        }
        DSP_RingBuf_Read(r);
        DSP_RingBuf_Read(r);
        return 0;
    }
    DSP_RingBuf_Skip(r);
    return -1;
}
