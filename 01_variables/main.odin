package main

import "core:fmt"


main :: proc() 
{
  fmt.println( "--- variables ---" )
  
  fmt.println( "-- no value --" )
  i_00 : int    // integer 64 bit
  f_00 : f32    // floating point 32 bit
  b_00 : bool   // boolean value
  fmt.println( "i_00:", i_00, "f_00:", f_00, "b_00:", b_00 )

  fmt.println( "-- with value --" )
  i_01 : int  = 10
  f_01 : f32  = 1.9753
  b_01 : bool = true
  fmt.println( "i_01:", i_01, "f_01:", f_01, "b_01:", b_01 )

  fmt.println( "-- type inferance --" ) // too lazy to google how its properly spelled sry
  i_02 := 10     // is int
  f_02 := 1.9753 // is f64 -> 64 bit floating point
  b_02 := true   // is bool
  fmt.println( "i_02:", i_02, typeid_of(type_of(i_02)), "f_02:", f_02, typeid_of(type_of(f_02)), "b_02:", b_02, typeid_of(type_of(b_02)) )

  fmt.println( "--- maths ---" )
  res_00 := 2 + i_02 // 12 -> add
  res_01 := i_02 - 2 // 8  -> subtract
  res_02 := 2 * i_02 // 20 -> times/multiply
  res_03 := i_02 / 2 // 5  -> divide
  res_04 := 2 % i_02 // 0  -> modulo aka. der rest von geteilt operation
  fmt.println( "res_00:", typeid_of(type_of(res_00)), "res_01:", typeid_of(type_of(res_01)), "res_02:", typeid_of(type_of(res_02)), "res_03:", typeid_of(type_of(res_03)), "res_04:", typeid_of(type_of(res_04)) )
  fmt.println( "res_00:", res_00, "res_01:", res_01, "res_02:", res_02, "res_03:", res_03, "res_04:", res_04 )

  fmt.println( "-- shorthands --" )
  res_05 := 10    // int
  res_05 += 2     // res_05: 12
  res_05 -= 2     // res_05: 10
  res_05 *= 2     // res_05: 20
  res_05 /= 2     // res_05: 10
  res_05 %= 3     // res_05: 1 -> 10/3 = 3 rest 1
  fmt.println( "res_05:", res_05 )

  fmt.println( "--- type conversion ---" )

  i_03 : int = 10
  f_03 : f32 = 1.23456
  f_04 : f32 = f_03 + f32(i_03) // convert int to f32
  i_04 : int = int(f_03) + i_03 // convert f32 to int -> !!! loses precision
  fmt.println( "i_03:", i_03, "f_03:", f_03, "f_04:", f_04, "i_04:", i_04 )

  fmt.println( "--- strings ---" )

  s_00 : string = "hello there"
  s_01 :=         "éèâäöüêÄÖ🌈"   // <- non ascii runes
  fmt.println( "s_00:", s_00, "s_01:", s_01 )
  fmt.println( "len(s_00):", len(s_00), "len(s_01):", len(s_01) )

  s_02 := `raw string literal`
  fmt.println( "s_02:", s_02, "type:", typeid_of(type_of(s_02)) )

  fmt.println( "-- multi-line strings --" )

  s_03 := """
  	Hellope,
  	  "World"!
  	"""
  assert(s_03 == "Hellope,\n  \"World\"!")
  fmt.println( "s_03:\n", s_03 )          // the '\n' rune is a newline character
  
  s_04 := ```
  	C:\Windows\notepad.exe
  	```
  assert(s_04 == `C:\Windows\notepad.exe`)
  fmt.println( "s_04:\n", s_04 )

  fmt.println( "-- runes --" )
  // rune is a single character, aka. letter, number, symbol or escape code
  // runes are utf8 encoded so you can use stuff like öüäéêâ🌈
  rune_00 : rune = 'a' 
  rune_01 := '_'
  rune_02 := '🌈' // <- non ascii character 
  fmt.println( "rune_00:", rune_00, "rune_01:", rune_01, "rune_02:", rune_02 )

  fmt.println( "--- booleans ---" )
  bool_00 : bool = true
  bool_01 := false
  fmt.println( "bool_00:", bool_00, "bool_01:", bool_01 )

  fmt.println( "-- logic operators --" )

  bool_02 := 0 == 1 // 0 is equal to one -> false
  bool_03 := 0 != 1 // 0 is not equal to one -> true
  bool_04 := 0 < 1  // 0 is less than one -> true
  bool_05 := 0 <= 1 // 0 is less than one or equal to one -> true
  bool_06 := 0 > 1  // 0 is more than one -> false
  bool_07 := 0 >= 1 // 0 is more than one or equal to one -> false
  fmt.println( "bool_02:", bool_02, "bool_03:", bool_03 "bool_04:", bool_04, "bool_05:", bool_05, "bool_06:", bool_06, "bool_07:", bool_07 )

  fmt.println( "--- default values ---" )
  // odin zeroes everything by default, bzw. len(string) == 0
  default_int_00    : int
  default_i8_00     : i8 
  default_i16_00    : i16 
  default_i32_00    : i32 
  default_i64_00    : i64 
  fmt.println( "default_int_00:", default_int_00, "default_i8_00:", default_i8_00, "default_i16_00:", default_i16_00, "default_i32_00:", default_i32_00, "default_i64_00:", default_i64_00 )

  default_uint_00   : uint
  default_u8_00     : u8 
  default_u16_00    : u16 
  default_u32_00    : u32 
  default_u64_00    : u64 
  fmt.println( "default_uint_00:", default_uint_00, "default_u8_00:", default_u8_00, "default_u16_00:", default_u16_00, "default_u32_00:", default_u32_00, "default_u64_00:", default_u64_00 )

  default_f32_00    : f32
  default_f64_00    : f64
  fmt.println( "default_f32_00:", default_f32_00, "default_f64_00:", default_f64_00 )

  default_bool_00   : bool
  fmt.println( "default_bool_00:", default_bool_00 )

  default_string_00 : string
  fmt.println( "default_string_00:", default_string_00)


  fmt.println( "--- constants ---" )
  // constants are variables that cannot be changed during the runtime of the programm

  const_int_00    :: 123456
  const_f64_00    :: 1.23456
  const_bool_00   :: true
  const_string_00 :: "hello there"
  fmt.println( "const_int_00:", const_int_00, "const_f64_00:", const_f64_00, "const_bool_00:", const_bool_00, "const_string_00:", const_string_00 )



}
