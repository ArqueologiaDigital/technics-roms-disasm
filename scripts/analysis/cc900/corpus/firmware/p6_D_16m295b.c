/* Phase 6, lane_p6 helper D, round 16, module 295 (v10 audio/audioinit_routines.s, compiled -Xr), form b (see
   p6_D_16m295.c): the drum-mode switch with its cases in the ROM's compare order (0x43, 0x3c, 0x37), and
   ConfigurePanning's 0xe9c0 test written as <= 14 first. */

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
	unsigned char pad183[7];
	unsigned char pan190;
	unsigned char pad191[5];
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

extern void CtrlPanel_SetIndicatorBit(unsigned int);

extern struct audio_state __near AUDIO_STATE;
extern unsigned int __near AUDIO_CONFIG_FLAGS;
extern unsigned int __near AUDIO_SEQ_TRACK_FLAGS;
extern unsigned int __near AUDIO_STATE_CHANGES;
extern unsigned int __near AUDIO_VOICE_CHANGES;
extern unsigned char __near PANEL_CONDUCTOR[];
extern unsigned char __near PANEL_PLAY_SETTINGS[];
extern unsigned char __near ram_e9c0;
extern unsigned char __near ram_c5c8;
extern unsigned char __near ram_c5a2;
extern unsigned char __near ram_8f58;

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

void AudioInit_DrumRoutingCheck(void)
{
	unsigned int f = 0;

	if ((AUDIO_STATE.s0 & 4)
	    || ((AUDIO_SEQ_TRACK_FLAGS & 6) && !(AUDIO_SEQ_TRACK_FLAGS & 1) && (AUDIO_CONFIG_FLAGS & 3))
	    || (!(AUDIO_SEQ_TRACK_FLAGS & 0x60) && (AUDIO_CONFIG_FLAGS & 3))) {
		if (AUDIO_STATE.s1 == 255) {
			f |= 8;
			ram_c5c8 = ram_c5a2;
		} else {
			if (ram_c5c8 != 255) f |= 8;
			ram_c5c8 = 255;
		}
		if (AUDIO_STATE.b196.val != ram_c5a2) {
			AUDIO_STATE.b196.chg = 1;
			AUDIO_STATE.b196.val = ram_c5a2;
			AUDIO_VOICE_CHANGES |= 512;
		}
		if (AUDIO_STATE.b200.val != ram_c5a2) {
			AUDIO_STATE.b200.chg = 1;
			AUDIO_STATE.b200.val = ram_c5a2;
			AUDIO_VOICE_CHANGES |= 512;
		}
		if (AUDIO_STATE.b204.val != (unsigned char)(ram_c5a2 - 1)) {
			AUDIO_STATE.b204.chg = 1;
			AUDIO_STATE.b204.val = ram_c5a2 - 1;
			AUDIO_VOICE_CHANGES |= 512;
		}
		if (AUDIO_STATE.s0 & 8) {
			if (AUDIO_STATE.b208.val != (unsigned char)(ram_c5a2 - 1)) {
				AUDIO_STATE.b208.chg = 1;
				AUDIO_STATE.b208.val = ram_c5a2 - 1;
				AUDIO_VOICE_CHANGES |= 512;
			}
		} else {
			if (AUDIO_STATE.b208.val != 0) {
				AUDIO_STATE.b208.chg = 1;
				AUDIO_STATE.b208.val = 0;
				AUDIO_VOICE_CHANGES |= 512;
			}
		}
		if (AUDIO_STATE.b212.val != ram_c5a2) {
			AUDIO_STATE.b212.chg = 1;
			AUDIO_STATE.b212.val = ram_c5a2;
			AUDIO_VOICE_CHANGES |= 512;
		}
	} else {
		if (ram_c5c8 != 255) f |= 8;
		ram_c5c8 = 255;
		if (AUDIO_STATE.b196.val != 0) {
			AUDIO_STATE.b196.chg = 1;
			AUDIO_STATE.b196.val = 0;
			AUDIO_VOICE_CHANGES |= 512;
		}
		if (AUDIO_STATE.b200.val != 0) {
			AUDIO_STATE.b200.chg = 1;
			AUDIO_STATE.b200.val = 0;
			AUDIO_VOICE_CHANGES |= 512;
		}
		if (AUDIO_STATE.b204.val != 0) {
			AUDIO_STATE.b204.chg = 1;
			AUDIO_STATE.b204.val = 0;
			AUDIO_VOICE_CHANGES |= 512;
		}
		if (AUDIO_CONFIG_FLAGS & 4) {
			if (AUDIO_STATE.b208.val != 0x7f) {
				AUDIO_STATE.b208.chg = 1;
				AUDIO_STATE.b208.val = 0x7f;
				AUDIO_VOICE_CHANGES |= 512;
			}
		} else {
			if (AUDIO_STATE.b208.val != 0) {
				AUDIO_STATE.b208.chg = 1;
				AUDIO_STATE.b208.val = 0;
				AUDIO_VOICE_CHANGES |= 512;
			}
		}
	}
	if (!(f & 8)) return;
	CtrlPanel_SetIndicatorBit(0x45);
	if (ram_c5c8 != 255) {
		if (PANEL_PLAY_SETTINGS[0] & 3) {
			switch (ram_c5a2) {
			case 0x43:
				ram_8f58 = 4;
				break;
			case 0x3c:
				ram_8f58 = 2;
				break;
			case 0x37:
				ram_8f58 = 1;
				break;
			}
		} else
			ram_8f58 &= 0xf8;
	} else
		ram_8f58 &= 0xf8;
}
