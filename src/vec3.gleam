import gleam/float
import util.{sqrt}

pub type Vec3 {
  Vec3(x: Float, y: Float, z: Float)
}

pub type Point3 =
  Vec3

pub fn negate(v: Vec3) -> Vec3 {
  Vec3(float.negate(v.x), float.negate(v.y), float.negate(v.z))
}

pub fn add(u: Vec3, v: Vec3) -> Vec3 {
  Vec3(u.x +. v.x, u.y +. v.y, u.z +. v.z)
}

pub fn sub(u: Vec3, v: Vec3) -> Vec3 {
  Vec3(u.x -. v.x, u.y -. v.y, u.z -. v.z)
}

pub fn scale(v: Vec3, t: Float) -> Vec3 {
  Vec3(v.x *. t, v.y *. t, v.z *. t)
}

pub fn div(v: Vec3, t: Float) -> Vec3 {
  scale(v, 1.0 /. t)
}

pub fn mul(u: Vec3, v: Vec3) -> Vec3 {
  Vec3(u.x *. v.x, u.y *. v.y, u.z *. v.z)
}

pub fn length(v: Vec3) -> Float {
  sqrt(length_sq(v))
}

pub fn length_sq(v: Vec3) -> Float {
  dot(v, v)
}

const epsilon = 1.0e-8

pub fn near_zero(v: Vec3) -> Bool {
  float.absolute_value(v.x) <. epsilon
  && float.absolute_value(v.y) <. epsilon
  && float.absolute_value(v.z) <. epsilon
}

pub fn dot(u: Vec3, v: Vec3) -> Float {
  u.x *. v.x +. u.y *. v.y +. u.z *. v.z
}

pub fn cross(u: Vec3, v: Vec3) -> Vec3 {
  Vec3(
    u.y *. v.z -. u.z *. v.y,
    u.z *. v.x -. u.x *. v.z,
    u.x *. v.y -. u.y *. v.x,
  )
}

pub fn reflect(v: Vec3, n: Vec3) -> Vec3 {
  v |> sub(n |> scale(2.0 *. dot(v, n)))
}

pub fn refract(uv: Vec3, n: Vec3, ri: Float) {
  let cos = uv |> negate |> dot(n) |> float.min(1.0)
  let perp = n |> scale(cos) |> add(uv) |> scale(ri)
  let par =
    scale(n, float.negate(sqrt(float.absolute_value(1.0 -. length_sq(perp)))))
  add(perp, par)
}

pub fn normalize(v: Vec3) -> Vec3 {
  div(v, length(v))
}

pub fn random() -> Vec3 {
  Vec3(float.random(), float.random(), float.random())
}

pub fn random_in_range(min: Float, max: Float) -> Vec3 {
  Vec3(
    util.random_in_range(min, max),
    util.random_in_range(min, max),
    util.random_in_range(min, max),
  )
}

pub fn random_unit() -> Vec3 {
  let p = random_in_range(-1.0, 1.0)
  let lensq = length_sq(p)
  case { 1.0e-160 <=. lensq && lensq <=. 1.0 } {
    True -> div(p, sqrt(lensq))
    False -> random_unit()
  }
}

pub fn random_hemi(normal: Vec3) -> Vec3 {
  let on_unit_sphere = random_unit()
  case on_unit_sphere |> dot(normal) >. 0.0 {
    True -> on_unit_sphere
    False -> negate(on_unit_sphere)
  }
}
