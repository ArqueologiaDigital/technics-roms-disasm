-- arena_verify.lua -- verifier for lane "hmp" (independent of the tracer's arena_tap.lua).
-- Question: at runtime, which address does alloc 0x4853411C return right after the arena reset
-- 0x485340BE, and who else touches the arena during boot? Caller addresses come from MDR (AM33
-- caches the return address of every call in MDR), not from (SP).
-- Run (cwd /home/fsanches/compartilhado/kn7000_mame_build; fresh empty nvram dir = blank custom flash):
--   ./kn7000 kn7000 -rompath roms -video none -sound none -nothrottle -debug -debugger none \
--     -seconds_to_run 20 -nvram_directory <scratch>/mame_run/nvram -cfg_directory <scratch>/mame_run/cfg \
--     -autoboot_delay 0 -autoboot_script <scratch>/arena_verify.lua
-- Signal: "ALLOC_OUT a0=503BB810" after "RESET ret=48496FD0" and "ALLOC_IN d0=42B6 ret=48496FDA".
local OUT = "/home/fsanches/compartilhado/tmp/kn7000-ramq/hmp-verify/mame_run/arena_verify.log"
local logf = io.open(OUT, "w")
local function LOG(s) if logf then logf:write(s .. "\n"); logf:flush() end end
local mach = manager.machine
local cpu = mach.devices[":maincpu"]
local mem = cpu.spaces["program"]
local dbg = mach.debugger
if not cpu.debug then LOG("!! no debugger: run with -debug -debugger none"); return end
cpu.debug:bpset(0x485340BE, "1", 'printf "RESET ret=%08X",mdr; g')
cpu.debug:bpset(0x485340B4, "1", 'printf "ZAP0 ret=%08X",mdr; g')
cpu.debug:bpset(0x4853411C, "1", 'printf "ALLOC_IN d0=%X ret=%08X",d0,mdr; g')
cpu.debug:bpset(0x4853418B, "1", 'printf "ALLOC_OUT a0=%08X d2=%X",a0,d2; g')
cpu.debug:bpset(0x4853419F, "1", 'printf "FREE a0=%08X ret=%08X",a0,mdr; g')
cpu.debug:bpset(0x4847F9F7, "1", 'printf "FLASHPROG dst=%08X src=%08X len=%X ret=%08X",a0,a1,d0,mdr; g')
dbg.execution_state = "run"
local done = false
local function hdr(a)
  return string.format("%08X: size=%08X magic=%02X used=%02X next=%08X prev=%08X", a,
    mem:read_u32(a), mem:read_u8(a + 4), mem:read_u8(a + 5), mem:read_u32(a + 8), mem:read_u32(a + 12))
end
keep = emu.add_machine_frame_notifier(function()
  if done or mach.time.seconds < 16 then return end
  done = true
  for _, l in ipairs(dbg.consolelog) do LOG("CON " .. l) end
  LOG("sentinel " .. hdr(0x501605F8))
  LOG("arena0   " .. hdr(0x503BB800))
  LOG(string.format("0x5006B798=%08X 0x500022F4=%08X flash[0x96811000]=%08X flash[0x9681118C]=%04X",
    mem:read_u32(0x5006B798), mem:read_u32(0x500022F4), mem:read_u32(0x96811000), mem:read_u16(0x9681118C)))
  if logf then logf:close(); logf = nil end
end)
