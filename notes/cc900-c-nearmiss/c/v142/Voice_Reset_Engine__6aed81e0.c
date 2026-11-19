/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AP_32b.c (2026-11-19-52-sub-r32a)
   sha256 6aed81e0496ca7dd53cc158e8b458f4b2b7e0e8431eeb95955acdccfd3dafe53 (name+funcs); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char __tiny ram_18;
extern unsigned int ram_100000;
extern unsigned int ram_100002;
extern unsigned char __near ram_112d[];
extern unsigned char __near ram_112e[];
extern unsigned char __near ram_1349[];
extern unsigned char __near ram_148d[];
extern unsigned int __near ram_292e[];
extern unsigned int __near ram_2936[];
extern unsigned char Voice_Pool_Quota_ModeA[];
extern unsigned char Voice_Pool_Quota_ModeB[];
extern unsigned char *Voice_Part_PoolPtr_ModeA[];
extern unsigned char *Voice_Part_PoolPtr_ModeB[];
void Voice_Retire_ToFreePool(unsigned char *v);
void VoiceState_FullReset(void);
void Voice_Reset_Engine(unsigned char a)
{
    unsigned char i;
    unsigned char j;
    unsigned char *n;
    for (i = 0; i < 4; i++)
        if (ram_292e[(int)i] != 0) break;
    if (i < 4) {
        for (i = 0; i < 0x40; i++) {
            ram_18 &= 0x7f;
            ram_100000 = i + 0x840;
            __asm(" nop");
            ram_18 |= 0x80;
            ram_100002 = 0xa200;
            __asm(" jr $+2");
            __asm(" nop");
            __asm(" nop");
            __asm(" nop");
            ram_18 &= 0x7f;
            ram_100000 = i + 0x800;
            __asm(" nop");
            ram_18 |= 0x80;
            ram_100002 = 0xa280;
            __asm(" jr $+2");
            __asm(" nop");
            __asm(" nop");
            __asm(" nop");
        }
    }
    if (i < 4) {
        for (i = 0; i < 0x40; i++) {
            ram_18 &= 0x7f;
            ram_100000 = (unsigned char)(i + 0xc0);
            __asm(" nop");
            ram_18 |= 0x80;
            ram_100002 = 0;
            __asm(" jr $+2");
            __asm(" nop");
            __asm(" nop");
            __asm(" nop");
            ram_18 &= 0x7f;
            ram_100000 = i;
            __asm(" nop");
            ram_18 |= 0x80;
            ram_100002 = 0x7e00;
            __asm(" jr $+2");
            __asm(" nop");
            __asm(" nop");
            __asm(" nop");
        }
    }
    for (i = 0; i < 0x12; i++) {
        if (a == 0) ram_112d[(int)i * 30] = Voice_Pool_Quota_ModeA[i];
        else ram_112d[(int)i * 30] = Voice_Pool_Quota_ModeB[i];
        ram_112e[(int)i * 30] = 0;
        for (j = 0; j < 7; j++)
            *(unsigned long *)(&ram_112d[(int)i * 30] + (((int)j << 2) + 2)) = 0;
    }
    for (i = 0; i < 0x1b; i++) {
        if (a == 0) *(unsigned char **)&ram_1349[(int)i * 12] = Voice_Part_PoolPtr_ModeA[i];
        else *(unsigned char **)&ram_1349[(int)i * 12] = Voice_Part_PoolPtr_ModeB[i];
        for (j = 0; j < 2; j++)
            *(unsigned long *)(&ram_1349[(int)i * 12] + (((int)j << 2) + 4)) = 0;
    }
    for (i = 0; i < 0x40; i++) {
        n = &ram_148d[0] + (int)i * 39;
        n[36] = i;
        *(unsigned char **)n = n;
        *(unsigned char **)(n + 4) = n;
        *(unsigned char **)(n + 8) = n;
        *(unsigned char **)(n + 12) = n;
        *(unsigned char **)(n + 16) = n;
        *(unsigned char **)(n + 20) = n;
        n[34] = 0;
        *(unsigned char **)(n + 24) = &ram_1349[0];
        n[28] = 1;
        *(unsigned char **)(n + 29) = &ram_112d[0];
        n[33] = 6;
        n[37] = 0;
    }
    n = &ram_148d[0];
    for (i = 0; i < 0x40; i++) {
        Voice_Retire_ToFreePool(n);
        n += 39;
    }
    for (i = 0; i < 4; i++) {
        ram_292e[(int)i] = 0;
        ram_2936[(int)i] = 0;
    }
    VoiceState_FullReset();
}
