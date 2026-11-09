/* Phase 2 exit test: code built by our clang with -mabi=cc900 calls Toshiba-compiled library routines -- the
   copies inside the KN5000 v10 firmware (scripts/analysis/cc900/results/pairs.tsv) -- and the C9H_divlu helper,
   and stores what they return.  run.sh links it with the routines' firmware addresses and runs it in MAME. */
typedef unsigned int size_t;
extern size_t strlen(const char *s);
extern char *strcpy(char *d, const char *s);
extern char *strcat(char *d, const char *s);
extern int strncmp(const char *a, const char *b, size_t n);
extern char *strchr(const char *s, int c);
extern void *memset(void *s, int c, size_t n);
extern void *memcpy(void *d, const void *s, size_t n);
extern char *ultoa(unsigned long v, char *s, int radix);

struct results {
    unsigned short magic;          /* 0xc900 when the test has finished */
    unsigned short len5, len3, cmp_lt, cmp_eq, chr_off;
    unsigned long quot, rem;
    char cat[12], hex[12], fill[8];
};
struct results R;
static char buf[16];

void cc900_test(void)
{
    volatile unsigned long a = 1000000UL, b = 7UL;
    char *p;
    R.len5 = strlen("hello");
    strcpy(buf, "abc");
    R.len3 = strlen(buf);
    strcat(buf, "def");
    memcpy(R.cat, buf, 7);
    R.cmp_lt = strncmp("abc", "abd", 3) < 0;
    R.cmp_eq = strncmp("abcx", "abcy", 3) == 0;
    p = strchr(buf, 'e');
    R.chr_off = p ? (unsigned short)(p - buf) : 0xffff;
    ultoa(1193046UL, R.hex, 16);
    memset(R.fill, 'x', 4);
    R.quot = a / b;
    R.rem = a % b;
    __asm__ __volatile__("" ::: "memory");   /* the helper calls touch no memory: keep this store last */
    *(volatile unsigned short *)&R.magic = 0xc900;
}
