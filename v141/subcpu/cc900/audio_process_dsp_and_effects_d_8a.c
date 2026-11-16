/* Functions of core/13_audio_process_dsp_and_effects.s.
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
struct e50 { unsigned int f0; char pad[48]; };
extern struct e50 __near ram_4940[];
extern void EFF_Disconnect(unsigned int, unsigned int);
extern void EFF_Change_WithDebug(unsigned int, unsigned int);
extern void EFF_DataChange_WithDebug(unsigned int, unsigned int);
extern void EFF_VolumeChange_Check(unsigned int, unsigned long);

/* cc900-module: EFF_VolumeChange_Check */
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
    EFF_VolumeChange_Check(slot, p);
}
