/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AK_23a.c (2026-11-19-11-sub-r23h-helpers)
   sha256 4a24922c9cacfd2bb26eb34d451f6c3f059d692d5b474e169b542a9dbffe7789 (name+funcs); compiled at -Xr
   cc900-options: -Xr
   cc900-name: Voice_Env_UpdVelCounters=Voice_Env_UpdateVelocityCounters */
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
void Voice_SetPitch(unsigned char part, unsigned char key, unsigned char vel, unsigned char w)
{
    unsigned char req[14];
    unsigned char s;

    if (((*(unsigned char **)(ram_4136e + (int)part * 287))[16] & 0xc0) != 0x40) return;
    if (!(*(unsigned int *)(ram_4136a + (int)part * 287) & 7)) return;
    if (vel & 0x80) return;
    Voice_Env_ApplyVelocity_Type0(part, w);
    Voice_Env_UpdVelCounters(part);
    Voice_NoteOn_Rhythm(req, part, key, vel);
    s = req[10];
    if (s < 0x40) {
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
    }
}
