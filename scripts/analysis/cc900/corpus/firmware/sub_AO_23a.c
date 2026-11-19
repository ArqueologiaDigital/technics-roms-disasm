/* lane_sub helper AO, round 23, form a (KN5000 sub-CPU payload v1.42, core/08_voice_noteon_and_tonegen.s and
   core/11_ringbuf_and_midi_dispatch.s).  Every tone-generator write in the matched writers' spelling (staged
   voice_noteon_and_tonegen_lane_23w2a.c): P6 as ram_18, latch / data port ram_100000 / ram_100002, inline assembly
   as the LOWER-CASE `__asm(" nop")` / `__asm(" jr $+2")`, so a value live across it stays in XIZ / IZ / QIZx.
   Form a: the plain spellings.
   - frame-style writers (`dec 4,xsp; pushw iz; ld (xsp+2),xbc; ld iz,wa`): plain (unsigned int reg, unsigned int *p),
     as ToneGen_WriteExtParams_56 matched.  ToneGen_WriteExtParams_15 / _56b / _15_Alt / _15_Banked / _TypeDispatch
     are ToneGen_WriteExtParams_56 / ToneGen_Write_ExtParam_05C0_Strobe / TG_WriteExtParam_TypeDisp_One with other
     register numbers and words; ToneGen_WriteLevelPair is a copy of ToneGen_WriteNote2ch, ToneGen_WriteLevelBurst of
     ToneGen_WriteVoice_6Words (same registers, same words).
   - _Ext / _Ext2 read a word at the ODD byte offset 45 of the second record: *(unsigned int *)((unsigned char *)p + 45).
   - ToneGen_WriteVoiceParams starts with a dead `ld wa,0`: an unused local, `unsigned int i = 0;`.
   - ToneGen_ReadPitch_AndScale: the data port written through the cast constant *(unsigned int *)0x100002 (the ROM
     loads 0x100002 with `ld xwa,imm` and keeps it in a frame slot across Math_Multiply32); the record is 71 bytes,
     so the index is a long product on a byte array, ram_430bb = Payload_Bss_Start+0x4245.
   - Voice_Poly_NoteOn: byte locals ch, note, vel declared in that order (the ROM keeps them in QIZH, QIZL, IZH), the
     status byte through a byte temporary s (the ROM tests the loaded E after taking the channel from it), ch reused
     as the release loop's counter (QIZH again), break out of the loop.
   - Also the dead routines that sit inside the pool rows' spans (pool sizes 194 / 591 B include them):
     ToneGen_WriteReg0840_Shadow2E, ToneGen_Write_Reg0180 / _0440 / _0480 / _04C0 (`push xiz; ld xiz,xbc`: a
     register pointer, as ToneGen_WriteVoice_EnvLevel matched), ToneGen_WriteVoice_TvfRegs_Dup and
     ToneGen_WriteReg0440_0480 (frame style).
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
void ToneGen_WriteVoiceParams(unsigned int reg, unsigned int *p);
void ToneGen_WriteGlobalConfig(unsigned int *p);
void ToneGen_WriteReg0440_0480(unsigned int reg, unsigned int *p);
void ToneGen_Write_Reg0180(unsigned int reg, register unsigned int *p);
void ToneGen_Write_Reg0440(unsigned int reg, register unsigned int *p);
void ToneGen_Write_Reg0480(unsigned int reg, register unsigned int *p);
void ToneGen_Write_Reg04C0(unsigned int reg, register unsigned int *p);
void TG_WriteExtParams_15_Banked(unsigned int reg, unsigned int *p);
void ToneGen_WriteLevelBurst(unsigned int reg, unsigned int *p);
void ToneGen_WriteLevelPair(unsigned int reg, unsigned int *p);
void ToneGen_WriteReg0840_Shadow2E(unsigned int reg, register unsigned int *p);
void TG_WriteVoice_TvfRegs_Dup(unsigned int reg, unsigned int *p);
void TG_WriteExtParams_TypeDispatch(unsigned int reg, unsigned int *p);
void ToneGen_WriteVoiceParams_Ext(unsigned int reg, unsigned int *p2, unsigned int *p3);
void ToneGen_WriteVoiceParams_Ext2(unsigned int reg, unsigned int *p);
void ToneGen_ReadPitch_AndScale(unsigned int reg, unsigned int *p);
void ToneGen_WriteExtParams_15(unsigned int reg, unsigned int *p);
void ToneGen_WriteExtParams_56b(unsigned int reg, unsigned int *p);
void ToneGen_WriteExtParams_15_Alt(unsigned int reg, unsigned int *p);
void Voice_Poly_NoteOn(unsigned char *msg);

/* cc900-name: TG_WriteExtParams_15_Banked=ToneGen_WriteExtParams_15_Banked */
/* cc900-name: TG_WriteExtParams_TypeDispatch=ToneGen_WriteExtParams_TypeDispatch */
/* cc900-name: TG_WriteVoice_TvfRegs_Dup=ToneGen_WriteVoice_TvfRegs_Dup */
void ToneGen_WriteVoiceParams(unsigned int reg, unsigned int *p)
{
    unsigned int i = 0;

    ram_18 &= ~0x80; ram_100000 = (reg + 0x40); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[1]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x80); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[2] | 0x8000); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0xc0); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[3]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x100); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[4]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x140); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[5]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x180); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[6]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x400); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[7]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x440); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[8]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x480); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[9]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x4c0); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[10]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x500); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[11]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x800); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[12]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (0x8100); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x840); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[13]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x880); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[14]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x8c0); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[15]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x900); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[16]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x940); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[17]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x980); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[18]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x9c0); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[19]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0xa00); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[20]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0xa40); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[21]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x80); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[2] & ~0x8000); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
}

