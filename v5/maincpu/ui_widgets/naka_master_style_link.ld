/* naka_master_style_link.ld — Linker script for naka_master_style.c  * v7 addresses where v7's own bytes agree:
 * scripts/generators/generate_v7_naka_link_scripts.py
 */

ENTRY(0)

SECTIONS {
    .text 0xED27E8 : SUBALIGN(1) { *(.text*) *(.rodata*) }
    /DISCARD/ : { *(.comment) *(.note*) *(.eh_frame*) }
}

/* Linked widget descriptors */
NakaParam_VariScreen                     = 0x00ED1FB2;
NakaParam_RVariScreen                    = 0x00ED2024;
ParamStr_Table_09                        = 0x00ED2138;
NakaParam_AcChordBox                     = 0x00ED2096;
NakaParam_AcFreeSplitBox                 = 0x00ED209C;
NakaParam_AcBkNoBox                      = 0x00ED20A2;
NakaParam_AcPmBkNoBox                    = 0x00ED20A8;
NakaParam_PmBankScreen                   = 0x00ED21BC;
ParamStr_Table_10                        = 0x00ED20AE;
ParamStr_Table_11                        = 0x00ED20F8;
ParamStr_Table_12                        = 0x00ED2112;
ParamStr_Table_13                        = 0x00ED215A;
NakaParam_IvPmemWindowPageCtl            = 0x00ED21A2;
NakaParam_IvMstStyleWindowPgCtl          = 0x00ED21B2;
NakaParam_AcTchSensGridBox               = 0x00ED21C2;
ParamStr_Table_14                        = 0x00ED21D2;
ParamStr_Table_15                        = 0x00ED21FE;
ParamStr_Table_16                        = 0x00ED222A;
ParamStr_Table_17                        = 0x00ED2256;
NakaParam_AcMstStyleAlpGridBox           = 0x00ED2282;
ParamStr_Table_18                        = 0x00ED2324;
NakaParam_AcMstStyle1SubGridBox          = 0x00ED23A0;
ParamStr_Table_20                        = 0x00ED240C;
ParamStr_Table_21                        = 0x00ED2482;
NakaParam_AcMstSong2GridBox              = 0x00ED254A;
ParamStr_Table_22                        = 0x00ED25B4;
ParamStr_Table_23                        = 0x00ED2674;
ParamStr_Table_24                        = 0x00ED26B4;

/* NakaInst/NakaDesc string blocks */
NakaInst_AcMstSugAlpGridBox              = 0x00ED2A86;
NakaDesc_AcDispTimeSetGridBox            = 0x00ED2A9C;
NakaInst_AcDispTimeSetGridBox            = 0x00ED2AA0;
NakaDesc_AcPmExpFilterGridBox            = 0x00ED2AB6;
NakaInst_AcPmExpFilterGridBox            = 0x00ED2ABA;
NakaDesc_AcFSWAssGridBox                 = 0x00ED2ACA;
NakaInst_AcFSWAssGridBox                 = 0x00ED2ACE;
NakaDesc_AcTchSensGridBox                = 0x00ED2AE0;
NakaInst_AcTchSensGridBox                = 0x00ED2AE2;
NakaDesc_IvMstStyleWindowPgCtl           = 0x00ED2AF8;
NakaInst_IvMstStyleWindowPgCtl           = 0x00ED2AFA;
NakaDesc_IvPmemWindowPageCtl             = 0x00ED2B0E;
NakaInst_IvPmemWindowPageCtl             = 0x00ED2B10;
NakaDesc_IvWindowPageControl             = 0x00ED2B24;
NakaInst_IvWindowPageControl             = 0x00ED2B2A;
NakaDesc_PmemModeBox                     = 0x00ED2B36;
NakaInst_PmemModeBox                     = 0x00ED2B3C;
NakaDesc_MsaModeScreen                   = 0x00ED2B4A;
NakaInst_MsaModeScreen                   = 0x00ED2B4E;
NakaDesc_AcPmBkEditBox                   = 0x00ED2B5C;
NakaInst_AcPmBkEditBox                   = 0x00ED2B64;
NakaDesc_PmBankScreen                    = 0x00ED2B72;
NakaInst_PmBankScreen                    = 0x00ED2B74;
NakaDesc_AcPmBkNoBox                     = 0x00ED2B7E;
NakaInst_AcPmBkNoBox                     = 0x00ED2B80;
NakaDesc_AcBkNoBox                       = 0x00ED2B88;
NakaInst_AcBkNoBox                       = 0x00ED2B8A;
NakaDesc_AcFreeSplitBox                  = 0x00ED2B98;
NakaInst_AcFreeSplitBox                  = 0x00ED2B9A;
NakaDesc_AcChordBox                      = 0x00ED2BA4;
NakaInst_AcChordBox                      = 0x00ED2BA6;
NakaDesc_AcTransposeBox                  = 0x00ED2BB4;
NakaInst_AcTransposeBox                  = 0x00ED2BBE;
NakaDesc_RVariScreen                     = 0x00ED2BCA;
NakaInst_RVariScreen                     = 0x00ED2BD4;
NakaDesc_VariScreen                      = 0x00ED2BE0;
NakaInst_VariScreen                      = 0x00ED2BE2;

/* Proc handler functions */
PmemExpLng_Boundary                      = 0x00FB7423;
AcMstStyleAlp_Boundary                   = 0x00FB742A;
MstStyle1Grid_Boundary                   = 0x00FB8B0B;
MstStyle1SubGrid_Boundary                = 0x00FB903D;
MstStyle2Grid_Boundary                   = 0x00FB978D;
MstGrid2_Boundary                        = 0x00FB9AD9;
MstSong1Grid_Boundary                    = 0x00FBA6E8;
MstSong2Grid_Boundary                    = 0x00FB9AE7;
TchSensGrid_Boundary                     = 0x00FBA7BB;
FSWAssGrid_Boundary                      = 0x00FBAD9B;
IvPmemWindow_Boundary                    = 0x00FBADC8;
PmemPageCtl_Boundary                     = 0x00FBAF44;
PmExpFilterCheck_Boundary                = 0x00FBC412;
NormScreen_Boundary                      = 0x00FBC1E9;
IvWindowPgCtl_Boundary                   = 0x00FBD022;
MssName_Boundary                         = 0x00FBD3EC;
AcPmBkNoBox_Boundary                     = 0x00FBD4EB;
AcBkNoBox_Boundary                       = 0x00FBD5C3;
MsaMode_Boundary                         = 0x00FBD841;
PmemMode_Boundary                        = 0x00FBDB3D;
GmOnOff_Boundary                         = 0x00FBE1E7;
IsHalfRangeAbove_End                     = 0x00FBF518;
RVari_UpdateNotify_End                   = 0x00FC0E1A;
PmBank_Boundary                          = 0x00FC131E;
MainMssSetUp_End                         = 0x00FC2103;
AcTranspose_ParamData_End                = 0x00FC22BB;
AcChordBoxProc_Entry                     = 0x00FC23B3;
