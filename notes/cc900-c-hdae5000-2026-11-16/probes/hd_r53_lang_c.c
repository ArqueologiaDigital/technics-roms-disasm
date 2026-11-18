/* hd_r53_lang_c.c (lane_hd round 53): HDAE5000_AcLanguageText1Proc, form c, from hd_r50_lang.c (helper h_lang).
   Run 2026-11-18-4-hd-r50: both forms give the ROM's 6,229 bytes but for two items (selectlist/cmp.py with the
   whole procedure, 0x17b4 bytes from the label):
   1. the text pointer passed to StrNCmp: the ROM `ld xwa,xiz; push xwa` (3 times), V4.23 `push xiz`: an argument
      that is CONVERTED goes through XWA (the format-string idiom of Separate*Check);
   2. the GET_STR_PTR SendEvent: the ROM loads the function pointer into XIX and copies the result to XIZ, V4.23
      into XHL.  In SelectListProc the pointer went to XIX only when the result was assigned to a register local
      held in XHL (`u = GETVIEWL(obj)`), so the result goes through such a local here.
   This form: str an `unsigned char *`, passed `(char *)str`; the result converted, `str = (unsigned char *)CALLR(long, ..)(..)`.
   cc900-options: -Xr
   cc900-data: HDAE5000_AcLanguageText1Proc 1 = HDAE5000_LangText_CaseTable
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

extern char *__cdecl HDAE5000_StrCpy(char *, char *);
extern int __cdecl HDAE5000_StrNCmp(char *, char *, unsigned int);

struct LangTextView { char pad[26]; int msg; };

extern char HDAE5000_Str_Aclanguage1[];
extern char HDAE5000_Str_LANENG00[];
extern char HDAE5000_Str_LANDEU00[];
extern char HDAE5000_Str_LANFRA00[];
extern char HDAE5000_LangMsg_NoMessage[];
extern char HDAE5000_LangMsg_001_EN[], HDAE5000_LangMsg_001_DE[], HDAE5000_LangMsg_001_FR[];
extern char HDAE5000_LangMsg_002_EN[], HDAE5000_LangMsg_002_DE[], HDAE5000_LangMsg_002_FR[];
extern char HDAE5000_LangMsg_003_EN[], HDAE5000_LangMsg_003_DE[], HDAE5000_LangMsg_003_FR[];
extern char HDAE5000_LangMsg_004_EN[], HDAE5000_LangMsg_004_DE[], HDAE5000_LangMsg_004_FR[];
extern char HDAE5000_LangMsg_005_EN[], HDAE5000_LangMsg_005_DE[], HDAE5000_LangMsg_005_FR[];
extern char HDAE5000_LangMsg_006_EN[], HDAE5000_LangMsg_006_DE[], HDAE5000_LangMsg_006_FR[];
extern char HDAE5000_LangMsg_007_EN[], HDAE5000_LangMsg_007_DE[], HDAE5000_LangMsg_007_FR[];
extern char HDAE5000_LangMsg_008_EN[], HDAE5000_LangMsg_008_DE[], HDAE5000_LangMsg_008_FR[];
extern char HDAE5000_LangMsg_009_EN[], HDAE5000_LangMsg_009_DE[], HDAE5000_LangMsg_009_FR[];
extern char HDAE5000_LangMsg_010_EN[], HDAE5000_LangMsg_010_DE[], HDAE5000_LangMsg_010_FR[];
extern char HDAE5000_LangMsg_011_EN[], HDAE5000_LangMsg_011_DE[], HDAE5000_LangMsg_011_FR[];
extern char HDAE5000_LangMsg_012_EN[], HDAE5000_LangMsg_012_DE[], HDAE5000_LangMsg_012_FR[];
extern char HDAE5000_LangMsg_013_EN[], HDAE5000_LangMsg_013_DE[], HDAE5000_LangMsg_013_FR[];
extern char HDAE5000_LangMsg_014_EN[], HDAE5000_LangMsg_014_DE[], HDAE5000_LangMsg_014_FR[];
extern char HDAE5000_LangMsg_015_EN[], HDAE5000_LangMsg_015_DE[], HDAE5000_LangMsg_015_FR[];
extern char HDAE5000_LangMsg_016_EN[], HDAE5000_LangMsg_016_DE[], HDAE5000_LangMsg_016_FR[];
extern char HDAE5000_LangMsg_017_EN[], HDAE5000_LangMsg_017_DE[], HDAE5000_LangMsg_017_FR[];
extern char HDAE5000_LangMsg_018_EN[], HDAE5000_LangMsg_018_DE[], HDAE5000_LangMsg_018_FR[];
extern char HDAE5000_LangMsg_019_EN[], HDAE5000_LangMsg_019_DE[], HDAE5000_LangMsg_019_FR[];
extern char HDAE5000_LangMsg_020_EN[], HDAE5000_LangMsg_020_DE[], HDAE5000_LangMsg_020_FR[];
extern char HDAE5000_LangMsg_021_EN[], HDAE5000_LangMsg_021_DE[], HDAE5000_LangMsg_021_FR[];
extern char HDAE5000_LangMsg_022_EN[], HDAE5000_LangMsg_022_DE[], HDAE5000_LangMsg_022_FR[];
extern char HDAE5000_LangMsg_023_EN[], HDAE5000_LangMsg_023_DE[], HDAE5000_LangMsg_023_FR[];
extern char HDAE5000_LangMsg_024_EN[], HDAE5000_LangMsg_024_DE[], HDAE5000_LangMsg_024_FR[];
extern char HDAE5000_LangMsg_025_EN[], HDAE5000_LangMsg_025_DE[], HDAE5000_LangMsg_025_FR[];
extern char HDAE5000_LangMsg_026_EN[], HDAE5000_LangMsg_026_DE[], HDAE5000_LangMsg_026_FR[];
extern char HDAE5000_LangMsg_027_EN[], HDAE5000_LangMsg_027_DE[], HDAE5000_LangMsg_027_FR[];
extern char HDAE5000_LangMsg_028_EN[], HDAE5000_LangMsg_028_DE[], HDAE5000_LangMsg_028_FR[];
extern char HDAE5000_LangMsg_029_EN[], HDAE5000_LangMsg_029_DE[], HDAE5000_LangMsg_029_FR[];
extern char HDAE5000_LangMsg_030_EN[], HDAE5000_LangMsg_030_DE[], HDAE5000_LangMsg_030_FR[];
extern char HDAE5000_LangMsg_031_EN[], HDAE5000_LangMsg_031_DE[], HDAE5000_LangMsg_031_FR[];
extern char HDAE5000_LangMsg_032_EN[], HDAE5000_LangMsg_032_DE[], HDAE5000_LangMsg_032_FR[];
extern char HDAE5000_LangMsg_033_EN[], HDAE5000_LangMsg_033_DE[], HDAE5000_LangMsg_033_FR[];
extern char HDAE5000_LangMsg_034_EN[], HDAE5000_LangMsg_034_DE[], HDAE5000_LangMsg_034_FR[];
extern char HDAE5000_LangMsg_035_EN[], HDAE5000_LangMsg_035_DE[], HDAE5000_LangMsg_035_FR[];
extern char HDAE5000_LangMsg_036_EN[], HDAE5000_LangMsg_036_DE[], HDAE5000_LangMsg_036_FR[];
extern char HDAE5000_LangMsg_037_EN[], HDAE5000_LangMsg_037_DE[], HDAE5000_LangMsg_037_FR[];
extern char HDAE5000_LangMsg_038_EN[], HDAE5000_LangMsg_038_DE[], HDAE5000_LangMsg_038_FR[];
extern char HDAE5000_LangMsg_039_EN[], HDAE5000_LangMsg_039_DE[], HDAE5000_LangMsg_039_FR[];
extern char HDAE5000_LangMsg_040_EN[], HDAE5000_LangMsg_040_DE[], HDAE5000_LangMsg_040_FR[];
extern char HDAE5000_LangMsg_041_EN[], HDAE5000_LangMsg_041_DE[], HDAE5000_LangMsg_041_FR[];
extern char HDAE5000_LangMsg_042_EN[], HDAE5000_LangMsg_042_DE[], HDAE5000_LangMsg_042_FR[];
extern char HDAE5000_LangMsg_043_EN[], HDAE5000_LangMsg_043_DE[], HDAE5000_LangMsg_043_FR[];
extern char HDAE5000_LangMsg_044_EN[], HDAE5000_LangMsg_044_DE[], HDAE5000_LangMsg_044_FR[];
extern char HDAE5000_LangMsg_045_EN[], HDAE5000_LangMsg_045_DE[], HDAE5000_LangMsg_045_FR[];
extern char HDAE5000_LangMsg_046_EN[], HDAE5000_LangMsg_046_DE[], HDAE5000_LangMsg_046_FR[];
extern char HDAE5000_LangMsg_047_EN[], HDAE5000_LangMsg_047_DE[], HDAE5000_LangMsg_047_FR[];
extern char HDAE5000_LangMsg_048_EN[], HDAE5000_LangMsg_048_DE[], HDAE5000_LangMsg_048_FR[];
extern char HDAE5000_LangMsg_049_EN[], HDAE5000_LangMsg_049_DE[], HDAE5000_LangMsg_049_FR[];
extern char HDAE5000_LangMsg_050_EN[], HDAE5000_LangMsg_050_DE[], HDAE5000_LangMsg_050_FR[];
extern char HDAE5000_LangMsg_051_EN[], HDAE5000_LangMsg_051_DE[], HDAE5000_LangMsg_051_FR[];
extern char HDAE5000_LangMsg_052_EN[], HDAE5000_LangMsg_052_DE[], HDAE5000_LangMsg_052_FR[];
extern char HDAE5000_LangMsg_053_EN[], HDAE5000_LangMsg_053_DE[], HDAE5000_LangMsg_053_FR[];
extern char HDAE5000_LangMsg_054_EN[], HDAE5000_LangMsg_054_DE[], HDAE5000_LangMsg_054_FR[];
extern char HDAE5000_LangMsg_055_EN[], HDAE5000_LangMsg_055_DE[], HDAE5000_LangMsg_055_FR[];
extern char HDAE5000_LangMsg_056_EN[], HDAE5000_LangMsg_056_DE[], HDAE5000_LangMsg_056_FR[];
extern char HDAE5000_LangMsg_057_EN[], HDAE5000_LangMsg_057_DE[], HDAE5000_LangMsg_057_FR[];
extern char HDAE5000_LangMsg_058_EN[], HDAE5000_LangMsg_058_DE[], HDAE5000_LangMsg_058_FR[];
extern char HDAE5000_LangMsg_059_EN[], HDAE5000_LangMsg_059_DE[], HDAE5000_LangMsg_059_FR[];
extern char HDAE5000_LangMsg_060_EN[], HDAE5000_LangMsg_060_DE[], HDAE5000_LangMsg_060_FR[];
extern char HDAE5000_LangMsg_061_EN[], HDAE5000_LangMsg_061_DE[], HDAE5000_LangMsg_061_FR[];
extern char HDAE5000_LangMsg_062_EN[], HDAE5000_LangMsg_062_DE[], HDAE5000_LangMsg_062_FR[];
extern char HDAE5000_LangMsg_064_EN[], HDAE5000_LangMsg_064_DE[], HDAE5000_LangMsg_064_FR[];
extern char HDAE5000_LangMsg_065_EN[], HDAE5000_LangMsg_065_DE[], HDAE5000_LangMsg_065_FR[];
extern char HDAE5000_LangMsg_066_EN[], HDAE5000_LangMsg_066_DE[], HDAE5000_LangMsg_066_FR[];
extern char HDAE5000_LangMsg_067_EN[], HDAE5000_LangMsg_067_DE[], HDAE5000_LangMsg_067_FR[];
extern char HDAE5000_LangMsg_200_EN[], HDAE5000_LangMsg_200_DE[], HDAE5000_LangMsg_200_FR[];
extern char HDAE5000_LangMsg_201_EN[], HDAE5000_LangMsg_201_DE[], HDAE5000_LangMsg_201_FR[];
extern char HDAE5000_LangMsg_202_EN[], HDAE5000_LangMsg_202_DE[], HDAE5000_LangMsg_202_FR[];
extern char HDAE5000_LangMsg_203_EN[], HDAE5000_LangMsg_203_DE[], HDAE5000_LangMsg_203_FR[];
extern char HDAE5000_LangMsg_206_EN[], HDAE5000_LangMsg_206_DE[], HDAE5000_LangMsg_206_FR[];
extern char HDAE5000_LangMsg_207_EN[], HDAE5000_LangMsg_207_DE[], HDAE5000_LangMsg_207_FR[];
extern char HDAE5000_LangMsg_208_EN[], HDAE5000_LangMsg_208_DE[], HDAE5000_LangMsg_208_FR[];
extern char HDAE5000_LangMsg_209_EN[], HDAE5000_LangMsg_209_DE[], HDAE5000_LangMsg_209_FR[];
extern char HDAE5000_LangMsg_210_EN[], HDAE5000_LangMsg_210_DE[], HDAE5000_LangMsg_210_FR[];
extern char HDAE5000_LangMsg_211_EN[], HDAE5000_LangMsg_211_DE[], HDAE5000_LangMsg_211_FR[];
extern char HDAE5000_LangMsg_212_EN[], HDAE5000_LangMsg_212_DE[], HDAE5000_LangMsg_212_FR[];

long HDAE5000_AcLanguageText1Proc(long obj, long ev, long arg)
{
    unsigned char *str;
    char buf[200];
    int lang;

    switch (ev) {
    default:
        return CALLR(long, ROOT->InheritedProc)(obj, ev, arg);
    case EVT_GET_STR_PTR:
        return (long)HDAE5000_Str_Aclanguage1;
    case EVT_PARA_DRAW:
        if (arg == 0) {
            str = (unsigned char *)CALLR(long, ROOT->SendEvent)(obj, EVT_GET_STR_PTR, 0L);
            if (*str == 0) {
                CALLV(ROOT->InheritedProc)(obj, ev, arg);
                return 0;
            }
        } else
            str = (unsigned char *)arg;
        lang = -1;
        if (HDAE5000_StrNCmp((char *)str, HDAE5000_Str_LANENG00, 8) == 0)
            lang = 1;
        if (HDAE5000_StrNCmp((char *)str, HDAE5000_Str_LANDEU00, 8) == 0)
            lang = 2;
        if (HDAE5000_StrNCmp((char *)str, HDAE5000_Str_LANFRA00, 8) == 0)
            lang = 3;
        if (lang < 0) {
            CALLV(ROOT->InheritedProc)(obj, ev, arg);
            return 0;
        }
        switch (CALLR(struct LangTextView *, ROOT->GetViewInstance)(obj)->msg) {
        case 1:
            if (lang == 1)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_001_EN);
            if (lang == 2)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_001_DE);
            if (lang == 3)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_001_FR);
            break;
        case 2:
            if (lang == 1)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_002_EN);
            if (lang == 2)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_002_DE);
            if (lang == 3)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_002_FR);
            break;
        case 3:
            if (lang == 1)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_003_EN);
            if (lang == 2)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_003_DE);
            if (lang == 3)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_003_FR);
            break;
        case 4:
            if (lang == 1)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_004_EN);
            if (lang == 2)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_004_DE);
            if (lang == 3)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_004_FR);
            break;
        case 5:
            if (lang == 1)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_005_EN);
            if (lang == 2)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_005_DE);
            if (lang == 3)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_005_FR);
            break;
        case 6:
            if (lang == 1)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_006_EN);
            if (lang == 2)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_006_DE);
            if (lang == 3)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_006_FR);
            break;
        case 7:
            if (lang == 1)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_007_EN);
            if (lang == 2)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_007_DE);
            if (lang == 3)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_007_FR);
            break;
        case 8:
            if (lang == 1)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_008_EN);
            if (lang == 2)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_008_DE);
            if (lang == 3)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_008_FR);
            break;
        case 9:
            if (lang == 1)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_009_EN);
            if (lang == 2)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_009_DE);
            if (lang == 3)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_009_FR);
            break;
        case 10:
            if (lang == 1)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_010_EN);
            if (lang == 2)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_010_DE);
            if (lang == 3)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_010_FR);
            break;
        case 11:
            if (lang == 1)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_011_EN);
            if (lang == 2)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_011_DE);
            if (lang == 3)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_011_FR);
            break;
        case 12:
            if (lang == 1)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_012_EN);
            if (lang == 2)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_012_DE);
            if (lang == 3)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_012_FR);
            break;
        case 13:
            if (lang == 1)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_013_EN);
            if (lang == 2)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_013_DE);
            if (lang == 3)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_013_FR);
            break;
        case 14:
            if (lang == 1)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_014_EN);
            if (lang == 2)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_014_DE);
            if (lang == 3)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_014_FR);
            break;
        case 15:
            if (lang == 1)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_015_EN);
            if (lang == 2)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_015_DE);
            if (lang == 3)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_015_FR);
            break;
        case 16:
            if (lang == 1)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_016_EN);
            if (lang == 2)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_016_DE);
            if (lang == 3)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_016_FR);
            break;
        case 17:
            if (lang == 1)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_017_EN);
            if (lang == 2)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_017_DE);
            if (lang == 3)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_017_FR);
            break;
        case 18:
            if (lang == 1)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_018_EN);
            if (lang == 2)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_018_DE);
            if (lang == 3)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_018_FR);
            break;
        case 19:
            if (lang == 1)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_019_EN);
            if (lang == 2)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_019_DE);
            if (lang == 3)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_019_FR);
            break;
        case 20:
            if (lang == 1)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_020_EN);
            if (lang == 2)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_020_DE);
            if (lang == 3)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_020_FR);
            break;
        case 21:
            if (lang == 1)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_021_EN);
            if (lang == 2)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_021_DE);
            if (lang == 3)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_021_FR);
            break;
        case 22:
            if (lang == 1)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_022_EN);
            if (lang == 2)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_022_DE);
            if (lang == 3)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_022_FR);
            break;
        case 23:
            if (lang == 1)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_023_EN);
            if (lang == 2)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_023_DE);
            if (lang == 3)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_023_FR);
            break;
        case 24:
            if (lang == 1)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_024_EN);
            if (lang == 2)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_024_DE);
            if (lang == 3)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_024_FR);
            break;
        case 25:
            if (lang == 1)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_025_EN);
            if (lang == 2)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_025_DE);
            if (lang == 3)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_025_FR);
            break;
        case 26:
            if (lang == 1)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_026_EN);
            if (lang == 2)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_026_DE);
            if (lang == 3)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_026_FR);
            break;
        case 27:
            if (lang == 1)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_027_EN);
            if (lang == 2)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_027_DE);
            if (lang == 3)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_027_FR);
            break;
        case 28:
            if (lang == 1)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_028_EN);
            if (lang == 2)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_028_DE);
            if (lang == 3)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_028_FR);
            break;
        case 29:
            if (lang == 1)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_029_EN);
            if (lang == 2)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_029_DE);
            if (lang == 3)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_029_FR);
            break;
        case 30:
            if (lang == 1)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_030_EN);
            if (lang == 2)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_030_DE);
            if (lang == 3)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_030_FR);
            break;
        case 31:
            if (lang == 1)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_031_EN);
            if (lang == 2)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_031_DE);
            if (lang == 3)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_031_FR);
            break;
        case 32:
            if (lang == 1)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_032_EN);
            if (lang == 2)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_032_DE);
            if (lang == 3)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_032_FR);
            break;
        case 33:
            if (lang == 1)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_033_EN);
            if (lang == 2)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_033_DE);
            if (lang == 3)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_033_FR);
            break;
        case 34:
            if (lang == 1)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_034_EN);
            if (lang == 2)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_034_DE);
            if (lang == 3)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_034_FR);
            break;
        case 35:
            if (lang == 1)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_035_EN);
            if (lang == 2)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_035_DE);
            if (lang == 3)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_035_FR);
            break;
        case 36:
            if (lang == 1)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_036_EN);
            if (lang == 2)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_036_DE);
            if (lang == 3)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_036_FR);
            break;
        case 37:
            if (lang == 1)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_037_EN);
            if (lang == 2)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_037_DE);
            if (lang == 3)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_037_FR);
            break;
        case 38:
            if (lang == 1)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_038_EN);
            if (lang == 2)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_038_DE);
            if (lang == 3)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_038_FR);
            break;
        case 39:
            if (lang == 1)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_039_EN);
            if (lang == 2)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_039_DE);
            if (lang == 3)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_039_FR);
            break;
        case 40:
            if (lang == 1)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_040_EN);
            if (lang == 2)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_040_DE);
            if (lang == 3)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_040_FR);
            break;
        case 41:
            if (lang == 1)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_041_EN);
            if (lang == 2)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_041_DE);
            if (lang == 3)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_041_FR);
            break;
        case 42:
            if (lang == 1)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_042_EN);
            if (lang == 2)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_042_DE);
            if (lang == 3)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_042_FR);
            break;
        case 43:
            if (lang == 1)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_043_EN);
            if (lang == 2)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_043_DE);
            if (lang == 3)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_043_FR);
            break;
        case 44:
            if (lang == 1)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_044_EN);
            if (lang == 2)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_044_DE);
            if (lang == 3)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_044_FR);
            break;
        case 45:
            if (lang == 1)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_045_EN);
            if (lang == 2)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_045_DE);
            if (lang == 3)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_045_FR);
            break;
        case 46:
            if (lang == 1)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_046_EN);
            if (lang == 2)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_046_DE);
            if (lang == 3)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_046_FR);
            break;
        case 47:
            if (lang == 1)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_047_EN);
            if (lang == 2)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_047_DE);
            if (lang == 3)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_047_FR);
            break;
        case 48:
            if (lang == 1)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_048_EN);
            if (lang == 2)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_048_DE);
            if (lang == 3)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_048_FR);
            break;
        case 49:
            if (lang == 1)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_049_EN);
            if (lang == 2)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_049_DE);
            if (lang == 3)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_049_FR);
            break;
        case 50:
            if (lang == 1)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_050_EN);
            if (lang == 2)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_050_DE);
            if (lang == 3)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_050_FR);
            break;
        case 51:
            if (lang == 1)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_051_EN);
            if (lang == 2)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_051_DE);
            if (lang == 3)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_051_FR);
            break;
        case 52:
            if (lang == 1)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_052_EN);
            if (lang == 2)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_052_DE);
            if (lang == 3)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_052_FR);
            break;
        case 53:
            if (lang == 1)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_053_EN);
            if (lang == 2)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_053_DE);
            if (lang == 3)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_053_FR);
            break;
        case 54:
            if (lang == 1)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_054_EN);
            if (lang == 2)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_054_DE);
            if (lang == 3)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_054_FR);
            break;
        case 55:
            if (lang == 1)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_055_EN);
            if (lang == 2)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_055_DE);
            if (lang == 3)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_055_FR);
            break;
        case 56:
            if (lang == 1)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_056_EN);
            if (lang == 2)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_056_DE);
            if (lang == 3)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_056_FR);
            break;
        case 57:
            if (lang == 1)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_057_EN);
            if (lang == 2)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_057_DE);
            if (lang == 3)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_057_FR);
            break;
        case 58:
            if (lang == 1)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_058_EN);
            if (lang == 2)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_058_DE);
            if (lang == 3)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_058_FR);
            break;
        case 59:
            if (lang == 1)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_059_EN);
            if (lang == 2)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_059_DE);
            if (lang == 3)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_059_FR);
            break;
        case 60:
            if (lang == 1)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_060_EN);
            if (lang == 2)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_060_DE);
            if (lang == 3)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_060_FR);
            break;
        case 61:
            if (lang == 1)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_061_EN);
            if (lang == 2)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_061_DE);
            if (lang == 3)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_061_FR);
            break;
        case 62:
            if (lang == 1)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_062_EN);
            if (lang == 2)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_062_DE);
            if (lang == 3)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_062_FR);
            break;
        case 64:
            if (lang == 1)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_064_EN);
            if (lang == 2)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_064_DE);
            if (lang == 3)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_064_FR);
            break;
        case 65:
            if (lang == 1)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_065_EN);
            if (lang == 2)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_065_DE);
            if (lang == 3)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_065_FR);
            break;
        case 66:
            if (lang == 1)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_066_EN);
            if (lang == 2)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_066_DE);
            if (lang == 3)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_066_FR);
            break;
        case 67:
            if (lang == 1)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_067_EN);
            if (lang == 2)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_067_DE);
            if (lang == 3)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_067_FR);
            break;
        case 200:
            if (lang == 1)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_200_EN);
            if (lang == 2)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_200_DE);
            if (lang == 3)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_200_FR);
            break;
        case 201:
            if (lang == 1)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_201_EN);
            if (lang == 2)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_201_DE);
            if (lang == 3)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_201_FR);
            break;
        case 202:
            if (lang == 1)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_202_EN);
            if (lang == 2)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_202_DE);
            if (lang == 3)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_202_FR);
            break;
        case 203:
            if (lang == 1)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_203_EN);
            if (lang == 2)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_203_DE);
            if (lang == 3)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_203_FR);
            break;
        case 206:
            if (lang == 1)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_206_EN);
            if (lang == 2)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_206_DE);
            if (lang == 3)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_206_FR);
            break;
        case 207:
            if (lang == 1)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_207_EN);
            if (lang == 2)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_207_DE);
            if (lang == 3)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_207_FR);
            break;
        case 208:
            if (lang == 1)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_208_EN);
            if (lang == 2)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_208_DE);
            if (lang == 3)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_208_FR);
            break;
        case 209:
            if (lang == 1)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_209_EN);
            if (lang == 2)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_209_DE);
            if (lang == 3)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_209_FR);
            break;
        case 210:
            if (lang == 1)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_210_EN);
            if (lang == 2)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_210_DE);
            if (lang == 3)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_210_FR);
            break;
        case 211:
            if (lang == 1)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_211_EN);
            if (lang == 2)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_211_DE);
            if (lang == 3)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_211_FR);
            break;
        case 212:
            if (lang == 1)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_212_EN);
            if (lang == 2)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_212_DE);
            if (lang == 3)
                HDAE5000_StrCpy(buf, HDAE5000_LangMsg_212_FR);
            break;
        default:
            HDAE5000_StrCpy(buf, HDAE5000_LangMsg_NoMessage);
        }
        CALLV(ROOT->SendEvent)(obj, EVT_PARA_DRAW, (long)buf);
        return 0;
    }
}
