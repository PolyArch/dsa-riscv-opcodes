SHELL := /bin/sh

ISASIM_H := ../riscv-isa-sim/riscv/encoding.h
ISASIM_HWACHA_H := ../riscv-isa-sim/hwacha/opcodes_hwacha_ut.h
ISASIM_SOFTBRAIN_H := ../riscv-isa-sim/softbrain/opcodes_sb.h
ISASIM_SOFTBRAIN_E := ../riscv-isa-sim/softbrain/encodings_sb.h


PK_H := ../riscv-pk/pk/encoding.h
FESVR_H := ../riscv-fesvr/fesvr/encoding.h
ENV_H := ../riscv-tests/env/encoding.h
GAS_H := ../riscv-gnu-toolchain/binutils/include/opcode/riscv-opc.h

ALL_OPCODES := opcodes-pseudo opcodes opcodes-rvc opcodes-rvc-pseudo opcodes-hwacha-pseudo opcodes-hwacha opcodes-hwacha-ut opcodes-custom opcodes-sb

SB_OPCODES := opcodes-pseudo opcodes opcodes-rvc opcodes-rvc-pseudo opcodes-custom opcodes-sb

install: $(ISASIM_H) $(PK_H) $(FESVR_H) $(ENV_H) $(GAS_H) $(ISASIM_SOFTBRAIN_H) $(ISASIM_SOFTBRAIN_E) inst.chisel instr-table.tex priv-instr-table.tex

$(ISASIM_H) $(PK_H) $(FESVR_H) $(ENV_H): $(ALL_OPCODES) parse-opcodes encoding.h
	cp encoding.h $@
	cat opcodes opcodes-rvc-pseudo opcodes-rvc | ./parse-opcodes -c >> $@

$(ISASIM_SOFTBRAIN_H): $(ALL_OPCODES) parse-opcodes
	cat opcodes-sb | ./parse-opcodes -c | \
	cpp -P -D DECLARE_INSN=DECLARE_INSN > $@

$(ISASIM_SOFTBRAIN_E): $(ALL_OPCODES) parse-opcodes
	echo "#ifndef ENCODINGS_SB" > $@
	echo "#define ENCODINGS_SB" >> $@
	cat opcodes-sb | ./parse-opcodes -c | \
	grep "#define M" >> $@
	echo "#endif //ENCODINGS_SB" >> $@



$(GAS_H) $(XCC_H): $(ALL_OPCODES) parse-opcodes
	cat $(SB_OPCODES) | ./parse-opcodes -c > $@

$(ISASIM_HWACHA_H): $(ALL_OPCODES) parse-opcodes
	cat opcodes opcodes-hwacha-ut | ./parse-opcodes -c | \
	sed 's/DECLARE_INSN(/DECLARE_INSN(ut_/g' | \
	cpp -P -D DECLARE_INSN=DECLARE_INSN | sort -o $@

inst.chisel: $(ALL_OPCODES) parse-opcodes
	cat opcodes opcodes-custom opcodes-pseudo opcodes-sb | ./parse-opcodes -chisel > $@

instr-table.tex: $(ALL_OPCODES) parse-opcodes
	cat opcodes opcodes-pseudo | ./parse-opcodes -tex > $@

priv-instr-table.tex: $(ALL_OPCODES) parse-opcodes
	cat opcodes opcodes-pseudo | ./parse-opcodes -privtex > $@

.PHONY : install
