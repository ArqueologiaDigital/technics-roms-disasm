// Step I1 of the feedback plan (section 13): after Ghidra's auto-analysis of one thc1 / thc2 build, write
//   <out>/functions.tsv   entry, size, name, thunk, library (Function ID match), callers, callees, decompiled lines
//   <out>/decomp/<entry>.c  the decompiler's C for each non-library function
// The output reproduces Toshiba's code, so <out> must be inside the private ~/compartilhado/cc900-oracle/internals/
// (clean-room rule, README section 13).  Run by i1_ghidra.sh as a headless post-script:  -postScript
// ExportFunctions.java <out>
//@category cc900

import ghidra.app.decompiler.DecompInterface;
import ghidra.app.decompiler.DecompileResults;
import ghidra.app.script.GhidraScript;
import ghidra.program.model.listing.Function;
import ghidra.program.model.listing.FunctionIterator;
import ghidra.program.model.symbol.SourceType;

import java.io.File;
import java.io.FileWriter;
import java.io.PrintWriter;

public class ExportFunctions extends GhidraScript {
    @Override
    public void run() throws Exception {
        String[] args = getScriptArgs();
        File out = new File(args[0]);
        File dec = new File(out, "decomp");
        dec.mkdirs();
        DecompInterface di = new DecompInterface();
        di.openProgram(currentProgram);
        try (PrintWriter tsv = new PrintWriter(new FileWriter(new File(out, "functions.tsv")))) {
            tsv.println("entry\tsize\tname\tthunk\tlibrary\tcallers\tcallees\tdecomp_lines");
            FunctionIterator it = currentProgram.getFunctionManager().getFunctions(true);
            while (it.hasNext() && !monitor.isCancelled()) {
                Function f = it.next();
                boolean lib = f.getSymbol().getSource() == SourceType.ANALYSIS
                        && !f.getName().startsWith("FUN_") && !f.getName().startsWith("thunk_");
                int lines = 0;
                if (!lib && !f.isThunk()) {
                    DecompileResults r = di.decompileFunction(f, 120, monitor);
                    if (r != null && r.decompileCompleted()) {
                        String c = r.getDecompiledFunction().getC();
                        lines = c.split("\n").length;
                        try (PrintWriter w = new PrintWriter(new FileWriter(
                                new File(dec, f.getEntryPoint().toString() + ".c")))) {
                            w.print(c);
                        }
                    } else {
                        lines = -1;
                    }
                }
                tsv.printf("%s\t%d\t%s\t%d\t%d\t%d\t%d\t%d%n", f.getEntryPoint(), f.getBody().getNumAddresses(),
                        f.getName(), f.isThunk() ? 1 : 0, lib ? 1 : 0, f.getCallingFunctions(monitor).size(),
                        f.getCalledFunctions(monitor).size(), lines);
            }
        }
        di.dispose();
    }
}
