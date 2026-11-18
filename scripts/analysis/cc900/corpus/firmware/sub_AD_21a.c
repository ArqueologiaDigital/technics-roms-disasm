/* lane_sub helper AD, round 21, form a (KN5000 sub-CPU payload v1.42, core/06_voice_envelopes_and_channels.s).
   Starts from round 20 (run 2026-11-18-6-sub-r20a) and changes only:
   - AudioMod_Apply_Slot_Field2A / Field29 (sub_AD_20a.c; its only difference left is the doubling, ROM `ld e,c;
     add c,e`, ours `add c,c` for `val * 2`, `val *= 2`, `val + val`, `val += val`): `val = val + (unsigned char)val;`,
     the cast making a copy in the scratch register as in idiom (aa);
   - the four AudioMod_Scale_To_* (all three round-20 forms gave the same code: d in DE, r in HL, the ROM has the
     reverse; declaration order and a byte temporary changed nothing): d declared in each branch's own block, r at
     function scope, so that r is allocated first;
   - AudioChannel_AllVoices_Update_Variant3: a fourth, first case `case 4:` with the empty ones, `case 4: case 0x20:
     case 8: break;`.  Hypothesis: V4.23 omits the LAST compare it emits (the first case in the source, since it
     emits in reverse) when that case's target is the switch's exit, the same place as the `jr` after the compares;
     the sibling AudioChannel_AllVoices_Update_PanShift's switch also tests 4, 8, 0x10, 0x20. */

struct f40 { unsigned char pad[40]; unsigned char f40, f41, f42; };

extern unsigned char ram_41368[];
extern unsigned char ram_41383[];
extern unsigned char ram_41384[];
extern unsigned char ram_41387[];
extern unsigned char ram_41388[];
extern unsigned char ram_4308e[][0x47];
extern unsigned int ram_451cc[];

extern void ToneGen_WriteVoice_Reg21_Reg22(unsigned int ch, unsigned int *p);
extern void Voice_WriteChPanShift2(unsigned char *v, int flag);
extern void Voice_Calc_LevelPair_FixedAtk(unsigned char *v);

/* ---- modulation scalers: m[1] bit 7 = bipolar, m[2] = depth ---- */

void AudioMod_Scale_To_Part_1C(unsigned char part, unsigned char v, unsigned char *m)
{
    unsigned int r;
    if (m[1] & 0x80) {
        unsigned int d;
        d = m[2];
        r = (int)v - 64;
        r = r + r;
        r = r * d;
    } else {
        unsigned int d;
        d = m[2];
        r = (unsigned int)v;
        r = r * d;
    }
    r = r >> 6;
    ram_41384[part * 0x11f] = r;
}

void AudioMod_Scale_To_Part_1B(unsigned char part, unsigned char v, unsigned char *m)
{
    unsigned int r;
    if (m[1] & 0x80) {
        unsigned int d;
        d = m[2];
        r = (int)v - 64;
        r = r + r;
        r = r * d;
    } else {
        unsigned int d;
        d = m[2];
        r = (unsigned int)v;
        r = r * d;
    }
    r = r >> 6;
    ram_41383[part * 0x11f] = r;
}

void AudioMod_Scale_To_Part_1F(unsigned char part, unsigned char v, unsigned char *m)
{
    int r;
    if (m[1] & 0x80) {
        int d;
        d = m[2];
        r = (int)v - 64;
        r = r + r;
        r = r * d;
    } else {
        int d;
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
    int r;
    if (m[1] & 0x80) {
        int d;
        d = m[2];
        r = (int)v - 64;
        r = r + r;
        r = r * d;
    } else {
        int d;
        d = m[2];
        r = (int)v;
        r = r * d;
    }
    r = r / 127;
    ram_41388[part * 0x11f] = r;
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
            case 4:
            case 0x20:
            case 8:
                break;
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
            val = val + (unsigned char)val;
        } else val = 0;
    }
    if (val != 0) {
        x = ((struct f40 *)&((unsigned char *)(unsigned long)(ram_41368 + (int)(part) * 287))[(int)(k) * 16 + (int)(slot) * 4])->f40 & 0x55;
        y = m[0] & 0x55;
        x = x | y;
        y = m[0] & 0xaa;
        ((struct f40 *)&((unsigned char *)(unsigned long)(ram_41368 + (int)(part) * 287))[(int)(k) * 16 + (int)(slot) * 4])->f40 = x | y;
    } else ((struct f40 *)&((unsigned char *)(unsigned long)(ram_41368 + (int)(part) * 287))[(int)(k) * 16 + (int)(slot) * 4])->f40 = 0;
    t = val;
    d = m[2];
    t = t * d;
    t >>= 6;
    if (t == 0 && val != 0) t = 1;
    ((struct f40 *)&((unsigned char *)(unsigned long)(ram_41368 + (int)(part) * 287))[(int)(k) * 16 + (int)(slot) * 4])->f42 = t;
}

void AudioMod_Apply_Slot_Field29(unsigned char part, unsigned char val, unsigned char *m, unsigned char slot, unsigned char k)
{
    unsigned char x, y;
    unsigned int t, d;
    if (m[1] & 0x80) {
        if (val > 64) {
            val = val - 64;
            val = val + (unsigned char)val;
        } else val = 0;
    }
    if (val != 0) {
        x = ((struct f40 *)&((unsigned char *)(unsigned long)(ram_41368 + (int)(part) * 287))[(int)(k) * 16 + (int)(slot) * 4])->f40 & 0x55;
        y = m[0] & 0x55;
        x = x | y;
        y = m[0] & 0xaa;
        ((struct f40 *)&((unsigned char *)(unsigned long)(ram_41368 + (int)(part) * 287))[(int)(k) * 16 + (int)(slot) * 4])->f40 = x | y;
    } else ((struct f40 *)&((unsigned char *)(unsigned long)(ram_41368 + (int)(part) * 287))[(int)(k) * 16 + (int)(slot) * 4])->f40 = 0;
    t = val;
    d = m[2];
    t = t * d;
    t >>= 6;
    if (t == 0 && val != 0) t = 1;
    ((struct f40 *)&((unsigned char *)(unsigned long)(ram_41368 + (int)(part) * 287))[(int)(k) * 16 + (int)(slot) * 4])->f41 = t;
}
