/**
 * control_menu_header.c — CONTROL MENU screen header (first 9 widgets)
 *
 * Proof-of-concept: NAKA widget descriptors expressed as C structs
 * with named fields instead of raw .byte sequences.
 *
 * Source: control_menu_screens.s lines 3-97
 * ROM address range: 0xED3C96 - 0xED3EE6 (592 bytes)
 *
 * Widgets:
 *   w1: CONTAINER  "CONTROL MENU"
 *   w2: MENU_ITEM  "INITIAL"
 *   w3: MENU_ITEM  "OVERALL TOUCH SENSITIVITY"
 *   w4: MENU_ITEM  "FOOT CONTROLLERS"
 *   w5: MENU_ITEM  "DISPLAY TIME OUT"
 *   w6: MENU_ITEM  "PANEL MEMORY MODE"
 *   w7: TYPE_0x48  (separator/spacer)
 *   w8: MENU_ITEM  "MUSIC STYLE ARRANGER MODE"
 *   w9: MENU_ITEM  "WALLPAPER SETTING"
 */

#include "naka_types.h"

/* ── External handler addresses (resolved by linker script) ── */

extern const char Naka_PresentationRootState;  /* 0x00EF013F */

/* ── Base ROM address of this data block ─────────────────── */

#define BASE  0x00ED3C96u

/* ── Overall layout struct ───────────────────────────────── */

typedef struct __attribute__((packed)) {
    /* w1: CONTAINER "CONTROL MENU" */
    /* element 0 of Viewable slot 0x40 "ControlMenu": TtlScreen (class id 0x01600034) */
    naka_cls_TtlScreen_t ControlMenu;
    char w1_text[14];       /* "CONTROL MENU" + NUL + 0xFF pad */

    /* w2: MENU_ITEM "INITIAL" */
    /* element 1 of Viewable slot 0x40: AcTitleMenu (class id 0x0160001D) */
    naka_cls_AcTitleMenu_t Initial_AcTitleMenu;
    char Initial_text[8];        /* "INITIAL" + NUL */

    /* w3: MENU_ITEM "OVERALL TOUCH SENSITIVITY" */
    /* element 2 of Viewable slot 0x40: AcTitleMenu (class id 0x0160001D) */
    naka_cls_AcTitleMenu_t OverallTouchSensitivity_AcTitleMenu;
    char OverallTouchSensitivity_text[26];       /* "OVERALL TOUCH SENSITIVITY" + NUL */

    /* w4: MENU_ITEM "FOOT CONTROLLERS" */
    /* element 3 of Viewable slot 0x40: AcTitleMenu (class id 0x0160001D) */
    naka_cls_AcTitleMenu_t ControlMenu_AcTitleMenu;
    char w4_text[18];       /* "FOOT CONTROLLERS" + NUL + 0xFF pad */

    /* w5: MENU_ITEM "DISPLAY TIME OUT" */
    /* element 4 of Viewable slot 0x40: AcTitleMenu (class id 0x0160001D) */
    naka_cls_AcTitleMenu_t v40_e4;
    char w5_text[18];       /* "DISPLAY TIME OUT" + NUL + 0xFF pad */

    /* w6: MENU_ITEM "PANEL MEMORY MODE" */
    /* element 5 of Viewable slot 0x40: AcTitleMenu (class id 0x0160001D) */
    naka_cls_AcTitleMenu_t PanelMemoryMode_AcTitleMenu;
    char PanelMemoryMode_text[18];       /* "PANEL MEMORY MODE" + NUL */

    /* w7: TYPE_0x48 (separator/spacer) */
    /* element 6 of Viewable slot 0x40: IvExitMode (class id 0x01600048) */
    naka_cls_IvExitMode_t ControlMenu_IvExitMode;

    /* w8: MENU_ITEM "MUSIC STYLE ARRANGER MODE" */
    /* element 7 of Viewable slot 0x40: AcTitleMenu (class id 0x0160001D) */
    naka_cls_AcTitleMenu_t MusicStyleArrangerMode_AcTitleMenu;
    char MusicStyleArrangerMode_text[26];       /* "MUSIC STYLE ARRANGER MODE" + NUL */

    /* w9: MENU_ITEM "WALLPAPER SETTING" */
    /* element 8 of Viewable slot 0x40: AcTitleMenu (class id 0x0160001D) */
    naka_cls_AcTitleMenu_t WallpaperSetting_AcTitleMenu;
    char WallpaperSetting_text[18];       /* "WALLPAPER SETTING" + NUL */
} ctrl_menu_header_t;

/* Self-referential pointer: computes ROM address of a field */
#define SELF(field)  (BASE + __builtin_offsetof(ctrl_menu_header_t, field))

_Static_assert(sizeof(ctrl_menu_header_t) == 592,
    "ctrl_menu_header must be exactly 592 bytes");

/* ── Data ────────────────────────────────────────────────── */

/* ── Object tables: the element names the records link by ─────────── */

