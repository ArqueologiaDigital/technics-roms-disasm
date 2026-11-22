/* Helper R, round 1 of 2026-11-20: modules 270-274 (file_io/medley.s, storage/fdc_routines.s, ui/ui_control_panel.s,
   audio/presentation_sound_nav.s, ui/ui_widget_defs.s, display/graphics_text_vga.s, ui/bitmap_out_routines.s).
   Form a. */
/* cc900-module: SetDialFocus */   /* scripts/analysis/cc900/module_calls.py v10 */

#define EVT_PARA_DRAW 0x1c0000fL
#define EVT_SELE_DRAW 0x1c0000eL
#define EVT_EDIT_DOWN_SET 0x1e00070L

struct font { unsigned int w; unsigned int h; unsigned char pad[12]; };

extern unsigned int ram_9480e;
extern unsigned char __near ram_8b20;
extern unsigned char __near ram_8b22;
extern unsigned char __near FDC_RESULT;
extern long ApPostEvent(long, long, long);
extern long DIAL_DOWN_CALLBACK;
extern long DIAL_DOWN_EVENT;
extern long DIAL_DOWN_PARAM;
extern void SetDialFocus(long);
extern unsigned int ram_30464;
extern void VGA_ScreenUnblank(void);
extern unsigned char __near ram_8d4a;
extern void PanelMem_InitFromFactory(unsigned int);
extern void PanelTlv_ValidatePanelMemory(unsigned int);

unsigned int Composer_GetPassword(void)
{
  return ram_9480e;
}

void FDC_RecordDensityCode(unsigned char a)
{
  ram_8b20 = ram_8b22;
  ram_8b22 = a;
}

void FDC_TIMING_DELAY(void)
{
  FDC_RESULT = 255;
}

void UI_PostTimerResetEvent(void)
{
  ApPostEvent(-1L, EVT_PARA_DRAW, 0L);
  ApPostEvent(-1L, EVT_SELE_DRAW, 0L);
}

void UI_PostDialRangeEvent(unsigned char a)
{
  ApPostEvent(-1L, EVT_EDIT_DOWN_SET, a);
}

int BoxLeftCheck(int x)
{
  if (x > 0x88 || x < 0x80) return 0;
  return 1;
}

void SetDialDown(long cb, long ev, long p)
{
  DIAL_DOWN_CALLBACK = cb;
  DIAL_DOWN_EVENT = ev;
  DIAL_DOWN_PARAM = p;
  SetDialFocus(cb);
}

void InitGraphics_SetupVRAM_Loop(void)
{
  ram_30464 = 1;
  VGA_ScreenUnblank();
}

unsigned int GetCharHeight(unsigned long id)
{
  return ((struct font *)0x945c00L)[id].h;
}

unsigned char _Read_VGA_Register(unsigned int r)
{
  return *(unsigned char *)(0x170000L + r);
}

unsigned char BitMapOut_GetRenderMode_CheckBit3(unsigned char a)
{
  unsigned char *p = &ram_8d4a;
  *p |= a;
  return *p;
}

void PanelMemory_PostSlotLoad(unsigned char n, int r)
{
  if (r < 0)
    PanelMem_InitFromFactory(n);
  else
    PanelTlv_ValidatePanelMemory(n);
}
