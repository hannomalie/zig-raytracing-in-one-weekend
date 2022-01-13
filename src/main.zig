const std = @import("std");
const Float3 = @import("./float3.zig").Float3;
const Ray = @import("./ray.zig").Ray;
const _hit = @import("./hit.zig");
const Sphere = @import("./sphere.zig").Sphere;
const Camera = @import("./camera.zig").Camera;
const random = @import("./random.zig");
const random_double = random.random_double;
const Material = @import("./material.zig").Material;

fn ray_color(r: Ray, comptime T: type, comptime L: usize, objects: [L]T, depth: u8) Float3 {
    if(depth <= 0) return Float3{};

    const optional_hit_result = _hit.hit(T, objects.len, objects, r, 0.001, 10000.0);

    if(optional_hit_result) |hit_result| {
        const scatterResult = hit_result.material.scatter(r, hit_result);
        if(scatterResult.foo) {
            return ray_color(scatterResult.ray, T, L, objects, depth-1).multiply(scatterResult.attenuation);
        } else {
            return Float3{};
        }
    }

    const unit_direction = r.direction.unit_vector();
    const t_new = 0.5 * (unit_direction.y + 1.0);
    return (Float3{.x=1.0,.y=1.0,.z=1.0}).multiply_float(1.0 - t_new).add((Float3{.x=0.5,.y=0.7,.z=1.0}).multiply_float(t_new));
}

pub fn main() anyerror!void {

    const spheres = [_]Sphere{
        Sphere{.center = Float3{.y=-100.5,.z=-1.0}, .radius = 100.0, .material = Material{.albedo=Float3{.x=1.0}}},
        Sphere{.center = Float3{.z=-1.0}, .radius = 0.5},
        Sphere{.center = Float3{.x=-1.0,.z=-1.0}, .radius = 0.5, .material = Material{.transparency=1.0,.ir=1.5}},
        Sphere{.center = Float3{.x=1.0,.z=-1.0}, .radius = 0.5, .material = Material{.albedo=Float3{.x=0.1,.y=0.8,.z=0.1},.metallic=1.0,.fuzz=0.3}}
    };

    const stdout = std.io.getStdOut().writer();
    try stdout.print("Starting ray tracing process ...\n", .{});

    const aspect_radio = 16.0 / 9.0;
    const image_width = 400;
    const image_height = @floatToInt(u32, image_width / aspect_radio);

    const max_depth: u8 = 20;

    const camera = Camera{.aspect_ratio=aspect_radio};

    const file = try std.fs.cwd().createFile("image.ppm", .{});
    const writer = file.writer();
    defer file.close();
    // P3 means ASCII, then width, height and max color value
    try writer.print("P3\n{} {}\n255\n", .{image_width, image_height});

    const start = std.time.milliTimestamp();
    for(range(image_height)) | _, j | {
        try stdout.print("Remaining scanlines: {}\r", .{image_height - j});
        for(range(image_width)) | _, i | {
            try stdout.print("tracing pixel at {} x {} process ...\n", .{i, j});
            var color = Float3{};
            const use_multisampling = true;

            if(use_multisampling) {
                const samples_per_pixel = 120;
                const scale = 1.0 / @intToFloat(f64, samples_per_pixel);
                for(range(samples_per_pixel)) | _ | {
                    const u = (@intToFloat(f64, i) + random_double()) / @intToFloat(f64, image_width);
                    const v = (@intToFloat(f64, (image_height - j)) + random_double()) / @intToFloat(f64, image_height);
                    const cameraRay = camera.get_ray(u, v);
                    color = color.add(ray_color(cameraRay, Sphere, spheres.len, spheres, max_depth).multiply_float(scale));
                }
                try color.printColor(writer);
            } else {
                const u = (@intToFloat(f64, i)) / @intToFloat(f64, image_width);
                const v = (@intToFloat(f64, (image_height - j))) / @intToFloat(f64, image_height);
                const cameraRay = camera.get_ray(u, v);
                color = ray_color(cameraRay, Sphere, spheres.len, spheres, max_depth);
                try color.printColor(writer);
            }
        }
    }

    const duration = std.time.milliTimestamp() - start;
    try stdout.print("Ray tracing process finished in {}ms...\n", .{duration});
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
