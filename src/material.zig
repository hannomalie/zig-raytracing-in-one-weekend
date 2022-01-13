const std = @import("std");
const Float3 = @import("./float3.zig").Float3;
const Ray = @import("./ray.zig").Ray;
const HitRecord = @import("./hit.zig").HitRecord;
const random = @import("./random.zig");

const ScatterResult = struct {
    ray: Ray,
    attenuation: Float3,
    foo: bool,
};

pub const Material = struct {
    albedo: Float3 = Float3{.x=1.0,.y=1.0,.z=1.0},
    metallic: f64 = 0.0,
    fuzz: f64 = 0.0,
    transparency: f64 = 0.0,
    ir: f64 = 0.0,

    pub fn scatter(self: Material, ray: Ray, hit_result: HitRecord) ScatterResult {
        if(self.transparency > 0.0) {
            const refraction_ratio = if(hit_result.front_face) 1.0/self.ir else self.ir;
            const unit_direction = ray.direction.unit_vector();

            const cos_theta = std.math.min(unit_direction.multiply_float(-1.0).dot(hit_result.normal), 1.0);
            const sin_theta = std.math.sqrt(1.0 - (cos_theta*cos_theta));

            const cannot_refract = refraction_ratio * sin_theta > 1.0;
            const reflectance_too_big = reflectance(cos_theta, refraction_ratio) > random.random_double();
            const direction = if (cannot_refract or reflectance_too_big) unit_direction.reflect(hit_result.normal) else unit_direction.refract(hit_result.normal, refraction_ratio);
            return ScatterResult{.ray=Ray{.origin=hit_result.p, .direction=direction}, .attenuation=self.albedo, .foo=true};
        }

        if(self.metallic > 0.0) {
            const reflected = ray.direction.unit_vector().reflect(hit_result.normal);
            const scatteredReflected = Ray{.origin=hit_result.p, .direction=reflected.add(random.random_float3_in_unit_sphere().multiply_float(self.fuzz))};
            const foo = scatteredReflected.direction.dot(hit_result.normal) > 0;
            return ScatterResult{.ray=scatteredReflected, .attenuation=self.albedo, .foo=foo};
        }

        var scatter_direction = hit_result.normal.add(random.random_unit_float3());
        if(scatter_direction.is_near_zero()) {
            scatter_direction = hit_result.normal;
        }
        const scattered = Ray{.origin=hit_result.p, .direction=scatter_direction};
        const result = ScatterResult{.ray=scattered, .attenuation=self.albedo, .foo=true};

        return result;
    }
};

// Use Schlick's approximation for reflectance.
pub fn reflectance(cosine: f64, ref_idx: f64) f64 {
    var r0 = (1-ref_idx) / (1+ref_idx);
    r0 = r0*r0;
    return r0 + ((1-r0) * std.math.pow(f64, (1 - cosine), 5));
}