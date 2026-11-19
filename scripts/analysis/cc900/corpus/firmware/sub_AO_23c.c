/* lane_sub helper AO, round 23, form c (same functions as sub_AO_23a.c; read its header first).
   Form c changes:
   - every record as struct tgv { unsigned int w[36]; } * (p->w[N]); frame-style writers plain parameters,
     register-pointer dead routines `register struct tgv *p`;
   - _Ext / _Ext2: the odd word as ((unsigned int *)((char *)p + 45))[0];
   - ToneGen_WriteVoiceParams: the dead `ld wa,0` as an expression statement `0;`;
   - ToneGen_ReadPitch_AndScale: pointer local q as in form b, the product signed ((long)reg * 71) and the mask
     written & 0x7fff;
   - Voice_Poly_NoteOn: byte locals declared vel, note, ch, s (reverse order), `return` instead of `break` in the
     release loop.
   cc900-options: -Xr
*/

extern unsigned char __tiny ram_18;            /* P6 (sfr_tmp94c241.s) */
extern unsigned int ram_100000;                 /* ToneGen_RegAddrLatch */
extern unsigned int ram_100002;                 /* ToneGen_RegDataPort */
extern unsigned int ram_41343;                  /* Voice_GlobalFlags */
extern unsigned char ram_430bb[];               /* Payload_Bss_Start+0x4245: 71-byte records */
extern unsigned char __near ram_3b13;           /* the poly round-robin slot, 0..7 */
extern unsigned char __near ram_3b14[];         /* per slot: note | 0x80 while sounding */
extern void (*Voice_PolyNoteOn_Setup_PtrTable[])(int, int, int, int);
struct tgv { unsigned int w[36]; };
void ToneGen_WriteVoiceParams(unsigned int reg, struct tgv *p);
void ToneGen_WriteGlobalConfig(struct tgv *p);
void ToneGen_WriteReg0440_0480(unsigned int reg, struct tgv *p);
void ToneGen_Write_Reg0180(unsigned int reg, register struct tgv *p);
void ToneGen_Write_Reg0440(unsigned int reg, register struct tgv *p);
void ToneGen_Write_Reg0480(unsigned int reg, register struct tgv *p);
void ToneGen_Write_Reg04C0(unsigned int reg, register struct tgv *p);
void TG_WriteExtParams_15_Banked(unsigned int reg, struct tgv *p);
void ToneGen_WriteLevelBurst(unsigned int reg, struct tgv *p);
void ToneGen_WriteLevelPair(unsigned int reg, struct tgv *p);
void ToneGen_WriteReg0840_Shadow2E(unsigned int reg, register struct tgv *p);
void TG_WriteVoice_TvfRegs_Dup(unsigned int reg, struct tgv *p);
void TG_WriteExtParams_TypeDispatch(unsigned int reg, struct tgv *p);
void ToneGen_WriteVoiceParams_Ext(unsigned int reg, struct tgv *p2, struct tgv *p3);
void ToneGen_WriteVoiceParams_Ext2(unsigned int reg, struct tgv *p);
void ToneGen_ReadPitch_AndScale(unsigned int reg, struct tgv *p);
void ToneGen_WriteExtParams_15(unsigned int reg, struct tgv *p);
void ToneGen_WriteExtParams_56b(unsigned int reg, struct tgv *p);
void ToneGen_WriteExtParams_15_Alt(unsigned int reg, struct tgv *p);
void Voice_Poly_NoteOn(unsigned char *msg);

