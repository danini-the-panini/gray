import camera
import file_streams/file_stream.{open_write}
import gleam/int
import gleam/io
import gleam/list.{each}
import image
import object.{Group, Sphere}
import otpimpl

// import otpimpl2
// import syncimpl
import vec3.{Vec3}

pub fn main() -> Nil {
  let world =
    Group([
      Sphere(Vec3(0.0, 0.0, -1.0), 0.5),
      Sphere(Vec3(0.0, -100.5, -1.0), 100.0),
    ])

  let cam = camera.new(1000, 1000, 50)

  let assert Ok(file) = open_write("out.ppm")

  image.write_header_f(file, cam.image_width, cam.image_height)

  otpimpl.run(cam, world)
  |> each(fn(row) {
    let #(j, data) = row
    io.print_error(
      "\rOUTPUT: Scanlines remaining: "
      <> int.to_string(cam.image_height - j)
      <> " ",
    )
    data
    |> each(fn(p) { image.write_pixel_f(file, p) })
  })

  io.println_error("\rDone.                         ")

  Nil
}
