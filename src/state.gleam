import gleam/list
import gleam/string
import lane.{type Lane}
import row.{type Row}
import types.{type Bit, Zero}

pub opaque type State {
  State(inner: List(Bit))
}

pub fn blank() -> State {
  list.repeat(Zero, 1600)
  |> State
}

pub fn to_list(state: State) -> List(Bit) {
  state.inner
}

pub fn new(list: List(Bit)) -> State {
  case list.length(list) {
    1600 -> State(list)
    _ -> panic as "State should be 1600 long"
  }
}

pub fn get_lane(state: State, n: Int) -> Lane {
  to_list(state)
  |> list.index_map(fn(x, i) { #(i, x) })
  |> list.filter(fn(x) { x.0 / 64 == n })
  |> list.map(fn(x) { x.1 })
  |> lane.new
}

pub fn pi(state: State) -> State {
  [
    0, 6, 12, 18, 24, 3, 9, 10, 16, 22, 1, 7, 13, 19, 20, 4, 5, 11, 17, 23, 2, 8,
    14, 15, 21,
  ]
  // |> list.map( fn(x) { get_lane(state, x) } )
  |> list.map(get_lane(state, _))
  |> list.map(lane.to_list)
  |> list.flatten
  |> new
}

pub fn iota(state: State, round: Int) -> State {
  let rc = [
    "1000000000000000000000000000000000000000000000000000000000000000",
    "0100000100000001000000000000000000000000000000000000000000000000",
    "0101000100000001000000000000000000000000000000000000000000000001",
    "0000000000000001000000000000000100000000000000000000000000000001",
    "1101000100000001000000000000000000000000000000000000000000000000",
    "1000000000000000000000000000000100000000000000000000000000000000",
    "1000000100000001000000000000000100000000000000000000000000000001",
    "1001000000000001000000000000000000000000000000000000000000000001",
    "0101000100000000000000000000000000000000000000000000000000000000",
    "0001000100000000000000000000000000000000000000000000000000000000",
    "1001000000000001000000000000000100000000000000000000000000000000",
    "0101000000000000000000000000000100000000000000000000000000000000",
    "1101000100000001000000000000000100000000000000000000000000000000",
    "1101000100000000000000000000000000000000000000000000000000000001",
    "1001000100000001000000000000000000000000000000000000000000000001",
    "1100000000000001000000000000000000000000000000000000000000000001",
    "0100000000000001000000000000000000000000000000000000000000000001",
    "0000000100000000000000000000000000000000000000000000000000000001",
    "0101000000000001000000000000000000000000000000000000000000000000",
    "0101000000000000000000000000000100000000000000000000000000000001",
    "1000000100000001000000000000000100000000000000000000000000000001",
    "0000000100000001000000000000000000000000000000000000000000000001",
    "1000000000000000000000000000000100000000000000000000000000000000",
    "0001000000000001000000000000000100000000000000000000000000000001",
  ]

  let l1 =
    rc
    |> types.get(round)
    |> string.split("")
    |> list.map(types.from_string)

  let l2 =
    state
    |> to_list
    |> list.sized_chunk(64)
    |> types.get(0)

  let l1xorl2 = list.map2(l1, l2, types.xor)

  state
  |> to_list
  |> list.drop(64)
  |> list.append(l1xorl2, _)
  |> new
}

pub fn rho(state: State) -> State {
  let consts = [
    0, 1, 62, 28, 27, 36, 44, 6, 55, 20, 3, 10, 43, 25, 39, 41, 45, 15, 21, 8,
    18, 2, 61, 56, 14,
  ]

  state
  |> to_list
  |> list.sized_chunk(64)
  |> list.map(lane.new)
  |> list.map2(consts, fn(x, y) { lane.rotate_right(x, y) })
  |> list.map(lane.to_list)
  |> list.flatten
  |> new
}

// fn to_rows(state: State) -> List(Row) {

//   let process_group = fn (grp: List(Bit)) -> List(Row) {
//     let ls = list.sized_chunk(grp, 64)
//     let g = types.get
//     let l0 = g(ls,0)
//     let l1 = g(ls,1)
//     let l2 = g(ls,2)
//     let l3 = g(ls,3)
//     let l4 = g(ls,4)

//     list.range(0, 63)
//     |> list.map( fn(x) { [ g(l0,x), g(l0,x), ]  })
//   }

//   state
//   |> to_list
//   |> list.sized_chunk(64*5)
//   |> list.map( process_group )
//   |> list.flatten
// }

fn to_rows(state: State) -> List(Row) {
  state
  |> to_list
  |> list.sized_chunk(64)
  |> list.interleave
  |> list.sized_chunk(5)
  |> list.map(row.new)
}

// pub fn rows_to_cols(state: State, width: Int) -> List(Bit) {
//   let s = state
//   |> to_list
//   |> list.index_map(fn(x, i) { #(i, x) })

//   list.range(0, width-1)
//   |> fn(i) { list.map( list.filter(s, fn()) ) }
// }

// note: use list.window for theta

pub fn chi(state: State) -> State {
  state
  |> to_rows
  |> list.map(row.chi)
  |> list.map(row.to_list)
  |> list.flatten
  |> list.sized_chunk(25)
  |> list.interleave
  |> new
}

pub fn theta(state: State) -> State {
  state
  |> to_list
  |> list.index_map(fn(x, i) { #(i % 64, i / 64, x) })
  |> fn(s) { list.map(s, theta_step(s, _)) }
  |> new
}

type BitXY =
  #(Int, Int, Bit)

fn theta_step(state: List(BitXY), current: BitXY) -> Bit {
  let x = current.0
  let y = current.1

  let bs = [
    types.get_xy(state, 64, x, y).2,
    types.get_xy(state, 64, x, y + 4).2,
    types.get_xy(state, 64, x, y + 9).2,
    types.get_xy(state, 64, x, y + 14).2,
    types.get_xy(state, 64, x, y + 19).2,
    types.get_xy(state, 64, x, y + 24).2,
    types.get_xy(state, 64, x - 1, y + 1).2,
    types.get_xy(state, 64, x - 1, y + 6).2,
    types.get_xy(state, 64, x - 1, y + 11).2,
    types.get_xy(state, 64, x - 1, y + 16).2,
    types.get_xy(state, 64, x - 1, y + 21).2,
  ]

  bs
  |> list.fold(Zero, types.xor)
}
