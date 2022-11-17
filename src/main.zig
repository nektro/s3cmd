const std = @import("std");
const common = @import("./_common.zig");

const commands = struct {
    pub const ls = @import("./ls.zig");
};

pub fn main() !void {
    const alloc = std.heap.c_allocator;

    var argsiter = try std.process.argsWithAllocator(alloc);
    defer argsiter.deinit();
    _ = argsiter.next().?;

    const config = try common.Config.read(alloc);

    const command = argsiter.next() orelse {
        std.log.info("Usage: s3cmd [options] COMMAND [parameters]", .{});
        return;
    };
    inline for (comptime std.meta.declarations(commands)) |decl| {
        if (std.mem.eql(u8, command, decl.name)) {
            return try @field(commands, decl.name).execute(alloc, &argsiter, &config);
        }
    }

    std.log.err("invalid command: {s}", .{command});
}
