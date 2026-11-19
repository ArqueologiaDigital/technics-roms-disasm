/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AK_23c.c (2026-11-19-11-sub-r23h-helpers)
   sha256 65cbfbbe65fa282d080e419a18a57186237b2fde7a8580acbb4d99f475fc1845 (name+funcs); compiled at -Xr
   cc900-options: -Xr
   cc900-name: Voice_Env_UpdVelCounters=Voice_Env_UpdateVelocityCounters */
extern unsigned char __tiny ram_18;
extern unsigned int ram_100000;
extern unsigned int ram_100002;
extern unsigned char ram_4136a[];
extern unsigned char ram_4136e[];
extern unsigned char ram_430bb[];
void Voice_Env_ApplyVelocity_Type0(int a, int c);
void Voice_Env_UpdVelCounters(int a);
void Voice_NoteOn_Rhythm(unsigned char *p, int part, int key, int vel);
void Voice_Init_Type1(int n);
void ToneGen_WriteSingleReg(int reg, unsigned int v);
void VoiceSlot_NoteOff(int n);
void Voice_NoteOff(unsigned char part, unsigned char key, unsigned char vel, unsigned char w)
{
    unsigned char req[14];
    unsigned char s;

    if (((*(unsigned char **)(ram_4136e + (int)part * 287))[16] & 0xc0) != 0x40) return;
    if (!(*(unsigned int *)(ram_4136a + (int)part * 287) & 7)) return;
    Voice_Env_ApplyVelocity_Type0(part, w);
    Voice_Env_UpdVelCounters(part);
    Voice_NoteOn_Rhythm(req, part, key, vel);
    if ((s = req[11]) < 0x40) {
        ram_18 &= ~0x80;
        ram_100000 = s + 0x840;
        __asm("nop");
        ram_18 |= 0x80;
        ram_100002 = 0xff00;
        __asm("jr $+2");
        __asm("nop");
        __asm("nop");
        __asm("nop");
        ram_18 &= ~0x80;
        ram_100000 = s + 0x800;
        __asm("nop");
        ram_18 |= 0x80;
        ram_100002 = 0xff80;
        __asm("jr $+2");
        __asm("nop");
        __asm("nop");
        __asm("nop");
        Voice_Init_Type1(s);
        ToneGen_WriteSingleReg(s, *(unsigned int *)&ram_430bb[(int)s * 71]);
        VoiceSlot_NoteOff(s);
    }
}
