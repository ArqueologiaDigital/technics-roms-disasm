/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/system_handlers.c (2026-11-16-55-p6-r10)
   sha256 bfd0e3133bebfcc5ff281e0beca2cca883c22f692506e95295fcea794dc731b6 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
void SeqDMA_MultiWrite_SoundEdit(unsigned char n, unsigned char *p)
{
	unsigned int i;

	for (i = 0; i < n; i++)
		SeqBuf_SoundEdit_BytecodeBlock(*p++);
}
