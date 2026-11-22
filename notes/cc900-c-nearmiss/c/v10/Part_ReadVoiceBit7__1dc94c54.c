/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_W_21r2m234a.c (2026-11-21-9-p6-r64)
   sha256 1dc94c54d9af65fddb59288ee7e3432f99fe311ae82b9aa577571452715500ab (tar-sha256); compiled at -Xr */
extern unsigned char Part_ReadByteDirect(unsigned int, unsigned int);
unsigned char Part_ReadVoiceBit7(unsigned char a, unsigned char c)
{
  return Part_ReadByteDirect(a, (c *= 3, c -= 3, c += 0xd0)) & 0x80;
}
