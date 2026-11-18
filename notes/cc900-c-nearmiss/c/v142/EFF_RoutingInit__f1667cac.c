/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AI_22a.c (2026-11-18-29-sub-r21f)
   sha256 f1667cac05ec896d30235087cc0a76bcfed9f9fea2e4a484286b1e79967f607f (tar-sha256); compiled at -Xr */
struct slotrt { unsigned char pad[26]; unsigned int w[256]; };
extern unsigned char ram_41368[];
void RoutingFlag_Encode(struct slotrt *p, unsigned char *q, unsigned char e, unsigned char slot, unsigned char ch);
void SlotRouting_WriteSingle(struct slotrt *p, unsigned char slot, unsigned char ch, unsigned char f);
void SlotRouting_Chan1(struct slotrt *p, unsigned char slot, unsigned char ch, unsigned char f);
void SlotRouting_Chan3(struct slotrt *p, unsigned char slot, unsigned char ch, unsigned char f);
#define PART_ROW(p)     ((unsigned char *)(unsigned long)(ram_41368 + (p) * 0x11f))
void EFF_RoutingInit(unsigned char part, unsigned char slot, unsigned char grp)
{
    struct slotrt *p;
    unsigned char *q;
    unsigned char k;

    p = (struct slotrt *)&PART_ROW(part)[(int)slot * 37 + 110];
    p->w[grp] = 0;
    for (k = 0; k < 4; k++) {
        q = (unsigned char *)((unsigned long)&PART_ROW(part)[(int)grp * 16 + (int)k * 4] + 39);
        if (*q & 0x0a) {
            RoutingFlag_Encode(p, q, slot, grp, k);
        } else if (*q & 5) {
            switch (grp) {
            case 0:
                SlotRouting_WriteSingle(p, grp, k, (*(unsigned char **)&PART_ROW(part)[(int)slot * 37 + 110])[6]);
                break;
            case 1:
                SlotRouting_Chan1(p, grp, k, (*(unsigned char **)&PART_ROW(part)[(int)slot * 37 + 110])[38]);
                break;
            case 2:
                SlotRouting_Chan3(p, grp, k, (*(unsigned char **)&PART_ROW(part)[(int)slot * 37 + 110])[56]);
                break;
            }
        }
    }
}
