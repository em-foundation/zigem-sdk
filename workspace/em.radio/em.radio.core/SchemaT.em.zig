pub const em = @import("../../zigem/em.zig");
pub const em__T = em.template(@This(), .{});
pub const EM__CONFIG = struct {
    em__upath: []const u8,
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
            const tags = em.std.meta.tags(ResName);
            var app_upath: []const u8 = undefined;

            pub fn em__constructM() void {
                var sb = em.StringM{};
                sb.addM("           struct {\n");
                sb.addM("               //\n");
                sb.fmtM("               const App = em.import.@\"{s}\";\n", .{app_upath});
                sb.addM("               pub fn fetch(resid: i8, src: *u32) void {\n");
                sb.addM("                   switch (resid) {\n");
                inline for (tags, 0..) |tag, idx| {
                    // const rname = @tagName(tag);
                    // const rdesc = @typeName(em.std.meta.FieldType(RT, tag));
                    //em.print("name = {s}, type = {s}\n", .{ rname, rdesc });
                    _ = tag;
                    _ = idx;
                }
                sb.addM("                       else => _ = src");
                sb.addM("                   }");
                sb.addM("               }");
                sb.addM("           }");
                em__C.Aux.defineM(sb.getM());
            }

            pub fn bindAppUpathM(upath: []const u8) void {
                app_upath = upath;
            }
        };

        pub const EM__TARG = struct {
            //
        };

        
        //->> zigem publish #|c8f6ef647fe244c2d71a3c61f796a2e362cad88ad6f633a54c29b837c8a688cf|#

        //->> EM__META publics
        pub const bindAppUpathM = EM__META.bindAppUpathM;

        //->> EM__TARG publics

        //->> zigem publish -- end of generated code
    };
}
