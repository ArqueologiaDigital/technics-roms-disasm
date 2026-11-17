/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_16m232.c (2026-11-16-118-p6-r23)
   sha256 a1f2035416f0f07618277d0127c7c6434bb33ff1c25975f9e621002b9c0b8651 (tar-sha256); compiled at -O3 -XS -Xr */
extern void BmDrEdit_SaveSongPosition(void);
extern void BmDrEdit_ApplyVelocityChange(unsigned int, unsigned char *, unsigned int);
extern void BmDrEdit_WalkToGridPosition(void);
extern unsigned char __near ram_2969;
extern unsigned char __near ram_296a;
extern unsigned char __near ram_296b;
extern unsigned char __near ram_296c;
extern unsigned char __near ram_2967;
extern unsigned char __near ram_2968;
extern unsigned char __near BMDREDIT_CHANNEL;
extern unsigned char __near ram_2960;
extern unsigned char __near ram_2961;
extern unsigned int __near ram_279a;
extern unsigned int __near ram_278e;
void BmDrEdit_PrepareAndInsertNote(void)
{
	BmDrEdit_WalkToGridPosition();
	ram_2967 = 144;
	ram_2968 = ram_279a % 96;
	ram_2969 = ram_2960;
	ram_296a = ram_2961;
	ram_296b = (ram_278e % 96) & 0x7f;
	ram_296c = (ram_278e / 96) & 0x7f;
	BmDrEdit_SaveSongPosition();
	BmDrEdit_ApplyVelocityChange((unsigned char)(BMDREDIT_CHANNEL + 1), (unsigned char *)0x2967, 6);
}
