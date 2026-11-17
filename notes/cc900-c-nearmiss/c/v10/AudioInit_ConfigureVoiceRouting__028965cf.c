/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/audioinit_routines_m295_xr.c (2026-11-17-6-p6-r30-staged)
   sha256 028965cf85d106ffdea58e86d54406ed87b86f33f0471bd20e76937c4b56dcd0 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char __near AUDIO_STATE[];
extern unsigned int __near AUDIO_CONFIG_FLAGS;
extern unsigned int __near AUDIO_SEQ_TRACK_FLAGS;
extern unsigned int __near AUDIO_STATE_CHANGES;
extern unsigned char __near PANEL_STYLE[];
extern unsigned char __near PANEL_PART_LEFT[];
extern unsigned char __near PANEL_PART_BASS[];
extern unsigned char __near PANEL_PART_CHRD[];
extern unsigned char __near ram_d67;
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
