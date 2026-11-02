# The propdata (+16, field signature) string of each NAKA class descriptor is ClassPropdata_<Class>,
# the convention of scripts/converters/name_class_string_pointers.py.  These twelve were named
# NakaInst_* after the record that follows them; each one's only C use is its class descriptor's
# propdata field (lane open6/kn5000-c, 2026-11-02).
s/\bNakaInst_AcEntertainerGridBox\b/ClassPropdata_AcEntertainerGridBox/g
s/\bNakaInst_AccIll\b/ClassPropdata_AccIll/g
s/\bNakaInst_EqualizerBox\b/ClassPropdata_EffectBox/g
s/\bNakaInst_IvSongCopyExit\b/ClassPropdata_IvSongCopyExit/g
s/\bNakaInst_SngSel\b/ClassPropdata_SngSel/g
s/\bNakaInst_SngSel2\b/ClassPropdata_SngSel2/g
s/\bNakaInst_SqedtFix\b/ClassPropdata_SqedtFix/g
s/\bNakaInst_SqedtVal\b/ClassPropdata_SqedtVal/g
s/\bNakaInst_SqedtVal2_End\b/ClassPropdata_SqedtVal2/g
s/\bNakaInst_SqedtVal3\b/ClassPropdata_SqedtVal3/g
s/\bNakaInst_SqedtVal_B\b/ClassPropdata_EqualizerBox/g
s/\bNakaInst_SqplyVal\b/ClassPropdata_SqplyVal/g
