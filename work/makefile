all:
	@rm -rf zig-out
	@mkdir zig-out
	@zig build-exe -femit-bin=zig-out/meta-main.exe meta-main.zig
	@zig-out/meta-main.exe

## -----------------

TOOLS=C:/Users/biosb/em-sdk/tools

OBJCOPY=$(TOOLS)/segger-arm/gcc/arm-none-eabi/bin/objcopy.exe
OBJDUMP=$(TOOLS)/segger-arm/gcc/arm-none-eabi/bin/objdump.exe

ODIR=zig-out

TARG_OPTS=\
	--name main \
	-fentry=em__start \
	-fno-lto \
	-mcpu cortex_m0plus \
	-target thumb-freestanding-eabi \
	-O ReleaseSmall	\
	-femit-asm=$(ODIR)/main.asm \
	-femit-bin=$(ODIR)/main.out \

targ:
	@rm -rf zig-out
	@mkdir zig-out
	@zig build-exe $(TARG_OPTS) targ-main.zig
	@rm -f $(ODIR)/main.out.o
#	@$(OBJDUMP) -h -d  $(ODIR)/main.out >$(ODIR)/main.out.dis
	@size $(ODIR)/main.out
