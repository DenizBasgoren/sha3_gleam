# sha3

An implementation of SHA-3 cryptography algorithm in Gleam language.

```sh
git clone https://github.com/denizbasgoren/gleam_sha3
cd gleam_sha3
gleam run
```
```gleam
"Your input string goes here"
  |> types.utf8_to_bits
  |> sha3(types.Sha256)
  |> types.hash_to_hexstring(":")
  |> io.println
  // outputs "FB:AF:84:96:18:9F:8E:82:D3:BD:58:E4:96:67:B1:1D:D7:76:61:E0:D6:06:2A:4D:14:FD:01:C4:8B:C5:F0:C4"

  // for shake variants, output bit length is provided by the user
  "Another input string"
  |> types.utf8_to_bits
  |> sha3(types.Shake128(types.to_unsigned_int(200)))
  |> types.hash_to_hexstring(":")
  |> io.println
  // outputs "5B:79:B5:0E:E9:46:DA:B4:FF:1A:90:FD:F7:DB:43:63:B3:9F:EE:AE:1C:27:4D:7E:86"

  // the core algorithm works on lists of bits.
  [One, Zero, One, Zero, Zero]
  |> sha3(types.Sha224)
  |> types.hash_to_hexstring(":")
  |> io.println
  // outputs "6A:64:8A:72:C6:99:31:E5:1C:79:AD:4D:A0:B5:1B:A0:C3:E7:C3:2A:38:71:F4:72:3E:79:47:70"
```

## Important
This package is not intended to be used in production. This implementation is not fast, nor safe. I made this package to learn Gleam.