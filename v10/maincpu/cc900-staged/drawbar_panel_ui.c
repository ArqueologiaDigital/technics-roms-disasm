/* Functions of ui/drawbar_panel_ui.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern long ApPostEvent(long, long, long);
#define EVT_END_SONG 0x1c10006L

void Seq_DispatchEventType6(int v)
{
  ApPostEvent(-1L, EVT_END_SONG, v);
}

#define EVT_START_SONG 0x1c10005L
#define EVT_EXIT_PRESENTATION 0x1e1000dL
#define NAKA_MAINFUNC_MainPreControl 0x1410000L
struct grid { unsigned char b[12]; };
extern long ram_3ea34;
extern struct grid *ram_3ea30;
extern void MainPreControl(long, long, long);

void Seq_DispatchEventType5(int v)
{
  ApPostEvent(-1L, EVT_START_SONG, v);
}

void Seq_StartMainControlAlt(void)
{
  MainPreControl(NAKA_MAINFUNC_MainPreControl, EVT_EXIT_PRESENTATION, 0L);
}

struct grid *Util_SignExtendAndDouble(int i)
{
  return &ram_3ea30[i];
}

void Util_StoreGridArrayBase(long a)
{
  ram_3ea34 = a;
}
