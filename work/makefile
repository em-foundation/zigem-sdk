DISTRO = ti.cc23xx/ti.distro.cc23xx

host:
	@rm -f .gen/targ.zig
	@touch .gen/targ.zig
	@rm -rf .out/*
	@zig build-exe -I. -femit-bin=.out/host-main.exe .main-host.zig
	@.out/host-main.exe 
	@zig fmt .gen/targ.zig 2>&1 >/dev/null

hal:
	@zig translate-c $(DISTRO)/hal.h > $(DISTRO)/hal.zig

## -----------------

TOOLS=C:/Users/biosb/em-sdk/tools

OBJCOPY=$(TOOLS)/segger-arm/gcc/arm-none-eabi/bin/objcopy.exe
OBJDUMP=$(TOOLS)/segger-arm/gcc/arm-none-eabi/bin/objdump.exe

TARG_OPTS=\
	--name main \
	-fentry=em__start \
	-fno-lto \
	-fsingle-threaded \
	-fno-strip \
	-mcpu cortex_m0plus \
	-target thumb-freestanding-eabi \
	-O ReleaseSmall	\
	-femit-asm=.out/main.asm \
	-femit-bin=.out/main.out \

targ:
	@zig build-exe -I. $(TARG_OPTS) --script .out/linkcmd.ld .out/startup.c .main-targ.zig
	@rm -f .out/main.out.o
	@$(OBJCOPY) -O ihex .out/main.out .out/main.out.hex
	@$(OBJDUMP) -h -d .out/main.out >.out/main.out.dis
	@$(OBJDUMP) -t .out/main.out | tail -n +5 | sed -e 's/[FO] /  /' | sed -e 's/df /   /' >.out/main.out.sym
	@sort -k1 .out/main.out.sym > .out/main.out.syma
	@sort -k5 .out/main.out.sym > .out/main.out.symn
	@$(OBJDUMP) -h .out/main.out

load:
	@$(TOOLS)/ti-uniflash/dslite.bat -c ti.cc23xx/ti.distro.cc23xx/CC2340R5.ccxml .out/main.out

