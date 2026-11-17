/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/midi_dispatch_handlers_m286.c (2026-11-16-111-p6-r22-staged)
   sha256 50fe3fc4ceceb3ffe0199fe0e069a8546a863d08b5f562b58bc535771eb6a352 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ram_bc7c;
extern unsigned char __near ram_bc64;
extern unsigned char __near ram_bc66;
extern unsigned char __near ram_bc68;
extern unsigned char __near ram_bc6a;
extern unsigned char __near ram_bc6c;
extern unsigned char __near ram_bc6e;
extern unsigned char __near ram_bc70;
extern unsigned char __near ram_bc72;
extern unsigned char __near ram_bc74;
extern unsigned char __near ram_bc76;
extern unsigned char __near ram_bc78;
extern unsigned char __near ram_bc7a;
void MidiSeq_SyncToneStates_Upper(void)
{
    if (ram_bc7c & 0x40) {
        ram_bc64 &= ~0x80;
        ram_bc66 = ram_bc64;
        ram_bc68 &= ~0x80;
        ram_bc6a = ram_bc68;
        ram_bc6c &= ~0x80;
        ram_bc6e = ram_bc6c;
    } else {
        ram_bc70 &= ~0x80;
        ram_bc72 = ram_bc70;
        ram_bc74 &= ~0x80;
        ram_bc76 = ram_bc74;
        ram_bc78 &= ~0x80;
        ram_bc7a = ram_bc78;
    }
}
