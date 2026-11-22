/* Probe round 35r1, helper Z, form a: demo/fdemotext_routines.s (module 265), the xr_screen.py shape at -O3 -Xr.
   FDemoText_GetInstanceID(name): search the view objects, class 255 down to 0 and each class's instances, for
   a viewable one whose name equals name; return its id (class << 16 | instance), else post an error memo and
   return -1.  The class and the instance count are frame cells (declared last-first: class at the frame base),
   the instance a `register` local (XIZ). */
/* cc900-module: FDemoText_ByteData_DisplayRefresh */
/* cc900-name: FdtDisplayRefresh=FDemoText_ByteData_DisplayRefresh */

extern char *__cdecl Strcpy(char *, char *);
extern int __cdecl Strcmp(char *, char *);
extern unsigned int CountObject(unsigned int);
extern int CheckViewObject(unsigned long);
extern char *FdtDisplayRefresh(unsigned long id);
extern void DbMemo_PostString(char *);
extern char ErrStr_GetInstanceID[];
extern unsigned long FDemoText_GetInstanceID(char *);

unsigned long FDemoText_GetInstanceID(char *name)
{
    char buf[128];
    unsigned long n;
    long cls;
    register unsigned long i;

    Strcpy(buf, name);
    for (cls = 255; cls >= 0; cls--) {
        if ((n = CountObject((unsigned int)cls)) != 0) {
            for (i = 0; i < n; i++) {
                if (CheckViewObject((cls << 16) + i) != 0
                    && Strcmp(buf, FdtDisplayRefresh((cls << 16) + i)) == 0)
                    return (cls << 16) + i;
            }
        }
    }
    DbMemo_PostString(ErrStr_GetInstanceID);
    return -1;
}
