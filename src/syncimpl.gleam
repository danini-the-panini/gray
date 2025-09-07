import camera.{type Camera, render}
import color
import gleam/int
import gleam/io
import gleam/list.{map, range}
import object.{type Object}

pub fn run(cam: Camera, world: Object) -> List(#(Int, List(#(Int, Int, Int)))) {
  range(0, cam.image_height)
  |> map(fn(j) {
    io.print_error(
      "\rRENDER: Scanlines remaining: "
      <> int.to_string(cam.image_height - j)
      <> " ",
    )
    let row =
      range(0, cam.image_width)
      |> map(fn(i) { cam |> render(world, i, j) |> color.to_pixel })
    #(j, row)
  })
}