void ToneGen_WriteGlobalConfig(unsigned int *p)
{
    if (ram_41343 & 8) p[0] &= ~8;
    else p[0] |= 8;
    ram_18 &= ~0x80; ram_100000 = (0x200); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[0]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (0x201); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[1]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (0x202); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[2]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (0x203); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[3]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (0x204); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[4]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (0x205); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[5]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (0xc00); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[6]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (0xc01); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[7]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (0xc02); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[8]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (0xc03); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[9]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (0xc04); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[10]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (0xc05); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[11]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (0xe00); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[12]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
}

void ToneGen_WriteReg0440_0480(unsigned int reg, unsigned int *p)
{
    ram_18 &= ~0x80; ram_100000 = (reg + 1088); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[8]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 1152); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[9]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
}

void ToneGen_Write_Reg0180(unsigned int reg, register unsigned int *p)
{
    ram_18 &= ~0x80; ram_100000 = (reg + 384); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[6]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
}

void ToneGen_Write_Reg0440(unsigned int reg, register unsigned int *p)
{
    ram_18 &= ~0x80; ram_100000 = (reg + 1088); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[8]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
}

void ToneGen_Write_Reg0480(unsigned int reg, register unsigned int *p)
{
    ram_18 &= ~0x80; ram_100000 = (reg + 1152); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[9]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
}

void ToneGen_Write_Reg04C0(unsigned int reg, register unsigned int *p)
{
    ram_18 &= ~0x80; ram_100000 = (reg + 1216); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[10]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
}

void TG_WriteExtParams_15_Banked(unsigned int reg, unsigned int *p)
{
    if (reg < 64) {
        if (p[29] & 0x8000) {
            ram_18 &= ~0x80; ram_100000 = (reg + 0x540); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[29]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
        }
        ram_18 &= ~0x80; ram_100000 = (reg + 448); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[28]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
        ram_18 &= ~0x80; ram_100000 = (reg + 0x540); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[29] & ~0x8000); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    } else {
        if (p[31] & 0x8000) {
            ram_18 &= ~0x80; ram_100000 = (reg + 0x580); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[31]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
        }
        ram_18 &= ~0x80; ram_100000 = (reg + 1536); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[33]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
        ram_18 &= ~0x80; ram_100000 = (reg + 0x580); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[31] & ~0x8000); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    }
}

