/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/midi_dispatch_handlers_m288.c (2026-11-16-68-p6-r12)
   sha256 eeea1a2bd476a660613047c2771c0c8cc91b28c8a6a07048ee262d69f9845a4d (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern void MidiTG_WriteRegByDescriptor(unsigned char *);
void TGReg_WriteCC7_Reverb(void)
{
    unsigned char d[4];
    d[1] = 0x7;
    d[2] = 0x28;
    d[3] = 0x7f;
    for (d[0] = 0; d[0] <= 15; d[0]++) MidiTG_WriteRegByDescriptor(d);
}
