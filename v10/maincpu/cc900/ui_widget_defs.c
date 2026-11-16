/* Firmware C for functions of ui/ui_widget_defs.s (cc900 phase 6).  Built by scripts/build/cc900_firmware_c.py:
   the cc900 reference model at -O3 -XS -Xr, no Toshiba program.  Names are the tree's (shared/ram_variables.s). */
extern long LSW_FILTER;
extern void *ROOT_OBJECT;

void SetLswFilter(long a, long b) { LSW_FILTER = a + b; }
void SetRootObject(void *p) { ROOT_OBJECT = p; }
