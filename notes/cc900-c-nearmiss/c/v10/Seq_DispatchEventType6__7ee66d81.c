/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_Q_20r1m264a.c (2026-11-21-2-p6-r58)
   sha256 7ee66d8182fdc601d4b26121bf1537c591d575eec6b096e0120b56468d49d920 (tar-sha256); compiled at -Xr */
extern long ApPostEvent(long, long, long);
#define EVT_END_SONG 0x1c10006L
void Seq_DispatchEventType6(int v)
{
  ApPostEvent(-1L, EVT_END_SONG, v);
}
