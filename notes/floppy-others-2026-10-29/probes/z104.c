/* usage: z104 level < raw > deflated(raw, with zlib header/trailer as 1.0.4 deflateInit_ writes) */
#include <stdio.h>
#include <stdlib.h>
#include "zlib.h"
int main(int argc,char**argv){
  int level=argc>1?atoi(argv[1]):6;
  static unsigned char in[1<<25], out[1<<25]; size_t n=fread(in,1,sizeof in,stdin);
  z_stream s={0}; deflateInit(&s,level);
  s.next_in=in; s.avail_in=n; s.next_out=out; s.avail_out=sizeof out;
  if(deflate(&s,Z_FINISH)!=Z_STREAM_END){fprintf(stderr,"err\n");return 1;}
  fwrite(out,1,s.total_out,stdout); deflateEnd(&s); return 0;}
