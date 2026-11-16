/* Functions of file_io/medley.s.  Firmware C (cc900 phase 6), built by scripts/build/cc900_firmware_c.py with the cc900 reference model;
   no Toshiba program.  Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet. */
extern unsigned char ram_888a;
extern char ram_888c;

unsigned char GetPlayState1(void) { return ram_888a; }
unsigned char GetPlayState2(void) { return ram_888c; }
void SmfMedley_RawData(char c) { ram_888c = (c != 0); }

/* E, then 'M' and the song number n + 1 in two digits (three, without the 'M', from 100 up); n = 0xff gives three
   spaces, n = 0xfe 'M' and two spaces.  The goto form gives the ROM's block order (corpus/firmware/p6_m3b.c fmt_e;
   V4.23 gives the same bytes at -O3 -XS -Xr and -Xr, runs 2026-11-16-10-p6-m3b). */
void FormatMedleyNumber(unsigned char *p, unsigned char n, unsigned char first)
{
    *p++ = first;
    if (n == 0xff) n = ' ';
    else if (n == 0xfe) n = 'M';
    else goto number;
    *p++ = n; *p++ = ' '; *p = ' ';
    return;
number:
    n++;
    if (n >= 100) { *p++ = n / 100 + '0'; n = n % 100; }
    else *p++ = 'M';
    if (n < 10) { *p++ = '0'; *p = n + '0'; }
    else { *p++ = n / 10 + '0'; *p = n % 10 + '0'; }
}
