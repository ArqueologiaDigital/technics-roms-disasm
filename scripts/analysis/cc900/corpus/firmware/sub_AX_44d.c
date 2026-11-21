/* lane_sub helper AX, round 44, form d (KN5000 sub-CPU payload v1.42, core/07_voice_ctrlchange.s).
   Voice_SetPitch and Voice_NoteOff, from sub_AK_23a.c (run 2026-11-19-11-sub-r23h-helpers).  Its only real
   difference, in both functions, is the request record's address: the ROM builds it in XWA first, keeps it in XHL
   while the other arguments are loaded and moves it back for the call; V4.23 built it last.  Round 39's lesson: an
   address the ROM builds in XWA and copies to another register is an address expression.
   form d: the record passed as &req[0].  (Form e: (unsigned char *)(void *)req; form f: through a pointer local.)
   Everything else as sub_AK_23a.c (the slot read into s, then tested; byte callee parameters), with the inline
   assembly spelled as the built files spell it (`__asm(" nop")`). */

extern unsigned char __tiny ram_18;
extern unsigned int ram_100000;
extern unsigned int ram_100002;
extern unsigned char ram_4136a[];
extern unsigned char ram_4136e[];
extern unsigned char ram_430bb[];

/* cc900-name: Voice_Env_UpdVelCounters=Voice_Env_UpdateVelocityCounters */
void Voice_Env_ApplyVelocity_Type0(unsigned char a, unsigned char c);
void Voice_Env_UpdVelCounters(unsigned char a);
void Voice_NoteOn_Rhythm(unsigned char *p, unsigned char part, unsigned char key, unsigned char vel);
void Voice_Init_Type1(unsigned char n);
void ToneGen_WriteSingleReg(unsigned int reg, unsigned int v);
void VoiceSlot_NoteOff(unsigned char n);
void Voice_SetPitch(unsigned char part, unsigned char key, unsigned char vel, unsigned char w);
void Voice_NoteOff(unsigned char part, unsigned char key, unsigned char vel, unsigned char w);

/* cc900-module: Voice_SetPitch Voice_NoteOff Voice_NoteOn_Rhythm Voice_Init_Type1 */
void Voice_SetPitch(unsigned char part, unsigned char key, unsigned char vel, unsigned char w)
{
    unsigned char req[14];
    unsigned char s;

    if (((*(unsigned char **)(ram_4136e + (int)part * 287))[16] & 0xc0) != 0x40) return;
    if (!(*(unsigned int *)(ram_4136a + (int)part * 287) & 7)) return;
    if (vel & 0x80) return;
    Voice_Env_ApplyVelocity_Type0(part, w);
    Voice_Env_UpdVelCounters(part);
    Voice_NoteOn_Rhythm(&req[0], part, key, vel);
    s = req[10];
    if (s < 0x40) {
        ram_18 &= ~0x80;
        ram_100000 = s + 0x840;
        __asm(" nop");
        ram_18 |= 0x80;
        ram_100002 = 0xff00;
        __asm(" jr $+2");
        __asm(" nop");
        __asm(" nop");
        __asm(" nop");
        ram_18 &= ~0x80;
        ram_100000 = s + 0x800;
        __asm(" nop");
        ram_18 |= 0x80;
        ram_100002 = 0xff80;
        __asm(" jr $+2");
        __asm(" nop");
        __asm(" nop");
        __asm(" nop");
        Voice_Init_Type1(s);
        ToneGen_WriteSingleReg(s, *(unsigned int *)&ram_430bb[(int)s * 71]);
    }
}

void Voice_NoteOff(unsigned char part, unsigned char key, unsigned char vel, unsigned char w)
{
    unsigned char req[14];
    unsigned char s;

    if (((*(unsigned char **)(ram_4136e + (int)part * 287))[16] & 0xc0) != 0x40) return;
    if (!(*(unsigned int *)(ram_4136a + (int)part * 287) & 7)) return;
    Voice_Env_ApplyVelocity_Type0(part, w);
    Voice_Env_UpdVelCounters(part);
    Voice_NoteOn_Rhythm(&req[0], part, key, vel);
    s = req[11];
    if (s < 0x40) {
        ram_18 &= ~0x80;
        ram_100000 = s + 0x840;
        __asm(" nop");
        ram_18 |= 0x80;
        ram_100002 = 0xff00;
        __asm(" jr $+2");
        __asm(" nop");
        __asm(" nop");
        __asm(" nop");
        ram_18 &= ~0x80;
        ram_100000 = s + 0x800;
        __asm(" nop");
        ram_18 |= 0x80;
        ram_100002 = 0xff80;
        __asm(" jr $+2");
        __asm(" nop");
        __asm(" nop");
        __asm(" nop");
        Voice_Init_Type1(s);
        ToneGen_WriteSingleReg(s, *(unsigned int *)&ram_430bb[(int)s * 71]);
        VoiceSlot_NoteOff(s);
    }
}
