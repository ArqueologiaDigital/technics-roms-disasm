/* How is a switch lowered, dense and sparse? */
int sw_dense(int x) { switch (x) { case 0: return 10; case 1: return 11; case 2: return 12; case 3: return 13; case 4: return 14; case 5: return 15; default: return -1; } }
int sw_sparse(int x) { switch (x) { case 1: return 1; case 100: return 2; case 1000: return 3; case 30000: return 4; default: return 0; } }
int sw_char(char c) { switch (c) { case 'a': return 1; case 'b': return 2; case 'c': return 3; case 'd': return 4; case 'e': return 5; } return 0; }
int sw_long(long x) { switch (x) { case 0: return 1; case 1: return 2; case 2: return 3; case 3: return 4; case 4: return 5; } return 0; }
