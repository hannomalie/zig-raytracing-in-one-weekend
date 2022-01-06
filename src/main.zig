const std = @import("std");
const Float3 = @import("./float3.zig").Float3;
const Ray = @import("./ray.zig").Ray;
const _hit = @import("./hit.zig");
const Sphere = @import("./sphere.zig").Sphere;

fn ray_color(r: Ray) Float3 {
    const spheres = [_]Sphere{
        Sphere{.center = Float3{.z=-1.0}, .radius = 0.5},
        Sphere{.center = Float3{.z=-4.0}, .radius = 2.5}
    };
    const optional_hit_result = _hit.hit(Sphere, spheres.len, spheres, r, 0.0, 1000.0);

    if(optional_hit_result) |hit_result| {
        return hit_result.normal.add(Float3{.x=1,.y=1,.z=1}).multiplyFloat(0.5);
    } else {
        const unit_direction = r.direction.unit_vector();
        const t_new = 0.5 * (unit_direction.y + 1.0);
        return (Float3{.x=1.0,.y=1.0,.z=1.0}).multiplyFloat(1.0 - t_new).add((Float3{.x=0.5,.y=0.7,.z=1.0}).multiplyFloat(t_new));
    }
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
    const horizontal_half = horizontal.divideFloat(2.0);
    const vertical_half = vertical.divideFloat(2.0);
    var lower_left_corner = origin.subtract(horizontal_half);
    lower_left_corner = lower_left_corner.subtract(vertical_half);
    lower_left_corner = lower_left_corner.subtract(Float3{.x=0.0,.y=0.0,.z=focal_length});

    const file = try std.fs.cwd().createFile("image.ppm", .{});
    const writer = file.writer();
    defer file.close();
    // P3 means ASCII, then width, height and max color value
    try writer.print("P3\n{} {}\n255\n", .{image_width, image_height});

    for(range(image_height)) | _, j | {
        try stdout.print("Remaining scanlines: {}\r", .{image_height - j});
        for(range(image_width)) | _, i | {
            try stdout.print("tracing pixel at {} x {} process ...\n", .{i, j});
            const u = @intToFloat(f64, i) / @intToFloat(f64, image_width);
            const v = @intToFloat(f64, image_height - j) / @intToFloat(f64, image_height);
            const uTimesHorizontal = horizontal.multiplyFloat(u);
            const vTimesVertical = vertical.multiplyFloat(v);
            const position = lower_left_corner.add(uTimesHorizontal.add(vTimesVertical));
            const direction = position.subtract(origin);
            const cameraRay = Ray{.origin=origin, .direction=direction};

            const color = ray_color(cameraRay);

            try color.printColor(writer);
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
