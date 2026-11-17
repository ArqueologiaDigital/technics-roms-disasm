/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/bmdredit_routines_m232.c (2026-11-16-111-p6-r22-staged)
   sha256 08d180327d39612b36806070e17419d5ff27e6973cb45f2ed75fb40b17d07ac7 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned char BmDrEdit_CheckAndSelectChannel(void);
extern void BmDrEdit_ValidateAndProcessVoice(unsigned int, unsigned int, unsigned int *);
extern unsigned int __near ram_2863;
extern unsigned int __near ram_272a;
extern unsigned char __near BMDREDIT_CHANNEL;
unsigned int BmDrEdit_SyncChannelAndGetPos(void)
{
	unsigned int r;
	unsigned char h;

	ram_2863 = ram_272a;
	h = BmDrEdit_CheckAndSelectChannel();
	BmDrEdit_ValidateAndProcessVoice((unsigned char)(BMDREDIT_CHANNEL + 1), h, &r);
	return r;
}
