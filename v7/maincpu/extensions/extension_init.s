; =============================================================================
; Extension Device Registration (internal codename: "TOSHI")
; =============================================================================
;
; This subsystem registers expansion slot devices (such as the HD-AE5000 hard
; disk board) with the main firmware. It creates object tables, titles, and
; modes for each device so that the UI framework can present extension-specific
; screens and route events to extension handlers.
;
; "TOSHI" is the Matsushita/Technics developer codename for this subsystem.
; All original symbol names (InitializeToshi, etc.) are preserved.
;
; Files in this directory:
;   extension_init.s  - InitializeToshi(): 70+ RegisterObjectTable calls
;   extension_data.s  - Extension device data tables and NAKA descriptors
; =============================================================================

; -----------------------------------------------------------------------------
; The 30 viewable-object tables (ViewableProc, registry slot N) and their
; parallel resource-name tables (ResNameProc, slot N + 0x300) that
; InitializeToshi registers lie inside NakaInst_ExtDevice_Screens
; (ui_widgets/extension_device_screens.s, compiled from naka_extension_device.c),
; which carries no labels at these offsets, so they are named here as offsets
; from it.  Each table is `count` 4-byte pointers plus a NULL (the names: string
; pointers, most of them to "").  The suffix is the title RegTitle registers
; for the same index N below ("TT_CTMENU" for 0x40); slot 0x46 (CTPMPARA) is
; registered with count 0 and holds only the NULL.  Offsets checked against the
; v10 dump; the tables sit at the same addresses in v9 and v7.
; -----------------------------------------------------------------------------
Toshi_Viewable_NORMAL     = NakaInst_ExtDevice_Screens + 0x1002	; slot 0x001, 63 entries
Toshi_ResName_NORMAL      = NakaInst_ExtDevice_Screens + 0x168a	; slot 0x301, 63 entries
Toshi_Viewable_CTMENU     = NakaInst_ExtDevice_Screens + 0x1102	; slot 0x040, 9 entries
Toshi_ResName_CTMENU      = NakaInst_ExtDevice_Screens + 0x182a	; slot 0x340, 9 entries
Toshi_Viewable_CTINIT     = NakaInst_ExtDevice_Screens + 0x112a	; slot 0x041, 17 entries
Toshi_ResName_CTINIT      = NakaInst_ExtDevice_Screens + 0x1870	; slot 0x341, 17 entries
Toshi_Viewable_CTFSWAS    = NakaInst_ExtDevice_Screens + 0x1172	; slot 0x042, 6 entries
Toshi_ResName_CTFSWAS     = NakaInst_ExtDevice_Screens + 0x18f6	; slot 0x342, 6 entries
Toshi_Viewable_CTTOUCH    = NakaInst_ExtDevice_Screens + 0x118e	; slot 0x043, 8 entries
Toshi_ResName_CTTOUCH     = NakaInst_ExtDevice_Screens + 0x192a	; slot 0x343, 8 entries
Toshi_Viewable_MSAMODE    = NakaInst_ExtDevice_Screens + 0x11b2	; slot 0x044, 19 entries
Toshi_ResName_MSAMODE     = NakaInst_ExtDevice_Screens + 0x196a	; slot 0x344, 19 entries
Toshi_Viewable_CTPMMD     = NakaInst_ExtDevice_Screens + 0x1202	; slot 0x045, 19 entries
Toshi_ResName_CTPMMD      = NakaInst_ExtDevice_Screens + 0x19e2	; slot 0x345, 19 entries
Toshi_Viewable_CTPMPARA   = NakaInst_ExtDevice_Screens + 0x1252	; slot 0x046, 0 entries
Toshi_ResName_CTPMPARA    = NakaInst_ExtDevice_Screens + 0x1a62	; slot 0x346, 0 entries
Toshi_Viewable_CTSYSTEM   = NakaInst_ExtDevice_Screens + 0x1256	; slot 0x047, 7 entries
Toshi_ResName_CTSYSTEM    = NakaInst_ExtDevice_Screens + 0x1a68	; slot 0x347, 7 entries
Toshi_Viewable_CTWALLSET  = NakaInst_ExtDevice_Screens + 0x1276	; slot 0x048, 25 entries
Toshi_ResName_CTWALLSET   = NakaInst_ExtDevice_Screens + 0x1aa2	; slot 0x348, 25 entries
Toshi_Viewable_ONETCH     = NakaInst_ExtDevice_Screens + 0x12de	; slot 0x0c0, 4 entries
Toshi_ResName_ONETCH      = NakaInst_ExtDevice_Screens + 0x1b56	; slot 0x3c0, 4 entries
Toshi_Viewable_MUSICSTYL  = NakaInst_ExtDevice_Screens + 0x12f2	; slot 0x0c1, 4 entries
Toshi_ResName_MUSICSTYL   = NakaInst_ExtDevice_Screens + 0x1b7a	; slot 0x3c1, 4 entries
Toshi_Viewable_MSCTSEL    = NakaInst_ExtDevice_Screens + 0x1306	; slot 0x0c2, 20 entries
Toshi_ResName_MSCTSEL     = NakaInst_ExtDevice_Screens + 0x1ba0	; slot 0x3c2, 20 entries
Toshi_Viewable_MSSCTSEL   = NakaInst_ExtDevice_Screens + 0x135a	; slot 0x0c3, 17 entries
Toshi_ResName_MSSCTSEL    = NakaInst_ExtDevice_Screens + 0x1c30	; slot 0x3c3, 17 entries
Toshi_Viewable_MSSONGLIST = NakaInst_ExtDevice_Screens + 0x13a2	; slot 0x0c4, 8 entries
Toshi_ResName_MSSONGLIST  = NakaInst_ExtDevice_Screens + 0x1cac	; slot 0x3c4, 8 entries
Toshi_Viewable_MSALPSEL   = NakaInst_ExtDevice_Screens + 0x13c6	; slot 0x0c5, 7 entries
Toshi_ResName_MSALPSEL    = NakaInst_ExtDevice_Screens + 0x1cec	; slot 0x3c5, 7 entries
Toshi_Viewable_PMBKSEL    = NakaInst_ExtDevice_Screens + 0x13e6	; slot 0x0d0, 6 entries
Toshi_ResName_PMBKSEL     = NakaInst_ExtDevice_Screens + 0x1d24	; slot 0x3d0, 6 entries
Toshi_Viewable_PMVIEW     = NakaInst_ExtDevice_Screens + 0x1402	; slot 0x0d1, 13 entries
Toshi_ResName_PMVIEW      = NakaInst_ExtDevice_Screens + 0x1d54	; slot 0x3d1, 13 entries
Toshi_Viewable_PMNAME     = NakaInst_ExtDevice_Screens + 0x143a	; slot 0x0d2, 7 entries
Toshi_ResName_PMNAME      = NakaInst_ExtDevice_Screens + 0x1dae	; slot 0x3d2, 7 entries
Toshi_Viewable_PMBKNAME   = NakaInst_ExtDevice_Screens + 0x145a	; slot 0x0d3, 7 entries
Toshi_ResName_PMBKNAME    = NakaInst_ExtDevice_Screens + 0x1de4	; slot 0x3d3, 7 entries
Toshi_Viewable_SVARI      = NakaInst_ExtDevice_Screens + 0x147a	; slot 0x0e8, 2 entries
Toshi_ResName_SVARI       = NakaInst_ExtDevice_Screens + 0x1e1c	; slot 0x3e8, 2 entries
Toshi_Viewable_RVARI      = NakaInst_ExtDevice_Screens + 0x1486	; slot 0x0e9, 3 entries
Toshi_ResName_RVARI       = NakaInst_ExtDevice_Screens + 0x1e32	; slot 0x3e9, 3 entries
Toshi_Viewable_TEST1      = NakaInst_ExtDevice_Screens + 0x1496	; slot 0x0f4, 14 entries
Toshi_ResName_TEST1       = NakaInst_ExtDevice_Screens + 0x1e4e	; slot 0x3f4, 14 entries
Toshi_Viewable_TEST2      = NakaInst_ExtDevice_Screens + 0x14d2	; slot 0x0f5, 23 entries
Toshi_ResName_TEST2       = NakaInst_ExtDevice_Screens + 0x1eb6	; slot 0x3f5, 23 entries
Toshi_Viewable_TEST3      = NakaInst_ExtDevice_Screens + 0x1532	; slot 0x0f6, 1 entries
Toshi_ResName_TEST3       = NakaInst_ExtDevice_Screens + 0x1f6a	; slot 0x3f6, 1 entries
Toshi_Viewable_TEST4      = NakaInst_ExtDevice_Screens + 0x153a	; slot 0x0f7, 3 entries
Toshi_ResName_TEST4       = NakaInst_ExtDevice_Screens + 0x1f7a	; slot 0x3f7, 3 entries
Toshi_Viewable_TEST5      = NakaInst_ExtDevice_Screens + 0x154a	; slot 0x0f8, 67 entries
Toshi_ResName_TEST5       = NakaInst_ExtDevice_Screens + 0x1f96	; slot 0x3f8, 67 entries
Toshi_Viewable_TEST6      = NakaInst_ExtDevice_Screens + 0x165a	; slot 0x0f9, 9 entries
Toshi_ResName_TEST6       = NakaInst_ExtDevice_Screens + 0x2156	; slot 0x3f9, 9 entries
Toshi_Viewable_EXT        = NakaInst_ExtDevice_Screens + 0x1682	; slot 0x0fb, 1 entries
Toshi_ResName_EXT         = NakaInst_ExtDevice_Screens + 0x21a2	; slot 0x3fb, 1 entries

InitializeToshi:	.include "includes/generated/cc900/InitializeToshi.s"	; C: cc900/extension_init_m276.c
