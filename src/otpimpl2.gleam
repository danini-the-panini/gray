import camera.{type Camera, render}
import color
import gleam/erlang/process
import gleam/function.{tap}
import gleam/int
import gleam/io
import gleam/list.{each, map, range, sort}
import gleam/otp/actor
import object.{type Object}

pub fn run(cam: Camera, world: Object) -> List(#(Int, List(#(Int, Int, Int)))) {
  let output = process.new_subject()

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
                |> map(fn(i) { cam |> render(world, i, j) |> color.to_pixel })

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
}
