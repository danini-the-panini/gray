import color.{type Color}
import gleam/float
import gleam/int
import gleam/list.{fold, range}
import gleam/option.{None, Some}
import gleam_community/maths.{degrees_to_radians, tan}
import interval
import object.{type Object}
import ray.{type Ray, Ray}
import scatter.{scatter}
import vec3.{type Vec3, Vec3, add, cross, div, mul, normalize, scale, sub}

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
    u: Vec3,
    v: Vec3,
    w: Vec3,
    defocus_angle: Float,
    defocus_disk_u: Vec3,
    defocus_disk_v: Vec3,
  )
}

pub fn new(
  image_width: Int,
  image_height: Int,
  vfov: Float,
  lookfrom: Vec3,
  lookat: Vec3,
  vup: Vec3,
  defocus_angle: Float,
  focus_dist: Float,
  samples: Int,
  max_depth: Int,
) -> Camera {
  let aspect_ratio = int.to_float(image_width) /. int.to_float(image_height)

  let samples_scale = 1.0 /. int.to_float(samples)

  let center = lookfrom

  let theta = degrees_to_radians(vfov)
  let h = tan(theta /. 2.0)
  let viewport_height = 2.0 *. h *. focus_dist
  let viewport_width = viewport_height *. aspect_ratio

  let w = lookfrom |> sub(lookat) |> normalize
  let u = vup |> cross(w) |> normalize
  let v = w |> cross(u)

  let viewport_u = u |> scale(viewport_width)
  let viewport_v = v |> vec3.negate |> scale(viewport_height)

  let pixel_delta_u = viewport_u |> div(int.to_float(image_width))
  let pixel_delta_v = viewport_v |> div(int.to_float(image_height))

  let viewport_upper_left =
    center
    |> sub(w |> scale(focus_dist))
    |> sub(viewport_u |> div(2.0))
    |> sub(viewport_v |> div(2.0))
  let pixel00_loc =
    viewport_upper_left
    |> add(
      pixel_delta_u
      |> add(pixel_delta_v)
      |> scale(0.5),
    )

  let defocus_radius =
    focus_dist *. tan(degrees_to_radians(defocus_angle /. 2.0))
  let defocus_disk_u = u |> scale(defocus_radius)
  let defocus_disk_v = v |> scale(defocus_radius)

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
    u,
    v,
    w,
    defocus_angle,
    defocus_disk_u,
    defocus_disk_v,
  )
}

fn sample_square() -> Vec3 {
  Vec3(float.random() -. 0.5, float.random() -. 0.5, 0.0)
}

fn defocus_disk_sample(cam: Camera) -> Vec3 {
  let p = vec3.random_disk()
  cam.center
  |> add(cam.defocus_disk_u |> scale(p.x))
  |> add(cam.defocus_disk_v |> scale(p.y))
}

fn get_ray(cam: Camera, i: Int, j: Int) -> Ray {
  let offset = sample_square()
  let pixel_sample =
    cam.pixel00_loc
    |> add(cam.pixel_delta_u |> scale(int.to_float(i) +. offset.x))
    |> add(cam.pixel_delta_v |> scale(int.to_float(j) +. offset.y))

  let ray_orig = case cam.defocus_angle <=. 0.0 {
    True -> cam.center
    False -> defocus_disk_sample(cam)
  }
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
