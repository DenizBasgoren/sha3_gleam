import gleam/list
import types.{type Bit, Zero}

pub opaque type Lane {
  Lane(inner: List(Bit))
}

pub fn blank() -> Lane {
  list.repeat(Zero, 64)
  |> Lane
}

pub fn to_list(lane: Lane) -> List(Bit) {
  lane.inner
}

pub fn new(list: List(Bit)) -> Lane {
  case list.length(list) {
    64 -> Lane(list)
    _ -> panic as "Lane should be 64 long"
  }
}

pub fn rotate_right(lane: Lane, by n: Int) -> Lane {
  let l = to_list(lane)

  list.append(list.drop(l, 64 - n), list.take(l, 64 - n))
  |> new
}

pub fn xor(l1: Lane, l2: Lane) -> Lane {
  list.map2(l1.inner, l2.inner, types.xor)
  |> new
}
