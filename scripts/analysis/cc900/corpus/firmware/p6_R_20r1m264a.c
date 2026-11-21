/* Helper R, round 1 of 2026-11-20: modules 264-269 (ui/drawbar_panel_ui.s, demo/fdemotext_routines.s,
   demo/file_demo_proc.s, file_io/wallpaper.s).  Form a. */
/* cc900-module: Seq_CopyResourcePtrs */   /* scripts/analysis/cc900/module_calls.py v10 */

#define EVT_START_SONG 0x1c10005L
#define EVT_EXIT_PRESENTATION 0x1e1000dL
#define NAKA_MAINFUNC_MainPreControl 0x1410000L

struct grid { unsigned char b[12]; };
struct disk { long freesz; long total; };

extern long ram_3ea34;
extern struct grid *ram_3ea30;
extern long ApPostEvent(long, long, long);
extern void MainPreControl(long, long, long);
extern unsigned int ram_25b82;
extern void Seq_CopyResourcePtrs(unsigned int);
extern int GetFirstPageBase(void);
extern char *GetRecordPtrForFile(int);
extern int FileIO_OpenDefault(char *);
extern struct disk ram_25d6c;
extern void GetDiskFreeSpace(long *, long *);
extern char *PtrTbl_VariationNames[];

void Util_StoreGridArrayBase(long a)
{
  ram_3ea34 = a;
}

struct grid *Util_SignExtendAndDouble(int i)
{
  return &ram_3ea30[i];
}

void Seq_DispatchEventType5(int v)
{
  ApPostEvent(-1L, EVT_START_SONG, v);
}

void Seq_StartMainControlAlt(void)
{
  MainPreControl(NAKA_MAINFUNC_MainPreControl, EVT_EXIT_PRESENTATION, 0L);
}

void FDemoText_ScaleUpCoords(int *s, int *d)
{
  d[0] = s[0] << 3;
  d[1] = (s[1] << 2) + 3;
}

void Seq_PostProcessDisplay(void)
{
  Seq_CopyResourcePtrs(ram_25b82);
}

int GetFirstRecordAndOpen(void)
{
  int n = GetFirstPageBase();
  if (n < 0) return -0x68;
  return FileIO_OpenDefault(GetRecordPtrForFile(n));
}

long FileIO_GetDiskFreeSpace(void)
{
  GetDiskFreeSpace(&ram_25d6c.freesz, &ram_25d6c.total);
  return ram_25d6c.freesz;
}

char *SingleLoad_GetVariationName(unsigned int i)
{
  return *(char **)((unsigned long)PtrTbl_VariationNames + ((unsigned long)i << 2));
}
