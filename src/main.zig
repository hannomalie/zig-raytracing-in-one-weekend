const std = @import("std");
const float3 = @import("./float3.zig");
const Float3 = float3.Float3;
const ray = @import("./ray.zig");
const Ray = ray.Ray;

fn ray_color(r: Ray) f32 {
    const unit_direction = float3.unit_vector(r.direction);
    const t = 0.5 * (unit_direction.y + 1.0);
    return float3.multiply(1.0 - t, Float3{.x=1.0,.y=1.0,.z=1.0}) + float3.multiply(t, Float3{.x=0.5,.y=0.7,.z=1.0});
}

pub fn main() anyerror!void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("Starting ray tracing process ...\n", .{});

    const aspect_radio = 16.0 / 9.0;
    const image_width = 400;
    const image_height = @floatToInt(u32, image_width / aspect_radio);

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

            const color = Float3{
                .x = r,
                .y = g,
                .z = b,
            };

            try float3.printColor(writer, color);
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
