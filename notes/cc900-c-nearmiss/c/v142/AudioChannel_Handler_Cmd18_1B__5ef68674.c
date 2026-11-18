/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of sub/sub_AD_20b.c (2026-11-18-6-sub-r20a)
   sha256 5ef686741923bc7d60b2038cd3069004d6c345e7f5fcc9ee0b48e6fc9105791a (tar-sha256); compiled at -Xr */
/* lane_sub helper AD, round 20, form b (KN5000 sub-CPU payload v1.42, core/06_voice_envelopes_and_channels.s):
   as sub_AD_20a.c except
   - the six handlers and Field2A / Field29: the struct cast on a pointer sum, `((struct b4 *)(R + (slot * 4 + K)))->b3`
     and `((struct f40 *)(R + (k * 16 + slot * 4)))->f40`, instead of on `&R[...]`;
   - the four scalers: no byte temporary, `d = m[2];`, with r declared before d (`unsigned int r, d;`);
   - Voice_InterpolateNoteCurve: `h = (unsigned char)p[12];` (a byte-typed value before the int assignment);
   - Variant3: `case 0x20: case 8: continue;`. */

struct b4 { unsigned char b0, b1, b2, b3; };
struct f40 { unsigned char pad[40]; unsigned char f40, f41, f42; };

extern unsigned char ram_41368[];
extern unsigned char ram_41383[];
extern unsigned char ram_41384[];
extern unsigned char ram_41387[];
extern unsigned char ram_41388[];
extern unsigned char ram_4308e[][0x47];
extern unsigned int ram_451cc[];
extern unsigned int ram_45204;
extern unsigned int ram_45206;
extern unsigned int ram_45208;
extern unsigned int ram_4520c;
extern unsigned int ram_4520e;

extern unsigned char *Voice_Query_PartVoices(int part);
extern unsigned int *Voice_BuildOutputList(int, int, int);
extern void ToneGen_WriteVoice_Reg21_Reg22(unsigned int ch, unsigned int *p);
extern void Voice_WriteChPanShift2(unsigned char *v, int flag);
extern void Voice_Calc_LevelPair_FixedAtk(unsigned char *v);

extern void AlgoFlag_Write(int, int, int);
extern void AlgoFlag_Write_Bit3(int, int, int);
extern void EFF_RoutingInit(int, int, int);
extern void ExtVoice_Build_SlotRegisters(unsigned char *v);
/* cc900-name: Voice_SubVoice_ComputeAndTrig=Voice_SubVoice_ComputeAndTrigger */
extern void Voice_SubVoice_ComputeAndTrig(unsigned char *v);
extern void Voice2_UpdatePitch(unsigned char *v);
extern void Voice_OpSlot_WriteParams(int part, unsigned char *rec, int slot, int k, int voice);
extern unsigned int EGEnv_Compute_A(int n);
extern unsigned int EGEnv_Compute_B(int n);
extern unsigned int EGEnv_Compute_A_Simple(int n);
extern unsigned int EGEnv_Compute_B_Simple(int n);
extern void Voice_Freq_WriteLeft(int n);
extern void Voice_Freq_WriteRight(int n);
extern void ToneGen_WriteVoice_Reg11(int ch, unsigned int *p);
extern void ToneGen_WriteVoice_Reg13(int ch, unsigned int *p);
extern void ToneGen_WriteVoice_Reg18(int ch, unsigned int *p);
extern void ToneGen_WriteVoice_Reg16(int ch, unsigned int *p);
extern void ToneGen_WriteVoice_Reg07(int ch, unsigned int *p);
extern void ToneGen_WriteVoice_Reg15(int ch, unsigned int *p);
extern void ToneGen_WriteVoice_EnvLevel(int ch, unsigned int *p);
/* cc900-name: ToneGen_WrVoice_Reg07_Or_Reg18=ToneGen_WriteVoice_Reg07_Or_Reg18 */
extern void ToneGen_WrVoice_Reg07_Or_Reg18(int ch, unsigned int *p);
/* cc900-name: ToneGen_WrVoice_Reg15_Or_Reg16=ToneGen_WriteVoice_Reg15_Or_Reg16 */
extern void ToneGen_WrVoice_Reg15_Or_Reg16(int ch, unsigned int *p);

