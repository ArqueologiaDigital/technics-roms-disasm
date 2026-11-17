/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/audioinit_routines_m295_xr.c (2026-11-16-125-p6-r26-staged)
   sha256 16e82dd1e2b3377d99aa38b2aa948cd2ac23f4ccddf00249a7d06a83d0fd5fa4 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
struct bank7 {                     
	unsigned char chg:1;
	unsigned char r0:7;
	unsigned char val:7;
	unsigned char b0:1;
};
struct bank1 {                     
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
extern void CtrlPanel_SetIndicatorBit(unsigned int);
extern unsigned int __near AUDIO_VOICE_CHANGES;
extern unsigned char __near PANEL_PLAY_SETTINGS[];
extern unsigned char __near ram_c5c8;
extern unsigned char __near ram_c5a2;
extern unsigned char __near ram_8f58;
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
			case 0x37:
				ram_8f58 = 1;
				break;
			case 0x3c:
				ram_8f58 = 2;
				break;
			case 0x43:
				ram_8f58 = 4;
				break;
			}
		} else
			ram_8f58 &= 0xf8;
	} else
		ram_8f58 &= 0xf8;
}
