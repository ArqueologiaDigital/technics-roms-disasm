/* lane_p6 helper Q, round 30r1, form b: module 295 (audio/audioinit_routines.s), the AudioInit_Compare* passes of
   AudioInit_DispatchChanges (roots30_Q): each compares a field of AUDIO_STATE with its sent copy AUDIO_STATE_SENT
   and queues a command {cmd, index, new, old} (AudioInit_QueueCommand, char arguments, RETD 2) for each that differs.
   AudioInit_ComparePartStates (265 B), AudioInit_CompareChannelMappings (221 B), AudioInit_ComparePartAssignment
   (198 B), AudioInit_CompareChannelConfig (93 B), AudioInit_CompareVolumeTable (93 B), AudioInit_InitPartSendLevels
   (77 B).  Form b: AUDIO_STATE on the left of every compare (form a has the sent copy on the left).
   cc900-options: -Xr
*/
/* cc900-name: AudioInit_CompareChanMappings=AudioInit_CompareChannelMappings */
/* cc900-module: AudioInit_QueueCommand */

struct part_flags {
	unsigned char r0:4;
	unsigned char b4:1;
	unsigned char r5:1;
	unsigned char b6:1;
	unsigned char r7:1;
	unsigned char hi;
};
struct audio_state {
	unsigned char pad0[4];
	unsigned char assign[26];
	unsigned char pad30[6];
	unsigned char part[26];
	unsigned char pad62[6];
	unsigned char vol[26];
	unsigned char pad94[38];
	unsigned char chcfg[16];
	unsigned char chmap[16];
	unsigned char pad180[2];
	unsigned char pan182;
	unsigned char pad183[5];
	unsigned char b188;
	unsigned char b189;
	unsigned char pad190[102];
	struct part_flags pf[26];
	unsigned char pad344[14];
};
struct send_level {
	unsigned char level;
	unsigned char b1;
};
extern struct audio_state __near AUDIO_STATE;
extern struct audio_state __near AUDIO_STATE_SENT;
extern unsigned int __near AUDIO_STATE_CHANGES;
extern struct send_level __near ram_c62a[];
extern struct send_level __near ram_ca6a[];
extern void AudioInit_QueueCommand(unsigned char, unsigned char, unsigned char, unsigned char);
extern void AudioInit_ComparePartStates(void);
extern void AudioInit_CompareChanMappings(void);
extern void AudioInit_ComparePartAssignment(void);
extern void AudioInit_CompareChannelConfig(void);
extern void AudioInit_CompareVolumeTable(void);
extern void AudioInit_InitPartSendLevels(void);

void AudioInit_ComparePartStates(void)
{
	unsigned int i;

	if (AUDIO_STATE_CHANGES & 8) {
		for (i = 0; i < 26; i++) {
			if (AUDIO_STATE.part[i] != AUDIO_STATE_SENT.part[i])
				AudioInit_QueueCommand(0, i, AUDIO_STATE.part[i], AUDIO_STATE_SENT.part[i]);
			else if (AUDIO_STATE.part[i] != 0xff && AUDIO_STATE.pf[i].b6 != AUDIO_STATE_SENT.pf[i].b6)
				AudioInit_QueueCommand(0, i, 0xff, AUDIO_STATE.part[i]);
		}
		if (AUDIO_STATE.pf[0].b4 != AUDIO_STATE_SENT.pf[0].b4)
			AudioInit_QueueCommand(0, 0, 0xff, AUDIO_STATE.part[0]);
	}
	if (AUDIO_STATE_CHANGES & 0x100) {
		if (AUDIO_STATE.pan182 != AUDIO_STATE_SENT.pan182)
			AudioInit_QueueCommand(1, 0, AUDIO_STATE.pan182, AUDIO_STATE_SENT.pan182);
	}
}

void AudioInit_CompareChanMappings(void)
{
	unsigned int i;

	if (AUDIO_STATE_CHANGES & 0xc0) {
		for (i = 0; i < 16; i++) {
			if (AUDIO_STATE.chmap[i] != AUDIO_STATE_SENT.chmap[i])
				AudioInit_QueueCommand(3, i, AUDIO_STATE.chmap[i], AUDIO_STATE_SENT.chmap[i]);
			if (AUDIO_STATE.chcfg[i] != AUDIO_STATE_SENT.chcfg[i])
				AudioInit_QueueCommand(4, i, AUDIO_STATE.chcfg[i], AUDIO_STATE_SENT.chcfg[i]);
		}
	}
	if (AUDIO_STATE_CHANGES & 0x100) {
		if (AUDIO_STATE.pan182 != AUDIO_STATE_SENT.pan182)
			AudioInit_QueueCommand(5, 0, AUDIO_STATE.pan182, AUDIO_STATE_SENT.pan182);
	}
}

void AudioInit_ComparePartAssignment(void)
{
	unsigned int i;

	for (i = 0; i < 26; i++) {
		if (AUDIO_STATE.assign[i] == AUDIO_STATE_SENT.assign[i])
			continue;
		if (i == 2 && AUDIO_STATE.assign[i] != 0xff && AUDIO_STATE.b188 == 2 && AUDIO_STATE_SENT.b188 != 2)
			continue;
		if (i == 21 && AUDIO_STATE.assign[i] != 0xff && AUDIO_STATE.b188 == 21 && AUDIO_STATE_SENT.b188 != 21)
			continue;
		if (i == 22 && AUDIO_STATE.assign[i] != 0xff && AUDIO_STATE.b189 == 22 && AUDIO_STATE_SENT.b189 != 22)
			continue;
		AudioInit_QueueCommand(7, i, AUDIO_STATE.assign[i], AUDIO_STATE_SENT.assign[i]);
	}
}

void AudioInit_CompareChannelConfig(void)
{
	unsigned int i;

	for (i = 0; i < 16; i++) {
		if (AUDIO_STATE.chcfg[i] != AUDIO_STATE_SENT.chcfg[i])
			AudioInit_QueueCommand(9, i, AUDIO_STATE.chcfg[i], AUDIO_STATE_SENT.chcfg[i]);
	}
}

void AudioInit_CompareVolumeTable(void)
{
	unsigned int i;

	for (i = 0; i < 26; i++) {
		if (AUDIO_STATE.vol[i] != AUDIO_STATE_SENT.vol[i])
			AudioInit_QueueCommand(10, i, AUDIO_STATE.vol[i], AUDIO_STATE_SENT.vol[i]);
	}
}

void AudioInit_InitPartSendLevels(void)
{
	unsigned int i;

	for (i = 0; i < 161; i++) {
		ram_c62a[i].level = 16;
		ram_c62a[i].b1 = 0;
	}
	ram_ca6a[0].level = 8;
	ram_ca6a[0].b1 = 0;
	ram_ca6a[1].level = 8;
	ram_ca6a[1].b1 = 0;
	ram_ca6a[2].level = 16;
	ram_ca6a[2].b1 = 0;
}
