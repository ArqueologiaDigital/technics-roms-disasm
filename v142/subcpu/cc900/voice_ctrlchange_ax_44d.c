/* Functions of core/07_voice_ctrlchange.s.
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
extern unsigned char ram_4136a[];
extern unsigned char ram_4136e[];
extern unsigned char ram_430bb[];
void Voice_Env_ApplyVelocity_Type0(unsigned char a, unsigned char c);
void Voice_Env_UpdVelCounters(unsigned char a);
void Voice_NoteOn_Rhythm(unsigned char *p, unsigned char part, unsigned char key, unsigned char vel);
void Voice_Init_Type1(unsigned char n);
void ToneGen_WriteSingleReg(unsigned int reg, unsigned int v);
void VoiceSlot_NoteOff(unsigned char n);
void Voice_SetPitch(unsigned char part, unsigned char key, unsigned char vel, unsigned char w);
void Voice_NoteOff(unsigned char part, unsigned char key, unsigned char vel, unsigned char w);
void Voice_NoteOff(unsigned char part, unsigned char key, unsigned char vel, unsigned char w);
void Voice_SetPitch(unsigned char part, unsigned char key, unsigned char vel, unsigned char w);

/* cc900-name: Voice_Env_UpdVelCounters=Voice_Env_UpdateVelocityCounters */
/* cc900-module: Voice_Init_Type1 Voice_NoteOff Voice_NoteOn_Rhythm Voice_SetPitch */
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
