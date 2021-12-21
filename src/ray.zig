const float3 = @import("./float3.zig");
const Float3 = float3.Float3;

pub const Ray = packed struct {
    origin: Float3 = Float3 {},
    direction: Float3 = Float3 {},
};

pub fn at(ray: Ray, t: f32) Float3 {
    return float3.add(ray.origin, float3.multiplyFloat(ray.direction, t));
}