/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/midi_dispatch_handlers_m286.c (2026-11-16-111-p6-r22-staged)
   sha256 9f3eac398ca661b95d76beb22d80a3909e069044ad0e871e70dfe72c2bc86397 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ram_bc58;
extern unsigned char __near ram_bc40;
extern unsigned char __near ram_bc42;
extern unsigned char __near ram_bc44;
extern unsigned char __near ram_bc46;
extern unsigned char __near ram_bc48;
extern unsigned char __near ram_bc4a;
extern unsigned char __near ram_bc4c;
extern unsigned char __near ram_bc4e;
extern unsigned char __near ram_bc50;
extern unsigned char __near ram_bc52;
extern unsigned char __near ram_bc54;
extern unsigned char __near ram_bc56;
void MidiSeq_SyncToneStates_Upper(void)
{
    if (ram_bc58 & 0x40) {
        ram_bc40 &= ~0x80;
        ram_bc42 = ram_bc40;
        ram_bc44 &= ~0x80;
        ram_bc46 = ram_bc44;
        ram_bc48 &= ~0x80;
        ram_bc4a = ram_bc48;
    } else {
        ram_bc4c &= ~0x80;
        ram_bc4e = ram_bc4c;
        ram_bc50 &= ~0x80;
        ram_bc52 = ram_bc50;
        ram_bc54 &= ~0x80;
        ram_bc56 = ram_bc54;
    }
}
