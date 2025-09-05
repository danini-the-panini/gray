import gleam/float
import vec3.{type Vec3}

pub type Color =
  Vec3

pub fn to_pixel(c: Color) -> #(Int, Int, Int) {
  let r = c.x
  let g = c.y
  let b = c.z

  let rbyte = float.truncate(255.999 *. r)
  let gbyte = float.truncate(255.999 *. g)
  let bbyte = float.truncate(255.999 *. b)

  #(rbyte, gbyte, bbyte)
}
