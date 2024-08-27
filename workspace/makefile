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

TOOLS=../zig-out/tools

ifeq ($(OS),windows)
    BIN_SUF=".exe"
    SCRIPT_SUF=".bat"
else
    BIN_SUF=""
    SCRIPT_SUF=".sh"
endif

ifeq ($(OS),macos)
    SHA256=shasum -a 256
else
    SHA256=sha256sum
endif

OBJCOPY?=$(TOOLS)/arm-binutils/objcopy$(BIN_SUF)
OBJDUMP?=$(TOOLS)/arm-binutils/objdump$(BIN_SUF)

UNIFLASH?=$(TOOLS)/ti-uniflash/dslite$(SCRIPT_SUF)

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
	@$(SHA256) .out/main.out.hex | cut -c -8 >.out/main.out.sha32
	@$(OBJDUMP) -h .out/main.out

load:
	@$(UNIFLASH) --mode noConnectFlash -c ti.cc23xx/ti.distro.cc23xx/CC2340R5.ccxml .out/main.out

