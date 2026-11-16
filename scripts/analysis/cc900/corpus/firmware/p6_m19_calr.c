/* Phase 6, probe m19: does asm900 encode V4.23's `cal` to a function of the same file as the relative calr (the ROM
   has 9,477 calr beside 22,378 call)?  And a near tail jump as jr / jrl? */
extern void far_callee(void);
static void st_g(void) { far_callee(); far_callee(); }
void m19_g(void) { far_callee(); far_callee(); }
void m19_calls_same(unsigned char a) { m19_g(); if (a) m19_g(); }
void m19_calls_static(unsigned char a) { st_g(); if (a) st_g(); }
void m19_calls_far(unsigned char a) { far_callee(); if (a) far_callee(); }
void m19_tail_same(void) { m19_g(); }
