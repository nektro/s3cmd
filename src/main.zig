const std = @import("std");
const string = []const u8;
const common = @import("./_common.zig");

pub fn main() !void {
    const alloc = std.heap.c_allocator;

    var argsiter = try std.process.argsWithAllocator(alloc);
    defer argsiter.deinit();

    const config = try common.Config.read(alloc);

    std.log.debug("{s}", .{config.access_key});
    std.log.debug("{s}", .{config.secret_key});
}
