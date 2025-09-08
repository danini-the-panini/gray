import gleam/float.{square_root}
import gleam/result.{unwrap}

pub fn sqrt(x: Float) -> Float {
  x |> square_root |> unwrap(0.0)
}

pub fn random_in_range(min: Float, max: Float) -> Float {
  min +. { max -. min } *. float.random()
}
