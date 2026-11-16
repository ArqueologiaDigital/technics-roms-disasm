/* Functions of demo/file_demo_proc.s.  Firmware C (cc900 phase 6), built by scripts/build/cc900_firmware_c.py with the cc900 reference model;
   no Toshiba program.  Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet. */
extern unsigned int ram_272cc, ram_272ce;
extern unsigned int __near ram_7f48;
extern unsigned char ram_272d0, ram_25eaa, ram_271f2, SEQ_SONG_SLOTS;
extern unsigned char __near DEMO_TIMER_COUNTDOWN;
extern void *ram_25b7e;
extern long ram_25d6c, ram_25b8a, FileIO_DiskInfoInit;
extern unsigned int ram_3ec4e, ram_25b8e;

void Demo_ResetCountdownTimer(void) { DEMO_TIMER_COUNTDOWN = 15; }
unsigned int FileIO_FormatName_Done(void) { return ram_272ce; }
void *FileIO_GetRecordByType(void) { return &ram_25eaa; }
void *FileIO_GetRecordPtrAlt(void) { return &ram_271f2; }
unsigned int FileIO_ReturnError(void) { return ram_7f48; }
void FileIO_SetModeFlag_Reading(void) { ram_272d0 = 0; }
void FileIO_SetModeFlag_Writing(void) { ram_272d0 = 1; }
unsigned int FileIO_WriteRecordName_Loop(void) { return ram_272cc; }
void FDemo_ResetAllocBuffer(void) { ram_25b7e = &SEQ_SONG_SLOTS; }
void FileIO_ResetCurrentRecord(void) { ram_25d6c = FileIO_DiskInfoInit; }
void Demo_StoreRecordChainParams(long a, unsigned int b, unsigned int c) { ram_25b8a = a; ram_3ec4e = b; ram_25b8e = c; }
