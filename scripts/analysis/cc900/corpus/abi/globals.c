/* How are globals, statics, constants and strings placed and addressed? */
int g_init = 5; int g_bss; static int s_init = 6; static int s_bss;
const int c_val = 7; const char c_str[] = "abc";
char *g_strp = "hello";
extern int ext_i; extern char ext_arr[];
int gl_read(void) { return g_init + g_bss + s_init + s_bss + c_val + ext_i; }
void gl_write(int v) { g_init = v; g_bss = v; s_init = v; s_bss = v; ext_i = v; }
char gl_index(int i) { return ext_arr[i]; }
const char *gl_lit(void) { return "lit"; }
int gl_local_static(void) { static int n; return ++n; }
