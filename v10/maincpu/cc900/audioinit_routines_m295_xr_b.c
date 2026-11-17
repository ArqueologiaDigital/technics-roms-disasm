/* Functions of audio/audioinit_routines.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern unsigned char __near AUDIO_STATE[];
extern unsigned int __near AUDIO_CONFIG_FLAGS;
extern unsigned int __near AUDIO_SEQ_TRACK_FLAGS;
extern unsigned int __near AUDIO_STATE_CHANGES;
extern unsigned char __near PANEL_STYLE[];
extern unsigned char __near PANEL_PART_LEFT[];
extern unsigned char __near PANEL_PART_BASS[];
extern unsigned char __near PANEL_PART_CHRD[];
extern unsigned char __near ram_d67;
extern void AudioInit_ConfigureVoiceRouting(void);

void AudioInit_ConfigureVoiceRouting(void)
{
    AUDIO_CONFIG_FLAGS &= 0xfeff;
    if (AUDIO_CONFIG_FLAGS & 3) {
        if ((AUDIO_CONFIG_FLAGS & 0xa0) == 0xa0) {
            AUDIO_STATE[0] &= ~4;
            AUDIO_STATE_CHANGES |= 1;
            AUDIO_STATE[188] = 2;
            AUDIO_STATE[189] = 0x16;
            AUDIO_STATE[6] = 0xff;
            AUDIO_STATE[26] = 0xff;
            if (AUDIO_CONFIG_FLAGS & 0x200) {
                if ((PANEL_STYLE[5] & 0xfc) == 0 && (PANEL_STYLE[6] & 0xfc) == 0) {
                    if (!(PANEL_PART_LEFT[13] & 0x20)) AUDIO_STATE[6] = 2;
                } else {
                    AUDIO_CONFIG_FLAGS |= 0x100;
                }
            } else if (PANEL_STYLE[5] & 2) {
                if ((PANEL_STYLE[5] & 0xfc) == 0 && (PANEL_STYLE[6] & 0xfc) == 0) {
                    if (!(PANEL_PART_LEFT[13] & 0x20)) AUDIO_STATE[6] = 2;
                    if (!(PANEL_PART_BASS[13] & 0x20)) AUDIO_STATE[26] = 0x16;
                } else {
                    AUDIO_CONFIG_FLAGS |= 0x100;
                }
            } else {
                if ((PANEL_STYLE[5] & 0xfc) == 0 && (PANEL_STYLE[6] & 0xfc) == 0) {
                    if (!(PANEL_PART_LEFT[13] & 0x20)) AUDIO_STATE[6] = 2;
                    if (!(PANEL_PART_BASS[13] & 0x20)) AUDIO_STATE[26] = 0x16;
                } else if ((AUDIO_SEQ_TRACK_FLAGS & 0x60) == 0) {
                    if (!(PANEL_PART_LEFT[13] & 0x20)) AUDIO_STATE[6] = 2;
                    if (!(PANEL_PART_BASS[13] & 0x20)) AUDIO_STATE[26] = 0x16;
                } else {
                    AUDIO_CONFIG_FLAGS |= 0x100;
                }
            }
        } else {
            if (!(PANEL_PART_LEFT[13] & 0x20)) AUDIO_STATE[6] = 2;
            AUDIO_STATE[188] = 0x15;
            AUDIO_STATE[189] = 0x16;
            AUDIO_STATE[25] = 0xff;
            AUDIO_STATE[26] = 0xff;
            if (ram_d67 == 4 || (AUDIO_SEQ_TRACK_FLAGS & 0x22) == 0x20) {
                AUDIO_STATE[188] = 0xff;
                AUDIO_STATE[189] = 0xff;
            } else if (!(AUDIO_CONFIG_FLAGS & 0x200) && !(PANEL_STYLE[5] & 2)) {
                if ((PANEL_STYLE[5] & 0xfc) == 0 && (PANEL_STYLE[6] & 0xfc) == 0) {
                    if (!(PANEL_PART_CHRD[13] & 0x20)) AUDIO_STATE[25] = 0x15;
                    if (!(PANEL_PART_BASS[13] & 0x20)) AUDIO_STATE[26] = 0x16;
                } else if ((AUDIO_SEQ_TRACK_FLAGS & 0x60) == 0) {
                    if (!(PANEL_PART_CHRD[13] & 0x20)) AUDIO_STATE[25] = 0x15;
                    if (!(PANEL_PART_BASS[13] & 0x20)) AUDIO_STATE[26] = 0x16;
                }
            }
        }
    } else if (AUDIO_CONFIG_FLAGS & 4) {
        AUDIO_STATE[188] = 0x15;
        AUDIO_STATE[189] = 0x16;
        AUDIO_STATE[25] = 0xff;
        AUDIO_STATE[26] = 0xff;
    } else {
        AUDIO_STATE[188] = 0xff;
        AUDIO_STATE[189] = 0xff;
        AUDIO_STATE[25] = 0xff;
        AUDIO_STATE[26] = 0xff;
    }
    AUDIO_STATE_CHANGES |= 0x104;
}
