const std = @import("std");

pub fn main() anyerror!void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("Starting ray tracing process ...\n", .{});

    const image_width = 256;
    const image_height = 256;

    const file = try std.fs.cwd().createFile("image.ppm", .{});
    const writer = file.writer();
    defer file.close();
    // P3 means ASCII, then width, height and max color value
    try writer.print("P3\n{} {}\n255\n", .{image_width, image_height});

    for(range(image_height)) | _, j | {
        try stdout.print("Remaining scanlines: {}\r", .{image_height - j});
        for(range(image_width)) | _, i | {
            const r = @intToFloat(f32, image_width - i) / @intToFloat(f32, image_width);
            const g = @intToFloat(f32, image_height - j) / @intToFloat(f32, image_height);
            const b = 0.25;

            const ir = @floatToInt(u8, 255.999 * r);
            const ig = @floatToInt(u8, 255.999 * g);
            const ib = @floatToInt(u8, 255.999 * b);

            try writer.print("{} {} {}\n", .{ir, ig, ib});
        }
    }

    try stdout.print("Ray tracing process finished ...\n", .{});
}

test "basic test" {
    try std.testing.expectEqual(10, 3 + 7);
}

// https://github.com/nektro/zig-range/blob/master/src/lib.zig
/// Use this as a way to increment an index using a for loop. Works with both
/// runtime and comptime integers.
///
/// ```zig
/// for (range(10)) |_, i| {
///   // 'i' will increment from 0 -> 9
/// }
/// ```
pub fn range(len: usize) []const u0 {
    return @as([*]u0, undefined)[0..len];
}
