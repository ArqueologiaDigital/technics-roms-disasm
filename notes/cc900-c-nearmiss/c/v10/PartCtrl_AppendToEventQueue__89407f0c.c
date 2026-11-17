/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/sequencer_engine.c (2026-11-16-36-p6-staged-r4)
   sha256 89407f0c2d25bb39cbeb834be9f9a659e995f5e65ab955bf65c63980fa1ea092 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
struct evq { unsigned int w; unsigned char c, e; };
extern struct evq __near ram_e390[];
extern unsigned int __near ram_e3b8;
void PartCtrl_AppendToEventQueue(unsigned char w, unsigned char c, unsigned char e)
{
  if (ram_e3b8 >= 10) return;
  ram_e390[ram_e3b8].w = w;
  ram_e390[ram_e3b8].c = c;
  ram_e390[ram_e3b8].e = e;
  ram_e3b8++;
}
