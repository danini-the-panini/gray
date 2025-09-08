import gleam/float
import interval.{clamp}
import util.{sqrt}
import vec3.{type Vec3}

pub type Color =
  Vec3

fn linear_to_gamma(linear_component: Float) -> Float {
  case linear_component >. 0.0 {
    True -> sqrt(linear_component)
    False -> 0.0
  }
}

pub fn to_pixel(c: Color) -> #(Int, Int, Int) {
  let r = linear_to_gamma(c.x)
  let g = linear_to_gamma(c.y)
  let b = linear_to_gamma(c.z)

  let intensity = interval.new(0.0, 0.999)
  let rbyte = float.truncate(256.0 *. clamp(intensity, r))
  let gbyte = float.truncate(256.0 *. clamp(intensity, g))
  let bbyte = float.truncate(256.0 *. clamp(intensity, b))

  #(rbyte, gbyte, bbyte)
}
