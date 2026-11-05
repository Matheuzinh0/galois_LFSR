# Autor: Matheus Sousa, Labotatório de Comunicação e Segurança da Informação, DES-CTG, UFPE.

IVERILOG = iverilog
VVP      = vvp
RTL_DIR  = ../rtl
TB_DIR   = ../tb
BUILD_DIR = build

SRCS_RTL = $(wildcard $(RTL_DIR)/*.v)

all: sim_2bit sim_4bit sim_8bit sim_16bit sim_32bit sim_64bit sim_all

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

sim_2bit: $(BUILD_DIR)
	$(IVERILOG) -o $(BUILD_DIR)/sim_2bit.vvp $(RTL_DIR)/galois_lfsr_2bit.v $(TB_DIR)/tb_galois_lfsr_2bit.v
	$(VVP) $(BUILD_DIR)/sim_2bit.vvp

sim_4bit: $(BUILD_DIR)
	$(IVERILOG) -o $(BUILD_DIR)/sim_4bit.vvp $(RTL_DIR)/galois_lfsr_4bit.v $(TB_DIR)/tb_galois_lfsr_4bit.v
	$(VVP) $(BUILD_DIR)/sim_4bit.vvp

sim_8bit: $(BUILD_DIR)
	$(IVERILOG) -o $(BUILD_DIR)/sim_8bit.vvp $(RTL_DIR)/galois_lfsr_8bit.v $(TB_DIR)/tb_galois_lfsr_8bit.v
	$(VVP) $(BUILD_DIR)/sim_8bit.vvp

sim_16bit: $(BUILD_DIR)
	$(IVERILOG) -o $(BUILD_DIR)/sim_16bit.vvp $(RTL_DIR)/galois_lfsr_16bit.v $(TB_DIR)/tb_galois_lfsr_16bit.v
	$(VVP) $(BUILD_DIR)/sim_16bit.vvp

sim_32bit: $(BUILD_DIR)
	$(IVERILOG) -o $(BUILD_DIR)/sim_32bit.vvp $(RTL_DIR)/galois_lfsr_32bit.v $(TB_DIR)/tb_galois_lfsr_32bit.v
	$(VVP) $(BUILD_DIR)/sim_32bit.vvp

sim_64bit: $(BUILD_DIR)
	$(IVERILOG) -o $(BUILD_DIR)/sim_64bit.vvp $(RTL_DIR)/galois_lfsr_64bit.v $(TB_DIR)/tb_galois_lfsr_64bit.v
	$(VVP) $(BUILD_DIR)/sim_64bit.vvp

sim_all: $(BUILD_DIR)
	$(IVERILOG) -o $(BUILD_DIR)/sim_all.vvp $(SRCS_RTL) $(TB_DIR)/tb_galois_lfsr_all.v
	$(VVP) $(BUILD_DIR)/sim_all.vvp

clean:
	rm -rf $(BUILD_DIR) *.vcd

.PHONY: all clean sim_2bit sim_4bit sim_8bit sim_16bit sim_32bit sim_64bit sim_all
