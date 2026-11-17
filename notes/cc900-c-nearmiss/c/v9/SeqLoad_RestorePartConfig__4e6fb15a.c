/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/sequencer_engine_m235.c (2026-11-16-68-p6-r12)
   sha256 4e6fb15a9dcef11c657d923eaf017b50a32c6776dde159610f29f481be75a22a (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char Part_ReadByteDirect(unsigned char, unsigned int);
extern void Part_WriteByte(unsigned char, unsigned int, unsigned char);
extern unsigned int Part_ReadWord(unsigned char, unsigned int);
extern void Part_WriteWord(unsigned char, unsigned int, unsigned int);
extern unsigned char SEQ_CURRENT_SONG;
extern unsigned int SEQ_TRACK_MASK_COPY;
extern unsigned int __near SEQ_START_MEASURE;
extern unsigned char __near SEQ_RTMCFG;
void SeqLoad_RestorePartConfig(void)
{
  SEQ_CURRENT_SONG = Part_ReadByteDirect(1, 0xc7);
  Part_WriteByte(1, 0xc7, 0);
  SEQ_TRACK_MASK_COPY = Part_ReadWord(1, 0xc8);
  Part_WriteWord(1, 0xc8, 0);
  SEQ_START_MEASURE = 1;
  SEQ_RTMCFG &= ~0x08;
}
