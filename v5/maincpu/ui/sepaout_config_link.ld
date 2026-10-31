/* sepaout_config_link.ld -- Linker script for sepaout_config.c
 *
 * Provides absolute symbol addresses for extern references used in the
 * SepaOut configuration data's function pointer tables.
 *
 * Addresses obtained from: llvm-nm --no-sort rebuilt_ROMs/kn5000_v10_program.llvm.elf
  * v7 addresses where v7's own bytes agree:
 * scripts/generators/generate_v7_naka_link_scripts.py
 */

ENTRY(0)

SECTIONS {
    .text : { *(.text*) }
    /DISCARD/ : { *(.comment) *(.note*) *(.eh_frame*) }
}

/* Display/UI handler pointers */
Display_InitGraphicsAndScreen  = 0x00F22121;
Display_CallConditionalCompare = 0x00F22147;
Display_CallPollAudioUpdate    = 0x00F22154;
SqTrSel_CaseA                 = 0x00F22161;

/* Language check string pointers */
PartSelLangCheck      = 0x00F2A6B7;
AfterLangCheck        = 0x00F2A6C8;
TrAsPreLangCheck      = 0x00F2A6D9;
AtentionLangCheck     = 0x00F2A6EA;
AreYouSureLangCheck   = 0x00F2A6FB;
GmOnSureLangCheck     = 0x00F2A70C;
GmOffSureLangCheck    = 0x00F2A71D;
TrAsSureLangCheck     = 0x00F2A72E;

/* Sequencer/song function handlers */
SqTrAsPsSongFunc      = 0x00F2C9CA;
DemoSongSelFunc       = 0x00F2C958;
SmfMuteChSelFunc      = 0x00F2C969;
SqAftSetFunc          = 0x00F2CA2A;
MuteChSetFunc         = 0x00F2CA8F;
SMFMuteOnOffFunc      = 0x00F2CB78;
Rt1MuteFunc           = 0x00F2CBFD;
Rt2MuteFunc           = 0x00F2CC3C;
DocOrchMuteFunc       = 0x00F2CC7B;
PdOrchMuteFunc        = 0x00F2CCBB;
SeqNamingCheck        = 0x00F2CD25;
SeqNameOKFunc         = 0x00F2CCFB;
TrAsGridCheck         = 0x00F2C201;
DemoMedDspCheck       = 0x00F2CDF4;
DPPlayDspCheck        = 0x00F2CE6C;
DPPauseDspCheck       = 0x00F2CEE4;

/* UI box region boundary/end labels */
ComposerBox_End               = 0x00F2B32E;
MeasureBoxFunc                = 0x00F2B425;
MeasureBoxFunc_End            = 0x00F2B45B;
AcDiskFileName_End            = 0x00F2B502;
AcDocSongName_End             = 0x00F2B6F7;
AcPDSongName_End              = 0x00F2B845;
AcSmfFileName_End             = 0x00F2B5A9;
AcSmfSongName_End             = 0x00F2B650;
AcDocFileNo_End               = 0x00F2B79E;
IvNamingExitProc              = 0x00F2B8EC;
TrAsGridChk_End               = 0x00F2C6DF;
AcDemoSong_End                = 0x00F2C83D;
AcCurSong_End                 = 0x00F2C8B1;
VoiceConfig_End               = 0x00F2C79E;
TrAsGrid_BoxProc              = 0x00F2BCA9;
SqAftSetFunc_End              = 0x00F2CB1C;
Audio_ExternalCallback_End    = 0x00F2A7BD;
LyricsBoxFuncProc_Boundary    = 0x00F2AF95;
LyricsBoxFunc_End             = 0x00F2B150;
SongNameBox_End               = 0x00F2B23F;
SeqNameOK_End                 = 0x00F2CD7E;
DemoMedDsp_End                = 0x00F2CF5C;

/* Debug string pointer */
DbgStr_PartSelLangCheck       = 0x00E206FA;
