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
        pub const em__U = em.module(@This(), .{ .generated = true, .name = name, .inherits = SchemaI });
        pub const em__C = em__U.config(EM__CONFIG);

        pub const Resource = em.import.@"em.radio.core/Resource";
        pub const SchemaI = em.import.@"em.radio.core/SchemaI";

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

            const DispKind = enum { FETCH, STORE };
            var app_upath: []const u8 = undefined;

            pub fn em__generateM() void {
                var sb = em.StringM{};
                sb.addM("           struct {\n");
                sb.fmtM("               const App = em.import.@\"{s}\";\n", .{app_upath});
                genDispatch(&sb, .FETCH);
                genDispatch(&sb, .STORE);
                sb.addM("           }");
                em__C.Aux.defineM(sb.getM());
            }

            pub fn bindAppUpathM(upath: []const u8) void {
                app_upath = upath;
            }

            fn genDispatch(sb: *em.StringM, kind: DispKind) void {
                const fs = @tagName(kind);
                sb.fmtM("               pub fn {s}(resid: i8, vptr: *align(4) void) void {{\n", .{fs});
                sb.addM("                   switch (resid) {\n");
                var suf: []const u8 = "vptr";
                for (res_info_list) |ri| {
                    if (!testAcc(ri.acc, kind)) continue;
                    suf = "0";
                    sb.fmtM("                   {d} => App.{s}_{s}(@ptrCast(vptr)),", .{ ri.id, ri.name, fs });
                }
                sb.fmtM("                       else => _ = {s}", .{suf});
                sb.addM("                   }");
                sb.addM("               }");
            }

            fn testAcc(acc: Resource.Access, kind: DispKind) bool {
                return switch (kind) {
                    .FETCH => acc == .RW or acc == .RO,
                    .STORE => acc == .RW or acc == .WO,
                };
            }
        };

        pub const EM__TARG = struct {
            //
            pub fn fetch(resid: i8, optr: *align(4) void) void {
                if (em.IS_META) return;
                em__C.Aux.unwrap().FETCH(resid, optr);
            }
            pub fn store(resid: i8, iptr: *align(4) void) void {
                if (em.IS_META) return;
                em__C.Aux.unwrap().STORE(resid, iptr);
            }
        };

        
        //->> zigem publish #|75288f48d1bd7497a4b318b1082ce19b133967af0ad0ce88631c3eef59395ada|#

        //->> EM__META publics
        pub const bindAppUpathM = EM__META.bindAppUpathM;

        //->> EM__TARG publics
        pub const fetch = EM__TARG.fetch;
        pub const store = EM__TARG.store;

        //->> zigem publish -- end of generated code
    };
}
