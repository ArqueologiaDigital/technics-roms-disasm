/* Functions of core/08_voice_noteon_and_tonegen.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern unsigned char ram_41368[];
extern unsigned char ram_41382[];
extern unsigned int ram_41360;
extern unsigned char ram_4308e[][71];
extern void Voice_Allocate_Nodes(unsigned char *v);
extern void DSP_FlushAllSlots_ForPart();
void VoiceAlloc_CheckAndInit_FromRecord(unsigned char *m);
void Voice_SetPanning(unsigned char *v);

void VoiceAlloc_CheckAndInit_FromRecord(unsigned char *m)
{
    unsigned char e;
    unsigned char t;
    e = m[1];
    if (e <= 2 || (*(unsigned int *)(ram_41368 + e * 0x11f) & 3) == 3) {
        if (*(unsigned int *)(ram_41368 + e * 0x11f) & 1) {
            *(unsigned int *)(ram_41368 + e * 0x11f) |= 1;
        } else {
            *(unsigned int *)(ram_41368 + e * 0x11f) |= 1;
            t = ram_41382[e * 0x11f];
            if (t >= 64 && t < 80) DSP_FlushAllSlots_ForPart(e);
        }
    }
}

void Voice_SetPanning(unsigned char *v)
{
    unsigned char *r;
    *(unsigned int *)v = (ram_41360 >> 8) | 0x1480;
    v[2] = 0x80;
    v[6] = 0;
    v[3] = 0;
    v[4] = 0;
    v[5] = 0;
    Voice_Allocate_Nodes(v);
    if (v[10] >= 0x40) return;
    r = ram_4308e[v[10]];
    *(unsigned int *)(r + 8) = ram_41360;
    *(unsigned int *)(r + 6) = ram_41360;
    *(unsigned int *)(r + 1) = 1;
    *(long *)(r + 19) = 0;
    *(long *)(r + 23) = 0;
    *(long *)(r + 27) = 0;
    *(long *)(r + 31) = 0;
    *(long *)(r + 39) = 0;
    r[12] = 0;
    r[4] = 0x14;
    r[5] = ram_41360 >> 8;
    r[0] = v[10];
    r[3] = 0;
    *(unsigned int *)(r + 47) = 0;
    *(unsigned int *)(r + 49) = 0xff;
    r[53] = 0;
    *(unsigned int *)(r + 54) = 0;
    *(unsigned int *)(r + 58) = 0;
    *(unsigned int *)(r + 56) = 0;
}
