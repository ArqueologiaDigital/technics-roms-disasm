/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/bmdredit_routines_m232.c (2026-11-16-103-p6-r20-staged)
   sha256 2367aee83142575e41ca80d5e48d26199aab0cc2cce0b19bb1edacc43cb699d3 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned char BmDrEdit_CheckAndSelectChannel(void);
extern void BmDrEdit_ValidateAndProcessVoice(unsigned int, unsigned int, unsigned int *);
extern unsigned int __near ram_287f;
extern unsigned int __near ram_2744;
extern unsigned char __near BMDREDIT_CHANNEL;
unsigned int BmDrEdit_SyncChannelAndGetPos(void)
{
	unsigned int r;
	unsigned char h;

	ram_287f = ram_2744;
	h = BmDrEdit_CheckAndSelectChannel();
	BmDrEdit_ValidateAndProcessVoice((unsigned char)(BMDREDIT_CHANNEL + 1), h, &r);
	return r;
}
