/* Functions of demo/demo_seq_bridge.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: CDlikeSwTtl_ShowDocTitle CDlikeSwTtl_ShowPdTitle CDlikeSwTtl_ShowSongTitle SeqInit_LookupDispatchEntry SeqRecPlay_DisableBoth SeqRecPlay_EnablePlayOnly */   /* scripts/analysis/cc900/module_calls.py v10 */

#define EVT_SET_SELECTED 0x1e0004dL
extern void ApDeliveryEvent(long, long, long);
extern long SeqInit_LookupDispatchEntry(unsigned int);
extern unsigned char __near DEMO_ACTIVE_ENTRY;
extern void SeqInit_PostDispatchEvent(void);

void SeqInit_PostDispatchEvent(void)
{
  ApDeliveryEvent(SeqInit_LookupDispatchEntry(DEMO_ACTIVE_ENTRY), EVT_SET_SELECTED, 1L);
}
