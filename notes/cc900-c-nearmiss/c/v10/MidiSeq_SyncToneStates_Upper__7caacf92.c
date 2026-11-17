/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_15a.c (2026-11-16-100-p6-r19)
   sha256 7caacf92b81c580e558ace02d13d4a4484a651c893c11e49cb579bb494e4fe60 (tar-sha256); compiled at -O3 -XS -Xr */
extern unsigned char __near ram_bd18;
extern unsigned char __near ram_bd00;
extern unsigned char __near ram_bd02;
extern unsigned char __near ram_bd04;
extern unsigned char __near ram_bd06;
extern unsigned char __near ram_bd08;
extern unsigned char __near ram_bd0a;
extern unsigned char __near ram_bd0c;
extern unsigned char __near ram_bd0e;
extern unsigned char __near ram_bd10;
extern unsigned char __near ram_bd12;
extern unsigned char __near ram_bd14;
extern unsigned char __near ram_bd16;
void MidiSeq_SyncToneStates_Upper(void)
{
    if (ram_bd18 & 0x40) {
        ram_bd00 &= ~0x80;
        ram_bd02 = ram_bd00;
        ram_bd04 &= ~0x80;
        ram_bd06 = ram_bd04;
        ram_bd08 &= ~0x80;
        ram_bd0a = ram_bd08;
    } else {
        ram_bd0c &= ~0x80;
        ram_bd0e = ram_bd0c;
        ram_bd10 &= ~0x80;
        ram_bd12 = ram_bd10;
        ram_bd14 &= ~0x80;
        ram_bd16 = ram_bd14;
    }
}
