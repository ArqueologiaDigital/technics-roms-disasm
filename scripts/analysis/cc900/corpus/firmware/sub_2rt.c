/* lane_sub probe round 2: which runtime routines V4.23 calls for long / float / double arithmetic, so that
   sub_v423.py can map them to the payload's labels (Math_Multiply32, Int_SignedDiv_AltEntry, FP_*). */
long rt_lmul(long a, long b) { return a * b; }
unsigned long rt_ulmul(unsigned long a, unsigned long b) { return a * b; }
long rt_ldiv(long a, long b) { return a / b; }
unsigned long rt_uldiv(unsigned long a, unsigned long b) { return a / b; }
long rt_lmod(long a, long b) { return a % b; }
int rt_idiv(int a, int b) { return a / b; }
int rt_imod(int a, int b) { return a % b; }
unsigned int rt_uidiv(unsigned int a, unsigned int b) { return a / b; }
long rt_lshl(long a, int n) { return a << n; }
long rt_lshr(long a, int n) { return a >> n; }
float rt_fadd(float a, float b) { return a + b; }
float rt_fsub(float a, float b) { return a - b; }
float rt_fmul(float a, float b) { return a * b; }
float rt_fdiv(float a, float b) { return a / b; }
int rt_fcmp(float a, float b) { return a < b; }
int rt_ftoi(float a) { return (int)a; }
long rt_ftol(float a) { return (long)a; }
float rt_itof(int a) { return a; }
float rt_ltof(long a) { return a; }
double rt_ftod(float a) { return a; }
float rt_dtof(double a) { return (float)a; }
double rt_dadd(double a, double b) { return a + b; }
double rt_dsub(double a, double b) { return a - b; }
double rt_dmul(double a, double b) { return a * b; }
double rt_ddiv(double a, double b) { return a / b; }
int rt_dcmp(double a, double b) { return a < b; }
int rt_dtoi(double a) { return (int)a; }
double rt_itod(int a) { return a; }
float rt_fneg(float a) { return -a; }
double rt_dneg(double a) { return -a; }
