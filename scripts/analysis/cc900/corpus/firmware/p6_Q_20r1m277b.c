/* helper Q, round 20r1, module 277, form b: the delay loops as while (1) with an explicit break (form a: while (--n)). */

void DELAY_10_LOOPS(void)
{
  int n;
  n = 10;
  while (1) {
    n--;
    if (n == 0) break;
  }
}

void DELAY_1500_LOOPS(void)
{
  int n;
  n = 1500;
  while (1) {
    n--;
    if (n == 0) break;
  }
}
