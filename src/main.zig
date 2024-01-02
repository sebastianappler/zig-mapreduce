const std = @import("std");

pub const KeyValue = struct { k: []const u8, v: []const u8 };

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    var buf: [std.fs.MAX_PATH_BYTES]u8 = undefined;
    const cwd = try std.os.getcwd(&buf);
    const dir_path = try std.fs.path.join(allocator, &.{ cwd , "/files"});

    //
    // Data
    //
    const dir = try std.fs.cwd().openDir(dir_path, .{ .iterate = true });
    var dir_iter = dir.iterate();
    var kva = std.ArrayList(KeyValue).init(allocator);
    defer kva.deinit();
    var files = std.ArrayList(KeyValue).init(allocator);
    defer files.deinit();
    while (dir_iter.next() catch null) |file_entry| {
        const file_path = try std.fs.path.join(allocator, &.{ dir_path , "/", file_entry.name });
        defer allocator.free(file_path);
        const file = try std.fs.openFileAbsolute(file_path, .{ .mode = .read_only });
        const file_size = try file.getEndPos();
        const file_content = try file.readToEndAlloc(allocator, file_size);
        file.close();
        _ = std.ascii.upperString(file_content, file_content);
        _ = std.mem.replace(u8, file_content, "'", "", file_content);
        try files.append(.{ .k = file_entry.name, .v = file_content });
    }

    //
    // Map
    //
    for (files.items) |file| {
        try map(&kva, file.k, file.v);
    }

    //
    // Sort
    //
    std.sort.pdq(KeyValue, kva.items, {}, lessThan);

    //
    // Reduce
    //
    const file = try std.fs.cwd().createFile(
        "output.txt",
        .{ .read = true },
    );
    defer file.close();
    var i: usize = 0;
    var j: usize = 0;
    while (i < kva.items.len) {
        // Forward search all duplicate words to get slice range
        while (std.mem.eql(u8, kva.items[i].k, kva.items[j].k) == true) {
            j += 1;
            if (j == kva.items.len) {
                break;
            }
        }
        const output = reduce(kva.items[i].k, kva.items[i..j]);
        std.debug.print("{s} {}\n", .{ kva.items[i].k, output });
        try file.writer().print("{s} {}\n", .{ kva.items[i].k, output });

        i = j;
    }
}

fn lessThan(_: void, a: KeyValue, b: KeyValue) bool {
    return std.mem.lessThan(u8, a.k, b.k);
}

fn map(kva: *std.ArrayList(KeyValue), filename: []const u8, content: []const u8) !void {
    _ = filename;
    var words = std.mem.tokenizeAny(u8, content, " ,.;?!-:\n\"'*/%()$\r\t0123456789[]_@&#");
    while (words.next()) |word| {
        try kva.append(.{ .k = word, .v = "1" });
    }
}

fn reduce(key: []const u8, values: []KeyValue) usize {
    _ = key;
    return values.len;
}
