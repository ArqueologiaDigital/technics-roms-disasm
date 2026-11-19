/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/note_voice_mapping_m302_xr.c (2026-11-19-43-p6-r48)
   sha256 db00174f69507d744d034d9e106449906078e9cfb923f0e90a98000d7fca5b9c (tar-sha256); compiled at -O3 -Xr
   cc900-options: -Xr */
extern unsigned char __near ram_e91e;
extern long __near ram_e921;
extern long __near ram_e92f;
extern unsigned int __near ram_e91f;
extern long __near ram_e925;
extern unsigned int __near ram_e929;
extern unsigned int __near ram_e92b;
extern long __near ram_eb37;
extern unsigned int __near ram_eb3b;
extern unsigned char __near ram_e8fe;
extern void FileIO_InitTrackSlots(void);
extern void SysexRingBuf_Init(void);
extern void MidiRingBuf_Init(void);
void SongPlayer_ResetState(void)
{
	ram_e91e = 0;
	ram_e921 = 0;
	ram_e92f = 0;
	ram_e91f = 0;
	ram_e925 = 0;
	ram_e929 = 0;
	ram_e92b = 0;
	ram_eb37 = 0;
	ram_eb3b = 0;
	ram_e8fe = 0;
	FileIO_InitTrackSlots();
	SysexRingBuf_Init();
	MidiRingBuf_Init();
}
