/* helper U, round 21r1, module 271, form a: BoxRightCheck with `return 1` first (the in-range test), as the ROM
   places it; form b through a result local. */

int BoxRightCheck(int x)
{
  if (x <= 0xa8 && x >= 0xa0) return 1;
  return 0;
}
