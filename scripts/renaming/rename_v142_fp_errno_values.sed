# Spell the values the sub-CPU FP library stores into / compares against FP_Errno as the
# errno names (.equ ERRNO_EDOM 33, ERRNO_ERANGE 34 at the top of kn5000_subprogram_v142.s).
# Only lines that address FP_Errno are touched.  Run on v142/subcpu/subcpu_fp_math.s, then
# regenerate v141 (scripts/generators/create_v141_subcpu_source.py).
/(FP_Errno:24)/s/, 0x0021$/, ERRNO_EDOM/
/(FP_Errno:24)/s/, 0x0022$/, ERRNO_ERANGE/
/(FP_Errno:24)/s/, 33$/, ERRNO_EDOM/
