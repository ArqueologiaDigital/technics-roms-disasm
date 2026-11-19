/* Functions of core/05_voice_params_and_tvf.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

struct cmd { unsigned char quota; unsigned char count; unsigned long p[7]; };
struct chan { unsigned char *pool; unsigned long z[2]; };
extern unsigned char __tiny ram_18;
extern unsigned int ram_100000;
extern unsigned int ram_100002;
extern unsigned char __near ram_112d[];
extern unsigned char __near ram_112e[];
extern unsigned char __near ram_1349[];
extern unsigned char __near ram_148d[];
extern unsigned char __near ram_292e[];
extern unsigned char __near ram_2936[];
extern unsigned char Voice_Pool_Quota_ModeA[];
extern unsigned char Voice_Pool_Quota_ModeB[];
extern unsigned char *Voice_Part_PoolPtr_ModeA[];
extern unsigned char *Voice_Part_PoolPtr_ModeB[];
void Voice_Retire_ToFreePool(unsigned char *v);
void VoiceState_FullReset(void);
void Voice_Reset_Engine(unsigned char a);

/* cc900-module: VoiceState_FullReset Voice_Reset_Engine Voice_Retire_ToFreePool */
void Voice_Reset_Engine(unsigned char a)
{
    unsigned char i;
    unsigned char j;
    unsigned char *n;
    for (i = 0; i < 4; i++)
        if ((*(unsigned int *)&ram_292e[(int)(i) * 2]) != 0) break;
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
            (((struct cmd *)&ram_112d[(int)(i) * (30)])->p[j]) = 0;
    }
    for (i = 0; i < 0x1b; i++) {
        if (a == 0) *(unsigned char **)&ram_1349[(int)i * 12] = Voice_Part_PoolPtr_ModeA[i];
        else *(unsigned char **)&ram_1349[(int)i * 12] = Voice_Part_PoolPtr_ModeB[i];
        for (j = 0; j < 2; j++)
            (((struct chan *)&ram_1349[(int)(i) * (12)])->z[j]) = 0;
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
        (*(unsigned int *)&ram_292e[(int)(i) * 2]) = 0;
        (*(unsigned int *)&ram_2936[(int)(i) * 2]) = 0;
    }
    VoiceState_FullReset();
}
