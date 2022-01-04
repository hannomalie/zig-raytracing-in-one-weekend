const std = @import("std");
const float3 = @import("./float3.zig");
const Float3 = float3.Float3;
const ray = @import("./ray.zig");
const Ray = ray.Ray;

fn ray_color(r: Ray) Float3 {
    if (hit_sphere(Float3{.z=-1.0}, 0.5, r))
        return Float3{.x=1.0};
    const unit_direction = float3.unit_vector(r.direction);
    const t = 0.5 * (unit_direction.y + 1.0);
    return float3.add(float3.multiplyFloat(Float3{.x=1.0,.y=1.0,.z=1.0}, 1.0 - t), float3.multiplyFloat(Float3{.x=0.5,.y=0.7,.z=1.0}, t));
}

fn hit_sphere(center: Float3, radius: f64, r: Ray) bool {
    const oc = float3.subtract(r.origin, center);
    const a = float3.dot(r.direction, r.direction);
    const b = 2.0 * float3.dot(oc, r.direction);
    const c = float3.dot(oc, oc) - (radius * radius);
    const discriminant = (b * b) - (4 * a * c);
    return (discriminant > 0);
}

pub fn main() anyerror!void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("Starting ray tracing process ...\n", .{});

    const aspect_radio = 16.0 / 9.0;
    const image_width = 400;
    const image_height = @floatToInt(u32, image_width / aspect_radio);

    const viewport_height = 2.0;
    const viewport_width = aspect_radio * viewport_height;
    const focal_length = 1.0;

    const origin = Float3{};
    const horizontal = Float3{.x=viewport_width,.y=0.0,.z=0.0};
    const vertical = Float3{.x=0.0,.y=viewport_height,.z=0.0};
    const horizontal_half = float3.divideFloat(horizontal, 2.0);
    const vertical_half = float3.divideFloat(vertical, 2.0);
    var lower_left_corner = float3.subtract(origin, horizontal_half);
    lower_left_corner = float3.subtract(lower_left_corner, vertical_half);
    lower_left_corner = float3.subtract(lower_left_corner, Float3{.x=0.0,.y=0.0,.z=focal_length});

    const file = try std.fs.cwd().createFile("image.ppm", .{});
    const writer = file.writer();
    defer file.close();
    // P3 means ASCII, then width, height and max color value
    try writer.print("P3\n{} {}\n255\n", .{image_width, image_height});

    for(range(image_height)) | _, j | {
        try stdout.print("Remaining scanlines: {}\r", .{image_height - j});
        for(range(image_width)) | _, i | {
            try stdout.print("tracing pixel at {} x {} process ...\n", .{i, j});
            const u = @intToFloat(f64, image_width - i) / @intToFloat(f64, image_width);
            const v = @intToFloat(f64, image_height - j) / @intToFloat(f64, image_height);
            const uTimesHorizontal = float3.multiplyFloat(horizontal, u);
            const vTimesVertical = float3.multiplyFloat(vertical, v);
            const position = float3.add(lower_left_corner, float3.add(uTimesHorizontal, vTimesVertical));
            const direction = float3.subtract(position, origin);
            const cameraRay = Ray{.origin=origin, .direction=direction};

            const color = ray_color(cameraRay);

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
