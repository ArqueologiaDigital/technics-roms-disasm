/* lane_sub helper B, round 8, form c: the four modulation scalers of core/06_voice_envelopes_and_channels.s (KN5000
   sub-CPU payload v1.42) with the depth in __HL and the result in __DE.  With C locals V4.23 put the depth in DE and the
   result in HL (rounds 4-7, +4 each), the ROM the other way round.  A small file of its own, in case the
   pseudo-registers crash V4.23 here as __XIZ did. */

extern unsigned char ram_41383[];
extern unsigned char ram_41384[];
extern unsigned char ram_41387[];
extern unsigned char ram_41388[];

void AudioMod_Scale_To_Part_1F(unsigned char part, unsigned char v, unsigned char *m)
{
    if (m[1] & 0x80) {
        __HL = m[2];
        __DE = (int)v - 64;
        __DE += __DE;
        __DE = (int)__DE * (int)__HL;
    } else {
        __HL = m[2];
        __DE = v;
        __DE = (int)__DE * (int)__HL;
    }
    __DE = (int)__DE >> 1;
    __DE = (int)__DE / 127;
    ram_41387[part * 0x11f] = __DE;
}

/* cc900-name: AudioMod_Scale_To_LevelPairShf=AudioMod_Scale_To_LevelPairShift */
void AudioMod_Scale_To_LevelPairShf(unsigned char part, unsigned char v, unsigned char *m)
{
    if (m[1] & 0x80) {
        __HL = m[2];
        __DE = (int)v - 64;
        __DE += __DE;
        __DE = (int)__DE * (int)__HL;
    } else {
        __HL = m[2];
        __DE = v;
        __DE = (int)__DE * (int)__HL;
    }
    __DE = (int)__DE / 127;
    ram_41388[part * 0x11f] = __DE;
}

void AudioMod_Scale_To_Part_1C(unsigned char part, unsigned char v, unsigned char *m)
{
    if (m[1] & 0x80) {
        __HL = m[2];
        __DE = (unsigned int)v - 64;
        __DE += __DE;
        __DE *= __HL;
    } else {
        __HL = m[2];
        __DE = v;
        __DE *= __HL;
    }
    __DE >>= 6;
    ram_41384[part * 0x11f] = __DE;
}

void AudioMod_Scale_To_Part_1B(unsigned char part, unsigned char v, unsigned char *m)
{
    if (m[1] & 0x80) {
        __HL = m[2];
        __DE = (unsigned int)v - 64;
        __DE += __DE;
        __DE *= __HL;
    } else {
        __HL = m[2];
        __DE = v;
        __DE *= __HL;
    }
    __DE >>= 6;
    ram_41383[part * 0x11f] = __DE;
}
