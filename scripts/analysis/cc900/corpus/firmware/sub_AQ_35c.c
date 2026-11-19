/* sub_AQ_35c.c -- lane_sub helper AQ, round 35, form c (KN5000 sub-CPU payload v1.42; core/07_voice_ctrlchange.s).
   Names are the tree's labels; ram_<hex> is a RAM cell (sub-CPU address).  No __IZ / __XIZ; inline assembly is the
   firmware's lower-case `__asm`, so the slot counter and the channel live in the XIZ family as in the ROM.

   Voice_SetVelocity (969 B, never compiled).  span_refs.py v142/subcpu/core/07_voice_ctrlchange.s Voice_SetVelocity
   Voice_Allocate: all 28 inner labels (Type0_*, Drawbar, Type40_*, DrumKit, Type80_*, Exit) are inner-only, so it
   is one C function.  Parameters (part, note, vel) in A / C / E, saved to the frame (+20, +18, +16); the source tag
   is a pushed word (+26; the caller is Voice_NoteOn's `Voice_SetVelocity(m[1], m[2], m[3], ch)`), `retd 2`.
   One frame local, the 14-byte request block at +2 that Voice_Build_Four_Partials / Voice_NoteOn_Type1 / _Type2
   fill; byte 10+i is slot i's tone-generator channel (>= 0x40: none).
   Switch on the patch byte +0x10 & 0xc0 as in the built Voice_PerVoice_PortamentoPitchUpdate; the ROM compares
   0xc0, 0x80, 0x40, 0 (V4.23 emits them in reverse source order), the 0xc0 case is empty.
   The register writes are spelled as in the built Voice_AllVoices_PortamentoReset (voice_ctrlchange_lane_23w5a.c).
   Loops whose first test reads the block byte in memory (`cp (xbc+wa),0x40`) and then use the value just stored
   to the channel (`ldfr_berp` followed by `extz wa`, no reload) are written with the assignment inside the
   expression; the others assign the channel in a statement and test the register (`cp_erpb`).
   Voice records: 0x47 bytes from 0x4308e (flags word 0x4308f, pitch word 0x430bb, busy word 0x430bd), indexed
   as char arrays (0x47 is odd).

   form a: `ch` declared before `i` (the ROM keeps the channel in QIZH, the counter in QIZL; in the built
           Voice_AllVoices_PortamentoReset the first-declared byte local got QIZH); the block passed as `buf`;
           the mode-0 pitch-fix loop as nested ifs.
   form b: `i` declared before `ch`.
   form c: as a, with `&buf[0]` as the argument and the mode-0 pitch-fix tests joined with &&.

   Voice_Build_Four_Partials (682 B) is not attempted: its AltSlotPath copies a 71-byte voice record (`ldirw` of
   0x23 words + `ldi`), the odd-size copy that is blocked (README "Round 23").

   cc900-options: -Xr
*/

extern unsigned char __tiny ram_18;
extern volatile unsigned int ram_100000;
extern unsigned int ram_100002;
extern unsigned char ram_41368[];
extern unsigned char ram_4136e[];
extern unsigned char ram_4308f[];
extern unsigned char ram_430bb[];
extern unsigned char ram_430bd[];
void Voice_Env_ApplyVelocity_Type0(unsigned char a, unsigned char c);
void Voice_Env_UpdVelCounters(unsigned char a);
void Voice_Vol_ScaleVelocityWord(void);
void Voice_ClearLFO_ActiveFlag(unsigned char part);
void Voice_WriteChPitchWithVib(unsigned char part, unsigned char slot);
void ToneGen_WriteSingleReg(int n, int v);
void Voice_Build_Four_Partials(unsigned char *p, unsigned char part, unsigned char key, unsigned char vel);
void Voice_NoteOn_Type1(unsigned char *p, unsigned char part, unsigned char key, unsigned char vel);
void Voice_NoteOn_Type2(unsigned char *p, unsigned char part, unsigned char key, unsigned char vel);
void Voice_Init_Type2(unsigned char n);
void Voice_Build_Register_Set(unsigned char n);
void Voice_Release_Type4(unsigned char n);

/* cc900-name: Voice_Env_UpdVelCounters=Voice_Env_UpdateVelocityCounters */
/* cc900-module: Voice_Build_Four_Partials Voice_Build_Register_Set Voice_Init_Type2 Voice_NoteOn_Type1 Voice_NoteOn_Type2 Voice_Release_Type4 Voice_SetVelocity */

