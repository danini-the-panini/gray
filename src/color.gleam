import gleam/float
import interval.{clamp}
import vec3.{type Vec3}

pub type Color =
  Vec3

pub fn to_pixel(c: Color) -> #(Int, Int, Int) {
  let r = c.x
  let g = c.y
  let b = c.z

  let intensity = interval.new(0.0, 0.999)
  let rbyte = float.truncate(256.0 *. clamp(intensity, r))
  let gbyte = float.truncate(256.0 *. clamp(intensity, g))
  let bbyte = float.truncate(256.0 *. clamp(intensity, b))

  #(rbyte, gbyte, bbyte)
}
