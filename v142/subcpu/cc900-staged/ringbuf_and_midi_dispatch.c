/* Functions of core/11_ringbuf_and_midi_dispatch.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function at -Xr (notes/cc900-c-subcpu-2026-11-16/);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   cc900-options: -Xr */
unsigned int DSP_VelocityToVolume(unsigned int v) { return ((v * v) >> 2) + 0x3f; }
