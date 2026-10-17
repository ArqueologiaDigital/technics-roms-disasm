# The main CPU's "screen group" routine is the task scheduler's spawn (2026-10-17): it fills TCB 0x47D + 12*A from
# the task table, marks it ready (+9 := 4), links it into queue 0x4C1 + 4*priority and enters TaskSched_Dispatch.
# Its sub-CPU twin (v142) is TaskSched_SpawnTask (aligned run 63 B at +32, technics-docs cpu-subsystem.md).
s/\bShow_ScreenGroup\b/TaskSched_SpawnTask/g
s/\bTaskSched_ScreenGroupTable\b/TaskSched_TaskTable/g
s/\bScreenGroup3_IdleSpin\b/TaskSched_IdleTask/g
s/\bSndTable_LookupD_ShowScreen\b/SndTable_LookupD_SpawnReaderTask/g
