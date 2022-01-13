const Float3 = @import("./float3.zig").Float3;
const Ray = @import("./ray.zig").Ray;

pub const Camera = struct {
    origin: Float3 = Float3{},
    aspect_ratio: f64 = 16.0/9.0,

    pub fn get_ray(self: Camera, u: f64, v: f64) Ray {
        const viewport_height: f64 = 2.0;
        const viewport_width: f64 = self.aspect_ratio * viewport_height;
        const focal_length: f64 = 1.0;
        const horizontal: Float3 = Float3{.x=viewport_width};
        const vertical: Float3 = Float3{.y=viewport_height};
        const horizontal_half = horizontal.divideFloat(2.0);
        const vertical_half = vertical.divideFloat(2.0);
        var lower_left_corner: Float3 = self.origin.subtract(horizontal_half);
        lower_left_corner = lower_left_corner.subtract(vertical_half);
        lower_left_corner = lower_left_corner.subtract(Float3{.x=0.0,.y=0.0,.z=focal_length});

        const uTimesHorizontal = horizontal.multiply_float(u);
        const vTimesVertical = vertical.multiply_float(v);
        const position = lower_left_corner.add(uTimesHorizontal.add(vTimesVertical));
        const direction = position.subtract(self.origin);
        const cameraRay = Ray{.origin=self.origin, .direction=direction};

        return cameraRay;
    }
};