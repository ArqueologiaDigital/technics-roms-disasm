/* helper Q, round 20r1, module 277 (audio/tonegen_fileio_handlers.s, ui/cpanel_routines.s): panel TLV rule / validate
   wrappers (sibling of the built PanelTlv_Rule_ClearBits) and the two delay loops. */
/* cc900-module: PanelTlv_ValidateBlock0 PanelTlv_ValidateBlock1 */

extern unsigned char __near SEQ_SONG_RECORD[];
extern void PanelTlv_ValidateBlock0(unsigned char *mem);
extern void PanelTlv_ValidateBlock1(unsigned char *mem);
extern void ToneGen_DispatchByMode(void);
extern void SwbtWr_NullRet(void);

int PanelTlv_Rule_SetBits(unsigned char *rec, unsigned char *r)
{
  rec[r[1]] |= r[2];
  return 3;
}

void PanelTlv_ValidateLivePanel(void)
{
  PanelTlv_ValidateBlock0((unsigned char *)0xf9a0L);
  PanelTlv_ValidateBlock1((unsigned char *)0xfd60L);
  ToneGen_DispatchByMode();
  SwbtWr_NullRet();
}

void PanelTlv_ValidateSongPanel(void)
{
  PanelTlv_ValidateBlock0(&SEQ_SONG_RECORD[768]);
}

void DELAY_10_LOOPS(void)
{
  unsigned int n;
  n = 10;
  while (--n)
    ;
}

void DELAY_1500_LOOPS(void)
{
  unsigned int n;
  n = 1500;
  while (--n)
    ;
}
