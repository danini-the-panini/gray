import color.{type Color}
import gleam/float
import gleam/option.{type Option, Some}
import hit.{type Hit}
import material.{Dielectric, Lambert, Metal}
import ray.{type Ray, Ray}
import util.{pow, sqrt}
import vec3.{Vec3, add, dot, negate, normalize, reflect, refract, scale}

pub type Scatter {
  Scatter(att: Color, ray: Ray)
}

fn scatter_lambert(albedo: Color, hit: Hit) -> Option(Scatter) {
  let dir = hit.normal |> add(vec3.random_unit())
  let dir = case vec3.near_zero(dir) {
    True -> hit.normal
    False -> dir
  }
  Some(Scatter(albedo, Ray(hit.p, dir)))
}

fn scatter_metal(
  albedo: Color,
  fuzz: Float,
  r_in: Ray,
  hit: Hit,
) -> Option(Scatter) {
  let dir = r_in.dir |> reflect(hit.normal)
  let dir = dir |> normalize |> add(vec3.random_unit() |> scale(fuzz))
  Some(Scatter(albedo, Ray(hit.p, dir)))
}

fn reflectance(cos: Float, ri: Float) -> Float {
  let r0 = { 1.0 -. ri } /. { 1.0 +. ri }
  let r0 = r0 *. r0
  r0 +. { 1.0 -. r0 } *. pow(1.0 -. cos, 5.0)
}

fn scatter_dielectric(ri: Float, r_in: Ray, hit: Hit) -> Option(Scatter) {
  let ri = case hit.front_face {
    True -> 1.0 /. ri
    False -> ri
  }

  let unit_dir = normalize(r_in.dir)
  let cos = unit_dir |> negate |> dot(hit.normal) |> float.min(1.0)
  let sin = sqrt(1.0 -. cos *. cos)

  let cannot_refract = ri *. sin >. 1.0

  let dir = case cannot_refract || reflectance(cos, ri) >. float.random() {
    True -> reflect(unit_dir, hit.normal)
    False -> refract(unit_dir, hit.normal, ri)
  }

  Some(Scatter(Vec3(1.0, 1.0, 1.0), Ray(hit.p, dir)))
}

pub fn scatter(r_in: Ray, hit: Hit) -> Option(Scatter) {
  case hit.mat {
    Lambert(albedo) -> scatter_lambert(albedo, hit)
    Metal(albedo, fuzz) -> scatter_metal(albedo, fuzz, r_in, hit)
    Dielectric(ri) -> scatter_dielectric(ri, r_in, hit)
  }
}
