/* lane_sub, round 23, form p1 (KN5000 sub-CPU payload v1.42), 2026-11-19.
   The tone-generator writers keep their record pointer in XIZ (pushed) across the inline nops, where V4.23 with
   __ASM("...") keeps it in the scratch register it arrived in (sub_C_7f: even a `register` copy is merged into XBC;
   Voice_AllVoices_PortamentoReset: V4.23 holds p in XBC, the ROM in XIZ).  So the firmware's inline assembly may
   have been a block V4.23 treats as clobbering the scratch registers: here `#pragma asm` / `#pragma endasm`
   instead of __ASM.  A file of its own: if V4.23 does not know the pragma, the assembly lines are a syntax error.
   cc900-options: -Xr */

extern unsigned char __tiny ram_18;            /* P6 (sfr_tmp94c241.s) */
extern unsigned int ram_100000;                 /* ToneGen_RegAddrLatch */
extern unsigned int ram_100002;                 /* ToneGen_RegDataPort */
extern void Voice_NoteState_Clear(int n);
extern unsigned char *Voice_Query_AllChannels(void);

void ToneGen_WriteVoice_Reg07(unsigned int ch, unsigned int *p)
{
    ram_18 &= ~0x80;
    ram_100000 = ch + 448;
#pragma asm
	nop
#pragma endasm
    ram_18 |= 0x80;
    ram_100002 = p[28];
#pragma asm
	jr	$+2
	nop
	nop
	nop
#pragma endasm
}

void ToneGen_WriteVoice_Short(unsigned int ch, unsigned int *p)
{
    ram_18 &= ~0x80;
    ram_100000 = ch + 0x80;
#pragma asm
	nop
#pragma endasm
    ram_18 |= 0x80;
    ram_100002 = p[2] & 0x7fff;
#pragma asm
	jr	$+2
	nop
	nop
	nop
#pragma endasm
}

void Voice_AllVoices_PortamentoReset(void)
{
    unsigned char i;
    unsigned char *p;
    for (i = 0; i < 0x1a; i++) Voice_NoteState_Clear(i);
    p = (unsigned char *)Voice_Query_AllChannels() + 5;
    for (; *p < 0x40; p++) {
        ram_18 &= 0x7f;
        ram_100000 = *p + 0x840;
#pragma asm
	nop
#pragma endasm
        ram_18 |= 0x80;
        ram_100002 = 0xa200;
#pragma asm
	jr	$+2
	nop
	nop
	nop
#pragma endasm
        ram_18 &= 0x7f;
        ram_100000 = *p + 0x800;
#pragma asm
	nop
#pragma endasm
        ram_18 |= 0x80;
        ram_100002 = 0xa280;
#pragma asm
	jr	$+2
	nop
	nop
	nop
#pragma endasm
    }
}
