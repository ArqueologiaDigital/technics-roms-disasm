/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_B_2a.c (2026-11-16-47-sub-r2)
   sha256 317481c6cc0b0362eb3d69ef64a520bc9035dd3312d59f39df1c5ca8e5f184c4 (name+funcs); compiled at -Xr */
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
        ram_451f8 = t | 0x80;
    } else {
        ram_451f8 = 0x80;
        ram_451fa = 0;
    }
}
