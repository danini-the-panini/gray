import camera
import color
import gleam/erlang/process
import gleam/function.{tap}
import gleam/int
import gleam/io
import gleam/list.{each, map, range, sort}
import gleam/otp/actor
import object.{Group, Sphere}
import vec3.{Vec3}

pub fn main() -> Nil {
  let output = process.new_subject()

  let world =
    Group([
      Sphere(Vec3(0.0, 0.0, -1.0), 0.5),
      Sphere(Vec3(0.0, -100.5, -1.0), 100.0),
    ])

  let cam = camera.new(400, 225, 50)

  io.println(
    "P3\n"
    <> int.to_string(cam.image_width)
    <> " "
    <> int.to_string(cam.image_height)
    <> "\n256",
  )

  let workers =
    range(0, cam.image_height - 1)
    |> map(fn(j) {
      let assert Ok(worker) =
        actor.new(Nil)
        |> actor.on_message(fn(_, msg) {
          case msg {
            -1 -> actor.stop()
            j -> {
              let row =
                range(0, cam.image_width - 1)
                |> map(fn(i) { color.to_pixel(camera.render(cam, world, i, j)) })

              actor.send(output, #(j, row))

              actor.continue(Nil)
            }
          }
        })
        |> actor.start

      process.send(worker.data, j)

      worker
    })

  workers
  |> each(fn(worker) { process.send(worker.data, -1) })

  range(0, cam.image_height - 1)
  |> map(fn(j) {
    process.receive_forever(output)
    |> tap(fn(_) {
      io.print_error(
        "\rRENDER: Scanlines remaining: "
        <> int.to_string(cam.image_height - j)
        <> " ",
      )
    })
  })
  |> tap(fn(_) { io.println_error("\rDone.                         ") })
  |> sort(fn(a, b) {
    let #(j1, _) = a
    let #(j2, _) = b
    int.compare(j1, j2)
  })
  |> each(fn(row) {
    let #(j, data) = row
    io.print_error(
      "\rOUTPUT: Scanlines remaining: "
      <> int.to_string(cam.image_height - j)
      <> " ",
    )
    data
    |> each(fn(rgb) {
      let #(r, g, b) = rgb

      io.println(
        int.to_string(r) <> " " <> int.to_string(g) <> " " <> int.to_string(b),
      )
    })
  })

  io.println_error("\rDone.                         ")

  Nil
}
