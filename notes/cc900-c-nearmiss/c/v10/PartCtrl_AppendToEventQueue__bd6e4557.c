/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_1b.c (2026-11-16-30-p6-r1)
   sha256 bd6e4557c8e04a2edcf7c0a4f18652e01cf59f735fd3362c0cbe758f01080833 (tar-sha256); compiled at -O3 -XS -Xr */
struct evq { unsigned int w; unsigned char c, e; };
extern struct evq __near ram_e390[];
extern unsigned int __near ram_e3b8;
void PartCtrl_AppendToEventQueue(unsigned char w, unsigned char c, unsigned char e)
{
  if (ram_e3b8 < 10) {
    ram_e390[ram_e3b8].w = w;
    ram_e390[ram_e3b8].c = c;
    ram_e390[ram_e3b8].e = e;
    ram_e3b8 = ram_e3b8 + 1;
  }
}
