/* lane_sub helper AP, round 34, form b: form a with other macro spellings -- DST without the unary plus (with the
   edit buffer now a plain unsigned long object, the source order may survive), `x * 0x1d6 + 0x10 + EB`; ROWL the
   row as the node loop's matched spelling, `(unsigned char *)(void *)(&arr[0] + (int)x * st) + off`.
   Form a's notes follow.
   Round 34, form a (KN5000 sub-CPU payload v1.42, core/05 and core/11).  From sub_AP_33a.c; run
   2026-11-19-54-sub-r33a showed:
   - DSP_Reinit_VoiceSlots (+7): the unary plus kept the ROM's `add xhl,0x10` after the product, but the edit-buffer
     word read as `*(unsigned long *)&ram_4531c` is loaded into XDE and added there (`ld xde,(0x4531c); add xde,xhl`)
     where the ROM adds the memory word to XHL (`add xhl,(0x4531c)`).  Route2's matched sum adds ToneDB_RelBase, an
     object declared `unsigned long`, as a memory operand.  Form a: `extern unsigned long ram_4531c;` (EB is the
     object itself; the pointer uses go through EBP = (unsigned char *)ram_4531c).
   - Voice_Reset_Engine (+231; WORDAT fixed both word-array spots, ROWL fixed the folding: the offset now goes to HL
     and the store is `(xbc+hl)`): the (unsigned long) cast made the row address a 32-bit `exts xwa; add xwa,xbc;
     ld xbc,xwa`; the ROM has `lda xbc,(xbc+wa)` (the near array's 16-bit index, as `&ram_148d[0] + (int)i * 39`
     gives in the node loop).  Form a: the row kept apart by a `(void *)` cast instead,
     `(unsigned char *)(void *)&arr[(int)x * st] + off`.  Everything after that spot matches.
   Round 33's notes follow.
   Round 33, form a.  From sub_AP_32a.c (the
   best form of both functions in run 2026-11-19-52-sub-r32a); what that listing still showed:
   - DSP_Reinit_VoiceSlots (+7, the only difference): V4.23 reassociated the destination sum, product + edit buffer
     first and the +0x10 last (`lda xix,(xde+16)`); the ROM adds 0x10 to the product, then the pointer.  The FP
     lesson's unary plus stops V4.23's folding: `DST(x) = +((unsigned long)x * 0x1d6 + 0x10) + EB`.
   - Voice_Reset_Engine (+15): (1) the word arrays ram_292e / ram_2936 still widened the index to 32 bits; V4.23 gives
     `(xbc+wa)` for a near CHAR array indexed by an int, so the words are read through a char array,
     `WORDAT(arr, x) = *(unsigned int *)&arr[(int)x * 2]`.  (2) The long fields: V4.23 folded the row and the
     offset into one 16-bit index; the ROM builds the row address (`lda xbc,(xbc+wa)`) and stores at `(xbc+hl)`
     with the offset in HL.  The row kept apart by Route2's (unsigned long) cast:
     `ROWL(arr, x, st, off) = *(unsigned long *)((unsigned char *)(unsigned long)&arr[(int)x * st] + off)`.
   - Voice_Build_SoundingVoiceList not taken: its sub_AM_23a listing now checks, but the difference is register
     choice over the whole function (ROM q XIX, out XHL, b B, t QA, d D, s QC, IZ pushed as 16 bits; V4.23 q XIY,
     out XIX, b D, XIZ pushed) and I have no spelling for it.
   Forms b and c change only the macros DST / WORDAT / ROWL.
   Round 32's notes follow (still valid for the rest):
   - DSP_Reinit_VoiceSlots: (1) `a * 0x14 + c` on unsigned chars was computed in 8 bits (`mul a,20; add a,c`); the
     ROM extends both and multiplies in 16 bits: `(unsigned int)a * 0x14 + (unsigned int)c`, and likewise
     `n = (unsigned int)a * 0x14;`.  (2) V4.23 gave i IZ and n QIZ, the ROM the reverse: n now declared before i.
     (3) `(unsigned long)ram_4531c` was loaded and spilled to the stack before the long multiply; the ROM adds the
     edit-buffer pointer from memory last (`add xhl,(0x4531c)`), as an unsigned long object read in place:
     `#define EB (*(unsigned long *)&ram_4531c)`.  That also removes the extra frame slot (ROM frame 4).
   - Voice_Reset_Engine: (1) `ram_292e[i]` / `ram_2936[i]` with the byte i widened to 32 bits; the ROM indexes with a
     16-bit int (`(xbc+wa)`): `[(int)i]`.  (2) The 30- and 12-byte records as structs gave an unsigned `mul` and a
     32-bit address; the ROM has `muls` and a 16-bit register index (`(xhl+de)`), as for a char array:
     `ram_112d[(int)i * 30]`, `ram_112e[(int)i * 30]` (the count byte, which the ROM addresses as 0x112e), the
     longs `*(unsigned long *)(&ram_112d[(int)i * 30] + ((int)j * 4 + 2))` (offset first in HL, row by `lda`,
     store `(xbc+hl)`), the channel pointer `*(unsigned char **)&ram_1349[(int)i * 12]`.  (3) j*4 as a signed int
     (`sla`, not `sll`).
   Not taken: Voice_Build_Four_Partials (time).
   cc900-options: -Xr
*/

