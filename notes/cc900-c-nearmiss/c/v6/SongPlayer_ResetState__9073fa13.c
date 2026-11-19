/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/note_voice_mapping_m302_xr.c (2026-11-19-43-p6-r48)
   sha256 9073fa13940d58008cbebc3600823bedae3eeb1503ab7ae9adcce6fa3a2d20e3 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -Xr */
extern unsigned char __near ram_e8fa;
extern long __near ram_e8fd;
extern long __near ram_e90b;
extern unsigned int __near ram_e8fb;
extern long __near ram_e901;
extern unsigned int __near ram_e905;
extern unsigned int __near ram_e907;
extern long __near ram_eb13;
extern unsigned int __near ram_eb17;
extern unsigned char __near ram_e8da;
extern void FileIO_InitTrackSlots(void);
extern void SysexRingBuf_Init(void);
extern void MidiRingBuf_Init(void);
void SongPlayer_ResetState(void)
{
	ram_e8fa = 0;
	ram_e8fd = 0;
	ram_e90b = 0;
	ram_e8fb = 0;
	ram_e901 = 0;
	ram_e905 = 0;
	ram_e907 = 0;
	ram_eb13 = 0;
	ram_eb17 = 0;
	ram_e8da = 0;
	FileIO_InitTrackSlots();
	SysexRingBuf_Init();
	MidiRingBuf_Init();
}
