const std = @import("std");
const string = []const u8;
const Sha256 = std.crypto.hash.sha2.Sha256;
const hmac = std.crypto.auth.hmac.sha2.HmacSha256;
const knownfolders = @import("known-folders");
const ini = @import("ini");
const extras = @import("extras");
const xml = @import("./_xml.zig");
const time = @import("time");
const zfetch = @import("zfetch");

const default_region = "us-east-1";
const default_service = "s3";

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

pub fn makeRequest(alloc: std.mem.Allocator, method: std.http.Method, endpoint: string, payload: ?string, config: *const Config, max_size: usize) !xml.Document {
    const host = "s3." ++ default_region ++ ".amazonaws.com";
    const url = try std.fmt.allocPrint(alloc, "https://{s}{s}", .{ host, endpoint });
    const payload_hash = sha256(payload orelse "");
    const now = time.DateTime.now();
    const date = try now.formatAlloc(alloc, "ddd, DD MMM YYYY HH:mm:ss z");
    const datestamp = try now.formatAlloc(alloc, "YYYYMMDD");
    const algorithm = "AWS4-HMAC-SHA256";
    const signed_headers = "host;x-amz-date";
    const canonical_request = try std.mem.join(alloc, "\n", &.{ @tagName(method), endpoint, "", try std.fmt.allocPrint(alloc, "host:{s}", .{host}), try std.fmt.allocPrint(alloc, "x-amz-date:{s}", .{date}), "", signed_headers, &payload_hash });
    const credential_scope = try std.mem.join(alloc, "/", &.{ datestamp, default_region, default_service, "aws4_request" });
    const string_to_sign = try std.mem.join(alloc, "\n", &.{ algorithm, date, credential_scope, &sha256(canonical_request) });
    const signature = tohex(sign(&signingKey(config.secret_key, datestamp, default_region, default_service), string_to_sign));

    var req = try zfetch.Request.init(alloc, url, null);

    var headers = zfetch.Headers.init(alloc);
    try headers.appendValue("Host", host);
    try headers.appendValue("Date", date);
    try headers.appendValue("x-amz-date", date);
    try headers.appendValue("x-amz-content-sha256", &payload_hash);
    try headers.appendValue("Authorization", try std.fmt.allocPrint(alloc, "{s} Credential={s}/{s},SignedHeaders={s},Signature={s}", .{ algorithm, config.access_key, credential_scope, signed_headers, signature }));

    try req.do(method, headers, null);
    const r = req.reader();
    const body_content = try r.readAllAlloc(alloc, max_size);
    const doc = try xml.parse(alloc, body_content);
    return doc;
}

pub fn sha256(input: string) [Sha256.digest_length * 2]u8 {
    return tohex(extras.hashBytes(Sha256, input));
}

pub fn signingKey(key: string, datestamp: string, region: string, service: string) [hmac.mac_length]u8 {
    var scratch: [256]u8 = undefined;
    const first = std.fmt.bufPrint(&scratch, "{s}{s}", .{ "AWS4", key }) catch @panic("SecretAccessKey too long");
    return sign(&sign(&sign(&sign(first, datestamp), region), service), "aws4_request");
}

pub fn sign(key: string, msg: string) [hmac.mac_length]u8 {
    var sig = hmac.init(key);
    sig.update(msg);
    var buf: [hmac.mac_length]u8 = undefined;
    sig.final(&buf);
    return buf;
}

pub fn tohex(digest: anytype) [digest.len * 2]u8 {
    const array: [digest.len]u8 = digest;
    var hex: [digest.len * 2]u8 = undefined;
    _ = std.fmt.bufPrint(&hex, "{}", .{std.fmt.fmtSliceHexLower(&array)}) catch |err| switch (err) {
        error.NoSpaceLeft => unreachable,
    };
    return hex;
}
