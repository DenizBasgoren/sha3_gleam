import gleam/io
import gleam/list
import input_block.{type InputBlock}
import state.{type State}
import types.{
  type Bit, type Sha3Flavor, One, Sha224, Sha256, Sha384, Sha512, Shake128,
  Shake256, Zero,
}

pub fn main() {
  "Your input string goes here"
  |> types.utf8_to_bits
  |> sha3(types.Sha256)
  |> types.hash_to_hexstring(":")
  |> io.println

  // for shake variants, output bit length is provided by the user
  "Another input string"
  |> types.utf8_to_bits
  |> sha3(types.Shake128(types.to_unsigned_int(200)))
  |> types.hash_to_hexstring(":")
  |> io.println

  // the core algorithm works on lists of bits.
  [One, Zero, One, Zero, Zero]
  |> sha3(types.Sha224)
  |> types.hash_to_hexstring(":")
  |> io.println
}

fn is_shake(flavor: Sha3Flavor) -> Bool {
  case flavor {
    Sha224 -> False
    Sha256 -> False
    Sha384 -> False
    Sha512 -> False
    Shake128(_) -> True
    Shake256(_) -> True
  }
}

fn how_many_zeros_to_pad_with(input_bits_len: Int, flavor: Sha3Flavor) -> Int {
  let a = case is_shake(flavor) {
    True -> 4
    False -> 2
  }

  let r = types.rate(flavor)
  let sum = input_bits_len + 2 + a
  case sum % r {
    0 -> 0
    other -> r - other
  }
}

pub fn add_padding(input_bits: List(Bit), flavor: Sha3Flavor) -> List(Bit) {
  let n = how_many_zeros_to_pad_with(list.length(input_bits), flavor)
  let zeros = list.repeat(Zero, n)

  let a = case is_shake(flavor) {
    True -> [One, One, One, One]
    False -> [Zero, One]
  }

  input_bits
  |> list.append(a)
  |> list.append([One])
  |> list.append(zeros)
  |> list.append([One])
}

pub fn split_to_input_blocks(
  padded_input_bits: List(Bit),
  flavor: Sha3Flavor,
) -> List(InputBlock) {
  padded_input_bits
  |> list.sized_chunk(types.rate(flavor))
  |> list.map(input_block.new(_, flavor))
}

fn xor(ib: InputBlock, state: State) -> State {
  let ib = input_block.to_list(ib)
  let state = state.to_list(state)
  let n_zeros = 1600 - list.length(ib)
  // 1600-rate=capacity

  ib
  |> list.append(list.repeat(Zero, n_zeros))
  |> list.map2(state, types.xor)
  |> state.new
}

fn block_transform(state: State) -> State {
  list.range(0, 23)
  |> list.fold(state, fn(acc, round) {
    acc
    |> state.theta
    |> state.rho
    |> state.pi
    |> state.chi
    |> state.iota(round)
  })
}

pub fn sha3(input: List(Bit), flavor: Sha3Flavor) -> List(Bit) {
  input
  |> add_padding(flavor)
  |> split_to_input_blocks(flavor)
  |> list.fold(state.blank(), fn(state, ib) {
    xor(ib, state)
    |> block_transform
  })
  |> output_stage(flavor)
}

fn output_stage(state: State, flavor: Sha3Flavor) -> List(Bit) {
  let res = do_output_stage(state, [], flavor)
  let trgt_len = types.output_length(flavor)
  list.take(res, trgt_len)
}

fn do_output_stage(
  state: State,
  output: List(Bit),
  flavor: Sha3Flavor,
) -> List(Bit) {
  let trgt_len = types.output_length(flavor)

  case list.length(output) < trgt_len {
    False -> output
    True ->
      do_output_stage(
        block_transform(state),
        state
          |> state.to_list
          |> fn(s) { list.append(output, list.take(s, types.rate(flavor))) },
        flavor,
      )
  }
}
