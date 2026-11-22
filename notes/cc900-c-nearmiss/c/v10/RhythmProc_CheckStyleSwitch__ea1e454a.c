/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_Q_20r1m250a.c (2026-11-21-2-p6-r58)
   sha256 ea1e454a4b5807bfd1fc8cad8b76e1be7e47f93db9bbd0ea12d1a9eee498cc98 (tar-sha256); compiled at -O3 -XS -Xr */
extern unsigned char __near CURRENT_TITLE;
extern void AccPat_DispatchNoteChange(void);
void RhythmProc_CheckStyleSwitch(void)
{
  if (CURRENT_TITLE == 184) {
    AccPat_DispatchNoteChange();
  }
}
