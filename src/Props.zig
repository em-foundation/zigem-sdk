const std = @import("std");

const Ini = @import("ini");

const Fs = @import("./Fs.zig");
const Heap = @import("./Heap.zig");

const LOCAL_FILE = "local.ini";
const ZIGEM_FILE = "zigem.ini";

const PROP_EXTENDS = "em.lang.SetupExtends";
const PROP_REQUIRES = "em.lang.BundleRequires";

const SETUP_SEP = "://";

const PkgList = std.ArrayList([]const u8);

const PropMap = std.StringHashMap([]const u8);
const PropSet = std.StringHashMap(void);

var cur_pkgs = PkgList.init(Heap.get());
var cur_props = PropMap.init(Heap.get());

var done_set = PropSet.init(Heap.get());
var work_set = PropSet.init(Heap.get());

var has_setup: bool = undefined;
var root_dir: []const u8 = undefined;

pub fn addPackage(name: []const u8) anyerror!void {
    // std.log.info("adding package {s}", .{name});
    if (done_set.contains(name)) return;
    if (work_set.contains(name)) std.zig.fatal("package cycle in {s}", .{name});
    try work_set.put(name, {});
    const path = Fs.join(&.{ root_dir, name, "zigem-package.ini" });
    const pm = try readProps(path);
    try applyRequires(pm);
    var ent_iter = pm.iterator();
    while (ent_iter.next()) |e| try cur_props.put(e.key_ptr.*, e.value_ptr.*);
    _ = work_set.remove(name);
    try done_set.put(name, {});
    try cur_pkgs.insert(0, Fs.dirname(path));
}

pub fn addSetup(name: []const u8) anyerror!void {
    var seg_iter = std.mem.splitSequence(u8, name, SETUP_SEP);
    const seg0 = seg_iter.first();
    const seg1 = seg_iter.next().?;
    const conc: []const []const u8 = &.{ "setup-", seg1, ".ini" };
    const path = Fs.join(&.{ root_dir, seg0, try std.mem.concat(Heap.get(), u8, conc) });
    try addWorkspaceProps(path);
}

pub fn addWorkspace() anyerror!void {
    var path = Fs.join(&.{ root_dir, ZIGEM_FILE });
    if (!Fs.exists(path)) std.zig.fatal("can't find '{s}'", .{ZIGEM_FILE});
    try addWorkspaceProps(path);
    path = Fs.join(&.{ root_dir, LOCAL_FILE });
    if (!Fs.exists(path)) return;
    try addWorkspaceProps(path);
}

fn addWorkspaceProps(ppath: []const u8) anyerror!void {
    const pm = try readProps(ppath);
    if (!std.mem.endsWith(u8, ppath, "local.ini") or !has_setup) try applyExtends(pm);
    try applyRequires(pm);
    var ent_iter = pm.iterator();
    while (ent_iter.next()) |e| try cur_props.put(e.key_ptr.*, e.value_ptr.*);
}

fn applyExtends(pm: PropMap) anyerror!void {
    if (pm.contains(PROP_EXTENDS)) {
        const reqs = std.mem.trim(u8, pm.get(PROP_EXTENDS).?, &std.ascii.whitespace);
        var tok_iter = std.mem.tokenizeAny(u8, reqs, ", ");
        while (tok_iter.next()) |sn| try addSetup(sn);
    }
}

fn applyRequires(pm: PropMap) anyerror!void {
    if (pm.contains(PROP_REQUIRES)) {
        const reqs = std.mem.trim(u8, pm.get(PROP_REQUIRES).?, &std.ascii.whitespace);
        var tok_iter = std.mem.tokenizeAny(u8, reqs, ", ");
        while (tok_iter.next()) |bn| try addPackage(bn);
    }
}

pub fn getBundles() PkgList {
    return cur_pkgs;
}

pub fn getProps() PropMap {
    return cur_props;
}

pub fn init(dir: []const u8, sflg: bool) void {
    root_dir = dir;
    has_setup = sflg;
}

pub fn print() void {
    var props_iter = cur_props.iterator();
    while (props_iter.next()) |ent| std.log.debug("{s} = {s}", .{ ent.key_ptr.*, ent.value_ptr.* });
    for (cur_pkgs.items) |bn| std.log.debug("bundle {s}", .{bn});
}

fn readProps(path: []const u8) !PropMap {
    var pm = PropMap.init(Heap.get());
    var file = Fs.openFile(path);
    defer file.close();
    var parser = Ini.parse(Heap.get(), file.reader(), ";#");
    var pre: []const u8 = "";
    while (try parser.next()) |rec| {
        switch (rec) {
            .section => {
                const conc: []const []const u8 = &.{ rec.section, "." };
                pre = try std.mem.concat(Heap.get(), u8, conc);
            },
            .property => |kv| {
                const conc: []const []const u8 = &.{ pre, kv.key };
                const pname = try std.mem.concat(Heap.get(), u8, conc);
                try pm.put(pname, try std.mem.Allocator.dupe(Heap.get(), u8, kv.value));
            },
            else => {},
        }
    }
    return pm;
}

// function applyBundleProps(bundle: string, doneSet: Set<string>, workSet: Set<string>): void {
//     if (doneSet.has(bundle)) return
//     if (workSet.has(bundle)) throw `bundle cycle in '${bundle}'`
//     let ppath = findBundle(bundle)
//     if (!Fs.existsSync(ppath)) throw `can't find '${bundle}/bundles.properties'`
//     let pm = readProps(ppath)
//     applyRequires(pm, doneSet, workSet)
//     pm.forEach((v, k) => props.set(k, v))
//     doneSet.add(bundle)
//     pathSet.add(Path.dirname(ppath))
// }
//
// function applyExtends(pm: Map<string, string>, doneSet: Set<string>, workSet: Set<string>) {
//     let exts = pm.get(PROP_EXTENDS)
//     if (!exts) return
//     let setups = String(exts).trim().split(/[,]+/).filter(b => b.length)
//     applySetups(setups, doneSet, workSet)
// }
//
// function applyLocalProps(doneSet: Set<string>, workSet: Set<string>) {
//     let ppath = Path.join(rootdir, 'local.properties')
//     if (!Fs.existsSync(ppath)) return
//     applyWorkspaceProps(ppath, doneSet, workSet)
// }
//
// function applyRequires(pm: Map<string, string>, doneSet: Set<string>, workSet: Set<string>) {
//     let reqs = pm.get(PROP_REQUIRES)
//     if (reqs) {
//         String(reqs).trim().split(/[^\w\._]+/).filter(b => b.length).forEach(b => applyBundleProps(b, doneSet, workSet))
//     }
// }
//
// function applySetups(setups: string[], doneSet: Set<string>, workSet: Set<string>) {
//     setups.forEach(sn => {
//         let segs = sn.split(SETUP_SEP)
//         let bdir = Path.dirname(findBundle(segs[0]))
//         let fn = `setup-${segs[1]}.properties`
//         let ppath = Path.join(bdir, fn)
//         if (!Fs.existsSync(ppath)) {
//             Err.report(`can't find '${fn}'`)
//             return
//         }
//         applyWorkspaceProps(ppath, doneSet, workSet)
//     })
// }
//
// function applyWorkspaceProps(ppath: string, doneSet: Set<string>, workSet: Set<string>) {
//     let pm = readProps(ppath)
//     if (!ppath.endsWith('local.properties') || !curSetup) applyExtends(pm, doneSet, workSet)
//     applyRequires(pm, doneSet, workSet)
//     pm.forEach((v, k) => props.set(k, v))
// }
//
//
//
