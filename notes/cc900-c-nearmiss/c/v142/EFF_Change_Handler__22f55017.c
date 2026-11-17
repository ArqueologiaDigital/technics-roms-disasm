/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_D_7a.c (2026-11-16-79-sub-r7)
   sha256 22f5501791b9923dc24a181412e17aff9d6dfd27eb4cfed488e21519c2cd59d1 (name+funcs); compiled at -Xr */
struct slot { unsigned int type; unsigned int a[1]; int param[17]; int idx; int q[1]; int r42[6]; int on; };
struct cfg { unsigned int f0, f2, f4, f6; struct slot s[5]; };
struct e50 { unsigned int f0; char pad[48]; };
extern struct e50 __near ram_4940[];
extern void EFF_Disconnect(unsigned int, unsigned int);
extern void EFF_Change_WithDebug(unsigned int, unsigned int);
extern void EFF_DataChange_WithDebug(unsigned int, unsigned int);
extern void EFF_VolumeChange_Check(unsigned int, struct cfg *);
void EFF_Change_Handler(unsigned int slot, unsigned long p)
{
    if (ram_4940[slot].f0 == 1) {
        switch (slot) {
        case 2:
            if (((struct cfg *)p)->f4 == 1)
                EFF_Disconnect(slot, ((struct cfg *)p)->f6);
            break;
        default:
            EFF_Disconnect(slot, ((struct cfg *)p)->f6);
            break;
        }
        switch (slot) {
        default:
            EFF_Change_WithDebug(slot, ((struct slot *)(p + ((unsigned long)slot * 56 + 8)))->type);
            break;
        case 2: case 3: case 4:
            if (((struct cfg *)p)->f4 == 1)
                EFF_Change_WithDebug(slot, ((struct slot *)(p + ((unsigned long)slot * 56 + 8)))->type);
            else
                EFF_DataChange_WithDebug(slot, ((struct slot *)(p + ((unsigned long)slot * 56 + 8)))->type);
            break;
        }
    }
    EFF_VolumeChange_Check(slot, (struct cfg *)p);
}
