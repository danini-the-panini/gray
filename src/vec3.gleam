import gleam/float

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
  let assert Ok(l) = float.square_root(length_sq(v))
  l
}

pub fn length_sq(v: Vec3) -> Float {
  dot(v, v)
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

pub fn normalize(v: Vec3) -> Vec3 {
  div(v, length(v))
}
