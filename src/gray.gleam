import gleam/float
import gleam/int
import gleam/io
import gleam/list.{each, range}

pub fn main() -> Nil {
  // Image

  let image_width = 256
  let image_height = 256

  io.println(
    "P3\n"
    <> int.to_string(image_width)
    <> " "
    <> int.to_string(image_height)
    <> "\n256",
  )

  each(range(0, image_height - 1), fn(j) {
    each(range(0, image_width - 1), fn(i) {
      let r = int.to_float(i) /. int.to_float(image_width - 1)
      let g = int.to_float(j) /. int.to_float(image_height - 1)
      let b = 0.0

      let ir = float.truncate(255.999 *. r)
      let ig = float.truncate(255.999 *. g)
      let ib = float.truncate(255.999 *. b)

      io.println(
        int.to_string(ir)
        <> " "
        <> int.to_string(ig)
        <> " "
        <> int.to_string(ib),
      )
    })
  })
}
