/* Helper R, round 1 of 2026-11-20: modules 7 / 159 / 184 / 193 (display/scoop_display.s,
   storage/flash_floppy_handlers.s, factory_test/test_init.s, ui/ui_playback_modes.s).  Form a. */

extern void ChannelFilter_SetMode(void);
extern void ChannelFilter_ApplyWrapper(void);
extern unsigned int __near ram_1108;
extern unsigned char ram_1e8800[];
extern long __near MSP_SETTINGS;
extern void format_FD(unsigned int);
extern char FDTest_Format2ddAndLabel_Str_TEST_HAMA[];
extern int FileIO_CheckPathAndVolumeLabel(char *);
extern unsigned char __near PLAYBACK_START_ARMED;

void ChannelFilter_InitAndApply(void)
{
  ChannelFilter_SetMode();
  ChannelFilter_ApplyWrapper();
  ram_1108 = 0;
}

void FileHdr_InitBasePointer(void)
{
  MSP_SETTINGS = (long)ram_1e8800;
}

int FDTest_Format2ddAndLabel(void)
{
  format_FD(2);
  FileIO_CheckPathAndVolumeLabel(FDTest_Format2ddAndLabel_Str_TEST_HAMA);
  return 0;
}

void PlayMode_ClearModeFlag(void)
{
  PLAYBACK_START_ARMED = 0;
}

void DpMdlyPd_DisarmStartCountdown(void)
{
  PLAYBACK_START_ARMED = 0;
}
