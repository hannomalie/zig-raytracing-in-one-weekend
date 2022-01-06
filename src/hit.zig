const Float3 = @import("./float3.zig").Float3;

pub const Hit = enum {
    hit,
    no_hit,
};

pub const HitRecord = struct {
    p: Float3,
    normal: Float3,
    t: f64,
};
pub const HitResult = union(Hit) {
    hit: HitRecord,
    no_hit: void,
};