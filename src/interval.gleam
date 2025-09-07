import gleam/float
import gleam/order.{type Order, Eq, Gt, Lt}

pub type Floaty {
  Float(Float)
  Inf
  NegInf
}

pub type Interval {
  Interval(min: Floaty, max: Floaty)
}

pub fn empty() -> Interval {
  Interval(Inf, NegInf)
}

pub fn universe() -> Interval {
  Interval(NegInf, Inf)
}

pub fn new(a: Float, b: Float) -> Interval {
  Interval(Float(a), Float(b))
}

pub fn new_from(a: Float) -> Interval {
  Interval(Float(a), Inf)
}

fn compare(a: Floaty, b: Floaty) -> Order {
  case a, b {
    Inf, Inf | NegInf, NegInf -> Eq
    Inf, _ -> Gt
    NegInf, _ -> Lt
    _, Inf -> Lt
    _, NegInf -> Gt
    Float(a), Float(b) -> float.compare(a, b)
  }
}

pub fn size(i: Interval) -> Floaty {
  case i.min, i.max {
    Float(min), Float(max) -> Float(max -. min)
    NegInf, Inf -> Inf
    _, _ -> Float(0.0)
  }
}

pub fn contains(i: Interval, x: Float) -> Bool {
  case compare(Float(x), i.min), compare(Float(x), i.max) {
    Gt, Lt | Eq, Lt | Gt, Eq | Eq, Eq -> True
    _, _ -> False
  }
}

pub fn surrounds(i: Interval, x: Float) -> Bool {
  case compare(Float(x), i.min), compare(Float(x), i.max) {
    Gt, Lt -> True
    _, _ -> False
  }
}