/* cc900-name: TG_WriteExtParams_15_Banked=ToneGen_WriteExtParams_15_Banked */
/* cc900-name: TG_WriteExtParams_TypeDispatch=ToneGen_WriteExtParams_TypeDispatch */
/* cc900-name: TG_WriteVoice_TvfRegs_Dup=ToneGen_WriteVoice_TvfRegs_Dup */
void ToneGen_WriteVoiceParams(unsigned int reg, struct tgv *p)
{
    0;
    ram_18 &= ~0x80; ram_100000 = (reg + 0x40); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[1]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x80); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[2] | 0x8000); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0xc0); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[3]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x100); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[4]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x140); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[5]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x180); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[6]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x400); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[7]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x440); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[8]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x480); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[9]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x4c0); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[10]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x500); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[11]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x800); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[12]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (0x8100); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x840); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[13]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x880); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[14]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x8c0); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[15]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x900); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[16]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x940); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[17]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x980); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[18]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x9c0); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[19]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0xa00); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[20]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0xa40); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[21]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x80); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[2] & ~0x8000); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
}

void ToneGen_WriteGlobalConfig(struct tgv *p)
{
    if (ram_41343 & 8) p->w[0] &= ~8;
    else p->w[0] |= 8;
    ram_18 &= ~0x80; ram_100000 = (0x200); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[0]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (0x201); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[1]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (0x202); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[2]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (0x203); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[3]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (0x204); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[4]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (0x205); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[5]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (0xc00); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[6]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (0xc01); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[7]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (0xc02); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[8]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (0xc03); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[9]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (0xc04); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[10]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (0xc05); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[11]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (0xe00); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[12]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
}

void ToneGen_WriteReg0440_0480(unsigned int reg, struct tgv *p)
{
    ram_18 &= ~0x80; ram_100000 = (reg + 1088); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[8]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 1152); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[9]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
}

void ToneGen_Write_Reg0180(unsigned int reg, register struct tgv *p)
{
    ram_18 &= ~0x80; ram_100000 = (reg + 384); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[6]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
}

void ToneGen_Write_Reg0440(unsigned int reg, register struct tgv *p)
{
    ram_18 &= ~0x80; ram_100000 = (reg + 1088); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[8]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
}

void ToneGen_Write_Reg0480(unsigned int reg, register struct tgv *p)
{
    ram_18 &= ~0x80; ram_100000 = (reg + 1152); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[9]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
}

void ToneGen_Write_Reg04C0(unsigned int reg, register struct tgv *p)
{
    ram_18 &= ~0x80; ram_100000 = (reg + 1216); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[10]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
}

void TG_WriteExtParams_15_Banked(unsigned int reg, struct tgv *p)
{
    if (reg < 64) {
        if (p->w[29] & 0x8000) {
            ram_18 &= ~0x80; ram_100000 = (reg + 0x540); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[29]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
        }
        ram_18 &= ~0x80; ram_100000 = (reg + 448); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[28]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
        ram_18 &= ~0x80; ram_100000 = (reg + 0x540); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[29] & ~0x8000); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    } else {
        if (p->w[31] & 0x8000) {
            ram_18 &= ~0x80; ram_100000 = (reg + 0x580); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[31]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
        }
        ram_18 &= ~0x80; ram_100000 = (reg + 1536); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[33]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
        ram_18 &= ~0x80; ram_100000 = (reg + 0x580); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[31] & ~0x8000); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    }
}

void ToneGen_WriteLevelBurst(unsigned int reg, struct tgv *p)
{
    ram_18 &= ~0x80; ram_100000 = (reg + 0x840); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[23]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x940); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[25]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0xa00); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[27]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x800); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[22]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x900); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[24]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x9c0); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[26]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
}

void ToneGen_WriteLevelPair(unsigned int reg, struct tgv *p)
{
    ram_18 &= ~0x80; ram_100000 = (reg + 0x840); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[23]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x800); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[22]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
}

void ToneGen_WriteReg0840_Shadow2E(unsigned int reg, register struct tgv *p)
{
    ram_18 &= ~0x80; ram_100000 = (reg + 2112); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[23]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
}

void TG_WriteVoice_TvfRegs_Dup(unsigned int reg, struct tgv *p)
{
    ram_18 &= ~0x80; ram_100000 = (reg + 256); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[4]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 320); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[5]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
}

