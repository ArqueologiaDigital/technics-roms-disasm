/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/v142/dsp_voice_params_ai_21a.c (2026-11-18-21-sub-r21c-staged)
   sha256 b001dbb4de4506e7a85e41d2f2bc68d43f2af2b6a120f969e8630ff3d7d904e9 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
struct slotrt { unsigned char pad[26]; unsigned int w[256]; };
extern unsigned int SlotEnableMaskA[];
extern unsigned int SlotEnableMaskB[];
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
