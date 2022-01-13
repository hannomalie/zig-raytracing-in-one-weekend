const std = @import("std");
const clamp = std.math.clamp;
const random = @import("./random.zig");

pub const Float3 = packed struct {
    x: f64 = 0,
    y: f64 = 0,
    z: f64 = 0,
    pub fn add(a: Float3, b: Float3) Float3 {
        return Float3{
            .x = a.x + b.x,
            .y = a.y + b.y,
            .z = a.z + b.z,
        };
    }
    pub fn subtract_float(a: Float3, b: f64) Float3 {
        return a.subtract(Float3{.x=b,.y=b,.z=b});
    }
    pub fn subtract(a: Float3, b: Float3) Float3 {
        return Float3{
            .x = a.x - b.x,
            .y = a.y - b.y,
            .z = a.z - b.z,
        };
    }
    pub fn multiply(a: Float3, b: Float3) Float3 {
        return Float3{
            .x = a.x * b.x,
            .y = a.y * b.y,
            .z = a.z * b.z,
        };
    }
    pub fn multiply_float(a: Float3, b: f64) Float3 {
        return Float3{
            .x = a.x * b,
            .y = a.y * b,
            .z = a.z * b,
        };
    }
    pub fn divide(a: Float3, b: Float3) Float3 {
        return Float3{
            .x = a.x / b.x,
            .y = a.y / b.y,
            .z = a.z / b.z,
        };
    }
    pub fn divideFloat(a: Float3, b: f64) Float3 {
        return Float3{
            .x = a.x / b,
            .y = a.y / b,
            .z = a.z / b,
        };
    }
    pub fn invert(a: Float3) Float3 {
        return Float3{
            .x = -a.x,
            .y = -a.y,
            .z = -a.z,
        };
    }
    pub fn dot(a: Float3, b: Float3) f64 {
        return a.x * b.x + a.y * b.y + a.z * b.z;
    }
    pub fn cross(a: Float3, b: Float3) Float3 {
        return Float3{
            .x = a.y * b.z - a.z * b.y,
            .y = a.z * b.x - a.x * b.z,
            .z = a.x * b.y - a.y * b.x,
        };
    }
    pub fn length(a: Float3) f64 {
        return std.math.sqrt(length_squared(a));
    }
    pub fn length_squared(a: Float3) f64 {
        return a.x * a.x + a.y * a.y + a.z * a.z;
    }
    pub fn reflect(self: Float3, n: Float3) Float3 {
        return self.subtract(n.multiply_float(2.0 * self.dot(n)));
    }
    pub fn refract(self: Float3, n: Float3, etai_over_etat: f64) Float3 {
        const cos_theta = std.math.min(self.multiply_float(-1.0).dot(n), 1.0);
        const r_out_perp =  (self.add(n.multiply_float(cos_theta))).multiply_float(etai_over_etat);
        const r_out_parallel = n.multiply_float(-1.0 * std.math.sqrt(std.math.absFloat(1.0 - r_out_perp.length_squared())));
        return r_out_perp.add(r_out_parallel);
    }
    pub fn unit_vector(v: Float3) Float3 {
        return divideFloat(v, length(v));
    }

    // Return true if the vector is close to zero in all dimensions.
    pub fn is_near_zero(self: Float3) bool {
        const s = 1e-8;
        return (std.math.absFloat(self.x) < s) and (std.math.absFloat(self.y) < s) and (std.math.absFloat(self.z) < s);
    }

    pub fn print(writer: std.io.Writer, a: Float3) f64 {
        try writer.print("{} {} {}\n", .{a.x, a.y, a.z});
    }
    // https://issueexplorer.com/issue/ziglang/zig/9656
    // I need anytype here
    pub fn printColor(a: Float3, writer: anytype) !void {

        const r = @floatToInt(u8, 256 * clamp(std.math.sqrt(a.x), 0.0, 0.999));
        const g = @floatToInt(u8, 256 * clamp(std.math.sqrt(a.y), 0.0, 0.999));
        const b = @floatToInt(u8, 256 * clamp(std.math.sqrt(a.z), 0.0, 0.999));

        try writer.print("{} {} {}\n", .{r,g,b});
    }
};


test "Float3 has defined size of three floats" {
    const vector = Float3{};
    try std.testing.expect(@sizeOf(vector) == 96);
}
test "Float3 length is calculated correctly" {
    const vector = Float3{
        .x = 3,
        .y = 0,
        .z = 0,
    };
    try std.testing.expect(vector.length() == 3);
}