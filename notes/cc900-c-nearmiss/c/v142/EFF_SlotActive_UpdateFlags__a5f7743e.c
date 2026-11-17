/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_D_2a.c (2026-11-16-47-sub-r2)
   sha256 a5f7743e23bc8f55cc179cb7f13b9bea660c20e46906cee3cecdd47bc3068a8c (name+funcs); compiled at -Xr */
struct slot { unsigned int type; int f2; int param[25]; int on; };
struct cfg { unsigned int f0, f2, f4, f6; struct slot s[5]; };
struct e50 { unsigned int f0; char pad[48]; };
struct o16 { char pad[16]; unsigned int v; char pad2[32]; };
extern unsigned int __near ram_4930[];
extern unsigned int __near ram_493e;
extern struct e50 __near ram_4940[];
extern int __near ram_4944[][25];
extern struct o16 __near ram_4958[];
extern struct o16 __near ram_495a[];
extern struct o16 __near ram_495c[];
extern struct o16 __near ram_4960[];
void EFF_SlotActive_UpdateFlags(struct cfg *p)
{
    unsigned int i;
    unsigned int found;

    found = 0;
    if (ram_493e == 1) {
        for (i = 0; i < 5; i++)
            ram_4930[i] = 1;
    } else {
        for (i = 0; i < 5; i++) {
            switch (p->s[i].type) {
            case 0x46: case 0x45: case 0x34: case 0x33:
                found = 1;
            }
            if (ram_4940[i].f0 == 1 || (p->f0 == 1 && ram_4960[i].v == 1) || (ram_4960[i].v == 1 && found == 1)) {
                ram_4930[i] = 1;
                ram_4944[i][p->s[i].param[17]] = 1;
                ram_495a[i].v = 1;
                ram_495c[i].v = 1;
                ram_4960[i].v = 1;
                if (p->s[i].param[22] != 0x63)
                    ram_4958[i].v = 1;
            } else
                ram_4930[i] = 0;
        }
    }
}
