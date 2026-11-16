/* Functions of file_io/smf_operations.s.  Firmware C (cc900 phase 6), built by scripts/build/cc900_firmware_c.py with
   the cc900 reference model; no Toshiba program.
   Built at -O3 -XS -Xr (the default): V4.23 reproduces TrimAndPadSmfFilename's first 42 bytes only with -O
   (corpus/firmware/p6_m3.c trim_a, run 2026-11-16-9-p6-m3).  Its padding loop's entry test is the firmware rule
   loop-entry-copy (KN_LOOP_INVERT, notes/cc900-compat-plan-2026-11-08/rules.md), which the build switches on. */

/* The name, in place: '~' becomes '_', a control character a space; then spaces up to the width n and a NUL at
   n.  p reads, s writes; they start equal. */
void TrimAndPadSmfFilename(unsigned char *s, unsigned int n)
{
    unsigned int i = 0;
    unsigned char *p = s;
    unsigned char c;
    while (i < n && (c = *p) != 0) {
        if (c == '~') c = '_';
        else { c = *s; if (c >= ' ') goto next; c = ' '; }
        *s = c;
    next:
        i++; s++; p++;
    }
    while (i < n) { *s++ = ' '; i++; }
    *s = 0;
}
