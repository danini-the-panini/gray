import gleam/float
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/order.{Lt}
import gleam/result.{unwrap}
import interval.{type Interval, Float, Interval}
import ray.{type Ray}
import vec3.{type Point3, type Vec3, div, dot, sub}

pub type Hit {
  Hit(p: Point3, normal: Vec3, t: Float, front_face: Bool)
}

pub fn make_hit(p: Point3, outward_normal: Vec3, t: Float, r: Ray) -> Hit {
  let front_face = r.dir |> dot(outward_normal) <. 0.0
  let normal = case front_face {
    True -> outward_normal
    False -> vec3.negate(outward_normal)
  }
  Hit(p, normal, t, front_face)
}

pub type Object {
  Sphere(center: Point3, radius: Float)
  Group(List(Object))
}

fn hit_sphere(
  center: Point3,
  radius: Float,
  r: Ray,
  ray_t: Interval,
) -> Option(Hit) {
  let oc = vec3.sub(center, r.orig)
  let a = vec3.length_sq(r.dir)
  let h = vec3.dot(r.dir, oc)
  let c = vec3.length_sq(oc) -. radius *. radius
  let discriminant = h *. h -. a *. c

  case float.compare(discriminant, 0.0) {
    Lt -> None
    _ -> {
      let sqrtd = float.square_root(discriminant) |> unwrap(0.0)

      let root = { h -. sqrtd } /. a
      let in_range = case interval.surrounds(ray_t, root) {
        True -> Some(root)
        False -> {
          let root = { h +. sqrtd } /. a
          case interval.surrounds(ray_t, root) {
            True -> Some(root)
            False -> None
          }
        }
      }

      case in_range {
        Some(root) -> {
          let p = ray.at(r, root)
          Some(make_hit(p, p |> sub(center) |> div(radius), root, r))
        }
        None -> None
      }
    }
  }
}

fn hit_group(objects: List(Object), r: Ray, ray_t: Interval) -> Option(Hit) {
  let #(h, _) =
    objects
    |> list.fold(#(None, ray_t.max), fn(acc, obj) {
      let #(_, max) = acc
      case hit(obj, r, Interval(ray_t.min, max)) {
        Some(h) -> #(Some(h), Float(h.t))
        None -> acc
      }
    })
  h
}

pub fn hit(obj: Object, r: Ray, ray_t: Interval) -> Option(Hit) {
  case obj {
    Sphere(center, radius) -> hit_sphere(center, radius, r, ray_t)
    Group(objects) -> hit_group(objects, r, ray_t)
  }
}