/* ---- modulation scalers: m[1] bit 7 = bipolar, m[2] = depth ---- */

void AudioMod_Scale_To_Part_1C(unsigned char part, unsigned char v, unsigned char *m)
{
    unsigned int r, d;
    if (m[1] & 0x80) {
        d = m[2];
        r = (int)v - 64;
        r = r + r;
        r = r * d;
    } else {
        d = m[2];
        r = (unsigned int)v;
        r = r * d;
    }
    r = r >> 6;
    ram_41384[part * 0x11f] = r;
}

void AudioMod_Scale_To_Part_1B(unsigned char part, unsigned char v, unsigned char *m)
{
    unsigned int r, d;
    if (m[1] & 0x80) {
        d = m[2];
        r = (int)v - 64;
        r = r + r;
        r = r * d;
    } else {
        d = m[2];
        r = (unsigned int)v;
        r = r * d;
    }
    r = r >> 6;
    ram_41383[part * 0x11f] = r;
}

void AudioMod_Scale_To_Part_1F(unsigned char part, unsigned char v, unsigned char *m)
{
    int r, d;
    if (m[1] & 0x80) {
        d = m[2];
        r = (int)v - 64;
        r = r + r;
        r = r * d;
    } else {
        d = m[2];
        r = (int)v;
        r = r * d;
    }
    r = r >> 1;
    r = r / 127;
    ram_41387[part * 0x11f] = r;
}

/* cc900-name: AudioMod_Scale_To_LevelPairShf=AudioMod_Scale_To_LevelPairShift */
void AudioMod_Scale_To_LevelPairShf(unsigned char part, unsigned char v, unsigned char *m)
{
    int r, d;
    if (m[1] & 0x80) {
        d = m[2];
        r = (int)v - 64;
        r = r + r;
        r = r * d;
    } else {
        d = m[2];
        r = (int)v;
        r = r * d;
    }
    r = r / 127;
    ram_41388[part * 0x11f] = r;
}

/* ---- note curve: 0 inside [q1, q2], -512 outside [q0, q3], a -64 slope between ---- */

int Voice_InterpolateNoteCurve(unsigned char *p, unsigned char *q)
{
    int h, r;
    h = (unsigned char)p[12];
    h &= 0x7f;
    if (h < q[34]) {
        if (h < q[35]) r = -512;
        else r = ((int)q[34] - h) * -64 / (q[34] - (int)q[35]);
    } else if (h > q[36]) {
        if (h > q[37]) r = -512;
        else r = (h - (int)q[36]) * -64 / (q[37] - (int)q[36]);
    } else r = 0;
    return r;
}

/* ---- voice-list walker: only layer type 0x10 does anything; the load of the patch pointer is discarded ---- */

/* cc900-name: AudioChannel_AllVoices_UpdVar3=AudioChannel_AllVoices_Update_Variant3 */
/* cc900-module: ToneGen_WriteVoice_Reg21_Reg22 */
void AudioChannel_AllVoices_UpdVar3(unsigned char *list)
{
    unsigned char (*base)[0x47];
    unsigned char *q;
    unsigned char *v;
    unsigned char *f;
    base = ram_4308e;
    list += 5;
    q = list;
    if (*list < 0x40) {
        do {
            v = base[*q];
            switch (*(unsigned int *)(v + 1) & 0x3c) {
            case 0x20:
            case 8:
                continue;
            case 0x10:
                f = *(unsigned char **)(v + 19);
                Voice_Calc_LevelPair_FixedAtk(v);
                Voice_WriteChPanShift2(v, 0);
                ToneGen_WriteVoice_Reg21_Reg22(*q, ram_451cc);
                break;
            }
        } while (*++q < 0x40);
    }
}

/* ---- the slot byte writers: byte 40 of operator (k, slot) of the part record takes the routing bits of m[0];
   byte 42 (Field2A) / 41 (Field29) takes the scaled controller ---- */

