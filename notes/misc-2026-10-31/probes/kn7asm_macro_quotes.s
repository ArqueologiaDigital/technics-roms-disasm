.macro Q s
.ascii "\s"
.endm
.macro V a, r:vararg
.ascii "\a"
.ascii \r
.endm
.macro D a="dflt"
.ascii "\a"
.endm
.macro R s
Q "\s"
.endm
Q "de f"
Q gh
R "x,y"
Q "a\"b"
V "x", "y"
V "x", "y", "z"
D
D a="kw"