/* Viewable table Toshi_Viewable_CTMENU, registry slot 0x40, 9 elements.
 * InitializeToshi registers it: `RegObjTabl NAKA_CLASS_Viewable, ViewableProc, 9, Toshi_Viewable_CTMENU, 0x40`.
 * One constant per element, in index order, indented by depth in the object tree:
 * the records below link to each other (super = parent, sub = first child, next /
 * prev = siblings) by these names.  View id of element OBJ_x: NAKA_VIEW_ID(Toshi_Viewable_CTMENU, OBJ_x). */
#define Toshi_Viewable_CTMENU_SLOT 0x040u
enum Toshi_Viewable_CTMENU_objects {
    OBJ_ControlMenu,                           /*  0 TtlScreen "ControlMenu" */
      OBJ_Initial_AcTitleMenu,                 /*  1 AcTitleMenu */
      OBJ_OverallTouchSensitivity_AcTitleMenu, /*  2 AcTitleMenu */
      OBJ_ControlMenu_AcTitleMenu,             /*  3 AcTitleMenu */
      OBJ_v40_e4,                              /*  4 AcTitleMenu */
      OBJ_PanelMemoryMode_AcTitleMenu,         /*  5 AcTitleMenu */
      OBJ_ControlMenu_IvExitMode,              /*  6 IvExitMode */
      OBJ_MusicStyleArrangerMode_AcTitleMenu,  /*  7 AcTitleMenu */
      OBJ_WallpaperSetting_AcTitleMenu,        /*  8 AcTitleMenu */
};

