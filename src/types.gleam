import gleam/bit_array
import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub type Sha3Flavor {
  Sha224
  Sha256
  Sha384
  Sha512
  Shake128(d: UnsignedInt)
  Shake256(d: UnsignedInt)
}

pub type Bit {
  Zero
  One
}

pub fn xor(a: Bit, b: Bit) -> Bit {
  case a, b {
    Zero, Zero -> Zero
    Zero, One -> One
    One, Zero -> One
    One, One -> Zero
  }
}

pub fn and(a: Bit, b: Bit) -> Bit {
  case a, b {
    Zero, Zero -> Zero
    Zero, One -> Zero
    One, Zero -> Zero
    One, One -> One
  }
}

pub fn not(a: Bit) -> Bit {
  case a {
    Zero -> One
    One -> Zero
  }
}

pub fn from_string(s: String) -> Bit {
  case s {
    "0" -> Zero
    "1" -> One
    _ -> panic as "Huh"
  }
}

pub fn to_string(b: Bit) -> String {
  case b {
    Zero -> "0"
    One -> "1"
  }
}

pub fn to_listbits(str: String) -> List(Bit) {
  str
  |> string.split("")
  |> list.filter_map(fn(x) {
    case x {
      "0" -> Ok(Zero)
      "1" -> Ok(One)
      _ -> Error(0)
    }
  })
}

pub fn hash_to_hexstring(b: List(Bit), separator: String) -> String {
  b
  |> list.sized_chunk(8)
  |> list.map(list.reverse)
  |> list.map(byte_to_hexstring)
  |> string.join(separator)
}

pub fn utf8_to_bits(str: String) -> List(Bit) {
  str
  |> bit_array.from_string
  |> bit_array.base16_encode
  |> string.split("")
  |> list.sized_chunk(2)
  |> list.map(fn(x) { string.join(x, "") })
  |> list.map(hexstring_to_byte)
  |> list.map(list.reverse)
  |> list.flatten
}

// [0,0,1,0, 1,1,1,1] -> "2F"
pub fn byte_to_hexstring(byte: List(Bit)) -> String {
  byte
  |> list.sized_chunk(4)
  |> list.map(fn(nb) {
    case nb {
      [Zero, Zero, Zero, Zero] -> "0"
      [Zero, Zero, Zero, One] -> "1"
      [Zero, Zero, One, Zero] -> "2"
      [Zero, Zero, One, One] -> "3"
      [Zero, One, Zero, Zero] -> "4"
      [Zero, One, Zero, One] -> "5"
      [Zero, One, One, Zero] -> "6"
      [Zero, One, One, One] -> "7"
      [One, Zero, Zero, Zero] -> "8"
      [One, Zero, Zero, One] -> "9"
      [One, Zero, One, Zero] -> "A"
      [One, Zero, One, One] -> "B"
      [One, One, Zero, Zero] -> "C"
      [One, One, Zero, One] -> "D"
      [One, One, One, Zero] -> "E"
      [One, One, One, One] -> "F"
      _ -> "?"
    }
  })
  |> string.join("")
}

// "2F" -> [0,0,1,0, 1,1,1,1]
pub fn hexstring_to_byte(hex: String) -> List(Bit) {
  hex
  |> string.split("")
  |> list.map(fn(nb) {
    case nb {
      "0" -> [Zero, Zero, Zero, Zero]
      "1" -> [Zero, Zero, Zero, One]
      "2" -> [Zero, Zero, One, Zero]
      "3" -> [Zero, Zero, One, One]
      "4" -> [Zero, One, Zero, Zero]
      "5" -> [Zero, One, Zero, One]
      "6" -> [Zero, One, One, Zero]
      "7" -> [Zero, One, One, One]
      "8" -> [One, Zero, Zero, Zero]
      "9" -> [One, Zero, Zero, One]
      "A" | "a" -> [One, Zero, One, Zero]
      "B" | "b" -> [One, Zero, One, One]
      "C" | "c" -> [One, One, Zero, Zero]
      "D" | "d" -> [One, One, Zero, One]
      "E" | "e" -> [One, One, One, Zero]
      "F" | "f" -> [One, One, One, One]
      _ -> panic as "Not allowed"
    }
  })
  |> list.flatten
}

pub opaque type UnsignedInt {
  UnsignedInt(inner: Int)
}

pub fn to_unsigned_int(from: Int) -> UnsignedInt {
  case from {
    x if x >= 0 -> UnsignedInt(x)
    _ -> panic as "must be convertible to unsigned int"
  }
}

pub fn to_int(from: UnsignedInt) -> Int {
  from.inner
}

pub fn rate(flavor: Sha3Flavor) -> Int {
  case flavor {
    Sha224 -> 1152
    Sha256 -> 1088
    Sha384 -> 832
    Sha512 -> 576
    Shake128(_) -> 1344
    Shake256(_) -> 1088
  }
}

pub fn output_length(flavor: Sha3Flavor) -> Int {
  case flavor {
    Sha224 -> 224
    Sha256 -> 256
    Sha384 -> 384
    Sha512 -> 512
    Shake128(d) -> to_int(d)
    Shake256(d) -> to_int(d)
  }
}

pub fn get(l: List(a), n: Int) -> a {
  let out =
    l
    |> list.drop(n)
    |> list.take(1)

  case out {
    [x] -> x
    _ -> panic as "Huh"
  }
}

pub fn get_xy(l: List(a), width: Int, x: Int, y: Int) -> a {
  let height = list.length(l) / width
  let x = int.modulo(x, width) |> result.unwrap(0)
  let y = int.modulo(y, height) |> result.unwrap(0)

  l
  |> list.sized_chunk(width)
  |> get(y)
  |> get(x)
}
