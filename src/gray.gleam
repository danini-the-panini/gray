import color.{type Color}
import gleam/erlang/process
import gleam/float
import gleam/function.{tap}
import gleam/int
import gleam/io
import gleam/list.{each, map, range, sort}
import gleam/otp/actor
import ray.{type Ray, Ray}
import vec3.{type Point3, Vec3}

fn hit_sphere(center: Point3, radius: Float, r: Ray) -> Bool {
  let oc = vec3.sub(center, r.orig)
  let a = vec3.length_sq(r.dir)
  let b = -2.0 *. vec3.dot(r.dir, oc)
  let c = vec3.length_sq(oc) -. radius *. radius
  let d = b *. b -. 4.0 *. a *. c
  d >=. 0.0
}

fn ray_color(r: Ray) -> Color {
  case hit_sphere(Vec3(0.0, 0.0, -1.0), 0.5, r) {
    True -> Vec3(1.0, 0.0, 0.0)
    False -> {
      let unit_dir = vec3.normalize(r.dir)
      let a = 0.5 *. { unit_dir.y +. 1.0 }

      vec3.add(
        vec3.scale(Vec3(1.0, 1.0, 1.0), 1.0 -. a),
        vec3.scale(Vec3(0.5, 0.7, 1.0), a),
      )
    }
  }
}

pub fn main() -> Nil {
  let output = process.new_subject()

  // Image

  let image_width = 400
  let image_height = 225
  let aspect_ratio = int.to_float(image_width) /. int.to_float(image_height)

  let focal_length = 1.0
  let viewport_height = 2.0
  let viewport_width = viewport_height *. aspect_ratio
  let camera_center = Vec3(0.0, 0.0, 0.0)

  let viewport_u = Vec3(viewport_width, 0.0, 0.0)
  let viewport_v = Vec3(0.0, float.negate(viewport_height), 0.0)

  let pixel_delta_u = viewport_u |> vec3.div(int.to_float(image_width))
  let pixel_delta_v = viewport_v |> vec3.div(int.to_float(image_height))

  let viewport_upper_left =
    camera_center
    |> vec3.sub(Vec3(0.0, 0.0, focal_length))
    |> vec3.sub(vec3.div(viewport_u, 2.0))
    |> vec3.sub(vec3.div(viewport_v, 2.0))

  let pixel00_loc =
    viewport_upper_left
    |> vec3.add(pixel_delta_u |> vec3.add(pixel_delta_v) |> vec3.scale(0.5))

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
                  let pixel_center =
                    pixel00_loc
                    |> vec3.add(vec3.scale(pixel_delta_u, int.to_float(i)))
                    |> vec3.add(vec3.scale(pixel_delta_v, int.to_float(j)))
                  let r =
                    Ray(camera_center, vec3.sub(pixel_center, camera_center))

                  color.to_pixel(ray_color(r))
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
