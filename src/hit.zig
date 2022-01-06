const Float3 = @import("./float3.zig").Float3;
const Ray = @import("./ray.zig").Ray;

pub const Hit = enum {
    hit,
    no_hit,
};

pub const HitRecord = struct {
    p: Float3,
    normal: Float3,
    t: f64,
    front_face: bool,
};

pub const NormalInfo = struct {
    front_face: bool,
    normal: Float3,
};
pub fn calc_face_normal_info(r: Ray, outward_normal: Float3) NormalInfo {
    const front_face = r.direction.dot(outward_normal) < 0;
    return NormalInfo {
        .front_face = front_face,
        .normal = if(front_face) outward_normal else outward_normal.multiplyFloat(-1.0),
    };
}

pub fn hit(comptime T: type, comptime L: usize, objects: [L]T, r: Ray, t_min: f64, t_max: f64) ?HitRecord {
    for (objects) |object| {
        const optional_hit = object.hit(r, t_min, t_max);
        if(optional_hit) |value| {
            return value;
        }
    }
    return null;
}