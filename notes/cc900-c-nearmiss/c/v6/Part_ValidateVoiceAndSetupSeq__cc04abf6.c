/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/sequencer_engine_m234.c (2026-11-18-12-p6-r35)
   sha256 cc04abf6bd9183372ea4d401207ba7bbb922d5b7b56a23aa7e7eddfefd39244d (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
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
  unsigned char t;
  Part_ValidateVoiceChannel(a);
  if (SEQ_ERROR_CODE != 0) return;
  o = ram_f218[(unsigned char)(a - 1)];
  if (o < 5 || o > 0xff) goto bad;
  b = ram_f1f8[(unsigned char)(a - 1)];
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
