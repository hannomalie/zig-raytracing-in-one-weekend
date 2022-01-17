const std = @import("std");
const math = std.math;
const Float3 = @import("./float3.zig").Float3;
const Ray = @import("./ray.zig").Ray;

fn degrees_to_radians(degrees: f64) f64 {
    //return degrees * math.pi / 180.0;
    return degrees * 0.0174533;
}
pub const Camera = struct {
    origin: Float3 = Float3{},
    look_at: Float3,
    up: Float3 = Float3{.x=0,.y=1,.z=0},
    fov: f64 = 90.0,
    aspect_ratio: f64 = 16.0/9.0,

    pub fn get_ray(self: Camera, s: f64, t: f64) Ray {
        const theta = degrees_to_radians(self.fov);
        const h = std.math.tan(theta/2.0);
        const viewport_height: f64 = 2.0 * h;
        const viewport_width: f64 = self.aspect_ratio * viewport_height;

        const w = self.origin.subtract(self.look_at).unit_vector();
        const u = self.up.cross(w).unit_vector();
        const v = w.cross(u);

        const horizontal: Float3 = u.multiply_float(viewport_width);
        const vertical: Float3 = v.multiply_float(viewport_height);
        const horizontal_half = horizontal.divideFloat(2.0);
        const vertical_half = vertical.divideFloat(2.0);

        var lower_left_corner: Float3 = self.origin.subtract(horizontal_half)
            .subtract(vertical_half)
            .subtract(w);

        const sTimesHorizontal = horizontal.multiply_float(s);
        const tTimesVertical = vertical.multiply_float(t);
        const direction = lower_left_corner
            .add(sTimesHorizontal)
            .add(tTimesVertical)
            .subtract(self.origin);

        const cameraRay = Ray{.origin=self.origin, .direction=direction};
        return cameraRay;
    }
};