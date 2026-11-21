/* helper U, round 21r1, module 271, form b: BoxRightCheck's in-range test through a result local. */

int BoxRightCheck(int x)
{
  int r;
  if (x <= 0xa8 && x >= 0xa0) r = 1;
  else r = 0;
  return r;
}
