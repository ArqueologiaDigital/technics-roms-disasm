/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_17m295b.c (2026-11-16-123-p6-r25)
   sha256 fd16598fb9eacd69599f37f4163b9b86e719948e091589af8e3cf9ea560483b8 (tar-sha256); compiled at -Xr */
struct bank7 {                     /* value in bits 7..1 of the second byte, "changed" in bit 7 of the first */
	unsigned char chg:1;
	unsigned char r0:7;
	unsigned char val:7;
	unsigned char b0:1;
};
struct bank1 {                     /* "changed" in bit 7, value in bits 6..0 (padded to 2 bytes) */
	unsigned char chg:1;
	unsigned char val:7;
};
struct audio_state {
	unsigned char s0;
	unsigned char s1;
	unsigned char pad2[180];
	unsigned char pan182;
	unsigned char x183;
	unsigned char pad184[6];
	unsigned char pan190;
	unsigned char x191;
	unsigned char pad192[4];
	struct bank7 b196;
	unsigned char pad198[2];
	struct bank7 b200;
	unsigned char pad202[2];
	struct bank1 b204;
	unsigned char pad206[2];
	struct bank1 b208;
	unsigned char pad210[2];
	struct bank7 b212;
};
extern struct audio_state __near AUDIO_STATE;
extern unsigned int __near AUDIO_CONFIG_FLAGS;
extern unsigned int __near AUDIO_SEQ_TRACK_FLAGS;
extern unsigned int __near AUDIO_STATE_CHANGES;
extern unsigned char __near PANEL_CONDUCTOR[];
extern unsigned char __near ram_e9c0;
void AudioInit_ConfigurePanning(void)
{
	if ((AUDIO_CONFIG_FLAGS & 0x400) != 0x400) return;
	if (AUDIO_CONFIG_FLAGS & 4) return;
	if ((AUDIO_STATE.s1 == 255 && (AUDIO_STATE.s0 & 1)) || AUDIO_STATE.s1 == 0)
		AUDIO_STATE.pan182 = 0;
	else if ((AUDIO_STATE.s1 == 255 && (AUDIO_STATE.s0 & 2)) || AUDIO_STATE.s1 == 1)
		AUDIO_STATE.pan182 = 1;
	else if (AUDIO_SEQ_TRACK_FLAGS & 0x60) {
		if ((PANEL_CONDUCTOR[0] & 3) == 2) AUDIO_STATE.pan182 = 1;
		else AUDIO_STATE.pan182 = 0;
	} else
		AUDIO_STATE.pan182 = 255;
	if (ram_e9c0 <= 14)
		AUDIO_STATE.pan190 = ram_e9c0;
	else {
		if ((AUDIO_STATE.s1 == 255 && (AUDIO_STATE.s0 & 1)) || AUDIO_STATE.s1 == 0)
			AUDIO_STATE.pan190 = 0;
		else if ((AUDIO_STATE.s1 == 255 && (AUDIO_STATE.s0 & 2)) || AUDIO_STATE.s1 == 1)
			AUDIO_STATE.pan190 = 1;
		else if (AUDIO_SEQ_TRACK_FLAGS & 0x60) {
			if ((PANEL_CONDUCTOR[0] & 3) == 2) AUDIO_STATE.pan190 = 1;
			else AUDIO_STATE.pan190 = 0;
		} else
			AUDIO_STATE.pan190 = 255;
	}
	AUDIO_STATE_CHANGES |= 256;
}
