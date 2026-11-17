/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_14m232.c (2026-11-16-100-p6-r19)
   sha256 b5c38cb9e43a3631f9fd76c608f47f2f41b66081cae679390eebe9933612b9ff (tar-sha256); compiled at -Xr */
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
