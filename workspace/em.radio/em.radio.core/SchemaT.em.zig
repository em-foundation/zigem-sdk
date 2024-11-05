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

        pub const Resource = em.import.@"em.radio.core/Resource";

        pub const ResName = em.std.meta.FieldEnum(RT);

        const RT = params.ResT;

        const ResInfo = struct {
            id: i8,
            name: []const u8,
            typestr: []const u8,
            acc: Resource.Access,
        };

        const res_info_list = blk: {
            var rl: []const ResInfo = &.{};
            var id: i8 = 0;
            for (em.std.meta.tags(ResName)) |tag| {
                id += 1;
                const ts1 = @typeName(em.std.meta.FieldType(RT, tag));
                const l = ts1.len;
                const acc = em.std.meta.stringToEnum(Resource.Access, ts1[l - 3 .. l - 1]).?;
                const ts2 = ts1[em.std.mem.indexOf(u8, ts1, "(").? + 1 ..];
                const ts3 = ts2[0..em.std.mem.indexOf(u8, ts2, ",").?];
                rl = rl ++ .{ResInfo{ .id = id, .name = @tagName(tag), .acc = acc, .typestr = em.typestr(ts3) }};
            }
            break :blk rl;
        };

        pub fn resCount() usize {
            const ti = @typeInfo(RT);
            return ti.Union.fields.len;
        }

        pub fn ResType(comptime rn: ResName) type {
            const FT = em.std.meta.FieldType(RT, rn);
            return FT._T;
        }

        pub fn resFetch(rn: ResName) void {
            const tags = em.std.meta.tags(ResName);
            const idx = @intFromEnum(rn);
            em.print("rn = {s}\n", .{@tagName(tags[idx])});
        }

        pub const EM__META = struct {
            //
            var app_upath: []const u8 = undefined;

            pub fn em__constructM() void {
                // em.print("res_list = {any}\n", .{res_list});
                var sb = em.StringM{};
                sb.addM("           struct {\n");
                sb.addM("               //\n");
                sb.fmtM("               const App = em.import.@\"{s}\";\n", .{app_upath});
                sb.addM("               pub fn fetch(resid: i8, optr: *align(4) void) void {\n");
                sb.addM("                   switch (resid) {\n");
                var suf: []const u8 = "optr";
                for (res_info_list) |ri| {
                    if (ri.acc != .RO and ri.acc != .RW) continue;
                    suf = "0";
                    sb.fmtM("                   {d} => App.{s}_FETCH(@ptrCast(optr)),", .{ ri.id, ri.name });
                }
                sb.fmtM("                       else => _ = {s}", .{suf});
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
            const Aux = em__C.Aux.unwrap();
            pub fn fetch(resid: i8, optr: *align(4) void) void {
                Aux.fetch(resid, optr);
            }
        };

        
        //->> zigem publish #|ecc15efa682b31c9f65941b61f047192568f0f15f04988db8f5c8a9c2da48baa|#

        //->> EM__META publics
        pub const bindAppUpathM = EM__META.bindAppUpathM;

        //->> EM__TARG publics
        pub const fetch = EM__TARG.fetch;

        //->> zigem publish -- end of generated code
    };
}
