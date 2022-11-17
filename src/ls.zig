//! https://docs.aws.amazon.com/AmazonS3/latest/API/API_ListBuckets.html

const std = @import("std");
const common = @import("./_common.zig");

pub fn execute(alloc: std.mem.Allocator, args: *std.process.ArgIterator, config: *const common.Config) !void {
    _ = args;

    const ten_mb = 1024 * 1024 * 10;
    const doc = try common.makeRequest(alloc, .GET, "/", null, config, ten_mb);
    const w = std.io.getStdOut().writer();

    var buckets = doc.root.findChildByTag("Buckets").?.elements();
    while (buckets.next()) |item| {
        try w.print("{s}\ts3://{s}", .{ item.getCharData("CreationDate").?, item.getCharData("Name").? });
    }
}
