TOOLS=C:/Users/biosb/em-sdk/tools

OBJCOPY=$(TOOLS)/segger-arm/gcc/arm-none-eabi/bin/objcopy.exe
OBJDUMP=$(TOOLS)/segger-arm/gcc/arm-none-eabi/bin/objdump.exe

ODIR=zig-out

ZIGOPTS=\
	--name main \
	-fno-lto \
	-mcpu cortex_m0plus \
	-target thumb-freestanding-eabi \
	-O ReleaseSmall	\

ZIGEXE=\
	-fentry=__em_program_start \
	-femit-asm=zig-out/main.asm \
	-femit-bin=zig-out/main.out \
	-femit-llvm-ir=zig-out/main.ir \
	-fno-strip \
	--script etc/linkcmd.ld \

ZIGOBJ=\
	-femit-asm=zig-out/main.asm \
	-femit-bin=zig-out/main \
	-femit-h=zig-out/main.h

build:
	@rm -rf zig-out
	@zig build --summary all
	@$(OBJCOPY) -O ihex $(ODIR)/bin/main.out $(ODIR)/bin/main.out.hex
	@$(OBJDUMP) -h -d  $(ODIR)/bin/main.out >$(ODIR)/bin/main.out.dis

exe:
	@rm -rf zig-out
	@mkdir zig-out
	@zig build-exe $(ZIGOPTS) $(ZIGEXE) etc/startup.c --dep em -Mmain=src/main.zig -Mem=src/em.zig
	@$(OBJCOPY) -O ihex $(ODIR)/main.out $(ODIR)/main.out.hex
	@$(OBJDUMP) -h -d  $(ODIR)/main.out >$(ODIR)/main.out.dis

obj:
	@rm -rf zig-out
	@mkdir zig-out
	@zig build-obj $(ZIGOPTS) $(ZIGOBJ)

gen:
	rm -f src/hal/*.zig
	cd src/hal; for f in *.h; do zig translate-c -target thumb-freestanding-eabi $${f} > $${f%.h}.zig; done; cd ../..

load:
	$(TOOLS)/ti-uniflash/dslite.bat -c etc/CC2340R5.ccxml $(ODIR)/main.out

run: exe load

clean:
	rm -rf ../zig-cache
	rm -rf zig-out

