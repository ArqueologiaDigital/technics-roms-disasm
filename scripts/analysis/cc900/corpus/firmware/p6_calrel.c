/* Phase 6, probe calrel (lane_vmb): how does asm900 assemble V4.23's `cal` and `j` -- a call and a tail call --
   to a function of the same file, to a static one and to an extern, near and far?  The ROM has 22,378 `call` and
   9,477 `calr`, and jr / jrl tail calls, where V4.23's listings say `cal` / `j` everywhere.  ASM900's -O is "No
   optimization" (ETC/ASM900.HLP), and README/HIS96AE0.TXT calls J and CAL instructions "used for optimization"
   whose extern large / small operands once assembled wrongly; so the choice is presumably asm900's, by distance,
   for a target it can see.  Run it with asmflags `lst|-l` and `lstnoopt|-l -O` (p6_calrel-asmflags.txt): the list
   files show each final encoding, with and without that optimisation.

   What to read from the outputs, per function (the comment beside each):
     - same file, target above / below, a few bytes away: calr or call?  jr, jrl or jp?
     - static target: the same as a public one?
     - extern target: call #24 (1d), call #16 (1c) or something the linker fixes?  jp #24 for the tail call?
     - about 300 B away: jr out of reach -- jrl?
     - about 49 KB away (p6_calrel_far.c, apart so that a failure there cannot cost this file): call / jp?
   Compile at -O3 -Xr (p6_calrel-options.txt), the firmware's own option set. */

extern unsigned char __near flag;
extern unsigned char big[];                 /* large: each store below is ld (big+n:24), 1 -- 6 bytes */
extern void ext_fn(void);
void leaf_b(void);
void leaf_c(void);

#define S1(n)   big[n] = 1;
#define S16(n)  S1(n) S1(n+1) S1(n+2) S1(n+3) S1(n+4) S1(n+5) S1(n+6) S1(n+7) \
                S1(n+8) S1(n+9) S1(n+10) S1(n+11) S1(n+12) S1(n+13) S1(n+14) S1(n+15)

static void s_leaf(void) { flag = 1; }
void leaf_a(void) { flag = 2; }

void call_back(void) { leaf_a(); flag = 3; }        /* cal to a public function a few bytes above */
void call_static(void) { s_leaf(); flag = 4; }      /* cal to a static function above */
void tail_back(void) { leaf_a(); }                  /* j (tail call) to a public function above */
void tail_static(void) { s_leaf(); }                /* j to a static function above */
void call_fwd(void) { leaf_b(); flag = 5; }         /* cal to a public function a few bytes below */
void tail_fwd(void) { leaf_b(); }                   /* j to a public function below */
void call_ext(void) { ext_fn(); flag = 6; }         /* cal to an extern function */
void tail_ext(void) { ext_fn(); }                   /* j to an extern function */
void leaf_b(void) { flag = 7; }

void call_over(void) { leaf_c(); flag = 8; }        /* cal over about 300 bytes (pad300 below) */
void tail_over(void) { leaf_c(); }                  /* j over about 300 bytes: beyond jr */
void pad300(void) { S16(0) S16(16) S16(32) }        /* 48 stores, about 288 bytes */
void leaf_c(void) { flag = 9; }
