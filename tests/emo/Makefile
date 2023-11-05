.PHONY: clean

include ../../mk/toolchain.mk

ASFLAGS = -march=rv32i -mabi=ilp32
LDFLAGS = --oformat=elf32-littleriscv

%.o: %.s
	$(CROSS_COMPILE)as -R $(ASFLAGS) -o $@ $<

all: HammingDistance.elf

HammingDistance.elf: HammingDistance.o
	$(CROSS_COMPILE)ld -o $@ -T HammingDistance.ld $(LDFLAGS) $<
	
O0: 
	$(CROSS_COMPILE)gcc $(ASFLAGS) -O0 HammingDistance.c -o HammingDistance_O0.elf
	$(CROSS_COMPILE)objdump -d HammingDistance_O0.elf > HammingDistance_O0.txt
O1:
	$(CROSS_COMPILE)gcc $(ASFLAGS) -O1 HammingDistance.c -o HammingDistance_O1.elf
	$(CROSS_COMPILE)objdump -d HammingDistance_O1.elf > HammingDistance_O1.txt
O2:
	$(CROSS_COMPILE)gcc $(ASFLAGS) -O2 HammingDistance.c -o HammingDistance_O2.elf
	$(CROSS_COMPILE)objdump -d HammingDistance_O2.elf > HammingDistance_O2.txt
O3:
	$(CROSS_COMPILE)gcc $(ASFLAGS) -O3 HammingDistance.c -o HammingDistance_O3.elf
	$(CROSS_COMPILE)objdump -d HammingDistance_O3.elf > HammingDistance_O3.txt
Os:
	$(CROSS_COMPILE)gcc $(ASFLAGS) -Os HammingDistance.c -o HammingDistance_Os.elf
	$(CROSS_COMPILE)objdump -d HammingDistance_Os.elf > HammingDistance_Os.txt
Ofast:
	$(CROSS_COMPILE)gcc $(ASFLAGS) -Ofast HammingDistance.c -o HammingDistance_Ofast.elf
	$(CROSS_COMPILE)objdump -d HammingDistance_Ofast.elf > HammingDistance_Ofast.txt
clean:
	$(RM) HammingDistance.elf HammingDistance.o HammingDistance_O0.elf *.txt

