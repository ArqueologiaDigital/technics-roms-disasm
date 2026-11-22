/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_Q_20r1m269a.c (2026-11-21-2-p6-r58)
   sha256 9091283c541b6d73ef7060d340cb38e93b5932e4c72e9cbe9df0b43ad674a862 (tar-sha256); compiled at -Xr */
extern long __near ram_819c;
extern unsigned char __near ram_8946;
extern long SmfLoadAs_ModeTexts[];
extern long ApPostEvent(long, long, long);
#define EVT_PAINT 0x1c0000bL
#define EVT_PARA_DRAW 0x1c0000fL
#define EVT_PS_FILE_NAME_BOX_ID 0x1e50004L
long SmfLoadAsFunc(unsigned long obj, long evt, long par)
{
  switch (evt) {
  case EVT_PS_FILE_NAME_BOX_ID:
    ram_819c = par;
    break;
  case EVT_PAINT:
    ApPostEvent(ram_819c, EVT_PARA_DRAW, SmfLoadAs_ModeTexts[ram_8946]);
    break;
  }
  return 0;
}
