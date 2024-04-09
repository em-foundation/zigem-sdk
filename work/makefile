all:
	@rm -rf zig-out
	@mkdir zig-out
	@zig build-exe -femit-bin=zig-out/meta-main.exe meta-main.zig
	@zig-out/meta-main.exe