struct s426 { unsigned int w[0xd5]; };

extern unsigned long ram_4531c;
extern unsigned char ram_7800[];
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

#define EB ram_4531c
#define EBP ((unsigned char *)ram_4531c)
#define DST(x) ((unsigned long)(x) * 0x1d6 + 0x10 + EB)
#define WORDAT(arr, x) (*(unsigned int *)&arr[(int)(x) * 2])
#define ROWL(arr, x, st, off) (*(unsigned long *)((unsigned char *)(void *)(&arr[0] + (int)(x) * (st)) + (off)))

/* cc900-module: DSP1_ResolveStreamPtr DSP_FlushAllSlots DSP_InitChannelSlot DSP_Reinit_VoiceSlots DSP_ResetAlgoDefaults DSP_WriteCount_Compute */
void DSP_Reinit_VoiceSlots(unsigned char a, unsigned char c)
{
    unsigned char *p;
    unsigned int n;
    unsigned int i;
    if (a < 0x40) {
        if (c != 0xff) {
            i = (unsigned int)a * 0x14 + (unsigned int)c;
            p = DSP1_ResolveStreamPtr(i);
            *(struct s426 *)DST(i) = *(struct s426 *)p;
        } else {
            n = (unsigned int)a * 0x14;
            for (i = n; i < n + 0x14; i++) {
                p = DSP1_ResolveStreamPtr(i);
                *(struct s426 *)DST(i) = *(struct s426 *)p;
            }
        }
        *(unsigned int *)(EBP + 29352) = DSP_WriteCount_Compute();
    } else if (a != 0xff) {
        if (c != 0xff) DSP_InitChannelSlot(EBP + 18816, c);
        else {
            for (i = n; i < 0x80; i++)
                DSP_InitChannelSlot(EBP + 18816, i);
        }
        *(unsigned int *)(EBP + 29352) = DSP_WriteCount_Compute();
    } else {
        DSP_ResetAlgoDefaults();
        for (n = 0; n < 0x28; n++) {
            p = DSP1_ResolveStreamPtr(n);
            *(struct s426 *)DST(n) = *(struct s426 *)p;
        }
        DSP_FlushAllSlots(0, 0x40);
        *(unsigned int *)(EBP + 29352) = DSP_WriteCount_Compute();
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
            ROWL(ram_112d, i, 30, (int)j * 4 + 2) = 0;
    }
    for (i = 0; i < 0x1b; i++) {
        if (a == 0) *(unsigned char **)&ram_1349[(int)i * 12] = Voice_Part_PoolPtr_ModeA[i];
        else *(unsigned char **)&ram_1349[(int)i * 12] = Voice_Part_PoolPtr_ModeB[i];
        for (j = 0; j < 2; j++)
            ROWL(ram_1349, i, 12, (int)j * 4 + 4) = 0;
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
