/* lane_sub helper A, round 11, form c (third spellings): functions of the KN5000 sub-CPU payload v1.42 (v142/subcpu, core/05
   and core/07), mostly module-local (calr) callers.  Names are the tree's labels; ram_<hex> is a RAM cell (sub-CPU
   address) the tree has not named.  Voice (71 B), node (39 B), part (287 B) and row records have odd field offsets,
   so they are read through char pointers (W / SW / P). */

/* cc900-module: Quad_Decode_A_To_L */
/* cc900-module: VoiceSlot_UpdateNoteSource */
/* cc900-module: TVF_Calc_Cutoff */
/* cc900-module: Voice_Selector_FindBestSlot */
/* cc900-module: WaveSel_KeyTable_Lookup */
/* cc900-module: WaveSel_Emit_ZoneRecord_S4 */
/* cc900-module: WaveSel_Emit_ZoneRecord_S6 */
/* cc900-module: WaveSel_Emit_ZoneRecord_S10 */
/* cc900-module: WaveSel_Emit_ZoneRecord_S12 */
/* cc900-module: WaveSel_Emit_ZoneRecord_S13 */
/* cc900-module: WaveSel_Emit_ZoneRecord_S15 */
/* cc900-module: VoiceState_SwapSlot_DE_BC */
/* cc900-module: VoiceState_SwapSlot_HL_IY */

#define W(p, o) (*(unsigned int *)((p) + (o)))
#define SW(p, o) (*(int *)((p) + (o)))
#define P(p, o) (*(unsigned char **)((p) + (o)))

extern int __near ram_2940;
extern int ram_41347;
extern int ram_4135a;
extern unsigned int ram_451da;
extern unsigned char ram_4134c;
extern unsigned long ToneDB_RelBase;
extern unsigned int Voice_Part_Trim_Table_A[];
extern unsigned int Voice_Part_Trim_Table_B[];
extern unsigned int Voice_Part_Trim_Base[];
extern unsigned int Voice_Part_Trim_Addend_1[];
extern unsigned int Voice_Part_Trim_Addend_2[];
extern unsigned char ram_4138d[];
extern unsigned char ram_4146a[];
extern unsigned char ram_41476[];
extern unsigned char ram_41478[];
extern unsigned char ram_4147a[];
extern unsigned char __near ram_2126[];
extern unsigned char __near ram_2128[];
extern unsigned char __near ram_212a[];
extern unsigned char __near ram_24e6[];

unsigned int Pitch_Saturate_15bit(unsigned int a);
unsigned int Voice_Apply_GateRouting(int part, unsigned int g);
unsigned char Quad_Decode_A_To_L(int a);
void VoiceSlot_UpdateNoteSource(int a, int c, int e);
int TVF_Calc_Cutoff_NoKeyFollow(unsigned char *v, int c);
int TVF_Calc_Cutoff(unsigned char *v, int c, int d, char s);
void Voice_Selector_FindBestSlot(unsigned char *w, unsigned char *cnt, unsigned char *idx, unsigned char *val);
unsigned char WaveSel_KeyTable_Lookup(unsigned char *t, int k);
void WaveSel_Emit_ZoneRecord_S4(unsigned char *v, unsigned char *t, int i);
void WaveSel_Emit_ZoneRecord_S6(unsigned char *v, unsigned char *t, int i);
void WaveSel_Emit_ZoneRecord_S10(unsigned char *v, unsigned char *t, int i);
void WaveSel_Emit_ZoneRecord_S12(unsigned char *v, unsigned char *t, int i);
void WaveSel_Emit_ZoneRecord_S13(unsigned char *v, unsigned char *t, int i);
void WaveSel_Emit_ZoneRecord_S15(unsigned char *v, unsigned char *t, int i);
void VoiceState_SwapSlot_DE_BC(int a, int c);
void VoiceState_SwapSlot_HL_IY(int a, int c, int e);

void Voice_PitchPack_Mode5_Dual(unsigned char *v)
{
    unsigned char *z;
    int c1, c2;
    unsigned int x;
    z = P(v, 23);
    if (W(P(v, 35), 2) & 0x200) {
        c1 = z[77];
        c2 = z[79];
    } else {
        c1 = (int)z[77] + (char)P(v, 35)[103];
        c2 = (int)z[79] + (char)P(v, 35)[103];
    }
    c1 = TVF_Calc_Cutoff(v, c1, (char)z[55], (char)z[60]);
    c2 = TVF_Calc_Cutoff(v, c2, (char)z[55], (char)z[60]);
    x = ((unsigned int)z[78] << 13) | ((unsigned int)z[80] << 10);
    SW(v, 66) = (c1 | x) | 0x80;
    SW(v, 68) = c2;
    ram_2940 = 0;
}

