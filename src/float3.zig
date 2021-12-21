const std = @import("std");

pub const Float3 = packed struct {
    x: f32 = 0,
    y: f32 = 0,
    z: f32 = 0,
};

pub fn add(a: Float3, b: Float3) Float3 {
    return Float3{
        .x = a.x + b.x,
        .y = a.y + b.y,
        .z = a.z + b.z,
    };
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
pub fn multiplyFloat(a: Float3, b: f32) Float3 {
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
pub fn divideFloat(a: Float3, b: f32) Float3 {
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
pub fn dot(a: Float3, b: Float3) f32 {
    return a.x * b.x + a.y * b.y + a.z * b.z;
}
pub fn cross(a: Float3, b: Float3) Float3 {
    return Float3{
        .x = a.y * b.z - a.z * b.y,
        .y = a.z * b.x - a.x * b.z,
        .z = a.x * b.y - a.y * b.x,
    };
}
pub fn length(a: Float3) f32 {
    return std.math.sqrt(length_squared(a));
}
pub fn length_squared(a: Float3) f32 {
    return a.x * a.x + a.y * a.y + a.z * a.z;
}

pub fn unit_vector(v: Float3) Float3 {
    return divideFloat(v, length(v));
}
pub fn print(writer: std.io.Writer, a: Float3) f32 {
    try writer.print("{} {} {}\n", .{a.x, a.y, a.z});
}
// https://issueexplorer.com/issue/ziglang/zig/9656
// I need anytype here
pub fn printColor(writer: anytype, a: Float3) !void {
    const ir = @floatToInt(u8, 255.999 * a.x);
    const ig = @floatToInt(u8, 255.999 * a.y);
    const ib = @floatToInt(u8, 255.999 * a.z);

    try writer.print("{} {} {}\n", .{ir, ig, ib});
}



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
    try std.testing.expect(length(vector) == 3);
}