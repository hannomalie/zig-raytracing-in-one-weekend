const std = @import("std");
const float3 = @import("./float3.zig");
const Float3 = float3.Float3;

// https://zig.news/gowind/how-to-use-the-random-number-generator-in-zig-ef6
const RndGen = std.rand.DefaultPrng;
var rnd = RndGen.init(0);

// Returns a random real in [0,1).
pub fn random_double() f64 {
    return rnd.random().float(f64);
}

// Returns a random real in [min,max).
pub fn random_double_in_range(min: f64, max: f64) f64 {
    return min + (max-min)*random_double();
}
pub fn random_float3() Float3 {
    return Float3{.x=random_double(),.y=random_double(),.z=random_double(),};
}
pub fn random_float_in_range3(min: f64, max: f64) Float3 {
    return Float3{
        .x=random_double_in_range(min, max),
        .y=random_double_in_range(min, max),
        .z=random_double_in_range(min, max),
    };
}

pub fn random_float3_in_unit_sphere() Float3 {
    while(true) {
        const p = random_float3();
        if(p.length_squared() >= 1) continue;
        return p;
    }
}

pub fn random_unit_float3() Float3 {
    return random_float3_in_unit_sphere().unit_vector();
}