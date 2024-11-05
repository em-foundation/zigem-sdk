pub const em = @import("../../zigem/em.zig");
pub const em__T = em.template(@This(), .{});
pub const EM__CONFIG = struct {
    em__upath: []const u8,
    appUpath: em.Param([]const u8),
    Aux: em.Capsule(),
};

pub const Params = struct {
    ResT: type,
};

pub fn em__generateS(comptime name: []const u8, comptime params: Params) type {
    return struct {
        //
        pub const em__U = em.module(@This(), .{ .generated = true, .name = name });
        pub const em__C = em__U.config(EM__CONFIG);

        pub const ResName = em.std.meta.FieldEnum(RT);

        const AU = params.AppU;
        const RT = params.ResT;

        pub fn resCount() usize {
            const ti = @typeInfo(RT);
            return ti.Union.fields.len;
        }

        pub fn ResType(comptime rn: ResName) type {
            const FieldType = em.std.meta.FieldType;
            return FieldType(FieldType(RT, rn), .valp);
        }

        pub fn resFetch(rn: ResName) void {
            const tags = em.std.meta.tags(ResName);
            const idx = @intFromEnum(rn);
            em.print("rn = {s}\n", .{@tagName(tags[idx])});
        }

        var buf: [16]u32 = undefined;

        pub const EM__META = struct {
            //
            pub const c_appUpath = em__C.appUpath;

            pub fn em__constructM() void {
                const tags = em.std.meta.tags(ResName);
                var sbuf = em.StringM{};
                sbuf.addM("     struct {\n");
                sbuf.addM("         //\n");
                // sbuf.addM("         const App = em.import.@\"");
                sbuf.addM("         pub fn fetch(resid: i8, src: *u32) void {");
                sbuf.addM("             switch (resid) {");
                for (tags, 0..) |tag, idx| {
                    _ = tag;
                    _ = idx;
                }
                sbuf.addM("                 else => _ = src");
                sbuf.addM("             }");
                sbuf.addM("         }");
                sbuf.addM("     }");
                em__C.Aux.defineM(sbuf.getM());
            }
        };

        pub const EM__TARG = struct {
            //
        };

        
        //->> zigem publish #|d5a31c03255be9922c942e37e7ca7b4007d6afa71235c6b3e83d898df5abd599|#

        //->> EM__META publics
        pub const c_appUpath = EM__META.c_appUpath;

        //->> EM__TARG publics

        //->> zigem publish -- end of generated code
    };
}
