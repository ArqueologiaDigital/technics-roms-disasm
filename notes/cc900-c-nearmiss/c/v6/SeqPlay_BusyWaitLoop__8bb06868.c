/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/note_voice_mapping_m302_xs.c (2026-11-21-5-p6-r60)
   sha256 8bb068684293f35189100ee6df75fdeab5a44615060b9a5b9a1837d2761b32a6 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -XS -Xr */
extern volatile unsigned char __near ram_432;
void SeqPlay_BusyWaitLoop(void)
{
  while (ram_432 & 0x01)
    ;
}
