/* lane_sub helper AP, round 31, form c: form a with one change per function --
   DSP_Reinit_VoiceSlots the DMA destination a pointer, `(unsigned char *)0x1e0000` with a pointer parameter;
   Voice_Reset_Engine the node base as an address expression in both loops, `n = &ram_148d[0] + (int)i * 39;` and
   `n = &ram_148d[0];` (the ROM loads it with `lda`).
   Form a's notes follow.
   Round 31, form a (KN5000 sub-CPU payload v1.42, core/05 and core/11).  Two functions never
   compiled before; span_refs.py: every inner label of both is inner-only, so each is one C function.
   - DSP_Reinit_VoiceSlots (365 B, core/11): stream index i in QIZ and base n in IZ (both live across calls), the
     resolved stream pointer p on the stack.  V4.23 builds an expression assigned to a QIZ variable in WA and
     writes QIZ back after each step (the ROM's `mul wa,20; ld qiz,wa; add wa,bc; ld qiz,wa`), so the index is one
     expression, `i = a * 0x14 + c;`; the base likewise `n = a * 0x14;` (`ld izl,a; extz iz; ld wa,iz; mul ..;
     ld iz,wa`).  The 426-byte stream copy is a struct assignment (`ldirw`, 0xD5 words, even: not an odd-size
     copy), destination `(unsigned long)i * 0x1d6 + 0x10 + (unsigned long)ram_4531c` (product, +0x10, then the
     edit-buffer pointer from memory, as the ROM adds them).  The ROM's 128-channel loop starts `ld qiz,iz`: the
     loop variable starts from the IZ variable, which that path never sets -- written literally as
     `for (i = n; i < 0x80; i++)` (n is the same variable as the 0x28-stream loop counter, which shares IZ).
   - Voice_Reset_Engine (724 B, core/05): the loop byte i and the parameter a on the stack, the node pointer n in
     XIZ (lives across Voice_Retire_ToFreePool), j in E.  Tone-generator writes as the built writers (lower-case
     `__asm(" nop")` / `__asm(" jr $+2")`).  Records: 18 command entries of 30 bytes at 0x112d (byte, byte, seven
     longs from +2), 27 channel entries of 12 bytes at 0x1349 (pointer, two longs), 64 voice nodes of 39 bytes at
     0x148d (odd stride: a char array).  Form a: the 30- and 12-byte records as structs (`ram_112d[(int)i].p[j]`).
   Not taken this round: Voice_Build_Four_Partials (682 B; time).
   cc900-options: -Xr
*/

struct s426 { unsigned int w[0xd5]; };
struct cmd { unsigned char quota; unsigned char count; unsigned long p[7]; };
struct chan { unsigned char *pool; unsigned long z[2]; };

extern unsigned char *ram_4531c;
extern unsigned char ram_7800[];
extern unsigned char __tiny ram_18;
extern unsigned int ram_100000;
extern unsigned int ram_100002;
extern struct cmd __near ram_112d[];
extern struct chan __near ram_1349[];
extern unsigned char __near ram_148d[];
extern unsigned int __near ram_292e[];
extern unsigned int __near ram_2936[];
extern unsigned char Voice_Pool_Quota_ModeA[];
extern unsigned char Voice_Pool_Quota_ModeB[];
extern unsigned char *Voice_Part_PoolPtr_ModeA[];
extern unsigned char *Voice_Part_PoolPtr_ModeB[];

unsigned char *DSP1_ResolveStreamPtr(unsigned int n);
unsigned int DSP_WriteCount_Compute(void);
void DSP_ResetAlgoDefaults(void);
void DSP_FlushAllSlots(int a, int c);
void DSP_InitChannelSlot(unsigned char *rec, unsigned int n);
extern void InterCPU_E1_DMA_Transfer(unsigned char *src, unsigned int n, unsigned char *dst);
void Voice_Retire_ToFreePool(unsigned char *v);
void VoiceState_FullReset(void);
void DSP_Reinit_VoiceSlots(unsigned char a, unsigned char c);
void Voice_Reset_Engine(unsigned char a);

/* cc900-module: DSP1_ResolveStreamPtr DSP_FlushAllSlots DSP_InitChannelSlot DSP_Reinit_VoiceSlots DSP_ResetAlgoDefaults DSP_WriteCount_Compute */
void DSP_Reinit_VoiceSlots(unsigned char a, unsigned char c)
{
    unsigned char *p;
    unsigned int i;
    unsigned int n;
    if (a < 0x40) {
        if (c != 0xff) {
            i = a * 0x14 + c;
            p = DSP1_ResolveStreamPtr(i);
            *(struct s426 *)((unsigned long)i * 0x1d6 + 0x10 + (unsigned long)ram_4531c) = *(struct s426 *)p;
        } else {
            n = a * 0x14;
            for (i = n; i < n + 0x14; i++) {
                p = DSP1_ResolveStreamPtr(i);
                *(struct s426 *)((unsigned long)i * 0x1d6 + 0x10 + (unsigned long)ram_4531c) = *(struct s426 *)p;
            }
        }
        *(unsigned int *)(ram_4531c + 29352) = DSP_WriteCount_Compute();
    } else if (a != 0xff) {
        if (c != 0xff) DSP_InitChannelSlot(ram_4531c + 18816, c);
        else {
            for (i = n; i < 0x80; i++)
                DSP_InitChannelSlot(ram_4531c + 18816, i);
        }
        *(unsigned int *)(ram_4531c + 29352) = DSP_WriteCount_Compute();
    } else {
        DSP_ResetAlgoDefaults();
        for (n = 0; n < 0x28; n++) {
            p = DSP1_ResolveStreamPtr(n);
            *(struct s426 *)((unsigned long)n * 0x1d6 + 0x10 + (unsigned long)ram_4531c) = *(struct s426 *)p;
        }
        DSP_FlushAllSlots(0, 0x40);
        *(unsigned int *)(ram_4531c + 29352) = DSP_WriteCount_Compute();
    }
    InterCPU_E1_DMA_Transfer(ram_7800, 0x72aa, (unsigned char *)0x1e0000);
}

/* cc900-module: VoiceState_FullReset Voice_Reset_Engine Voice_Retire_ToFreePool */
void Voice_Reset_Engine(unsigned char a)
{
    unsigned char i;
    unsigned char j;
    unsigned char *n;
    for (i = 0; i < 4; i++)
        if (ram_292e[i] != 0) break;
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
        if (a == 0) ram_112d[(int)i].quota = Voice_Pool_Quota_ModeA[i];
        else ram_112d[(int)i].quota = Voice_Pool_Quota_ModeB[i];
        ram_112d[(int)i].count = 0;
        for (j = 0; j < 7; j++) ram_112d[(int)i].p[j] = 0;
    }
    for (i = 0; i < 0x1b; i++) {
        if (a == 0) ram_1349[(int)i].pool = Voice_Part_PoolPtr_ModeA[i];
        else ram_1349[(int)i].pool = Voice_Part_PoolPtr_ModeB[i];
        for (j = 0; j < 2; j++) ram_1349[(int)i].z[j] = 0;
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
        *(struct chan **)(n + 24) = &ram_1349[0];
        n[28] = 1;
        *(struct cmd **)(n + 29) = &ram_112d[0];
        n[33] = 6;
        n[37] = 0;
    }
    n = &ram_148d[0];
    for (i = 0; i < 0x40; i++) {
        Voice_Retire_ToFreePool(n);
        n += 39;
    }
    for (i = 0; i < 4; i++) {
        ram_292e[i] = 0;
        ram_2936[i] = 0;
    }
    VoiceState_FullReset();
}
