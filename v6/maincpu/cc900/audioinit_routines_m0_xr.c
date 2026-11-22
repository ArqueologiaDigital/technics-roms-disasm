/* Functions of audio/audioinit_routines.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/
/* cc900-module: AudioInit_QueueCommand */   /* scripts/analysis/cc900/module_calls.py v10 */

struct send_level {
	unsigned char level;
	unsigned char b1;
};
extern struct send_level __near ram_c56a[];
extern struct send_level __near ram_c9aa[];
extern void AudioInit_InitPartSendLevels(void);

void AudioInit_InitPartSendLevels(void)
{
	unsigned int i;

	for (i = 0; i < 161; i++) {
		ram_c56a[i].level = 16;
		ram_c56a[i].b1 = 0;
	}
	ram_c9aa[0].level = 8;
	ram_c9aa[0].b1 = 0;
	ram_c9aa[1].level = 8;
	ram_c9aa[1].b1 = 0;
	ram_c9aa[2].level = 16;
	ram_c9aa[2].b1 = 0;
}
