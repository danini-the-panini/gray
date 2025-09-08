import material.{type Material}
import vec3.{type Point3, type Vec3}

pub type Hit {
  Hit(p: Point3, normal: Vec3, t: Float, front_face: Bool, mat: Material)
}