void Voice_SetVelocity(unsigned char part, unsigned char note, unsigned char vel, unsigned char src)
{
    unsigned char ch;
    unsigned char i;
    unsigned char buf[14];

    switch ((*(unsigned char **)&ram_4136e[part * 287])[16] & 0xc0) {
    case 0:
        Voice_Env_ApplyVelocity_Type0(part, src);
        Voice_Env_UpdVelCounters(part);
        Voice_Vol_ScaleVelocityWord();
        Voice_Build_Four_Partials(&buf[0], part, note, vel);
        for (i = 0; i < 4; i++) {
            ch = buf[i + 10];
            if (ch < 0x40) {
                ram_18 &= 0x7f;
                ram_100000 = ch + 0x840;
                __asm(" nop");
                ram_18 |= 0x80;
                ram_100002 = 0xff00;
                __asm(" jr $+2");
                __asm(" nop");
                __asm(" nop");
                __asm(" nop");
                ram_18 &= 0x7f;
                ram_100000 = ch + 0x800;
                __asm(" nop");
                ram_18 |= 0x80;
                ram_100002 = 0xff80;
                __asm(" jr $+2");
                __asm(" nop");
                __asm(" nop");
                __asm(" nop");
                if (*(unsigned int *)&ram_4308f[ch * 0x47] & 2)
                    Voice_Init_Type2(ch);
                else
                    Voice_Build_Register_Set(ch);
            }
        }
        for (i = 0; i < 4; i++) {
            if (buf[i + 10] < 0x40 && *(unsigned int *)&ram_430bd[(ch = buf[i + 10]) * 0x47] == 0
                && !(*(unsigned int *)&ram_4308f[ch * 0x47] & 0x100))
                ToneGen_WriteSingleReg(ch, *(int *)&ram_430bb[ch * 0x47]);
        }
        Voice_ClearLFO_ActiveFlag(part);
        break;
    case 0x40:
        Voice_Env_ApplyVelocity_Type0(part, src);
        Voice_Env_UpdVelCounters(part);
        Voice_NoteOn_Type2(&buf[0], part, note, vel);
        for (i = 0; i < 4; i++) {
            ch = buf[i + 10];
            if (ch < 0x40) {
                ram_18 &= 0x7f;
                ram_100000 = ch + 0x840;
                __asm(" nop");
                ram_18 |= 0x80;
                ram_100002 = 0xff00;
                __asm(" jr $+2");
                __asm(" nop");
                __asm(" nop");
                __asm(" nop");
                ram_18 &= 0x7f;
                ram_100000 = ch + 0x800;
                __asm(" nop");
                ram_18 |= 0x80;
                ram_100002 = 0xff80;
                __asm(" jr $+2");
                __asm(" nop");
                __asm(" nop");
                __asm(" nop");
                Voice_Release_Type4(ch);
            }
        }
        for (i = 0; i < 4; i++) {
            ch = buf[i + 10];
            if (ch < 0x40)
                ToneGen_WriteSingleReg(ch, *(int *)&ram_430bb[ch * 0x47]);
        }
        Voice_ClearLFO_ActiveFlag(part);
        break;
    case 0x80:
        Voice_NoteOn_Type1(&buf[0], part, note, vel);
        for (i = 0; i < 2; i++) {
            ch = buf[i + 10];
            if (ch < 0x40) {
                Voice_WriteChPitchWithVib(part, ch);
                ram_18 &= 0x7f;
                ram_100000 = ch + 0x840;
                __asm(" nop");
                ram_18 |= 0x80;
                ram_100002 = 0xff00;
                __asm(" jr $+2");
                __asm(" nop");
                __asm(" nop");
                __asm(" nop");
                ram_18 &= 0x7f;
                ram_100000 = ch + 0x800;
                __asm(" nop");
                ram_18 |= 0x80;
                ram_100002 = 0xff80;
                __asm(" jr $+2");
                __asm(" nop");
                __asm(" nop");
                __asm(" nop");
                Voice_Init_Type2(ch);
            }
        }
        for (i = 0; i < 2; i++) {
            ch = buf[i + 10];
            if (ch < 0x40)
                ToneGen_WriteSingleReg(ch, *(int *)&ram_430bb[ch * 0x47]);
        }
        Voice_ClearLFO_ActiveFlag(part);
        break;
    case 0xc0:
        break;
    }
    *(unsigned int *)&ram_41368[part * 287] &= 0xfff3;
}
