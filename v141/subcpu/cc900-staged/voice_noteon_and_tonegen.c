/* Functions of core/08_voice_noteon_and_tonegen.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function at -Xr (notes/cc900-c-subcpu-2026-11-16/);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   cc900-options: -Xr */
void BlockCopy_Words_BC_to_HL(unsigned char *s, unsigned char *d, unsigned int n)
{
    unsigned int i;
    for (i = 0; i < n; i++) *d++ = *s++;
}
