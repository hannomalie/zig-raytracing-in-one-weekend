const Float3 = @import("./float3.zig").Float3;
const Ray = @import("./ray.zig").Ray;
const _hit = @import("./hit.zig");
const Material = @import("./material.zig").Material;

pub const Sphere = struct {
    center: Float3 = Float3 {},
    radius: f64 = 10.0,
    material: Material = Material{},

    pub fn hit(self: Sphere, r: Ray, t_min: f64, t_max: f64) ?_hit.HitRecord {
        const oc = r.origin.subtract(self.center);
        const a = r.direction.length_squared();
        const half_b = oc.dot(r.direction);
        const c = oc.length_squared() - (self.radius * self.radius);
        const discriminant = (half_b * half_b) - (a * c);

        if(discriminant < 0) {
            return null;
        } else {
            const sqrtd = @sqrt(discriminant);
            var root = (-half_b - sqrtd) / a;

            const root_smaller_than_min = root < t_min;
            const root_bigger_than_max = t_max < root;
            if(root_smaller_than_min or root_bigger_than_max) {
                root = (-half_b + sqrtd) / a;
                const new_root_smaller_than_min = root < t_min;
                const new_root_bigger_than_max = t_max < root;
                if (new_root_smaller_than_min or new_root_bigger_than_max) {
                    return null;
                }
            }
            const t_result = root;
            const p_result = r.at(t_result);
            const normal_result = (p_result.subtract(self.center)).divideFloat(self.radius);

            const normal_info = _hit.calc_face_normal_info(r, normal_result);

            return _hit.HitRecord{
                .p = p_result,
                .t = t_result,
                .material = self.material,
                .normal = normal_info.normal,
                .front_face = normal_info.front_face,
            };
        }
    }
};