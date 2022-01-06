const float3 = @import("./float3.zig");
const Float3 = float3.Float3;

pub const Ray = packed struct {
    origin: Float3 = Float3 {},
    direction: Float3 = Float3 {},
    pub fn at(ray: Ray, t: f64) Float3 {
        return ray.origin.add(ray.direction.multiplyFloat(t));
    }
};
