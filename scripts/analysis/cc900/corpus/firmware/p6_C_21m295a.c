/* Phase 6, lane_p6 helper C, round 21, module 295 (modules_v10.tsv) of v10 audio/audioinit_routines.s, form a:
   AudioInit_ConfigureVoiceRouting (new, poolnew_C, 476 B, no calls; the same file's built C is -Xr,
   cc900/audioinit_routines_xr.c, whose declarations this reuses).  Clears AUDIO_CONFIG_FLAGS bit 8, then routes the
   voices: with a recognizer mode (flags & 3) and both 0xa0 bits it marks the LEFT part (AUDIO_STATE[6] = 2) and the
   bass (AUDIO_STATE[26] = 0x16) by the split / style / part switches, setting flag bit 8 where the style's
   +5 / +6 bytes have bits above bit 1; otherwise assigns parts 0x15 / 0x16 and the chord part; with no recognizer
   mode it assigns or disables by flag bit 2.  Always ends by asking AudioInit_DispatchChanges for bits 2 and 8.
   The offsets: AUDIO_STATE +6 / +25 / +26 / +188 / +189 (0xc204 / 0xc217 / 0xc218 / 0xc2ba / 0xc2bb); PANEL_STYLE
   +5 / +6; the part records' byte 13 (LEFT, BASS, CHRD), bit 5 tested.  One form: the ROM's jumps between the
   branches (some threaded to the common tail, some to the end of the outer then-branch) are left to V4.23. */

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
