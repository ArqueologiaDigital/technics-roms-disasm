/* Functions of ui/ui_widget_defs.s.  Firmware C (cc900 phase 6), built by scripts/build/cc900_firmware_c.py with the cc900 reference model;
   no Toshiba program.  Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   cc900-options: -Xr
   (GetNamingWindowID's 32-bit constant load is the ld form that cc900 V4.23 writes without -O; at -O3 -XS -Xr it
   writes lda.  Every other function here gives the same bytes at either option set.) */
extern long LSW_FILTER, ROOT_PARAM, ROOT_EVENT, TITLE_NOW, TITLE_OLD, MODE_NOW, MODE_OLD, CURRENT_TARGET;
extern void *ROOT_OBJECT, *FOCUS_OBJECT;

void SetLswFilter(long a, long b) { LSW_FILTER = a + b; }
void ResetLswFilter(long a, long b) { LSW_FILTER = a + b; }
void SetRootObject(void *p) { ROOT_OBJECT = p; }
void *GetRootObject(void) { return ROOT_OBJECT; }
long GetRootEvent(void) { return ROOT_EVENT; }
void SetRootEvent(long e) { ROOT_EVENT = e; }
long GetRootParam(void) { return ROOT_PARAM; }
void SetRootParam(long p) { ROOT_PARAM = p; }
void *GetFocusObject(void) { return FOCUS_OBJECT; }
long GetTitleNow(void) { return TITLE_NOW; }
long GetTitleOld(void) { return TITLE_OLD; }
long GetModeNow(void) { return MODE_NOW; }
long GetModeOld(void) { return MODE_OLD; }
long GetCurrentTarget(void) { return CURRENT_TARGET; }
void SetCurrentTarget(long t) { if (t != -1) CURRENT_TARGET = t; }
long GetNamingWindowID(void) { return 10; }
