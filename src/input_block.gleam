import gleam/list
import types.{type Bit, type Sha3Flavor}

pub opaque type InputBlock {
  InputBlock(rate: Int, inner: List(Bit))
}

pub fn to_list(ib: InputBlock) -> List(Bit) {
  ib.inner
}

pub fn rate(ib: InputBlock) -> Int {
  ib.rate
}

pub fn new(list: List(Bit), flavor: Sha3Flavor) -> InputBlock {
  let rate = types.rate(flavor)
  case list.length(list) {
    x if x == rate -> InputBlock(rate, list)
    _ -> panic as "Length of list doesn't match"
  }
}