void AudioMod_Apply_Slot_Field2A(unsigned char part, unsigned char val, unsigned char *m, unsigned char slot, unsigned char k)
{
    unsigned char x, y;
    unsigned int t, d;
    if (m[1] & 0x80) {
        if (val > 64) {
            val = val - 64;
            val = val * 2;
        } else val = 0;
    }
    if (val != 0) {
        x = ((struct f40 *)(((unsigned char *)(unsigned long)(ram_41368 + (int)(part) * 287)) + ((int)(k) * 16 + (int)(slot) * 4)))->f40 & 0x55;
        y = m[0] & 0x55;
        x = x | y;
        y = m[0] & 0xaa;
        ((struct f40 *)(((unsigned char *)(unsigned long)(ram_41368 + (int)(part) * 287)) + ((int)(k) * 16 + (int)(slot) * 4)))->f40 = x | y;
    } else ((struct f40 *)(((unsigned char *)(unsigned long)(ram_41368 + (int)(part) * 287)) + ((int)(k) * 16 + (int)(slot) * 4)))->f40 = 0;
    t = val;
    d = m[2];
    t = t * d;
    t >>= 6;
    if (t == 0 && val != 0) t = 1;
    ((struct f40 *)(((unsigned char *)(unsigned long)(ram_41368 + (int)(part) * 287)) + ((int)(k) * 16 + (int)(slot) * 4)))->f42 = t;
}

void AudioMod_Apply_Slot_Field29(unsigned char part, unsigned char val, unsigned char *m, unsigned char slot, unsigned char k)
{
    unsigned char x, y;
    unsigned int t, d;
    if (m[1] & 0x80) {
        if (val > 64) {
            val = val - 64;
            val = val * 2;
        } else val = 0;
    }
    if (val != 0) {
        x = ((struct f40 *)(((unsigned char *)(unsigned long)(ram_41368 + (int)(part) * 287)) + ((int)(k) * 16 + (int)(slot) * 4)))->f40 & 0x55;
        y = m[0] & 0x55;
        x = x | y;
        y = m[0] & 0xaa;
        ((struct f40 *)(((unsigned char *)(unsigned long)(ram_41368 + (int)(part) * 287)) + ((int)(k) * 16 + (int)(slot) * 4)))->f40 = x | y;
    } else ((struct f40 *)(((unsigned char *)(unsigned long)(ram_41368 + (int)(part) * 287)) + ((int)(k) * 16 + (int)(slot) * 4)))->f40 = 0;
    t = val;
    d = m[2];
    t = t * d;
    t >>= 6;
    if (t == 0 && val != 0) t = 1;
    ((struct f40 *)(((unsigned char *)(unsigned long)(ram_41368 + (int)(part) * 287)) + ((int)(k) * 16 + (int)(slot) * 4)))->f41 = t;
}

/* ---- audio-channel commands 4 .. 0x1b: one operator slot's parameter of sub-voice K (0 / 1 / 2), applied at once
   to the part's sounding voices when the slot's byte is 0, otherwise through the part's output list ---- */

/* cc900-module: AudioMod_Apply_Slot_Field2A ToneGen_WriteVoice_Reg11 ToneGen_WriteVoice_Reg18 */
void AudioChannel_Handler_Cmd04_07(unsigned char part, unsigned char val, unsigned char *m, unsigned char slot)
{
    unsigned int i;
    if (((struct b4 *)(((unsigned char *)(unsigned long)(ram_41368 + (int)(part) * 287)) + ((int)(slot) * 4 + 39)))->b3 == 0) {
        unsigned char *list;
        unsigned char (*base)[0x47];
        unsigned char *q;
        AudioMod_Apply_Slot_Field2A(part, val, m, slot, 0);
        AlgoFlag_Write(part, 0, slot);
        for (i = 0; i < 4; i++) EFF_RoutingInit(part, (unsigned char)i, 0);
        list = Voice_Query_PartVoices(part);
        *(unsigned int *)&ram_41368[part * 0x11f] |= 8;
        base = ram_4308e;
        for (q = list + 5; *q < 0x40; q++) {
            ExtVoice_Build_SlotRegisters(base[*q]);
            ToneGen_WriteVoice_Reg11(*q, ram_451cc);
        }
    } else {
        unsigned int *olist;
        unsigned int j;
        AudioMod_Apply_Slot_Field2A(part, val, m, slot, 0);
        AlgoFlag_Write(part, 0, slot);
        for (i = 0; i < 4; i++) EFF_RoutingInit(part, (unsigned char)i, 0);
        olist = Voice_BuildOutputList(part, (unsigned char)(unsigned int)slot, 32);
        for (j = 0; (olist[j] & 0xff) < 0x80; j++) {
            i = olist[j];
            i &= 0xff;
            Voice_OpSlot_WriteParams(part, ram_41368 + part * 287, slot, 0, (unsigned char)i);
            if (val == 0) {
                *(unsigned int *)&ram_41368[part * 0x11f] |= 8;
                ram_4520c = 0;
            } else {
                ram_4520c = EGEnv_Compute_A((unsigned char)i);
            }
            ToneGen_WriteVoice_Reg18((unsigned char)i, ram_451cc);
        }
    }
}

