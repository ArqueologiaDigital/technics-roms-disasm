# RectX2Proc's internal labels were TabDraw_TopEdge* / TabDraw_BottomEdge*, borrowed from unrelated code
# (open item N-830904fd).  They take the names of the same cases of its sibling RectY2Proc: the property
# events it dispatches on (EVT_SET_PROPERTY_EX, EVT_GET_PROPERTY_EX, EVT_DUMP_PROPERTY_EX, EVT_GET_PROP_MEMBER,
# EVT_CHECK_PROP_STRING) and its ".width" member name.
s/\bTabDraw_TopEdge_Str_width\b/RectX2Proc_MemberName/g
s/\bTabDraw_TopEdge_Inner\b/RectX2Proc_OnDumpPropertyEx/g
s/\bTabDraw_TopEdge_CalcWidth\b/RectX2Proc_ForwardToCommon/g
s/\bTabDraw_TopEdge_CalcHeight\b/RectX2Proc_OnGetPropertyEx/g
s/\bTabDraw_TopEdge_Execute\b/RectX2Proc_ReturnZero/g
s/\bTabDraw_TopEdge_Done\b/RectX2Proc_OnSetPropertyEx/g
s/\bTabDraw_TopEdge\b/RectX2Proc_OnGetPropMember/g
s/\bTabDraw_BottomEdge_Prologue\b/RectX2Proc_Epilogue/g
s/\bTabDraw_BottomEdge\b/RectX2Proc_ReturnResult/g
