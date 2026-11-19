/* lane_sub helper AP, round 35, form c: form a with the record address in the node loop's matched spelling,
   `((struct ty *)(&arr[0] + (int)x * st))->f[j]`.  Form a's notes follow.
   Round 35, form a (KN5000 sub-CPU payload v1.42, core/05): Voice_Reset_Engine only
   (DSP_Reinit_VoiceSlots matched in run 2026-11-19-57-sub-r34a and is staged).  From sub_AP_34a.c.
   Run -57: every round-34 ROWL spelling ((void *) cast, &arr[0] + ..., index form) gave the same 32-bit row
   address `exts xwa; add xwa,xbc; ld xbc,xwa` where the ROM has `lda xbc,(xbc+wa)`; that is the only difference
   left (twice: the command records' seven longs, the channel records' two longs).  V4.23 gives `lda (xbc+wa)`
   for a near-array element address it keeps as an address (the node loop's `n = &ram_148d[0] + (int)i * 39`).
   The firmware most probably wrote the field through a struct pointer cast on the record's byte address, so the
   member offset (j*4 + 2) is computed first into HL and the record address taken with `lda`:
   form a: `ROWL(arr, x, st, ty, f, j) = ((struct ty *)&arr[(int)x * st])->f[j]` with
   struct cmd { quota, count, unsigned long p[7] } and struct chan { pool, unsigned long z[2] }.
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

#define WORDAT(arr, x) (*(unsigned int *)&arr[(int)(x) * 2])
#define ROWL(arr, x, st, ty, f, j) (((struct ty *)(&arr[0] + (int)(x) * (st)))->f[j])

/* cc900-module: VoiceState_FullReset Voice_Reset_Engine Voice_Retire_ToFreePool */
void Voice_Reset_Engine(unsigned char a)
{
    unsigned char i;
    unsigned char j;
    unsigned char *n;
    for (i = 0; i < 4; i++)
        if (WORDAT(ram_292e, i) != 0) break;
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
            ROWL(ram_112d, i, 30, cmd, p, j) = 0;
    }
    for (i = 0; i < 0x1b; i++) {
        if (a == 0) *(unsigned char **)&ram_1349[(int)i * 12] = Voice_Part_PoolPtr_ModeA[i];
        else *(unsigned char **)&ram_1349[(int)i * 12] = Voice_Part_PoolPtr_ModeB[i];
        for (j = 0; j < 2; j++)
            ROWL(ram_1349, i, 12, chan, z, j) = 0;
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
        WORDAT(ram_292e, i) = 0;
        WORDAT(ram_2936, i) = 0;
    }
    VoiceState_FullReset();
}