/* cc900-module: AudioMod_Apply_Slot_Field2A ToneGen_WriteVoice_EnvLevel ToneGen_WriteVoice_Reg07 */
void AudioChannel_Handler_Cmd08_0B(unsigned char part, unsigned char val, unsigned char *m, unsigned char slot)
{
    unsigned int i;
    if (((struct b4 *)(((unsigned char *)(unsigned long)(ram_41368 + (int)(part) * 287)) + ((int)(slot) * 4 + 55)))->b3 == 0) {
        unsigned char *list;
        unsigned char (*base)[0x47];
        unsigned char *q;
        AudioMod_Apply_Slot_Field2A(part, val, m, slot, 1);
        AlgoFlag_Write(part, 1, slot);
        for (i = 0; i < 4; i++) EFF_RoutingInit(part, (unsigned char)i, 1);
        list = Voice_Query_PartVoices(part);
        *(unsigned int *)&ram_41368[part * 0x11f] |= 8;
        base = ram_4308e;
        for (q = list + 5; *q < 0x40; q++) {
            Voice_SubVoice_ComputeAndTrig(base[*q]);
            ToneGen_WriteVoice_EnvLevel(*q, ram_451cc);
        }
    } else {
        unsigned int *olist;
        unsigned int j;
        AudioMod_Apply_Slot_Field2A(part, val, m, slot, 1);
        AlgoFlag_Write(part, 1, slot);
        for (i = 0; i < 4; i++) EFF_RoutingInit(part, (unsigned char)i, 1);
        olist = Voice_BuildOutputList(part, (unsigned char)((unsigned int)slot | 4), 32);
        for (j = 0; (olist[j] & 0xff) < 0x40; j++) {
            i = olist[j];
            i &= 0xff;
            Voice_OpSlot_WriteParams(part, ram_41368 + part * 287, slot, 1, (unsigned char)i);
            if (val == 0) {
                *(unsigned int *)&ram_41368[part * 0x11f] |= 8;
                ram_45204 = 0;
            } else {
                ram_45204 = EGEnv_Compute_B((unsigned char)i);
            }
            ToneGen_WriteVoice_Reg07((unsigned char)i, ram_451cc);
        }
    }
}

/* cc900-module: AudioMod_Apply_Slot_Field2A ToneGen_WriteVoice_Reg13 ToneGen_WriteVoice_Reg07_Or_Reg18 ToneGen_WrVoice_Reg07_Or_Reg18 */
void AudioChannel_Handler_Cmd0C_0F(unsigned char part, unsigned char val, unsigned char *m, unsigned char slot)
{
    unsigned int i;
    if (((struct b4 *)(((unsigned char *)(unsigned long)(ram_41368 + (int)(part) * 287)) + ((int)(slot) * 4 + 71)))->b3 == 0) {
        unsigned char *list;
        unsigned char (*base)[0x47];
        unsigned char *q;
        AudioMod_Apply_Slot_Field2A(part, val, m, slot, 2);
        AlgoFlag_Write(part, 2, slot);
        for (i = 0; i < 4; i++) EFF_RoutingInit(part, (unsigned char)i, 2);
        list = Voice_Query_PartVoices(part);
        *(unsigned int *)&ram_41368[part * 0x11f] |= 8;
        base = ram_4308e;
        for (q = list + 5; *q < 0x40; q++) {
            Voice2_UpdatePitch(base[*q]);
            ToneGen_WriteVoice_Reg13(*q, ram_451cc);
        }
    } else {
        unsigned int *olist;
        unsigned int j;
        AudioMod_Apply_Slot_Field2A(part, val, m, slot, 2);
        AlgoFlag_Write(part, 2, slot);
        for (i = 0; i < 4; i++) EFF_RoutingInit(part, (unsigned char)i, 2);
        olist = Voice_BuildOutputList(part, (unsigned char)((unsigned int)slot | 8), 32);
        for (j = 0; (olist[j] & 0xff) < 0x80; j++) {
            i = olist[j];
            i &= 0xff;
            Voice_OpSlot_WriteParams(part, ram_41368 + part * 287, slot, 2, (unsigned char)i);
            if (val == 0) {
                *(unsigned int *)&ram_41368[part * 0x11f] |= 8;
                ram_45204 = 0;
                ram_4520e = 0;
            } else {
                Voice_Freq_WriteLeft((unsigned char)i);
            }
            ToneGen_WrVoice_Reg07_Or_Reg18((unsigned char)i, ram_451cc);
        }
    }
}

