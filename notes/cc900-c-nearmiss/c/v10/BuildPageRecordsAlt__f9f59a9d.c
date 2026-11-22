/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_J_27r1m268e.c (2026-11-22-7-p6-r74)
   sha256 f9f59a9dda7ac7b8da310f8867632cec6de9a22ac014efe80222618a3e65e01e (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern int ram_271ec, ram_271ee, FILE_LIST_LAST, ram_272ca;
extern int BuildPageRecords(void);
void BuildPageRecordsAlt(void)
{
	int n;
	int last;

	ram_271ee = 0;
	FILE_LIST_LAST = 59;
	n = BuildPageRecords();
	last = n > 0 ? n - 1 : 0;
	ram_271ec = last;
	if (last < FILE_LIST_LAST)
		FILE_LIST_LAST = last;
}
