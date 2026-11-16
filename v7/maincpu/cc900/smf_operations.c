/* Functions of file_io/smf_operations.s.  Firmware C (cc900 phase 6), built by scripts/build/cc900_firmware_c.py.
   cc900-options: -O3 -Xr
   The firmware's -O files were compiled with -O3 -Xr, without -XS (lane_p6, run 2026-11-16-32-p6-m18): V4.23 then
   copies the padding loop's test to its entry and gives all of TrimAndPadSmfFilename (at -O3 -XS -Xr only its first
   42 bytes, run 2026-11-16-18-p6-firmware).  The reference model writes that as the firmware rule loop-entry-copy
   (KN_LOOP_INVERT, notes/cc900-compat-plan-2026-11-08/rules.md). */

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

extern unsigned char CType_ClassTable[];

void RenderSmfFilename(unsigned char *name, unsigned char len)
{
	int i;

	name[len] = 0;
	for (i = 0; i < 8 && name[i] != 0; i++)
		if (!(CType_ClassTable[name[i]] & 7)) name[i] = 0x5f;
	if (i < 8) do { name[i] = 0x5f; i++; } while (i < 8);
}
