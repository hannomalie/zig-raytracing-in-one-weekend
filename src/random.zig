const std = @import("std");

// Returns a random real in [0,1).
pub fn random_double() f64 {
    return std.rand.Random.float(f64);
}

// Returns a random real in [min,max).
pub fn random_double_in_range(min: f64, max: f64) f64 {
    return min + (max-min)*random_double();
}