/* spelling 10: t as a pointer to a struct with byte members 17..20 */
/* lane_sub helper A, idiom probe class (a) reload-after-store: TVF_Build_Short and Voice_PitchPack_RouteB (KN5000
   sub-CPU payload v1.42, core/05), identical in every probe file except the store of t and its first use. */
/* cc900-module: TVF_Calc_Cutoff_NoKeyFollow */
/* cc900-module: TVF_Bias_Clamp_Amount */
/* cc900-module: TVF_Lookup_Depth_Amount */

#define SW(p, o) (*(int *)((p) + (o)))
#define P(p, o) (*(unsigned char **)((p) + (o)))

extern int __near ram_2940;
int TVF_Calc_Cutoff_NoKeyFollow(unsigned char *v, int c);
int TVF_Bias_Clamp_Amount(int a);
unsigned int TVF_Lookup_Depth_Amount(int a);
struct trec { unsigned char pad[17]; unsigned char b17, b18, b19, b20; };

void TVF_Build_Short(unsigned char *v)
{
    struct trec *t;
    int r;
    unsigned int x;
    t = *(struct trec **)(v + 23);
    r = TVF_Calc_Cutoff_NoKeyFollow(v, t->b17);
    x = ((unsigned int)t->b18 << 13) | 0x400;
    SW(v, 66) = r | x;
    r = TVF_Bias_Clamp_Amount(t->b19);
    SW(v, 68) = r | TVF_Lookup_Depth_Amount(t->b20);
}

void Voice_PitchPack_RouteB(unsigned char *v)
{
    struct trec *t;
    int r;
    unsigned int x;
    t = *(struct trec **)(v + 23);
    r = TVF_Calc_Cutoff_NoKeyFollow(v, t->b17);
    x = ((unsigned int)t->b18 << 13) | 0x400;
    SW(v, 66) = (r | x) | 0x80;
    r = TVF_Bias_Clamp_Amount(t->b19);
    SW(v, 68) = r | TVF_Lookup_Depth_Amount(t->b20);
}
