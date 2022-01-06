const std = @import("std");
const Float3 = @import("./float3.zig").Float3;
const Ray = @import("./ray.zig").Ray;
const _hit = @import("./hit.zig");
const Sphere = @import("./sphere.zig").Sphere;
const Camera = @import("./camera.zig").Camera;

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

    const camera = Camera{.aspect_ratio=aspect_radio};

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
            const cameraRay = camera.get_ray(u, v);

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
