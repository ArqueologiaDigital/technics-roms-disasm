/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_1b.c (2026-11-16-32-p6-m18-olevels)
   sha256 bd6e4557c8e04a2edcf7c0a4f18652e01cf59f735fd3362c0cbe758f01080833 (tar-sha256); compiled at -O2 -Xr */
struct nent { unsigned char e0, e1, e2, e3, e4; };
struct nrec { unsigned char b0, count, b2, b3; struct nent ent[32]; };
void InitChannelState_Che_InitVal(struct nrec *r)
{
  unsigned int i;
  for (i = 0; i < r->count; i++) {
    r->ent[i].e4 = 0;
    if (r->ent[i].e1) {
      r->ent[i].e2 = r->ent[i].e0;
      r->ent[i].e3 = r->ent[i].e0;
    }
  }
}
