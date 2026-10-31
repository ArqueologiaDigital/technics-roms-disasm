/* naka_master_style_link.ld — Linker script for naka_master_style.c  * v7 addresses where v7's own bytes agree:
 * scripts/generators/generate_v7_naka_link_scripts.py
 */

ENTRY(0)

SECTIONS {
    .text 0xED27E8 : SUBALIGN(1) { *(.text*) *(.rodata*) }
    /DISCARD/ : { *(.comment) *(.note*) *(.eh_frame*) }
}

/* Linked widget descriptors */
NakaParam_VariScreen                     = 0x00ED1FCA;
NakaParam_RVariScreen                    = 0x00ED203C;
ParamStr_Table_09                        = 0x00ED2138;
NakaParam_AcChordBox                     = 0x00ED20AE;
NakaParam_AcFreeSplitBox                 = 0x00ED20B4;
NakaParam_AcBkNoBox                      = 0x00ED20BA;
NakaParam_AcPmBkNoBox                    = 0x00ED20C0;
NakaParam_PmBankScreen                   = 0x00ED21BC;
ParamStr_Table_10                        = 0x00ED20C6;
ParamStr_Table_11                        = 0x00ED2110;
ParamStr_Table_12                        = 0x00ED212A;
ParamStr_Table_13                        = 0x00ED2172;
NakaParam_IvPmemWindowPageCtl            = 0x00ED21BA;
NakaParam_IvMstStyleWindowPgCtl          = 0x00ED21CA;
NakaParam_AcTchSensGridBox               = 0x00ED21DA;
ParamStr_Table_14                        = 0x00ED21EA;
ParamStr_Table_15                        = 0x00ED2216;
ParamStr_Table_16                        = 0x00ED2242;
ParamStr_Table_17                        = 0x00ED226E;
NakaParam_AcMstStyleAlpGridBox           = 0x00ED229A;
ParamStr_Table_18                        = 0x00ED233C;
NakaParam_AcMstStyle1SubGridBox          = 0x00ED23B8;
ParamStr_Table_20                        = 0x00ED2424;
ParamStr_Table_21                        = 0x00ED249A;
NakaParam_AcMstSong2GridBox              = 0x00ED2562;
ParamStr_Table_22                        = 0x00ED25CC;
ParamStr_Table_23                        = 0x00ED268C;
ParamStr_Table_24                        = 0x00ED26CC;

/* NakaInst/NakaDesc string blocks */
NakaInst_AcMstSugAlpGridBox              = 0x00ED2A9E;
NakaDesc_AcDispTimeSetGridBox            = 0x00ED2AB4;
NakaInst_AcDispTimeSetGridBox            = 0x00ED2AB8;
NakaDesc_AcPmExpFilterGridBox            = 0x00ED2ACE;
NakaInst_AcPmExpFilterGridBox            = 0x00ED2AD2;
NakaDesc_AcFSWAssGridBox                 = 0x00ED2AE2;
NakaInst_AcFSWAssGridBox                 = 0x00ED2AE6;
NakaDesc_AcTchSensGridBox                = 0x00ED2AF8;
NakaInst_AcTchSensGridBox                = 0x00ED2AFA;
NakaDesc_IvMstStyleWindowPgCtl           = 0x00ED2B10;
NakaInst_IvMstStyleWindowPgCtl           = 0x00ED2B12;
NakaDesc_IvPmemWindowPageCtl             = 0x00ED2B26;
NakaInst_IvPmemWindowPageCtl             = 0x00ED2B28;
NakaDesc_IvWindowPageControl             = 0x00ED2B3C;
NakaInst_IvWindowPageControl             = 0x00ED2B42;
NakaDesc_PmemModeBox                     = 0x00ED2B4E;
NakaInst_PmemModeBox                     = 0x00ED2B54;
NakaDesc_MsaModeScreen                   = 0x00ED2B62;
NakaInst_MsaModeScreen                   = 0x00ED2B66;
NakaDesc_AcPmBkEditBox                   = 0x00ED2B74;
NakaInst_AcPmBkEditBox                   = 0x00ED2B7C;
NakaDesc_PmBankScreen                    = 0x00ED2B8A;
NakaInst_PmBankScreen                    = 0x00ED2B8C;
NakaDesc_AcPmBkNoBox                     = 0x00ED2B96;
NakaInst_AcPmBkNoBox                     = 0x00ED2B98;
NakaDesc_AcBkNoBox                       = 0x00ED2BA0;
NakaInst_AcBkNoBox                       = 0x00ED2BA2;
NakaDesc_AcFreeSplitBox                  = 0x00ED2BB0;
NakaInst_AcFreeSplitBox                  = 0x00ED2BB2;
NakaDesc_AcChordBox                      = 0x00ED2BBC;
NakaInst_AcChordBox                      = 0x00ED2BBE;
NakaDesc_AcTransposeBox                  = 0x00ED2BCC;
NakaInst_AcTransposeBox                  = 0x00ED2BD6;
NakaDesc_RVariScreen                     = 0x00ED2BE2;
NakaInst_RVariScreen                     = 0x00ED2BEC;
NakaDesc_VariScreen                      = 0x00ED2BF8;
NakaInst_VariScreen                      = 0x00ED2BFA;

/* Proc handler functions */
PmemExpLng_Boundary                      = 0x00FB776A;
AcMstStyleAlp_Boundary                   = 0x00FB7771;
MstStyle1Grid_Boundary                   = 0x00FB8B0B;
MstStyle1SubGrid_Boundary                = 0x00FB903D;
MstStyle2Grid_Boundary                   = 0x00FB978D;
MstGrid2_Boundary                        = 0x00FB9E20;
MstSong1Grid_Boundary                    = 0x00FBA6E8;
MstSong2Grid_Boundary                    = 0x00FB9E2E;
TchSensGrid_Boundary                     = 0x00FBA7BB;
FSWAssGrid_Boundary                      = 0x00FBAD9B;
IvPmemWindow_Boundary                    = 0x00FBB10F;
PmemPageCtl_Boundary                     = 0x00FBB28B;
PmExpFilterCheck_Boundary                = 0x00FBC412;
NormScreen_Boundary                      = 0x00FBC530;
IvWindowPgCtl_Boundary                   = 0x00FBD022;
MssName_Boundary                         = 0x00FBD3EC;
AcPmBkNoBox_Boundary                     = 0x00FBD4EB;
AcBkNoBox_Boundary                       = 0x00FBD5C3;
MsaMode_Boundary                         = 0x00FBD841;
PmemMode_Boundary                        = 0x00FBDB3D;
GmOnOff_Boundary                         = 0x00FBE1E7;
IsHalfRangeAbove_End                     = 0x00FBF518;
RVari_UpdateNotify_End                   = 0x00FC1161;
PmBank_Boundary                          = 0x00FC1665;
MainMssSetUp_End                         = 0x00FC244A;
AcTranspose_ParamData_End                = 0x00FC2602;
AcChordBoxProc                     = 0x00FC26FA;
