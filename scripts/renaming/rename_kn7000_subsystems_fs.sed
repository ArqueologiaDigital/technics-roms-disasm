# lane open14/kn7000-subsystems: the C file layer and string helpers of program 941 take the names lane
# open14/sibling-names3 gave the same routines in the KN6000 / KN2400 (FsOpen ..., StrCopy ...), so one routine has
# one name across the models; the helpers those lanes did not name follow the same prefix.  Word-bounded, so the
# labels made from them (FsOpen_Var ...) follow.
s/\bVfsFileOpen\b/FsOpen/g
s/\bVfsFileRead\b/FsRead/g
s/\bVfsFileWrite\b/FsWrite/g
s/\bVfsFileSeek\b/FsSeek/g
s/\bVfsFileTell\b/FsTell/g
s/\bVfsFileRewind\b/FsRewind/g
s/\bVfsFileGetc\b/FsGetc/g
s/\bVfsFilePutc\b/FsPutc/g
s/\bVfsFileCloseCore\b/FsCloseCore/g
s/\bVfsFileClose\b/FsClose/g
s/\bVfsRenameIoctl\b/FsRenameIoctl/g
s/\bVfsRename\b/FsRename/g
s/\bVfsRemove\b/FsRemove/g
s/\bVfsMkdir\b/FsMkdir/g
s/\bVfsRmdir\b/FsRmdir/g
s/\bVfsFree\b/FsFree/g
s/\bVfsMalloc\b/FsMalloc/g
s/\bVfsCalloc\b/FsCalloc/g
s/\bVfsFileGetPos\b/FsGetPos/g
s/\bVfsFileSetPos\b/FsSetPos/g
s/\bVfsFileGets\b/FsGets/g
s/\bVfsFilePuts\b/FsPuts/g
s/\bVfsFileFlush\b/FsFlush/g
s/\bVfsFileIoctl\b/FsIoctl/g
s/\bVfsAttribSet\b/FsAttribSet/g
s/\bFmmStrCopy\b/StrCopy/g
s/\bFmmStrCat\b/StrAppend/g
s/\bFmmStrNCopyPad\b/StrCopyPad/g
# the same for three more routines lane sibling-names3 named in the KN2400 / KN6000 (call-site pairs) and the
# INSTALL_SCRATCH cursor family whose KN6000 / KN2400 twins it named
s/\bFmmNameWithExtBuild\b/FileNameWithExt/g
s/\bFatVolumeMount\b/FsMountVolume/g
s/\bScratchCursorReset\b/ScratchPosReset/g
s/\bScratchCursorByteGet\b/ScratchReadByte/g
s/\bScratchCursorByteSet\b/ScratchWriteByte/g
s/\bScratchCursorInc\b/ScratchPosNext/g
s/\bScratchCursorGet\b/ScratchPos/g
s/\bScratchCursorSet\b/ScratchPosSet/g
s/\bScratchCursorAdvance\b/ScratchPosSkip/g
