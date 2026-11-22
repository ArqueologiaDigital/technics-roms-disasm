/* feedback plan I2, probe a: a leaf with loop locals and a function with calls (IZ / QIZ choice) */
extern int ga[10];
extern void f(int);
extern int g(void);

int leaf(int n)
{
    int i, s, t;
    s = 0;
    t = 1;
    for (i = 0; i < n; i++) {
        s += ga[i];
        t += s;
    }
    return s + t;
}

void calls(int n)
{
    int i, v;
    v = g();
    for (i = 0; i < n; i++) {
        f(v);
        v += g();
    }
}