/* cc900-module: AudioMod_Apply_Slot_Field29 ToneGen_WriteVoice_Reg11 ToneGen_WriteVoice_Reg18 ToneGen_WriteVoice_Reg16 */
void AudioChannel_Handler_Cmd10_13(unsigned char part, unsigned char val, unsigned char *m, unsigned char slot)
{
    unsigned int i;
    if (((struct b4 *)(((unsigned char *)(unsigned long)(ram_41368 + (int)(part) * 287)) + ((int)(slot) * 4 + 39)))->b2 == 0) {
        unsigned char *list;
        unsigned char (*base)[0x47];
        unsigned char *q;
        AudioMod_Apply_Slot_Field29(part, val, m, slot, 0);
        AlgoFlag_Write_Bit3(part, 0, slot);
        for (i = 0; i < 4; i++) EFF_RoutingInit(part, (unsigned char)i, 0);
        list = Voice_Query_PartVoices(part);
        *(unsigned int *)&ram_41368[part * 0x11f] |= 8;
        base = ram_4308e;
        for (q = list + 5; *q < 0x40; q++) {
            ExtVoice_Build_SlotRegisters(base[*q]);
            ToneGen_WriteVoice_Reg11(*q, ram_451cc);
        }
    } else {
        unsigned int *olist;
        unsigned int j;
        AudioMod_Apply_Slot_Field29(part, val, m, slot, 0);
        AlgoFlag_Write_Bit3(part, 0, slot);
        for (i = 0; i < 4; i++) EFF_RoutingInit(part, (unsigned char)i, 0);
        olist = Voice_BuildOutputList(part, (unsigned char)(unsigned int)slot, 32);
        for (j = 0; (olist[j] & 0xff) < 0x80; j++) {
            i = olist[j];
            i &= 0xff;
            Voice_OpSlot_WriteParams(part, ram_41368 + part * 287, slot, 0, (unsigned char)i);
            if (val == 0) {
                *(unsigned int *)&ram_41368[part * 0x11f] |= 8;
                ram_4520c = 0;
                ToneGen_WriteVoice_Reg18((unsigned char)i, ram_451cc);
            } else {
                ram_45208 = EGEnv_Compute_A_Simple((unsigned char)i);
                ToneGen_WriteVoice_Reg16((unsigned char)i, ram_451cc);
            }
        }
    }
}

