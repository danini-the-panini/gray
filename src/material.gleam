import color.{type Color}

pub type Material {
  Lambert(albedo: Color)
  Metal(albedo: Color, fuzz: Float)
  Dielectric(ri: Float)
}
