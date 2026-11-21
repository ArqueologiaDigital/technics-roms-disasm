/* Functions of core/06_voice_envelopes_and_channels.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern unsigned char __tiny ram_18;
extern unsigned int ram_100000;
extern unsigned int ram_100002;
extern unsigned char ram_41376[];
extern unsigned int ram_451b4[];
extern void Voice_ApplyPortamento(unsigned char *v);
extern void ToneGen_WriteExprReg(unsigned int reg, unsigned int v);
extern void ToneGen_WriteVoiceParams_Ext(unsigned int reg, unsigned int *p, unsigned char *v);
extern void ToneGen_WriteVoiceParams_Ext2(unsigned int reg, unsigned char *v);
extern void Voice_Clear_HoldBit(int ch);
extern void Voice_Reload_Levels(int ch);
void Voice_Step_ExprRamp(unsigned char *v);

/* cc900-module: Voice_ApplyPortamento Voice_Step_ExprRamp */
void Voice_Step_ExprRamp(unsigned char *v)
{
    int z;
    volatile unsigned int s;
    unsigned int u;
    u = *(unsigned int *)(v + 49);
    s = u;
    if ((u & 0x7f) == 0) {
        s |= v[53];
        s ^= 0x800;
        if (s & 0x800) {
            if (ram_41376[v[4] * 0x11f] == 1)
                ToneGen_WriteExprReg(*v, *(unsigned int *)(v + 43));
            else if (ram_41376[v[4] * 0x11f] == 2)
                ToneGen_WriteExprReg(*v, *(unsigned int *)(v + 43));
            else
                ToneGen_WriteExprReg(*v, (*(unsigned int *)(v + 43) & 0xff80) | (*(unsigned char **)(v + 39))[36]);
        } else
            ToneGen_WriteExprReg(*v, *(unsigned int *)(v + 43));
        switch (s & 0x7000) {
        case 0x4000:
            z = *(int *)(v + 54);
            z += *(int *)(v + 51);
            if (z <= -256) {
                *(int *)(v + 51) = 0xff00;
                Voice_Clear_HoldBit(*v);
                Voice_Reload_Levels(*v);
                s &= 0x6fff;
            } else {
                ram_18 &= ~0x80;
                ram_100000 = *v + 0x840;
                __asm(" nop");
                ram_18 |= 0x80;
                ram_100002 = 0xff00;
                __asm(" jr $+2");
                __asm(" nop");
                __asm(" nop");
                __asm(" nop");
                ram_18 &= ~0x80;
                ram_100000 = *v + 0x800;
                __asm(" nop");
                ram_18 |= 0x80;
                ram_100002 = 0xff80;
                __asm(" jr $+2");
                __asm(" nop");
                __asm(" nop");
                __asm(" nop");
                if (z < *(int *)(v + 58)) {
                    z = *(int *)(v + 58);
                    s &= ~0x4000;
                    s |= 0x2000;
                }
                *(int *)(v + 51) = z;
                Voice_ApplyPortamento(v);
                ToneGen_WriteVoiceParams_Ext(*v, ram_451b4, v);
            }
            break;
        case 0x2000:
            ram_18 &= ~0x80;
            ram_100000 = *v + 0x840;
            __asm(" nop");
            ram_18 |= 0x80;
            ram_100002 = 0xff00;
            __asm(" jr $+2");
            __asm(" nop");
            __asm(" nop");
            __asm(" nop");
            ram_18 &= ~0x80;
            ram_100000 = *v + 0x800;
            __asm(" nop");
            ram_18 |= 0x80;
            ram_100002 = 0xff80;
            __asm(" jr $+2");
            __asm(" nop");
            __asm(" nop");
            __asm(" nop");
            ToneGen_WriteVoiceParams_Ext2(*v, v);
            break;
        case 0x1000:
            z = *(int *)(v + 56);
            z += *(int *)(v + 51);
            if (z <= -256) {
                *(int *)(v + 51) = 0xff00;
                Voice_Clear_HoldBit(*v);
                Voice_Reload_Levels(*v);
                s &= 0x6fff;
            } else {
                ram_18 &= ~0x80;
                ram_100000 = *v + 0x840;
                __asm(" nop");
                ram_18 |= 0x80;
                ram_100002 = 0xff00;
                __asm(" jr $+2");
                __asm(" nop");
                __asm(" nop");
                __asm(" nop");
                ram_18 &= ~0x80;
                ram_100000 = *v + 0x800;
                __asm(" nop");
                ram_18 |= 0x80;
                ram_100002 = 0xff80;
                __asm(" jr $+2");
                __asm(" nop");
                __asm(" nop");
                __asm(" nop");
                *(int *)(v + 51) = z;
                Voice_ApplyPortamento(v);
                ToneGen_WriteVoiceParams_Ext(*v, ram_451b4, v);
            }
            break;
        default:
            s = 0;
            break;
        }
    } else if ((s & 0x7f) == 1) {
        ram_18 &= ~0x80;
        ram_100000 = *v + 0x840;
        __asm(" nop");
        ram_18 |= 0x80;
        ram_100002 = 0xa200;
        __asm(" jr $+2");
        __asm(" nop");
        __asm(" nop");
        __asm(" nop");
        ram_18 &= ~0x80;
        ram_100000 = *v + 0x800;
        __asm(" nop");
        ram_18 |= 0x80;
        ram_100002 = 0xa280;
        __asm(" jr $+2");
        __asm(" nop");
        __asm(" nop");
        __asm(" nop");
        s--;
    } else s--;
    *(unsigned int *)(v + 49) = s;
}
