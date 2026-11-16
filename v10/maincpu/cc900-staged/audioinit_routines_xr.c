/* Functions of audio/audioinit_routines.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern unsigned char __near CMP_RECORD_PART;
extern unsigned char __near AUDIO_STATE[];
extern unsigned char __near PANEL_MIDI[];
extern unsigned int __near AUDIO_STATE_CHANGES;
extern unsigned int __near AUDIO_CONFIG_UPDATE;

void AudioInit_ClearPartFlags_ByMode(void)
{
	unsigned int i;

	if (AUDIO_CONFIG_UPDATE & 3) {
		i = 0;
		if (i < 26) do {
			AUDIO_STATE[292 + i * 2] &= ~0x20;
			AUDIO_STATE_CHANGES |= 8;
			i++;
		} while (i < 26);
		return;
	}
	i = 0;
	if (i < 16) do {
		AUDIO_STATE[292 + i * 2] |= 0x20;
		i++;
	} while (i < 16);
	if (PANEL_MIDI[3] & 0x40) {
		AUDIO_STATE[324] |= 0x20; AUDIO_STATE[326] |= 0x20; AUDIO_STATE[328] |= 0x20; AUDIO_STATE[330] |= 0x20;
		AUDIO_STATE[334] |= 0x20;
	} else {
		AUDIO_STATE[324] &= ~0x20; AUDIO_STATE[326] &= ~0x20; AUDIO_STATE[328] &= ~0x20; AUDIO_STATE[330] &= ~0x20;
		AUDIO_STATE[334] &= ~0x20;
		AUDIO_STATE_CHANGES |= 8;
	}
	if (PANEL_MIDI[0] & 0x40) {
		AUDIO_STATE[332] |= 0x20;
	} else {
		AUDIO_STATE[332] &= ~0x20;
		AUDIO_STATE_CHANGES |= 8;
	}
	if (PANEL_MIDI[3] & 0x80) {
		AUDIO_STATE[342] |= 0x20;
	} else {
		AUDIO_STATE[342] &= ~0x20;
		AUDIO_STATE_CHANGES |= 8;
	}
}

void AudioInit_SelectPriority(void)
{
	switch (CMP_RECORD_PART) {
	case 1:
		AUDIO_STATE[84] = 0; AUDIO_STATE[85] = 255; AUDIO_STATE[86] = 255; AUDIO_STATE[87] = 255; AUDIO_STATE[88] = 255;
		AUDIO_STATE_CHANGES |= 16;
		return;
	case 2:
		AUDIO_STATE[84] = 255; AUDIO_STATE[85] = 1; AUDIO_STATE[86] = 255; AUDIO_STATE[87] = 255; AUDIO_STATE[88] = 255;
		AUDIO_STATE_CHANGES |= 16;
		return;
	case 4:
		AUDIO_STATE[84] = 255; AUDIO_STATE[85] = 255; AUDIO_STATE[86] = 2; AUDIO_STATE[87] = 255; AUDIO_STATE[88] = 255;
		AUDIO_STATE_CHANGES |= 16;
		return;
	case 8:
		AUDIO_STATE[84] = 255; AUDIO_STATE[85] = 255; AUDIO_STATE[86] = 255; AUDIO_STATE[87] = 3; AUDIO_STATE[88] = 255;
		AUDIO_STATE_CHANGES |= 16;
		return;
	case 16:
		AUDIO_STATE[84] = 255; AUDIO_STATE[85] = 255; AUDIO_STATE[86] = 255; AUDIO_STATE[87] = 255; AUDIO_STATE[88] = 4;
		AUDIO_STATE_CHANGES |= 16;
		return;
	default:
		AUDIO_STATE[84] = 255; AUDIO_STATE[85] = 255; AUDIO_STATE[86] = 255; AUDIO_STATE[87] = 255; AUDIO_STATE[88] = 255;
		AUDIO_STATE_CHANGES |= 16;
		return;
	}
}

extern unsigned char __near ram_7f0b;

void AudioInit_CheckMIDIStatus(void)
{
	if (ram_7f0b != 0) {
		AUDIO_STATE[123] = 0;
		AUDIO_STATE[124] = 255;
		AUDIO_STATE_CHANGES |= 32;
		return;
	}
	AUDIO_STATE[123] = 255;
	AUDIO_STATE[124] = 255;
	AUDIO_STATE_CHANGES |= 32;
}
