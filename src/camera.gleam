import color.{type Color}
import gleam/float
import gleam/int
import gleam/list.{fold, range}
import gleam/option.{None, Some}
import interval
import object.{type Object}
import ray.{type Ray, Ray}
import scatter.{Scatter, scatter}
import vec3.{type Vec3, Vec3, add, div, mul, normalize, scale, sub}

pub type Camera {
  Camera(
    image_width: Int,
    image_height: Int,
    aspect_ratio: Float,
    samples: Int,
    samples_scale: Float,
    max_depth: Int,
    center: Vec3,
    pixel_delta_u: Vec3,
    pixel_delta_v: Vec3,
    pixel00_loc: Vec3,
  )
}

pub fn new(
  image_width: Int,
  image_height: Int,
  samples: Int,
  max_depth: Int,
) -> Camera {
  let aspect_ratio = int.to_float(image_width) /. int.to_float(image_height)

  let samples_scale = 1.0 /. int.to_float(samples)

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
    samples,
    samples_scale,
    max_depth,
    center,
    pixel_delta_u,
    pixel_delta_v,
    pixel00_loc,
  )
}

fn sample_square() -> Vec3 {
  Vec3(float.random() -. 0.5, float.random() -. 0.5, 0.0)
}

fn get_ray(cam: Camera, i: Int, j: Int) -> Ray {
  let offset = sample_square()
  let pixel_sample =
    cam.pixel00_loc
    |> add(cam.pixel_delta_u |> scale(int.to_float(i) +. offset.x))
    |> add(cam.pixel_delta_v |> scale(int.to_float(j) +. offset.y))

  let ray_orig = cam.center
  let ray_dir = pixel_sample |> sub(ray_orig)

  Ray(ray_orig, ray_dir)
}

pub fn render(cam: Camera, world: Object, i: Int, j: Int) -> Color {
  range(0, cam.samples)
  |> fold(Vec3(0.0, 0.0, 0.0), fn(pixel_color, _) {
    pixel_color |> add(cam |> get_ray(i, j) |> ray_color(cam.max_depth, world))
  })
  |> scale(cam.samples_scale)
}

pub fn ray_color(r: Ray, depth: Int, world: Object) -> Color {
  case depth <= 0 {
    True -> Vec3(0.0, 0.0, 0.0)
    False -> {
      case object.hit(world, r, interval.new_from(0.001)) {
        Some(hit) -> {
          case scatter(r, hit) {
            Some(scat) -> scat.att |> mul(ray_color(scat.ray, depth - 1, world))
            None -> Vec3(0.0, 0.0, 0.0)
          }
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
  }
}
