import gleam/float.{power, square_root}
import gleam/result.{unwrap}

pub fn sqrt(x: Float) -> Float {
  x |> square_root |> unwrap(0.0)
}

pub fn pow(x: Float, p: Float) -> Float {
  x |> power(p) |> unwrap(0.0)
}

pub fn random_in_range(min: Float, max: Float) -> Float {
  min +. { max -. min } *. float.random()
}