/* cc900-module: AudioMod_Apply_Slot_Field29 ToneGen_WriteVoice_EnvLevel ToneGen_WriteVoice_Reg07 ToneGen_WriteVoice_Reg15 */
void AudioChannel_Handler_Cmd14_17(unsigned char part, unsigned char val, unsigned char *m, unsigned char slot)
{
    unsigned int i;
    if (((struct b4 *)(((unsigned char *)(unsigned long)(ram_41368 + (int)(part) * 287)) + ((int)(slot) * 4 + 55)))->b2 == 0) {
        unsigned char *list;
        unsigned char (*base)[0x47];
        unsigned char *q;
        AudioMod_Apply_Slot_Field29(part, val, m, slot, 1);
        AlgoFlag_Write_Bit3(part, 1, slot);
        for (i = 0; i < 4; i++) EFF_RoutingInit(part, (unsigned char)i, 1);
        list = Voice_Query_PartVoices(part);
        *(unsigned int *)&ram_41368[part * 0x11f] |= 8;
        base = ram_4308e;
        for (q = list + 5; *q < 0x40; q++) {
            Voice_SubVoice_ComputeAndTrig(base[*q]);
            ToneGen_WriteVoice_EnvLevel(*q, ram_451cc);
        }
    } else {
        unsigned int *olist;
        unsigned int j;
        AudioMod_Apply_Slot_Field29(part, val, m, slot, 1);
        AlgoFlag_Write_Bit3(part, 1, slot);
        for (i = 0; i < 4; i++) EFF_RoutingInit(part, (unsigned char)i, 1);
        olist = Voice_BuildOutputList(part, (unsigned char)((unsigned int)slot | 4), 32);
        for (j = 0; (olist[j] & 0xff) < 0x40; j++) {
            i = olist[j];
            i &= 0xff;
            Voice_OpSlot_WriteParams(part, ram_41368 + part * 287, slot, 1, (unsigned char)i);
            if (val == 0) {
                *(unsigned int *)&ram_41368[part * 0x11f] |= 8;
                ram_45204 = 0;
                ToneGen_WriteVoice_Reg07((unsigned char)i, ram_451cc);
            } else {
                ram_45206 = EGEnv_Compute_B_Simple((unsigned char)i);
                ToneGen_WriteVoice_Reg15((unsigned char)i, ram_451cc);
            }
        }
    }
}

/* cc900-module: AudioMod_Apply_Slot_Field29 ToneGen_WriteVoice_Reg13 ToneGen_WriteVoice_Reg07_Or_Reg18 ToneGen_WrVoice_Reg07_Or_Reg18 ToneGen_WriteVoice_Reg15_Or_Reg16 ToneGen_WrVoice_Reg15_Or_Reg16 */
void AudioChannel_Handler_Cmd18_1B(unsigned char part, unsigned char val, unsigned char *m, unsigned char slot)
{
    unsigned int i;
    if (((struct b4 *)(((unsigned char *)(unsigned long)(ram_41368 + (int)(part) * 287)) + ((int)(slot) * 4 + 71)))->b2 == 0) {
        unsigned char *list;
        unsigned char (*base)[0x47];
        unsigned char *q;
        AudioMod_Apply_Slot_Field29(part, val, m, slot, 2);
        AlgoFlag_Write_Bit3(part, 2, slot);
        for (i = 0; i < 4; i++) EFF_RoutingInit(part, (unsigned char)i, 2);
        list = Voice_Query_PartVoices(part);
        *(unsigned int *)&ram_41368[part * 0x11f] |= 8;
        base = ram_4308e;
        for (q = list + 5; *q < 0x40; q++) {
            Voice2_UpdatePitch(base[*q]);
            ToneGen_WriteVoice_Reg13(*q, ram_451cc);
        }
    } else {
        unsigned int *olist;
        unsigned int j;
        AudioMod_Apply_Slot_Field29(part, val, m, slot, 2);
        AlgoFlag_Write_Bit3(part, 2, slot);
        for (i = 0; i < 4; i++) EFF_RoutingInit(part, (unsigned char)i, 2);
        olist = Voice_BuildOutputList(part, (unsigned char)((unsigned int)slot | 8), 32);
        for (j = 0; (olist[j] & 0xff) < 0x80; j++) {
            i = olist[j];
            i &= 0xff;
            Voice_OpSlot_WriteParams(part, ram_41368 + part * 287, slot, 2, (unsigned char)i);
            if (val == 0) {
                *(unsigned int *)&ram_41368[part * 0x11f] |= 8;
                ram_45204 = 0;
                ram_4520e = 0;
                ToneGen_WrVoice_Reg07_Or_Reg18((unsigned char)i, ram_451cc);
            } else {
                Voice_Freq_WriteRight((unsigned char)i);
                ToneGen_WrVoice_Reg15_Or_Reg16((unsigned char)i, ram_451cc);
            }
        }
    }
}