void TG_WriteExtParams_TypeDispatch(unsigned int reg, struct tgv *p)
{
    if (reg < 0x40) {
        if (p->w[29] & 0x8000) {
            ram_18 &= ~0x80; ram_100000 = (reg + 0x540); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[29]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
        }
        ram_18 &= ~0x80; ram_100000 = (reg + 0x540); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[29] & ~0x8000); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    } else {
        if (p->w[31] & 0x8000) {
            ram_18 &= ~0x80; ram_100000 = (reg + 0x580); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[31]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
        }
        ram_18 &= ~0x80; ram_100000 = (reg + 0x580); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[31] & ~0x8000); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    }
}

void ToneGen_WriteVoiceParams_Ext(unsigned int reg, struct tgv *p2, struct tgv *p3)
{
    ram_18 &= ~0x80; ram_100000 = (reg + 0x800); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p3->w[30]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (0x8100); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x840); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p3->w[31]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x80); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p2->w[2] & ~0x8000); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (((unsigned int *)((char *)p3 + 45))[0]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
}

void ToneGen_WriteVoiceParams_Ext2(unsigned int reg, struct tgv *p)
{
    ram_18 &= ~0x80; ram_100000 = (reg + 0x800); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[30]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (0x8100); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x840); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[31]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (((unsigned int *)((char *)p + 45))[0]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
}

void ToneGen_ReadPitch_AndScale(unsigned int reg, struct tgv *p)
{
    unsigned int *q;

    ram_18 &= ~0x80; ram_100000 = (reg + 0xc0); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[3]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg); __asm(" nop"); ram_18 |= 0x80;
    q = (unsigned int *)0x100002;
    *q = *(unsigned int *)(ram_430bb + (long)reg * 71) & 0x7fff;
    __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
}

void ToneGen_WriteExtParams_15(unsigned int reg, struct tgv *p)
{
    if (p->w[29] & 0x8000) {
        ram_18 &= ~0x80; ram_100000 = (reg + 0x540); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[29]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    }
    ram_18 &= ~0x80; ram_100000 = (reg + 0x1c0); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[28]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x540); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[29] & ~0x8000); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
}

void ToneGen_WriteExtParams_56b(unsigned int reg, struct tgv *p)
{
    if (p->w[31] & 0x8000) {
        ram_18 &= ~0x80; ram_100000 = (reg + 0x5c0); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[31]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    }
    ram_18 &= ~0x80; ram_100000 = (reg + 0x640); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[33]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x5c0); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[31] & ~0x8000); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
}

void ToneGen_WriteExtParams_15_Alt(unsigned int reg, struct tgv *p)
{
    if (p->w[29] & 0x8000) {
        ram_18 &= ~0x80; ram_100000 = (reg + 0x540); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[29]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    }
    ram_18 &= ~0x80; ram_100000 = (reg + 0x540); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[29] & ~0x8000); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
}

void Voice_Poly_NoteOn(unsigned char *msg)
{
    unsigned char vel;
    unsigned char note;
    unsigned char ch;
    unsigned char s;

    s = msg[1];
    ch = s & 0x0f;
    if (s < 0xf0) return;
    if (ch > 5) ch = 0;
    ram_3b13 = (ram_3b13 + 1) & 7;
    vel = msg[3] & 0x7f;
    note = msg[2] & 0x7f;
    if (vel != 0) {
        ram_18 &= ~0x80; ram_100000 = (ram_3b13 + 0x840); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (0xff00); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
        ram_18 &= ~0x80; ram_100000 = (ram_3b13 + 0x800); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (0xff80); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
        Voice_PolyNoteOn_Setup_PtrTable[ch](ram_3b13, ch, note, vel);
        ram_3b14[ram_3b13] = note | 0x80;
    } else {
        note |= 0x80;
        for (ch = 0; ch < 8; ch++) {
            if (ram_3b14[ch] == note) {
                ram_18 &= ~0x80; ram_100000 = (ch + 0x840); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (0xa200); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
                ram_18 &= ~0x80; ram_100000 = (ch + 0x800); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (0xa280); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
                ram_3b14[ch] &= ~0x80;
                return;
            }
        }
    }
}
