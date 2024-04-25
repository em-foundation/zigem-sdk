host:
	@rm -f .gen/targ.zig
	@touch .gen/targ.zig
	@rm -rf .out/*
	@zig build-exe -femit-bin=.out/host-main.exe .main-host.zig
	@.out/host-main.exe

## -----------------

TOOLS=C:/Users/biosb/em-sdk/tools

OBJCOPY=$(TOOLS)/segger-arm/gcc/arm-none-eabi/bin/objcopy.exe
OBJDUMP=$(TOOLS)/segger-arm/gcc/arm-none-eabi/bin/objdump.exe

TARG_OPTS=\
	--name main \
	-fentry=em__start \
	-fno-lto \
	-fno-strip \
	-mcpu cortex_m0plus \
	-target thumb-freestanding-eabi \
	-O ReleaseSmall	\
	-femit-asm=.out/main.asm \
	-femit-bin=.out/main.out \

targ:
	@zig build-exe $(TARG_OPTS) --script .out/linkcmd.ld .out/startup.c .main-targ.zig
	@rm -f .out/main.out.o
	@$(OBJDUMP) -h -d  .out/main.out >.out/main.out.dis
#	@$(OBJDUMP) -h .out/main.out

load:
	@$(TOOLS)/ti-uniflash/dslite.bat -c ti.cc23xx.A/ti.distro.cc23xx/CC2340R5.ccxml .out/main.out

