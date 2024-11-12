const std = @import("std");

const Fs = @import("Fs.zig");
const Heap = @import("Heap.zig");
const Out = @import("Out.zig");
const Renderer = @import("Renderer.zig");

var zigem_exe: []const u8 = &.{};

fn delay(dt: u32) void {
    var dummy: u32 = 0;
    const dp: *volatile u32 = &dummy;
    for (0..dt) |_| {
        dp.* = 0;
    }
}

pub fn generate(ppath: []const u8, outdir: []const u8) !void {
    const pname = Fs.basename(ppath);
    const poutdir = Fs.join(&.{ outdir, pname });
    if (Fs.exists(poutdir)) Fs.delete(poutdir);
    Fs.mkdirs(outdir, pname);
    var file = try Out.open(Fs.join(&.{ poutdir, "index.md" }));
    file.print(
        \\<script>document.querySelector('body').classList.add('em-content')</script>
        \\# {{[ze,kr]package}}&thinsp;{{[fn]{s}}}
        \\
    , .{pname});
    file.close();
    const oname = Fs.basename(outdir);
    var sb = Out.StringBuf{};
    sb.fmt(
        \\    - {0s}:
        \\      - {1s}/{0s}/index.md
        \\
    , .{ pname, oname });
    var pdir_iter = Fs.openDir(ppath).iterate();
    while (try pdir_iter.next()) |ent1| {
        if (ent1.kind != .directory or ent1.name[0] == '.') continue;
        const bname = ent1.name;
        const boutdir = Fs.join(&.{ poutdir, bname });
        Fs.mkdirs(poutdir, bname);
        file = try Out.open(Fs.join(&.{ boutdir, "index.md" }));
        file.print(
            \\<script>document.querySelector('body').classList.add('em-content')</script>
            \\# {{[ze,kr]bucket}}&thinsp;{{[fn]{s}}}
            \\
        , .{bname});
        file.close();
        sb.fmt(
            \\      - {0s}:
            \\        - {1s}/{2s}/{0s}/index.md
            \\
        , .{ bname, oname, pname });
        var bdir_iter = Fs.openDir(Fs.join(&.{ ppath, bname })).iterate();
        while (try bdir_iter.next()) |ent2| {
            const suf = ".em.zig";
            if (ent2.kind != .file or !std.mem.endsWith(u8, ent2.name, suf)) continue;
            const uname = ent2.name[0 .. ent2.name.len - suf.len];
            std.log.debug("unit {s}/{s}", .{ bname, uname });
            delay(1_000_000_000);
            const src = try Renderer.exec(Fs.slashify(Fs.join(&.{ ppath, bname, ent2.name })), false);
            file = try Out.open(Fs.join(&.{ boutdir, Out.sprint("{s}.md", .{uname}) }));
            file.print(
                \\<script>document.querySelector('body').classList.add('em-content')</script>
                \\# {{[ze,kr]unit}}&thinsp;{{[ze,kt]{1s}}}
                \\```zigem linenums="1" title="{0s}/{1s}.em.zig"
                \\{2s}
                \\```
                \\
            , .{ bname, uname, src });
            file.close();
            sb.fmt(
                \\        - {0s}: {1s}/{2s}/{3s}/{0s}.md
                \\
            , .{ uname, oname, pname, bname });
        }
    }
    const yfile = Fs.join(&.{ outdir, "../../mkdocs.yml" });
    const ytext = Fs.readFile(yfile);
    var split_iter = std.mem.split(u8, ytext, "\n#==<");
    file = try Out.open(yfile);
    file.print("{s}", .{split_iter.first()});
    var found = false;
    while (split_iter.next()) |nxt| {
        const key = Out.sprint("{s}>\n", .{pname});
        if (std.mem.startsWith(u8, nxt, key)) {
            found = true;
            file.print("\n#==<{s}{s}", .{ key, sb.get() });
        } else if (nxt[0] == '>') {
            if (!found) file.print("\n#==<{s}{s}", .{ key, sb.get() });
            file.print("#==<>\n", .{});
        } else {
            file.print("\n#==<{s}", .{nxt});
        }
    }
    file.close();
}

fn render(path: []const u8) ![]const u8 {
    if (zigem_exe.len == 0) zigem_exe = try std.process.getEnvVarOwned(Heap.get(), "ZIGEM");
    const argv = [_][]const u8{ zigem_exe, "render", "-f", path };
    const proc = try std.process.Child.run(.{
        .allocator = Heap.get(),
        .argv = &argv,
    });
    if (proc.stderr.len > 0) {
        try std.io.getStdErr().writeAll(proc.stderr);
    }
    if (proc.term.Exited != 0) {
        std.process.exit(1);
    }
    return proc.stdout;
}
