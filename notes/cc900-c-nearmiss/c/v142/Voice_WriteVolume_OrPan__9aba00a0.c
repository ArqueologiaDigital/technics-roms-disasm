/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_B_2b.c (2026-11-16-47-sub-r2)
   sha256 9aba00a0c3e557e6d713bd84f64750019cb84970fa0099d1aa9e45ad5763c846 (name+funcs); compiled at -Xr */
extern unsigned int ram_451f8;
extern unsigned int ram_451fa;
extern unsigned char Voice_EnvelopeLevel_Curve[];
struct vflag { char pad[13]; unsigned char flags; };
struct vlvl { char pad[13]; unsigned char lvl; };
struct vref { char pad[19]; struct vflag *f; struct vlvl *l; };
void Voice_WriteVolume_OrPan(struct vref *v)
{
    struct vflag *f;
    struct vlvl *l;
    unsigned int t;
    f = v->f;
    l = v->l;
    if (f->flags & 0x20) {
        t = Voice_EnvelopeLevel_Curve[l->lvl] << 8;
        ram_451fa = t;
        t |= 0x80;
        ram_451f8 = t;
    } else {
        ram_451f8 = 0x80;
        ram_451fa = 0;
    }
}
