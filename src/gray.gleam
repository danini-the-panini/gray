import camera
import file_streams/file_stream.{open_write}
import gleam/float
import gleam/int
import gleam/io
import gleam/list.{append, each, filter_map, flat_map, range}
import image
import material.{Dielectric, Lambert, Metal}
import object.{Group, Sphere}
import otpimpl
import syncimpl
import util
import vec3.{Vec3, mul, sub}

pub fn main() -> Nil {
  let world =
    Group(
      range(-11, 10)
      |> flat_map(fn(a) {
        range(-11, 10)
        |> filter_map(fn(b) {
          let choose_mat = float.random()
          let center =
            Vec3(
              int.to_float(a) +. 0.9 *. float.random(),
              0.2,
              int.to_float(b) +. 0.9 *. float.random(),
            )

          case center |> sub(Vec3(4.0, 0.2, 0.0)) |> vec3.length >. 0.9 {
            True -> {
              case choose_mat <. 0.8, choose_mat <. 0.95 {
                True, _ -> {
                  Ok(Sphere(
                    center,
                    0.2,
                    Lambert(vec3.random() |> mul(vec3.random())),
                  ))
                }
                False, True -> {
                  Ok(Sphere(
                    center,
                    0.2,
                    Metal(
                      vec3.random_in_range(0.5, 1.0),
                      util.random_in_range(0.0, 0.5),
                    ),
                  ))
                }
                _, _ -> {
                  Ok(Sphere(center, 0.2, Dielectric(1.5)))
                }
              }
            }
            False -> Error(Nil)
          }
        })
      })
      |> append([
        Sphere(Vec3(0.0, -1000.0, 0.0), 1000.0, Lambert(Vec3(0.8, 0.8, 0.8))),
        Sphere(Vec3(0.0, 1.0, 0.0), 1.0, Dielectric(1.5)),
        Sphere(Vec3(-4.0, 1.0, 0.0), 1.0, Lambert(Vec3(0.4, 0.2, 0.1))),
        Sphere(Vec3(4.0, 1.0, 0.0), 1.0, Metal(Vec3(0.7, 0.6, 0.5), 0.0)),
      ]),
    )

  let cam =
    camera.new(
      400,
      225,
      20.0,
      Vec3(12.0, 2.0, 3.0),
      Vec3(0.0, 0.0, 0.0),
      Vec3(0.0, 1.0, 0.0),
      0.6,
      10.0,
      10,
      50,
    )

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

  let assert Ok(Nil) = file_stream.close(file)

  io.println_error("\rDone.                          ")

  Nil
}
