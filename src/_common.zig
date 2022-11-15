const std = @import("std");
const string = []const u8;
const knownfolders = @import("known-folders");
const ini = @import("ini");

pub const Config = struct {
    access_key: string,
    secret_key: string,

    pub fn read(alloc: std.mem.Allocator) !Config {
        const home = try knownfolders.open(alloc, .home, .{});
        const file = try home.?.openFile(".s3cfg", .{});
        const content = try file.reader().readAllAlloc(alloc, 1024 * 1024);
        const document = try ini.parseIntoMap(content, alloc);
        return Config{
            .access_key = document.map.get("default.access_key").?,
            .secret_key = document.map.get("default.secret_key").?,
        };
    }
};