void ToneGen_WriteLevelBurst(unsigned int reg, unsigned int *p)
{
    ram_18 &= ~0x80; ram_100000 = (reg + 0x840); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[23]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x940); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[25]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0xa00); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[27]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x800); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[22]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x900); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[24]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x9c0); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[26]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
}

void ToneGen_WriteLevelPair(unsigned int reg, unsigned int *p)
{
    ram_18 &= ~0x80; ram_100000 = (reg + 0x840); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[23]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x800); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[22]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
}

void ToneGen_WriteReg0840_Shadow2E(unsigned int reg, register unsigned int *p)
{
    ram_18 &= ~0x80; ram_100000 = (reg + 2112); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[23]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
}

void TG_WriteVoice_TvfRegs_Dup(unsigned int reg, unsigned int *p)
{
    ram_18 &= ~0x80; ram_100000 = (reg + 256); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[4]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 320); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[5]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
}

void TG_WriteExtParams_TypeDispatch(unsigned int reg, unsigned int *p)
{
    if (reg < 0x40) {
        if (p[29] & 0x8000) {
            ram_18 &= ~0x80; ram_100000 = (reg + 0x540); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[29]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
        }
        ram_18 &= ~0x80; ram_100000 = (reg + 0x540); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[29] & ~0x8000); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    } else {
        if (p[31] & 0x8000) {
            ram_18 &= ~0x80; ram_100000 = (reg + 0x580); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[31]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
        }
        ram_18 &= ~0x80; ram_100000 = (reg + 0x580); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[31] & ~0x8000); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    }
}

void ToneGen_WriteVoiceParams_Ext(unsigned int reg, unsigned int *p2, unsigned int *p3)
{
    ram_18 &= ~0x80; ram_100000 = (reg + 0x800); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p3[30]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (0x8100); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x840); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p3[31]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x80); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p2[2] & ~0x8000); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (*(unsigned int *)((unsigned char *)p3 + 45)); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
}

void ToneGen_WriteVoiceParams_Ext2(unsigned int reg, unsigned int *p)
{
    ram_18 &= ~0x80; ram_100000 = (reg + 0x800); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[30]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (0x8100); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x840); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[31]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (*(unsigned int *)((unsigned char *)p + 45)); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
}

void ToneGen_ReadPitch_AndScale(unsigned int reg, unsigned int *p)
{
    ram_18 &= ~0x80; ram_100000 = (reg + 0xc0); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[3]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg); __asm(" nop"); ram_18 |= 0x80;
    *(unsigned int *)0x100002 = *(unsigned int *)(ram_430bb + (unsigned long)reg * 71) & ~0x8000;
    __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
}

void ToneGen_WriteExtParams_15(unsigned int reg, unsigned int *p)
{
    if (p[29] & 0x8000) {
        ram_18 &= ~0x80; ram_100000 = (reg + 0x540); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[29]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    }
    ram_18 &= ~0x80; ram_100000 = (reg + 0x1c0); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[28]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x540); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[29] & ~0x8000); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
}

void ToneGen_WriteExtParams_56b(unsigned int reg, unsigned int *p)
{
    if (p[31] & 0x8000) {
        ram_18 &= ~0x80; ram_100000 = (reg + 0x5c0); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[31]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    }
    ram_18 &= ~0x80; ram_100000 = (reg + 0x640); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[33]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x5c0); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[31] & ~0x8000); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
}

void ToneGen_WriteExtParams_15_Alt(unsigned int reg, unsigned int *p)
{
    if (p[29] & 0x8000) {
        ram_18 &= ~0x80; ram_100000 = (reg + 0x540); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[29]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    }
    ram_18 &= ~0x80; ram_100000 = (reg + 0x540); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[29] & ~0x8000); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
}

void Voice_Poly_NoteOn(unsigned char *msg)
{
    unsigned char ch;
    unsigned char note;
    unsigned char vel;
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
                break;
            }
        }
    }
}
