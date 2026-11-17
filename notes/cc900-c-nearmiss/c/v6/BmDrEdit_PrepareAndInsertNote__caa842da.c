/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/bmdredit_routines_m232.c (2026-11-16-122-p6-r24-staged)
   sha256 caa842da0a49ca6251067b9b9a0d1b370620ba7c554bbe7135868e7b4488a908 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ram_2944;
extern unsigned char __near ram_2945;
extern void BmDrEdit_SaveSongPosition(void);
extern void BmDrEdit_ApplyVelocityChange(unsigned int, unsigned char *, unsigned int);
extern void BmDrEdit_WalkToGridPosition(void);
extern unsigned char __near ram_294d;
extern unsigned char __near ram_294e;
extern unsigned char __near ram_294f;
extern unsigned char __near ram_2950;
extern unsigned char __near ram_294b;
extern unsigned char __near ram_294c;
extern unsigned char __near BMDREDIT_CHANNEL;
extern unsigned int __near ram_2780;
extern unsigned int __near ram_2774;
void BmDrEdit_PrepareAndInsertNote(void)
{
	BmDrEdit_WalkToGridPosition();
	ram_294b = 144;
	ram_294c = ram_2780 % 96;
	ram_294d = ram_2944;
	ram_294e = ram_2945;
	ram_294f = (ram_2774 % 96) & 0x7f;
	ram_2950 = (ram_2774 / 96) & 0x7f;
	BmDrEdit_SaveSongPosition();
	BmDrEdit_ApplyVelocityChange((unsigned char)(BMDREDIT_CHANNEL + 1), (unsigned char *)0x294b, 6);
}
