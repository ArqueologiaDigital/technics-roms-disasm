/* Functions of core/05_voice_params_and_tvf.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern unsigned char __near ram_148d[];
extern unsigned char __near ram_134d[];
extern unsigned char __near ram_1351[];
void OutputBuf_Flush_A(unsigned char **pp, unsigned char *head, unsigned char key, unsigned char all);
void OutputBuf_Flush_B(unsigned char **pp, unsigned char *head, unsigned char key, unsigned char all);

/* cc900-module: NoteOn_RoutePacket OutputBuf_Flush_A OutputBuf_Flush_B */
void NoteOn_RoutePacket(unsigned char *q)
{
    unsigned char **l1;
    unsigned char **l2;
    unsigned char key;
    unsigned char all;
    unsigned char *out;
    unsigned char *v;
    unsigned char i;
    unsigned char ch;
    unsigned int x;
    x = (*(unsigned int *)((q) + (3))) & 0x7f;
    all = x;
    x = (*(unsigned int *)((q) + (1))) & 0x7f;
    key = x;
    out = q + 5;
    if ((*(unsigned int *)((q) + (3))) & 0x1f00) {
        v = ram_148d;
        for (i = 0; i < 0x40; i++) {
            if (!(v[34] & 1)) *out++ = v[36];
            v += 39;
        }
        *out = 0xff;
    } else {
        ch = ((*(unsigned int *)((q) + (1))) & 0x1f00) >> 8;
        l1 = (unsigned char **)(ram_134d + (int)ch * 12);
        l2 = (unsigned char **)(ram_1351 + (int)ch * 12);
        if (ch < 0x1a) {
            if (q[0] & 0x80) {
                if ((*(unsigned int *)((q) + (3))) & 0x7f) {
                    if (*l1 != 0) {
                        v = *l1;
                        for (;;) {
                            OutputBuf_Flush_B(&out, *l1, key, all);
                            if (*l1 == 0) break;
                            if (*l1 == v) break;
                        }
                    }
                    *out = 0xff;
                } else OutputBuf_Flush_B(&out, *l1, key, all);
            } else if (q[0] & 0x40) {
                OutputBuf_Flush_A(&out, *l2, key, all);
            } else if ((*(unsigned int *)((q) + (3))) & 0x80) {
                OutputBuf_Flush_A(&out, *l1, key, all);
                OutputBuf_Flush_A(&out, *l2, key, all);
            } else if ((*(unsigned int *)((q) + (1))) & 0x80) {
                OutputBuf_Flush_A(&out, *l1, key, all);
            } else {
                OutputBuf_Flush_A(&out, *l2, key, all);
            }
        } else *out = 0xff;
    }
}