const ctrl_menu_header_t ctrl_menu_header_data
    __attribute__((section(".text"), used)) = {

    /* ─── w1: CONTAINER "CONTROL MENU" ─────────────────── */
    .ControlMenu = {
        .class_ = NAKA_CLASS(TtlScreen),
        .super = NAKA_NONE,
        .sub = OBJ_Initial_AcTitleMenu,
        .next = NAKA_NONE,
        .prev = NAKA_NONE,
        .flag = VF_Fixed | VF_Const,
        .rect = NAKA_XYWH(0, 0, 320, 240),
        .color = CL_Gray,
        .border = BD_Single2,
        .exit = TITLE_NORMAL,
        .window = 0x0003F434,
        .title = SELF(w1_text),
        .icon = idICON_i145,
    },
    .w1_text = { 'C','O','N','T','R','O','L',' ','M','E','N','U', 0, 0xFF },

    /* ─── w2: MENU_ITEM "INITIAL" ──────────────────────── */
    .Initial_AcTitleMenu = {
        .class_ = NAKA_CLASS(AcTitleMenu),
        .super = OBJ_ControlMenu,
        .sub = NAKA_NONE,
        .next = OBJ_OverallTouchSensitivity_AcTitleMenu,
        .prev = NAKA_NONE,
        .flag = VF_Const,
        .rect = NAKA_XYWH(8, 30, 149, 26),
        .color = CL_Transparent,
        .border = BD_None,
        .index = 0xFFFF,
        .font = idCHARA1,
        .fontcolor = CL_White,
        .align = AL_Center,
        .editsw = ES_Left1,
        .selected = 0x0003F438,
        .str = SELF(Initial_text),
        .title = TITLE_CTINIT,
        .icon = idICON_i12,
    },
    .Initial_text = "INITIAL",

    /* ─── w3: MENU_ITEM "OVERALL TOUCH SENSITIVITY" ───── */
    .OverallTouchSensitivity_AcTitleMenu = {
        .class_ = NAKA_CLASS(AcTitleMenu),
        .super = OBJ_ControlMenu,
        .sub = NAKA_NONE,
        .next = OBJ_ControlMenu_AcTitleMenu,
        .prev = OBJ_Initial_AcTitleMenu,
        .flag = VF_Const,
        .rect = NAKA_XYWH(8, 72, 149, 26),
        .color = CL_Transparent,
        .border = BD_None,
        .index = 0xFFFF,
        .font = idCHARA1,
        .fontcolor = CL_White,
        .align = AL_Center,
        .editsw = ES_Left2,
        .selected = 0x0003F43A,
        .str = SELF(OverallTouchSensitivity_text),
        .title = TITLE_CTTOUCH,
        .icon = idICON_i8,
    },
    .OverallTouchSensitivity_text = "OVERALL TOUCH SENSITIVITY",

    /* ─── w4: MENU_ITEM "FOOT CONTROLLERS" ─────────────── */
    .ControlMenu_AcTitleMenu = {
        .class_ = NAKA_CLASS(AcTitleMenu),
        .super = OBJ_ControlMenu,
        .sub = NAKA_NONE,
        .next = OBJ_v40_e4,
        .prev = OBJ_OverallTouchSensitivity_AcTitleMenu,
        .flag = VF_Const,
        .rect = NAKA_XYWH(8, 114, 149, 26),
        .color = CL_Transparent,
        .border = BD_None,
        .index = 0xFFFF,
        .font = idCHARA1,
        .fontcolor = CL_White,
        .align = AL_Center,
        .editsw = ES_Left3,
        .selected = 0x0003F43C,
        .str = SELF(w4_text),
        .title = TITLE_CTFSWAS,
        .icon = idICON_i127,
    },
    .w4_text = { 'F','O','O','T',' ','C','O','N','T','R','O','L','L','E','R','S', 0, 0xFF },

    /* ─── w5: MENU_ITEM "DISPLAY TIME OUT" ─────────────── */
    .v40_e4 = {
        .class_ = NAKA_CLASS(AcTitleMenu),
        .super = OBJ_ControlMenu,
        .sub = NAKA_NONE,
        .next = OBJ_PanelMemoryMode_AcTitleMenu,
        .prev = OBJ_ControlMenu_AcTitleMenu,
        .flag = VF_Const,
        .rect = NAKA_XYWH(163, 30, 149, 26),
        .color = CL_Transparent,
        .border = BD_None,
        .index = 0xFFFF,
        .font = idCHARA1,
        .fontcolor = CL_White,
        .align = AL_Center,
        .editsw = ES_Right1,
        .selected = 0x0003F43E,
        .str = SELF(w5_text),
        .title = TITLE_CTSYSTEM,
        .icon = idICON_i146,
    },
    .w5_text = { 'D','I','S','P','L','A','Y',' ','T','I','M','E',' ','O','U','T', 0, 0xFF },

    /* ─── w6: MENU_ITEM "PANEL MEMORY MODE" ────────────── */
    .PanelMemoryMode_AcTitleMenu = {
        .class_ = NAKA_CLASS(AcTitleMenu),
        .super = OBJ_ControlMenu,
        .sub = NAKA_NONE,
        .next = OBJ_ControlMenu_IvExitMode,
        .prev = OBJ_v40_e4,
        .flag = VF_Const,
        .rect = NAKA_XYWH(163, 72, 149, 26),
        .color = CL_Transparent,
        .border = BD_None,
        .index = 0xFFFF,
        .font = idCHARA1,
        .fontcolor = CL_White,
        .align = AL_Center,
        .editsw = ES_Right2,
        .selected = 0x0003F440,
        .str = SELF(PanelMemoryMode_text),
        .title = TITLE_CTPMMD,
        .icon = idICON_i47,
    },
    .PanelMemoryMode_text = "PANEL MEMORY MODE",

    /* ─── w7: TYPE_0x48 (separator/spacer) ─────────────── */
    .ControlMenu_IvExitMode = {
        .class_ = NAKA_CLASS(IvExitMode),
        .super = OBJ_ControlMenu,
        .sub = NAKA_NONE,
        .next = OBJ_MusicStyleArrangerMode_AcTitleMenu,
        .prev = OBJ_PanelMemoryMode_AcTitleMenu,
        .flag = VF_Const | VF_InvisibleBox,
        .rect = NAKA_XYWH(0, 0, 32, 32),
        .mode = NAKA_MODE_MD_NORMAL,
    },

    /* ─── w8: MENU_ITEM "MUSIC STYLE ARRANGER MODE" ───── */
    .MusicStyleArrangerMode_AcTitleMenu = {
        .class_ = NAKA_CLASS(AcTitleMenu),
        .super = OBJ_ControlMenu,
        .sub = NAKA_NONE,
        .next = OBJ_WallpaperSetting_AcTitleMenu,
        .prev = OBJ_ControlMenu_IvExitMode,
        .flag = VF_Const,
        .rect = NAKA_XYWH(163, 114, 149, 26),
        .color = CL_WallPattern,
        .border = BD_None,
        .index = 0xFFFF,
        .font = idCHARA1,
        .fontcolor = CL_White,
        .align = AL_Center,
        .editsw = ES_Right3,
        .selected = 0x0003F442,
        .str = SELF(MusicStyleArrangerMode_text),
        .title = TITLE_MSAMODE,
        .icon = idICON_i48,
    },
    .MusicStyleArrangerMode_text = "MUSIC STYLE ARRANGER MODE",

    /* ─── w9: MENU_ITEM "WALLPAPER SETTING" ────────────── */
    .WallpaperSetting_AcTitleMenu = {
        .class_ = NAKA_CLASS(AcTitleMenu),
        .super = OBJ_ControlMenu,
        .sub = NAKA_NONE,
        .next = NAKA_NONE,
        .prev = OBJ_MusicStyleArrangerMode_AcTitleMenu,
        .flag = VF_Const,
        .rect = NAKA_XYWH(8, 156, 149, 26),
        .color = CL_Transparent,
        .border = BD_None,
        .index = 0xFFFF,
        .font = idCHARA1,
        .fontcolor = CL_White,
        .align = AL_Center,
        .editsw = ES_Left4,
        .selected = 0x0003F444,
        .str = SELF(WallpaperSetting_text),
        .title = TITLE_CTWALLSET,
        .icon = idICON_i131,
    },
    .WallpaperSetting_text = "WALLPAPER SETTING",
};
