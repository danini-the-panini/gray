import color.{type Color}
import gleam/float
import gleam/int
import gleam/option.{None, Some}
import interval
import object.{type Object}
import ray.{type Ray, Ray}
import vec3.{type Vec3, Vec3, add, div, normalize, scale, sub}

pub type Camera {
  Camera(
    image_width: Int,
    image_height: Int,
    aspect_ratio: Float,
    center: Vec3,
    pixel_delta_u: Vec3,
    pixel_delta_v: Vec3,
    pixel00_loc: Vec3,
  )
}

pub fn new(image_width: Int, image_height: Int) -> Camera {
  let aspect_ratio = int.to_float(image_width) /. int.to_float(image_height)

  let center = Vec3(0.0, 0.0, 0.0)

  let focal_length = 1.0
  let viewport_height = 2.0
  let viewport_width = viewport_height *. aspect_ratio

  let viewport_u = Vec3(viewport_width, 0.0, 0.0)
  let viewport_v = Vec3(0.0, float.negate(viewport_height), 0.0)

  let pixel_delta_u = viewport_u |> div(int.to_float(image_width))
  let pixel_delta_v = viewport_v |> div(int.to_float(image_height))

  let viewport_upper_left =
    center
    |> sub(Vec3(0.0, 0.0, focal_length))
    |> sub(viewport_u |> div(2.0))
    |> sub(viewport_v |> div(2.0))
  let pixel00_loc =
    viewport_upper_left
    |> add(
      pixel_delta_u
      |> add(pixel_delta_v)
      |> scale(0.5),
    )

  Camera(
    image_width,
    image_height,
    aspect_ratio,
    center,
    pixel_delta_u,
    pixel_delta_v,
    pixel00_loc,
  )
}

pub fn render(cam: Camera, world: Object, i: Int, j: Int) -> Color {
  let pixel_center =
    cam.pixel00_loc
    |> vec3.add(vec3.scale(cam.pixel_delta_u, int.to_float(i)))
    |> vec3.add(vec3.scale(cam.pixel_delta_v, int.to_float(j)))
  let r = Ray(cam.center, vec3.sub(pixel_center, cam.center))

  ray_color(r, world)
}

pub fn ray_color(r: Ray, world: Object) -> Color {
  case object.hit(world, r, interval.new_from(0.0)) {
    Some(hit) -> {
      hit.normal |> add(Vec3(1.0, 1.0, 1.0)) |> scale(0.5)
    }
    None -> {
      let unit_dir = normalize(r.dir)
      let a = 0.5 *. { unit_dir.y +. 1.0 }

      Vec3(1.0, 1.0, 1.0)
      |> scale(1.0 -. a)
      |> add(Vec3(0.5, 0.7, 1.0) |> scale(a))
    }
  }
}
