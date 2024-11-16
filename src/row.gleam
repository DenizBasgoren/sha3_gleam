import gleam/list
import types.{type Bit, Zero, and, not, xor}

pub opaque type Row {
  Row(inner: List(Bit))
}

pub fn blank() -> Row {
  list.repeat(Zero, 5)
  |> Row
}

pub fn to_list(row: Row) -> List(Bit) {
  row.inner
}

pub fn new(list: List(Bit)) -> Row {
  case list.length(list) {
    5 -> Row(list)
    _ -> panic as "Row should be 5 long"
  }
}

pub fn chi(r: Row) -> Row {
  let l =
    r
    |> to_list

  let g = types.get(l, _)

  [
    xor(g(0), and(not(g(1)), g(2))),
    xor(g(1), and(not(g(2)), g(3))),
    xor(g(2), and(not(g(3)), g(4))),
    xor(g(3), and(not(g(4)), g(0))),
    xor(g(4), and(not(g(0)), g(1))),
  ]
  |> new
}
