/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_5m302a.c (2026-11-19-37-p6-r47)
   sha256 3c3bc62b484f6532be956355729368a871ab0e8a31b0bff9a85ff7b71d95a4a4 (tar-sha256); compiled at -O3 -Xr
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
