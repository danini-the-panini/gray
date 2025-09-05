import vec3.{type Point3, type Vec3, add, scale}

pub type Ray {
  Ray(orig: Vec3, dir: Point3)
}

pub fn at(r: Ray, t: Float) -> Vec3 {
  r.dir |> scale(t) |> add(r.orig)
}