void Voice_AdvanceSlotIterator(unsigned char a)
{
    unsigned int i, end, j;
    i = a;
    i *= 0x30;
    end = i;
    end += 0x30;
    for (; i < end; i++) {
        if (ram_212a[i * 5] > 0x40 && ram_2128[i * 5] != 0x1a) {
            j = (unsigned char)i;
            VoiceSlot_UpdateNoteSource(j, 0x1a, Quad_Decode_A_To_L((unsigned char)i));
        }
    }
}

void OutputBuf_Flush_A(unsigned char **pp, unsigned char *head, unsigned char key, char all)
{
    unsigned char *n;
    if (head != 0) {
        n = head;
        do {
            if (all != 0 || n[35] == key) {
                **pp = n[36];
                *pp += 1;
            }
            n = P(n, 8);
        } while (n != head);
    }
    **pp = 0xff;
}

void VoiceState_SwapSlot_Guarded(unsigned char a, unsigned char c, unsigned char e)
{
    unsigned char k;
    unsigned char *r;
    unsigned char *s;
    r = ram_24e6 + (int)a * 12;
    k = r[(int)c + 8];
    if ((unsigned char)k < 0xc0) {
        s = &ram_2126[(int)k * 5];
        if (s[4] == a) {
            if (r[c] != a) s[4] = r[c];
            else s[4] = 0xff;
        }
    }
    s = &ram_2126[(int)e * 5];
    if (s[4] > 0x40) {
        s[4] = a;
        VoiceState_SwapSlot_DE_BC(a, c);
    } else VoiceState_SwapSlot_HL_IY(a, c, s[4]);
    r[(int)c + 8] = e;
}

void Voice_Selector_ComputeMixWeights(unsigned char part)
{
    unsigned char g2, g1, g0;
    unsigned int x;
    Voice_Selector_FindBestSlot(&ram_4146a[(int)part * 287], &g2, &g1, &g0);
    *(unsigned int *)&ram_41476[(int)part * 287] = Voice_Part_Trim_Table_A[g2];
    *(unsigned int *)&ram_4147a[(int)part * 287] = Voice_Part_Trim_Table_B[g1];
    x = Voice_Part_Trim_Base[g2];
    x += Voice_Part_Trim_Addend_1[g1];
    x += Voice_Part_Trim_Addend_2[g0];
    *(unsigned int *)&ram_41478[(int)part * 287] = x;
}

void WaveSel_StageB_Build_Reg040(unsigned char *v)
{
    unsigned char *z;
    unsigned char *a1;
    unsigned char *a2;
    unsigned char *p;
    unsigned char k;
    z = P(v, 31);
    a1 = (unsigned char *)(*(unsigned long *)(z + 1) + ToneDB_RelBase);
    a2 = (unsigned char *)(*(unsigned long *)(z + 5) + ToneDB_RelBase);
    p = (unsigned char *)(*(unsigned long *)a1 + ToneDB_RelBase);
    k = a1[(int)WaveSel_KeyTable_Lookup(p, SW(v, 6)) + 4];
    if (z[0] & 0x40) {
        if (z[0] & 0x80) {
            if (z[0] & 0x20) WaveSel_Emit_ZoneRecord_S15(v, a2, k);
            else WaveSel_Emit_ZoneRecord_S12(v, a2, k);
        } else {
            if (z[0] & 0x20) WaveSel_Emit_ZoneRecord_S13(v, a2, k);
            else WaveSel_Emit_ZoneRecord_S10(v, a2, k);
        }
    } else {
        if (z[0] & 0x80) WaveSel_Emit_ZoneRecord_S6(v, a2, k);
        else WaveSel_Emit_ZoneRecord_S4(v, a2, k);
    }
}

void Voice_ScanSlots_ReassignSources(unsigned char a)
{
    unsigned char *r;
    unsigned char i, s;
    unsigned char *q;
    unsigned int j;
    r = ram_24e6 + (int)a * 12;
    for (i = 0; i < 4; i++) {
        s = r[(int)i + 8];
        if ((int)s < 0xc0) {
            q = &ram_2126[(int)s * 5];
            if (q[4] == a) {
                if (r[i] != a) q[4] = r[i];
                else {
                    q[4] = 0xff;
                    j = s;
                    VoiceSlot_UpdateNoteSource(j, 0x1a, Quad_Decode_A_To_L(s));
                }
            }
            VoiceState_SwapSlot_DE_BC(a, i);
            r[(int)i + 8] = 0xff;
        }
    }
}
