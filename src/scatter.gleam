import color.{type Color}
import gleam/option.{type Option, Some}
import hit.{type Hit}
import material.{Dielectric, Lambert, Metal}
import ray.{type Ray, Ray}
import vec3.{Vec3, add, reflect}

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
  Some(Scatter(albedo, Ray(hit.p, dir)))
}

fn scatter_dielectric(ri: Float, r_in: Ray, hit: Hit) -> Option(Scatter) {
  let dir = hit.normal |> add(vec3.random_unit())
  Some(Scatter(Vec3(1.0, 1.0, 1.0), Ray(hit.p, dir)))
}

pub fn scatter(r_in: Ray, hit: Hit) -> Option(Scatter) {
  case hit.mat {
    Lambert(albedo) -> scatter_lambert(albedo, hit)
    Metal(albedo, fuzz) -> scatter_metal(albedo, fuzz, r_in, hit)
    Dielectric(ri) -> scatter_dielectric(ri, r_in, hit)
  }
}
