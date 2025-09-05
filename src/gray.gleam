import color
import gleam/erlang/process
import gleam/function.{tap}
import gleam/int
import gleam/io
import gleam/list.{each, map, range, sort}
import gleam/otp/actor
import vec3.{Vec3}

pub fn main() -> Nil {
  let output = process.new_subject()

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

  let workers =
    range(0, image_height - 1)
    |> map(fn(j) {
      let assert Ok(worker) =
        actor.new(Nil)
        |> actor.on_message(fn(_, msg) {
          case msg {
            -1 -> actor.stop()
            j -> {
              let row =
                range(0, image_width - 1)
                |> map(fn(i) {
                  let c =
                    Vec3(
                      x: int.to_float(i) /. int.to_float(image_width - 1),
                      y: int.to_float(j) /. int.to_float(image_height - 1),
                      z: 0.0,
                    )

                  color.to_pixel(c)
                })

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

  range(0, image_height - 1)
  |> map(fn(j) {
    process.receive_forever(output)
    |> tap(fn(_) {
      io.print_error(
        "\rScanlines remaining: " <> int.to_string(image_height - j),
      )
    })
  })
  |> sort(fn(a, b) {
    let #(j1, _) = a
    let #(j2, _) = b
    int.compare(j1, j2)
  })
  |> each(fn(row) {
    let #(_, data) = row
    data
    |> each(fn(rgb) {
      let #(r, g, b) = rgb

      io.println(
        int.to_string(r) <> " " <> int.to_string(g) <> " " <> int.to_string(b),
      )
    })
  })

  io.println_error("\rDone.                       ")

  Nil
}
