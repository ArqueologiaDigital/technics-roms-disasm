/* Functions of core/10_dsp_voice_params.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern unsigned char ram_41356[];
extern unsigned char ram_41352[];
extern unsigned char ram_4135a[];
extern unsigned char ram_413d6[];
extern unsigned char ram_413fb[];
extern unsigned char ram_41420[];
extern unsigned char ram_41445[];
struct slotrt { unsigned char pad[26]; unsigned int w[256]; };
extern unsigned int SlotEnableMaskA[];
extern unsigned int SlotEnableMaskB[];
void RoutingFlag_Encode(struct slotrt *p, unsigned char *q, unsigned char e, unsigned char slot, unsigned char ch);
void Partial_Build_Present_Word(unsigned char part);
void RoutingFlag_Encode(struct slotrt *p, unsigned char *q, unsigned char e, unsigned char slot, unsigned char ch);

/* cc900-module: RoutingFlag_Encode */
void Partial_Build_Present_Word(unsigned char part)
{
    unsigned int w;
    unsigned char l;
    w = (*(unsigned int *)(ram_41352 + (part) * 0x11f)) & 0xffff3ff0;
    l = (*(unsigned char **)(ram_41356 + (part) * 0x11f))[18];
    if ((*(unsigned char **)(ram_41356 + (part) * 0x11f))[17] & 1) w |= 1;
    else if ((*(unsigned int *)(ram_4135a + (part) * 0x11f)) & 0x8000L) {
        if ((*(unsigned char **)(ram_41356 + (part) * 0x11f))[17] & 4) {
            switch ((*(unsigned char **)(ram_41356 + (part) * 0x11f))[93] & 0xf) {
            case 0: case 1: case 2: case 3: case 4: case 5: case 6: case 7: case 8:
                w |= 0x4001;
            }
        }
    }
    if ((l & 3) == 1) (*(unsigned int *)((ram_413d6) + (part) * 0x11f)) |= 0x8000;
    else (*(unsigned int *)((ram_413d6) + (part) * 0x11f)) &= 0x7fff;
    if ((*(unsigned char **)(ram_41356 + (part) * 0x11f))[17] & 4) w |= 2;
    else if ((*(unsigned int *)(ram_4135a + (part) * 0x11f)) & 0x8000L) {
        if ((*(unsigned char **)(ram_41356 + (part) * 0x11f))[17] & 1) {
            switch ((*(unsigned char **)(ram_41356 + (part) * 0x11f))[93] & 0xf) {
            case 0: case 1: case 2: case 3: case 4: case 5: case 6: case 7: case 8:
                w |= 0x8002;
            }
        }
    }
    if ((l & 0xc) == 4) (*(unsigned int *)((ram_413fb) + (part) * 0x11f)) |= 0x8000;
    else (*(unsigned int *)((ram_413fb) + (part) * 0x11f)) &= 0x7fff;
    if ((*(unsigned char **)(ram_41356 + (part) * 0x11f))[17] & 0x10) w |= 4;
    if ((l & 0x30) == 0x10) (*(unsigned int *)((ram_41420) + (part) * 0x11f)) |= 0x8000;
    else (*(unsigned int *)((ram_41420) + (part) * 0x11f)) &= 0x7fff;
    if ((*(unsigned char **)(ram_41356 + (part) * 0x11f))[17] & 0x40) w |= 8;
    if ((l & 0xc0) == 0x40) (*(unsigned int *)((ram_41445) + (part) * 0x11f)) |= 0x8000;
    else (*(unsigned int *)((ram_41445) + (part) * 0x11f)) &= 0x7fff;
    (*(unsigned int *)(ram_41352 + (part) * 0x11f)) = w;
}

void RoutingFlag_Encode(struct slotrt *p, unsigned char *q, unsigned char e, unsigned char slot, unsigned char ch)
{
    if (SlotEnableMaskA[e] & q[1]) {
        if (SlotEnableMaskB[e] & q[1]) {
            switch (slot) {
            case 0:
                p->w[slot] = (unsigned int)ch | 0xc0;
                break;
            case 1:
                p->w[slot] = ch | 0xc000;
                break;
            case 2:
                p->w[slot] = ch | 0x3300;
                break;
            }
        } else {
            switch (slot) {
            case 0:
                p->w[slot] = (unsigned int)ch | 0x40;
                break;
            case 1:
                p->w[slot] = ch | 0x4000;
                break;
            case 2:
                p->w[slot] = ch | 0x1100;
                break;
            }
        }
    }
}
