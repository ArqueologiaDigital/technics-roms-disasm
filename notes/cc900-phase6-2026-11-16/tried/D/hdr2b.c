/* Phase 6, lane_p6 helper D, round 2, form b: round-1 misses refined after run 2026-11-16-31-p6-r1b, plus new
   leaf functions of the pool, each under its firmware name (or a short C name with a cc900-name comment).
   Form a (p6_D_2a.c) has the same names; this file holds the alternatives.
   __near: the ROM reaches the cell with a 16-bit absolute operand; plain: 24-bit (or a ROM label).
   One declarator per __near declaration. */

typedef unsigned char *ucp;

struct bit0 { unsigned char b0 : 1; unsigned char rest : 7; };
struct res12 { long a; char *p; long c; };
struct gate { unsigned char *p; unsigned char mask, val; };
struct pkt { unsigned char pad[12]; unsigned char g1, g2; };
struct sram_rgn { volatile unsigned char *start; unsigned long size; unsigned char flag, pad; };
struct sname { int key; char name[16]; };
struct box { int x0, y0, x1, y1; };
struct pt { int x, y; };
struct heap { unsigned int count; unsigned char data[16384]; };

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
extern struct bit0 __near ACC_VARIATION_CHANGE_PENDING;
extern unsigned char __near ACC_VARIATION_NEXT;
/* sequencer/bmdredit_routines.s */
extern unsigned char __near ram_2742;
extern unsigned char __near NOTEEDIT_BASE_KEY;
extern unsigned char __near ram_2774;
extern unsigned char __near ram_2960;
extern unsigned char __near ram_2746[];
extern unsigned char __near ram_27a4[];
extern unsigned char __near ram_25d8;
extern unsigned char __near ram_2784;
extern unsigned int __near ram_279e;
extern unsigned int __near ram_27ce;
extern unsigned int __near ram_27d0;
extern unsigned int __near ram_279a;
extern unsigned int __near ram_2772;
extern unsigned int __near ram_2782;
extern unsigned int __near ram_27b2;
extern unsigned int __near ram_2744;
extern unsigned int ram_210a6, ram_210a4;
extern unsigned char ram_b0000[];
extern unsigned char WidgetData_DrawbarPositionTable[];
/* storage/fdc_routines.s */
extern volatile unsigned char __near FDC_CMD_OPCODE;
extern unsigned char __near FDC_RESULT[];
extern unsigned char __near ram_8b00;
extern unsigned int __near FDC_REQ_TRACK;
extern unsigned int __near FDC_REQ_HEAD;
extern unsigned int __near FDC_COMMAND_INDEX;
extern unsigned int __near FDC_REQ_COUNT;
extern unsigned int __near FDC_PROBE_FLAG;
extern unsigned int __near FDC_REQ_SECTOR;
extern unsigned char FDC_Set_Status(int);
/* storage/flash_floppy_handlers.s */
extern ucp __near MSP_SETTINGS;
extern ucp __near RHYTHM_PATTERN_BUF_PTR;
extern ucp __near STYLE_WORK_IMAGE_PTR;
extern ucp __near FLASH_SECTOR_IMAGE_PTR;
extern ucp __near FLASH_SECTION_PTR_0;
extern ucp __near FLASH_SECTION_PTR_1;
extern ucp __near FLASH_SECTION_PTR_2;
extern ucp __near FLASH_SECTION_PTR_3;
extern ucp __near FLASH_SECTION_PTR_4;
extern ucp __near FLASH_SECTION_PTR_5;
extern ucp __near FLASH_SECTION_PTR_6;
extern ucp __near FLASH_SECTION_PTR_7;
extern unsigned char RHYTHM_PATTERN_BUF_A[], ram_300000[], ram_69800[];
extern unsigned char Composer_SettingsBlock[], Composer_DefaultHeaderFields[], MSP_Default_PartBankMap[];
extern unsigned char Composer_DefaultEmptyRecord[], Composer_DefaultUserBankNames[];
/* audio/semenu_routines.s */
extern unsigned char ram_20bf3[], ram_20c03[], ram_20c13[], ram_20c23[];
/* audio/audio_control_engine.s */
extern unsigned char __near EXTDATA_MASK;
extern unsigned char __near EXTDATA_VALUE;
extern unsigned char __near EXTDATA_TLV_OFFSET;
extern unsigned char __near PANEL_CONDUCTOR[];
extern unsigned char __near ram_90f9;
extern unsigned int __near ram_9163;
extern unsigned char SplitPoint_LedMaskByPreset[];
/* audio/dsp_config_sysex.s */
extern void *DspFxRecListPtrTable[];
/* audio/audioinit_routines.s */
extern unsigned char __near ram_7f0b;
extern unsigned char __near AUDIO_STATE[];
extern unsigned int __near AUDIO_STATE_CHANGES;
/* audio/sndparam_routines.s */
extern long __near ram_97d8[];
extern struct heap ram_380f8;
/* audio/tonegen_fileio_handlers.s: none */
/* ui/bitmap_out_routines.s */
extern unsigned int __near ram_90e2;
extern unsigned char __near ram_bf39[];
extern unsigned char __near PANEL_STYLE[];
extern unsigned char __near PANEL_PLAY_SETTINGS[];
extern unsigned char PANEL_RECALL_BACKUP[];
/* ui/ui_mode_handlers.s */
extern struct sram_rgn SramTest_IC21Regions[];
extern struct sname StyleNameOverride_C2C5[], StyleNameOverride_Default[];
/* ui/cpanel_routines.s */
extern unsigned char __near ram_8e5e;
extern unsigned char __near ram_8e4b;
extern unsigned char __near ram_8e60;
extern unsigned char __near ram_8e50;
/* ui/ui_control_panel.s */
extern unsigned int TITLE_FLAGS_LATCHED;
/* ui/ui_widget_defs.s */
extern int ram_3247c[];
extern ucp ram_32466, DRAW_QUEUE_WRITE_PTR;
extern unsigned char DRAW_QUEUE[];
/* demo/fdemotext_routines.s */
extern char Seq_CopyResourcePtrs_Str_Empty[];
extern char *ram_249cc, *ram_249d0, *ram_249d4;
extern char *ram_24fd8[];
/* midi/midipkt_routines.s */
extern struct gate MidiCtl_GateRecords[], MidiCtl_SecondGateRecords[];
/* file_io/smf_operations.s */
extern unsigned char CType_ClassTable[];

void BmDrEdit_CalcSongPosition(void);
