import camera.{type Camera, render}
import color
import gleam/erlang/process.{type Selector}
import gleam/int
import gleam/io
import gleam/list.{each, fold, map, range, sort}
import gleam/otp/actor
import object.{type Object}

fn loop(
  cam: Camera,
  workers: List(worker_type),
  selector: Selector(#(worker_type, #(Int, List(#(Int, Int, Int))))),
  result: List(#(Int, List(#(Int, Int, Int)))),
  sendfn: fn(worker_type, Int) -> Nil,
) -> List(#(Int, List(#(Int, Int, Int)))) {
  let len = list.length(result)
  case len == cam.image_height {
    True -> {
      io.println_error("\rDone.                         ")
      workers |> each(fn(worker) { sendfn(worker, -1) })
      result
    }
    False -> {
      io.print_error(
        "\rRENDER: Scanlines remaining: "
        <> int.to_string(cam.image_height - len)
        <> " ",
      )
      let #(worker, data) = selector |> process.selector_receive_forever
      sendfn(worker, len)
      loop(cam, workers, selector, list.append(result, [data]), sendfn)
    }
  }
}

pub fn run(cam: Camera, world: Object) -> List(#(Int, List(#(Int, Int, Int)))) {
  let output = process.new_subject()
  let threads = 10

  let workers =
    range(0, threads)
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

  let selector =
    workers
    |> fold(process.new_selector(), fn(selector, worker) {
      selector |> process.select_map(output, fn(msg) { #(worker, msg) })
    })

  loop(cam, workers, selector, [], fn(worker, j) {
    worker.data |> process.send(j)
  })
  |> sort(fn(a, b) {
    let #(j1, _) = a
    let #(j2, _) = b
    int.compare(j1, j2)
  })
}
