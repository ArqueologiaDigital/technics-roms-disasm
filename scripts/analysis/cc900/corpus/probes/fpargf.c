/* One double argument temporary and the frame around it (gen_fpargf.py): af_<R><P><B><A><V>.  R: V void, I returns
   gpi + 1, N returns gi.  P: N no parameter, L an unsigned long.  B before: N nothing, S guc /= 10, C vs(gps), W a
   switch with a call.  A after: N nothing, S gu += 3.  V: P vd(gd * gd2), E vd(gd * gda[3]). */
struct st { char c; int i; };
extern double gd, gd2, gda[4]; extern int gi, *gpi; extern unsigned int gu; extern unsigned char guc; extern long gl;
extern struct st *gps; extern void vd(double); extern void vs(struct st *);

void af_VNNNP(void) { vd(gd * gd2); }
void af_VNNNE(void) { vd(gd * gda[3]); }
void af_VNNSP(void) { vd(gd * gd2); gu += 3; }
void af_VNNSE(void) { vd(gd * gda[3]); gu += 3; }
void af_VNSNP(void) { guc /= 10; vd(gd * gd2); }
void af_VNSNE(void) { guc /= 10; vd(gd * gda[3]); }
void af_VNSSP(void) { guc /= 10; vd(gd * gd2); gu += 3; }
void af_VNSSE(void) { guc /= 10; vd(gd * gda[3]); gu += 3; }
void af_VNCNP(void) { vs(gps); vd(gd * gd2); }
void af_VNCNE(void) { vs(gps); vd(gd * gda[3]); }
void af_VNCSP(void) { vs(gps); vd(gd * gd2); gu += 3; }
void af_VNCSE(void) { vs(gps); vd(gd * gda[3]); gu += 3; }
void af_VNWNP(void) { switch (gu) { case 1: gl = 5; break; case 5: vs(gps); break; } vd(gd * gd2); }
void af_VNWNE(void) { switch (gu) { case 1: gl = 5; break; case 5: vs(gps); break; } vd(gd * gda[3]); }
void af_VNWSP(void) { switch (gu) { case 1: gl = 5; break; case 5: vs(gps); break; } vd(gd * gd2); gu += 3; }
void af_VNWSE(void) { switch (gu) { case 1: gl = 5; break; case 5: vs(gps); break; } vd(gd * gda[3]); gu += 3; }
void af_VLNNP(unsigned long a) { vd(gd * gd2); }
void af_VLNNE(unsigned long a) { vd(gd * gda[3]); }
void af_VLNSP(unsigned long a) { vd(gd * gd2); gu += 3; }
void af_VLNSE(unsigned long a) { vd(gd * gda[3]); gu += 3; }
void af_VLSNP(unsigned long a) { guc /= 10; vd(gd * gd2); }
void af_VLSNE(unsigned long a) { guc /= 10; vd(gd * gda[3]); }
void af_VLSSP(unsigned long a) { guc /= 10; vd(gd * gd2); gu += 3; }
void af_VLSSE(unsigned long a) { guc /= 10; vd(gd * gda[3]); gu += 3; }
void af_VLCNP(unsigned long a) { vs(gps); vd(gd * gd2); }
void af_VLCNE(unsigned long a) { vs(gps); vd(gd * gda[3]); }
void af_VLCSP(unsigned long a) { vs(gps); vd(gd * gd2); gu += 3; }
void af_VLCSE(unsigned long a) { vs(gps); vd(gd * gda[3]); gu += 3; }
void af_VLWNP(unsigned long a) { switch (gu) { case 1: gl = 5; break; case 5: vs(gps); break; } vd(gd * gd2); }
void af_VLWNE(unsigned long a) { switch (gu) { case 1: gl = 5; break; case 5: vs(gps); break; } vd(gd * gda[3]); }
void af_VLWSP(unsigned long a) { switch (gu) { case 1: gl = 5; break; case 5: vs(gps); break; } vd(gd * gd2); gu += 3; }
void af_VLWSE(unsigned long a) { switch (gu) { case 1: gl = 5; break; case 5: vs(gps); break; } vd(gd * gda[3]); gu += 3; }
int * af_INNNP(void) { vd(gd * gd2); return gpi + 1; }
int * af_INNNE(void) { vd(gd * gda[3]); return gpi + 1; }
int * af_INNSP(void) { vd(gd * gd2); gu += 3; return gpi + 1; }
int * af_INNSE(void) { vd(gd * gda[3]); gu += 3; return gpi + 1; }
int * af_INSNP(void) { guc /= 10; vd(gd * gd2); return gpi + 1; }
int * af_INSNE(void) { guc /= 10; vd(gd * gda[3]); return gpi + 1; }
int * af_INSSP(void) { guc /= 10; vd(gd * gd2); gu += 3; return gpi + 1; }
int * af_INSSE(void) { guc /= 10; vd(gd * gda[3]); gu += 3; return gpi + 1; }
int * af_INCNP(void) { vs(gps); vd(gd * gd2); return gpi + 1; }
int * af_INCNE(void) { vs(gps); vd(gd * gda[3]); return gpi + 1; }
int * af_INCSP(void) { vs(gps); vd(gd * gd2); gu += 3; return gpi + 1; }
int * af_INCSE(void) { vs(gps); vd(gd * gda[3]); gu += 3; return gpi + 1; }
int * af_INWNP(void) { switch (gu) { case 1: gl = 5; break; case 5: vs(gps); break; } vd(gd * gd2); return gpi + 1; }
int * af_INWNE(void) { switch (gu) { case 1: gl = 5; break; case 5: vs(gps); break; } vd(gd * gda[3]); return gpi + 1; }
int * af_INWSP(void) { switch (gu) { case 1: gl = 5; break; case 5: vs(gps); break; } vd(gd * gd2); gu += 3; return gpi + 1; }
int * af_INWSE(void) { switch (gu) { case 1: gl = 5; break; case 5: vs(gps); break; } vd(gd * gda[3]); gu += 3; return gpi + 1; }
int * af_ILNNP(unsigned long a) { vd(gd * gd2); return gpi + 1; }
int * af_ILNNE(unsigned long a) { vd(gd * gda[3]); return gpi + 1; }
int * af_ILNSP(unsigned long a) { vd(gd * gd2); gu += 3; return gpi + 1; }
int * af_ILNSE(unsigned long a) { vd(gd * gda[3]); gu += 3; return gpi + 1; }
int * af_ILSNP(unsigned long a) { guc /= 10; vd(gd * gd2); return gpi + 1; }
int * af_ILSNE(unsigned long a) { guc /= 10; vd(gd * gda[3]); return gpi + 1; }
int * af_ILSSP(unsigned long a) { guc /= 10; vd(gd * gd2); gu += 3; return gpi + 1; }
int * af_ILSSE(unsigned long a) { guc /= 10; vd(gd * gda[3]); gu += 3; return gpi + 1; }
int * af_ILCNP(unsigned long a) { vs(gps); vd(gd * gd2); return gpi + 1; }
int * af_ILCNE(unsigned long a) { vs(gps); vd(gd * gda[3]); return gpi + 1; }
int * af_ILCSP(unsigned long a) { vs(gps); vd(gd * gd2); gu += 3; return gpi + 1; }
int * af_ILCSE(unsigned long a) { vs(gps); vd(gd * gda[3]); gu += 3; return gpi + 1; }
int * af_ILWNP(unsigned long a) { switch (gu) { case 1: gl = 5; break; case 5: vs(gps); break; } vd(gd * gd2); return gpi + 1; }
int * af_ILWNE(unsigned long a) { switch (gu) { case 1: gl = 5; break; case 5: vs(gps); break; } vd(gd * gda[3]); return gpi + 1; }
int * af_ILWSP(unsigned long a) { switch (gu) { case 1: gl = 5; break; case 5: vs(gps); break; } vd(gd * gd2); gu += 3; return gpi + 1; }
int * af_ILWSE(unsigned long a) { switch (gu) { case 1: gl = 5; break; case 5: vs(gps); break; } vd(gd * gda[3]); gu += 3; return gpi + 1; }
int af_NNNNP(void) { vd(gd * gd2); return gi; }
int af_NNNNE(void) { vd(gd * gda[3]); return gi; }
int af_NNNSP(void) { vd(gd * gd2); gu += 3; return gi; }
int af_NNNSE(void) { vd(gd * gda[3]); gu += 3; return gi; }
int af_NNSNP(void) { guc /= 10; vd(gd * gd2); return gi; }
int af_NNSNE(void) { guc /= 10; vd(gd * gda[3]); return gi; }
int af_NNSSP(void) { guc /= 10; vd(gd * gd2); gu += 3; return gi; }
int af_NNSSE(void) { guc /= 10; vd(gd * gda[3]); gu += 3; return gi; }
int af_NNCNP(void) { vs(gps); vd(gd * gd2); return gi; }
int af_NNCNE(void) { vs(gps); vd(gd * gda[3]); return gi; }
int af_NNCSP(void) { vs(gps); vd(gd * gd2); gu += 3; return gi; }
int af_NNCSE(void) { vs(gps); vd(gd * gda[3]); gu += 3; return gi; }
int af_NNWNP(void) { switch (gu) { case 1: gl = 5; break; case 5: vs(gps); break; } vd(gd * gd2); return gi; }
int af_NNWNE(void) { switch (gu) { case 1: gl = 5; break; case 5: vs(gps); break; } vd(gd * gda[3]); return gi; }
int af_NNWSP(void) { switch (gu) { case 1: gl = 5; break; case 5: vs(gps); break; } vd(gd * gd2); gu += 3; return gi; }
int af_NNWSE(void) { switch (gu) { case 1: gl = 5; break; case 5: vs(gps); break; } vd(gd * gda[3]); gu += 3; return gi; }
int af_NLNNP(unsigned long a) { vd(gd * gd2); return gi; }
int af_NLNNE(unsigned long a) { vd(gd * gda[3]); return gi; }
int af_NLNSP(unsigned long a) { vd(gd * gd2); gu += 3; return gi; }
int af_NLNSE(unsigned long a) { vd(gd * gda[3]); gu += 3; return gi; }
int af_NLSNP(unsigned long a) { guc /= 10; vd(gd * gd2); return gi; }
int af_NLSNE(unsigned long a) { guc /= 10; vd(gd * gda[3]); return gi; }
int af_NLSSP(unsigned long a) { guc /= 10; vd(gd * gd2); gu += 3; return gi; }
int af_NLSSE(unsigned long a) { guc /= 10; vd(gd * gda[3]); gu += 3; return gi; }
int af_NLCNP(unsigned long a) { vs(gps); vd(gd * gd2); return gi; }
int af_NLCNE(unsigned long a) { vs(gps); vd(gd * gda[3]); return gi; }
int af_NLCSP(unsigned long a) { vs(gps); vd(gd * gd2); gu += 3; return gi; }
int af_NLCSE(unsigned long a) { vs(gps); vd(gd * gda[3]); gu += 3; return gi; }
int af_NLWNP(unsigned long a) { switch (gu) { case 1: gl = 5; break; case 5: vs(gps); break; } vd(gd * gd2); return gi; }
int af_NLWNE(unsigned long a) { switch (gu) { case 1: gl = 5; break; case 5: vs(gps); break; } vd(gd * gda[3]); return gi; }
int af_NLWSP(unsigned long a) { switch (gu) { case 1: gl = 5; break; case 5: vs(gps); break; } vd(gd * gd2); gu += 3; return gi; }
int af_NLWSE(unsigned long a) { switch (gu) { case 1: gl = 5; break; case 5: vs(gps); break; } vd(gd * gda[3]); gu += 3; return gi; }
