/* Phase 6, probe calrel, qualifier part (lane_vmb; see p6_calrel.c): do __near / __tiny apply to functions, and
   what do `cal` / `j` to such an extern become?  (A compile error here costs only this file.) */
extern unsigned char __near flag;
extern void __near ext_near_fn(void);
extern void __tiny ext_tiny_fn(void);
extern void ext_large_fn(void);

void call_near_ext(void) { ext_near_fn(); flag = 1; }
void tail_near_ext(void) { ext_near_fn(); }
void call_tiny_ext(void) { ext_tiny_fn(); flag = 2; }
void call_large_ext(void) { ext_large_fn(); flag = 3; }
