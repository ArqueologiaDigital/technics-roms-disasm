/* Phase 6, lane_p6 helper D, round 3, form b: round-2 misses refined after run 2026-11-16-35-p6-r3 (sets O3Xr / Xr),
   plus new leaf functions of the pool, each under its firmware name (or a short C name with a cc900-name comment).
   Form a (p6_D_3a.c) has the same names; this file holds the alternatives.
   __near: the ROM reaches the cell with a 16-bit absolute operand; plain: 24-bit (or a ROM label).
   One declarator per __near declaration.  V4.23 allocates unsigned char bitfields from bit 7 down. */

struct lo3 { unsigned char rest : 5; unsigned char v : 3; };
struct bit0 { unsigned char rest : 7; unsigned char b0 : 1; };
struct sname { int key; char name[16]; };
struct w10 { unsigned char *bmp; unsigned char rest[6]; };
struct r44 { unsigned int a, b; unsigned char rest[40]; };
struct aptimer { unsigned int a; unsigned int b; unsigned int pad[2]; long c; unsigned char rest[12]; };

/* sequencer/seq_audio_mode.s */
extern unsigned char __near ram_3310;
extern unsigned char __near ram_32f9;
extern unsigned char __near ram_3306;
extern unsigned char __near ram_3338;
extern unsigned char __near ACC_VARIATION_REQUEST;
extern unsigned char __near ACC_LANES_ENDING1;
extern unsigned char __near ACC_LANES_ENDING2;
extern unsigned char __near ACC_STYLE_NUMBER;
extern unsigned char __near ACC_STYLE_ARRANGER_ON;
extern unsigned char __near ACC_LANES_FILLIN1;
extern unsigned char __near ACC_LANES_FILLIN2;
extern char __near ACC_VARIATION_CHANGE_PENDING;
extern unsigned char __near ACC_VARIATION_NEXT;
extern unsigned char __near ACC_CHORD_TYPE;
extern unsigned char __near ACC_CHORD_PREV_TYPE;
extern unsigned char __near ACC_CHORD_BASS;
extern unsigned char __near ACC_CHORD_PREV_BASS;
extern unsigned char __near ram_32f3;
extern unsigned char __near ACC_LANES_INTRO1;
extern unsigned char __near ACC_LANES_COUNTIN;
extern unsigned char __near ACC_LANES_INTRO2;
extern unsigned char __near ACC_PENDING_STYLE;
extern unsigned char __near ACC_DEFER_ENDING_LANES;
extern unsigned char __near ACC_LANES_RESYNC;
extern unsigned char __near ACC_SECTION_BUTTONS_HELD;
extern unsigned char __near ram_3281;
extern unsigned char __near ram_3280;
extern unsigned char __near ACC_BEATS_PER_BAR;
extern unsigned char __near ram_3329;
/* sequencer/bmdredit_routines.s */
extern unsigned char __near ram_2742;
extern unsigned char __near ram_2960;
extern unsigned char __near ram_2746[];
extern unsigned int __near ram_281e;
extern unsigned int __near ram_27c2;
extern unsigned int __near ram_27c4;
extern unsigned int __near ram_27c6;
extern unsigned int __near ram_27c8;
extern unsigned int ram_210b2;
extern unsigned char ram_210b0;
extern unsigned int BmDrEdit_RenderVertical_Table[];
/* sequencer/smf_event_processor.s */
extern struct r44 ram_235a6[];
extern unsigned int ram_2358c, ram_2474e;
extern unsigned long ram_3e3e8;
/* audio/tonegen_fileio_handlers.s: none */
/* audio/sndparam_routines.s: none */
/* audio/semenu_routines.s */
extern unsigned char GUI_DisplayStructData_0x1110[];
/* audio/audio_control_engine.s */
extern unsigned char *PanelTlv_CompanionByPart[];
extern unsigned char __near PANEL_VARI_STYLE[];
/* storage/fdc_routines.s */
extern unsigned int __near SYSTEM_TIMESTAMP;
/* ui/ui_mode_handlers.s */
extern struct sname StyleNameOverride_C2C5[], StyleNameOverride_Default[];
/* ui/ui_window_procs.s */
extern struct w10 ChangeWall_WallpaperTable[];
extern unsigned int ram_3ef9c;
extern unsigned char *ram_3ef98, *WALLPAPER_BITMAP;
/* ui/ui_widget_defs.s */
extern struct aptimer ram_2f844[];
extern long ram_30444;
extern unsigned int ram_30448;

