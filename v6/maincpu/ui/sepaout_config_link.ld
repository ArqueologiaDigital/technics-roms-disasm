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
Display_InitGraphicsAndScreen  = 0x00F22139;
Display_CallConditionalCompare = 0x00F2215F;
Display_CallPollAudioUpdate    = 0x00F2216C;
SqTrSel_CaseA                 = 0x00F22179;

/* Language check string pointers */
PartSelLangCheck      = 0x00F2A74A;
AfterLangCheck        = 0x00F2A75B;
TrAsPreLangCheck      = 0x00F2A76C;
AtentionLangCheck     = 0x00F2A77D;
AreYouSureLangCheck   = 0x00F2A78E;
GmOnSureLangCheck     = 0x00F2A79F;
GmOffSureLangCheck    = 0x00F2A7B0;
TrAsSureLangCheck     = 0x00F2A7C1;

/* Sequencer/song function handlers */
SqTrAsPsSongFunc      = 0x00F2CAA6;
DemoSongSelFunc       = 0x00F2CA34;
SmfMuteChSelFunc      = 0x00F2CA45;
SqAftSetFunc          = 0x00F2CB06;
MuteChSetFunc         = 0x00F2CB6B;
SMFMuteOnOffFunc      = 0x00F2CC54;
Rt1MuteFunc           = 0x00F2CCD9;
Rt2MuteFunc           = 0x00F2CD18;
DocOrchMuteFunc       = 0x00F2CD57;
PdOrchMuteFunc        = 0x00F2CD97;
SeqNamingCheck        = 0x00F2CE01;
SeqNameOKFunc         = 0x00F2CDD7;
TrAsGridCheck         = 0x00F2C295;
DemoMedDspCheck       = 0x00F2CED0;
DPPlayDspCheck        = 0x00F2CF48;
DPPauseDspCheck       = 0x00F2CFC0;

/* UI box region boundary/end labels */
ComposerBox_End               = 0x00F2B3C1;
MeasureBoxFunc                = 0x00F2B4B8;
MeasureBoxFunc_End            = 0x00F2B4EE;
AcDiskFileName_End            = 0x00F2B595;
AcDocSongName_End             = 0x00F2B78A;
AcPDSongName_End              = 0x00F2B8D8;
AcSmfFileName_End             = 0x00F2B63C;
AcSmfSongName_End             = 0x00F2B6E3;
AcDocFileNo_End               = 0x00F2B831;
IvNamingExitProc              = 0x00F2B97F;
TrAsGridChk_End               = 0x00F2C7BB;
AcDemoSong_End                = 0x00F2C919;
AcCurSong_End                 = 0x00F2C98D;
VoiceConfig_End               = 0x00F2C87A;
TrAsGrid_BoxProc              = 0x00F2BD3C;
SqAftSetFunc_End              = 0x00F2CBF8;
Audio_ExternalCallback_End    = 0x00F2A850;
LyricsBoxFuncProc_Boundary    = 0x00F2B028;
LyricsBoxFunc_End             = 0x00F2B1E3;
SongNameBox_End               = 0x00F2B2D2;
SeqNameOK_End                 = 0x00F2CE5A;
DemoMedDsp_End                = 0x00F2D038;

/* Debug string pointer */
DbgStr_PartSelLangCheck       = 0x00E206FC;
