const std = @import("std");

pub fn REG(adr: u32) *volatile u32 {
    const reg: *volatile u32 = @ptrFromInt(adr);
    return reg;
}

pub fn halt() void {
    var dummy: u32 = 0xCAFE;
    const vp: *volatile u32 = &dummy;
    while (vp.* != 0) {}
}

pub fn Config(comptime T: type) type {
    return struct {
        val: T,
        pub fn get(this: *@This()) T {
            return this.val;
        }
        pub fn set(comptime this: *@This(), comptime val: T) void {
            comptime {
                this.val = val;
            }
        }
    };
}

pub const String = []const u8;

pub const Spec = struct {
    upath: String,
    uses: []const Import,
};

pub const Import = struct {
    from: type,
    as: String,
};
