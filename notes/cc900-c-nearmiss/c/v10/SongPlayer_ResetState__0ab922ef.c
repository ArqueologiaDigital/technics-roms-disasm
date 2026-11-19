/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/note_voice_mapping_m302_xr.c (2026-11-19-43-p6-r48)
   sha256 0ab922ef8dd17dc62f22cface2265accd37394de7139b23a1c84ade0a49cda2c (tar-sha256); compiled at -O3 -Xr
   cc900-options: -Xr */
extern unsigned char __near ram_e9e4;
extern long __near ram_e9e7;
extern long __near ram_e9f5;
extern unsigned int __near ram_e9e5;
extern long __near ram_e9eb;
extern unsigned int __near ram_e9ef;
extern unsigned int __near ram_e9f1;
extern long __near ram_ebfd;
extern unsigned int __near ram_ec01;
extern unsigned char __near ram_e9c4;
extern void FileIO_InitTrackSlots(void);
extern void SysexRingBuf_Init(void);
extern void MidiRingBuf_Init(void);
void SongPlayer_ResetState(void)
{
	ram_e9e4 = 0;
	ram_e9e7 = 0;
	ram_e9f5 = 0;
	ram_e9e5 = 0;
	ram_e9eb = 0;
	ram_e9ef = 0;
	ram_e9f1 = 0;
	ram_ebfd = 0;
	ram_ec01 = 0;
	ram_e9c4 = 0;
	FileIO_InitTrackSlots();
	SysexRingBuf_Init();
	MidiRingBuf_Init();
}
