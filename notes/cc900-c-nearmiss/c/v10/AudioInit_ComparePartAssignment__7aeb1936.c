/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_Q_30r1m295b.c (2026-11-22-13-p6-r80)
   sha256 7aeb19360e9ac62fdb71f031131ccf41972886aa933fe89f9e5d93be53918a51 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
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
extern struct audio_state __near AUDIO_STATE;
extern struct audio_state __near AUDIO_STATE_SENT;
extern void AudioInit_QueueCommand(unsigned char, unsigned char, unsigned char, unsigned char);
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
