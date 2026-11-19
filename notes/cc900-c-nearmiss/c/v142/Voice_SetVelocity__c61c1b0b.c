/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AQ_35b.c (2026-11-19-67-sub-r35q)
   sha256 c61c1b0b2f3ab160045642cb9432dcf379eeb9dbd9a40759d2614c85ba18da6a (name+funcs); compiled at -Xr
   cc900-options: -Xr
   cc900-name: Voice_Env_UpdVelCounters=Voice_Env_UpdateVelocityCounters */
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
void Voice_SetVelocity(unsigned char part, unsigned char note, unsigned char vel, unsigned char src)
{
    unsigned char i;
    unsigned char ch;
    unsigned char buf[14];

    switch ((*(unsigned char **)&ram_4136e[part * 287])[16] & 0xc0) {
    case 0:
        Voice_Env_ApplyVelocity_Type0(part, src);
        Voice_Env_UpdVelCounters(part);
        Voice_Vol_ScaleVelocityWord();
        Voice_Build_Four_Partials(buf, part, note, vel);
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
            if (buf[i + 10] < 0x40) {
                if (*(unsigned int *)&ram_430bd[(ch = buf[i + 10]) * 0x47] == 0) {
                    if (!(*(unsigned int *)&ram_4308f[ch * 0x47] & 0x100))
                        ToneGen_WriteSingleReg(ch, *(int *)&ram_430bb[ch * 0x47]);
                }
            }
        }
        Voice_ClearLFO_ActiveFlag(part);
        break;
    case 0x40:
        Voice_Env_ApplyVelocity_Type0(part, src);
        Voice_Env_UpdVelCounters(part);
        Voice_NoteOn_Type2(buf, part, note, vel);
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
        Voice_NoteOn_Type1(buf, part, note, vel);
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
