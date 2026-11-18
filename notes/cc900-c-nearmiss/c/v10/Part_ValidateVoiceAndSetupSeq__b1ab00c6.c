/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_21b.c (2026-11-18-1-p6-r33)
   sha256 b1ab00c6f6074ffdf1249fd168f079662716036ebd61b51184421d27b104b138 (tar-sha256); compiled at -O3 -Xr */
extern unsigned int __near SEQ_DATA_OFFSET;
extern unsigned int __near SEQ_DATA_BLOCK;
extern unsigned char __near SEQ_ERROR_CODE;
extern unsigned char __near ram_f218[];
extern unsigned int __near ram_f1f8[];
extern void Part_ValidateVoiceChannel(unsigned int);
extern unsigned char SeqData_ReadNextByte(void);
void Part_ValidateVoiceAndSetupSeq(unsigned char a)
{
  unsigned int o, b;
  unsigned char t, k;
  &a;
  Part_ValidateVoiceChannel(a);
  if (SEQ_ERROR_CODE != 0) return;
  k = a - 1;
  o = ram_f218[k];
  if (o < 5 || o > 0xff) goto bad;
  b = ram_f1f8[k];
  if (b > 0x4d8) { SEQ_ERROR_CODE = 10; return; }
  SEQ_DATA_BLOCK = b;
  SEQ_DATA_OFFSET = o;
  t = SeqData_ReadNextByte();
  if (t != 0x82 && t != 0x84) {
bad:
    SEQ_ERROR_CODE = 11;
    return;
  }
  SEQ_ERROR_CODE = 0;
}
