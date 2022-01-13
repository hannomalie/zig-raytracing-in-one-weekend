const Float3 = @import("./float3.zig").Float3;
const Ray = @import("./ray.zig").Ray;
const Material = @import("./material.zig").Material;

pub const Hit = enum {
    hit,
    no_hit,
};

pub const HitRecord = struct {
    p: Float3,
    normal: Float3,
    material: Material = Material{},
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
        .normal = if(front_face) outward_normal else outward_normal.multiply_float(-1.0),
    };
}

pub fn hit(comptime T: type, comptime L: usize, objects: [L]T, r: Ray, t_min: f64, t_max: f64) ?HitRecord {
    var potential_result: ?HitRecord = null;
    var closest_so_far = t_max;

    for (objects) |object| {
        const optional_hit = object.hit(r, t_min, closest_so_far);
        if(optional_hit) |value| {
            potential_result = value;
            closest_so_far = value.t;
        }
    }
    return potential_result;
}