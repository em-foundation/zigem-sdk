const std = @import("std");

const Fs = @import("Fs.zig");
const Heap = @import("Heap.zig");
const Out = @import("Out.zig");

pub fn generate(ppath: []const u8, outdir: []const u8) !void {
    const pname = Fs.basename(ppath);
    const poutdir = Fs.join(&.{ outdir, pname });
    if (Fs.exists(poutdir)) Fs.delete(poutdir);
    Fs.mkdirs(outdir, pname);
    var file = try Out.open(Fs.join(&.{ poutdir, "index.md" }));
    file.print(
        \\<script>document.querySelector('body').classList.add('em-content')</script>
        \\# package `{s}`
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
    var dir_iter = Fs.openDir(ppath).iterate();
    while (try dir_iter.next()) |ent| {
        if (ent.kind != .directory or ent.name[0] == '.') continue;
        const bname = ent.name;
        const boutdir = Fs.join(&.{ poutdir, bname });
        Fs.mkdirs(poutdir, bname);
        file = try Out.open(Fs.join(&.{ boutdir, "index.md" }));
        file.print(
            \\<script>document.querySelector('body').classList.add('em-content')</script>
            \\# bucket `{s}`
            \\
        , .{bname});
        file.close();
        sb.fmt(
            \\      - {0s}:
            \\        - {1s}/{2s}/{0s}/index.md
            \\
        , .{ bname, oname, pname });
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

// #-- em.bench
//     - em.bench:
//       - cargo/em.bench/index.md
//       - em.coremark:
//         - cargo/em.bench/em.coremark/index.md

//     var file = try Out.open(Fs.join(&.{ gen_root, "imports.zig" }));
//     const pre =
//         \\const em = @import("./em.zig");
//         \\
//         \\
//     ;
//     file.print(pre, .{});
//     for (Props.getPackages().items) |pkgpath| {
//         var iter = Fs.openDir(pkgpath).iterate();
//         const pkgname = Fs.basename(pkgpath);
//         while (try iter.next()) |ent| {
//             if (ent.kind != .directory) continue;
//             const buckname = ent.name;
//             const is_distro = std.mem.eql(u8, buckname, distro_buck);
//             if (buck_set.contains(buckname)) continue;
//             try buck_set.put(buckname, {});
//             var iter2 = Fs.openDir(Fs.join(&.{ pkgpath, ent.name })).iterate();
//             while (try iter2.next()) |ent2| {
//                 if (ent2.kind != .file) continue;
//                 const idx = std.mem.indexOf(u8, ent2.name, ".em.zig");
//                 if (idx == null) continue;
//                 file.print("pub const @\"{0s}/{1s}\" = @import(\"../{2s}/{0s}/{3s}\");\n", .{ buckname, ent2.name[0..idx.?], pkgname, ent2.name });
//                 const tn = Out.sprint("{s}.{s}.{s}.em", .{ pkgname, buckname, ent2.name[0..idx.?] });
//                 const un = Out.sprint("{s}/{s}", .{ buckname, ent2.name[0..idx.?] });
//                 try type_map.put(tn, un);
//                 if (!is_distro) continue;
//                 file.print("pub const @\"em__distro/{1s}\" = @import(\"../{2s}/{0s}/{3s}\");\n", .{ buckname, ent2.name[0..idx.?], pkgname, ent2.name });
//             }
//         }
//     }
//     file.close();

// export function generate(bpath: string, cargoRoot: string) {
//     let bname = Path.basename(bpath)
//     let dstdir = Path.resolve(cargoRoot, bname)
//     if (Fs.existsSync(dstdir)) Fs.rmSync(dstdir, {recursive: true})
//     Fs.mkdirSync(dstdir)
//     let blines = Array<String>()
//     blines.push("<script>document.querySelector('body').classList.add('em-content')</script>")
//     blines.push(`# bundle ${bname}`)
//     Fs.writeFileSync(Path.join(dstdir, 'index.md'), blines.join('\n'))
//     Out.clearText()
//     Out.print("    - %1:\n", bname)
//     Out.print("      - cargo/%1/index.md\n", bname)
//     for (let pn of Fs.readdirSync(bpath)) {
//         let pdir = Path.join(bpath, pn)
//         if (!Fs.lstatSync(pdir).isDirectory()) continue
//         let first = true
//         for (let uf of Fs.readdirSync(pdir)) {
//             if (Path.parse(uf).ext != '.em') continue
//             if (first) {
//                 Fs.mkdirSync(Path.join(dstdir, pn))
//                 let plines = Array<String>()
//                 plines.push("<script>document.querySelector('body').classList.add('em-content')</script>")
//                 plines.push(`# package ${pn}`)
//                 Fs.writeFileSync(Path.join(dstdir, pn, 'index.md'), plines.join('\n'))
//                 Out.print("      - %1:\n", pn)
//                 Out.print("        - cargo/%1/%2/index.md\n", bname, pn)
//                 first = false;
//             }
//             let un = Path.parse(uf).name
//             let ulines = Array<String>()
//             ulines.push("<script>document.querySelector('body').classList.add('em-content')</script>")
//             ulines.push(`# unit ${un}`)
//             let fence = '```'
//             let upath = `${pn}/${un}`
//             ulines.push(`${fence}em linenums="1" title="${upath}.em"`)
//             let spath = Path.join(pdir, uf)
//             let text = Fs.readFileSync(spath, 'utf-8')
//             let unit = SymTab.units().get(upath) || Session.parseUnit(text, spath, upath)!
//             ulines.push(annotate(text, unit))
//             ulines.push(fence)
//             Fs.writeFileSync(Path.join(dstdir, pn, `${un}.md`), ulines.join('\n'))
//             Out.print("        - %3: cargo/%1/%2/%3.md\n", bname, pn, un)
//         }
//     }
//     let yfile = Path.join(cargoRoot, '../../mkdocs.yml')
//     let mkdocs = String(Fs.readFileSync(yfile))
//     let re = RegExp(`(#-- ${bname}\\s)([\\s\\S]*?)(#--)`)
//     Fs.writeFileSync(yfile, mkdocs.replace(re, `$1${Out.getText()}$3`))
// }
