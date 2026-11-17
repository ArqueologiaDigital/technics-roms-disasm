# Round 5 for lane_sub's helpers (read after BRIEF.md, ROUND3.md, ROUND4.md)

Round 4 ran as oracle run 2026-11-16-62-sub-r4 (listings .../runs/2026-11-16-62-sub-r4/out/v423/Xr/sub/sub_<TAG>_4{a,b,c}.asm).
Verdicts: ~/compartilhado/tmp/cc900-tab/lane_sub/r4_<TAG>.tsv.  30 of 93 matched, 3,673 B, all staged.  About 250 functions
are staged now.

New facts:
- THE XIZ SAVE IS REACHABLE: ToneGen_WriteVoice_Direct matched with V4.23's pseudo-register `__IZ` (helper B's 4c:
  `__IZ = d; ... ram_100002 = __IZ;`); ToneGen_WriteVoice_Long, with `__XIZ = (unsigned long)p` and reads through
  it, got to +19.  So write the tone-generator writers with __IZ / __XIZ holding what the ROM keeps in IZ / XIZ across
  the inline nops.  Helpers B and C: this is your main task this round (all the writers in your pools).
- Stack parameters (helper E): V4.23 puts the FIRST stack parameter at the HIGHEST address, so with two or more stack
  parameters the C order is the reverse of the ascending (xsp+N) offsets.
- A record array declared with few elements makes V4.23 use an 8-bit index; declare it large (e.g. [100], [256]).
- V4.23 aligns struct members, arrays included, to even offsets: write odd offsets as integer addresses.
- Long divide / remainder: the checker maps C9H_divls -> Int_SignedDiv_ConstData, C9H_remls -> Int_SignedDiv_AltEntry,
  C9H_remlu -> Int_UnsignedRemainder (what the payload's headers say; unconfirmed), so `long / long` and `long % long`
  callers are in scope.  Try them; if all miss exactly at the call, the mapping is wrong; say so.
- QIZ byte registers (`ld qizh,..`) are translated now (Voice_AllVoices_PortamentoReset assembles; still +0 for the
  XIZ reason above).
- Same-module calls (calr / jrl) become checkable soon (a `cc900-module:` comment); not in this round yet.

Round 5: files sub_<TAG>_5a.c / _5b.c (/_5c.c).  Same rules; report as before.
