package main

import "core:fmt"


main :: proc()
{
  fmt.println( "--- loops ---" )

  fmt.println( "-- \"while\" loop --" )

  run_loop := true
  for run_loop
  {
    if run_loop do run_loop = false
  }

  fmt.println( "-- break --" )
  // break exits out of the loop completely

  run_loop = true
  for run_loop
  {
    if run_loop do break
  }

  
  fmt.println( "-- range based for loop --" )

  for i in 0..<4
  {
    fmt.println( "i:", i )
  }
  for i in 0..=4
  {
    fmt.println( "i:", i )
  }
  
  fmt.println( "-- array - for loop --" )

  arr_00 := [?]int{ 123, 45, 67, 253, 5668, 907, 97 }

  for value in arr_00
  {
    fmt.println( "value:", value )
  }
  for value, idx in arr_00
  {
    fmt.println( "[", idx, "]", "value:", value )
  }

  fmt.println( "-- map - for loop --" )

  map_00 := make( map[string]f32 )
  map_00["member_length"] = 0.1
  map_00["IQ"] = 45.6789
  map_00["number"] = 123
  map_00["another number"] = 678

  for key, value in map_00
  {
    fmt.println( "key:", key, "value:", value )
  }

  fmt.println( "-- continue --" )
  // invoking the continue statement skips to the next iteration of the loop

  arr_01 := [?]int{ 1, 2, 3, 4, 5, 6, 7, 8 }

  for val in arr_01
  {
    if val < 6 do continue
    fmt.println( "val:", val )
  }
  
  fmt.println( "-- c-style for loop --" )
  // loops with a declare, run condition, and after loop expression

  for i := 0; i < 10; i += 1
  {
    fmt.println( "i:", i )
  }

  for j := 23; j < 33; j += 3
  {
    fmt.println( "j:", j )
  }

  for k := 6; k > 0; k -= 1
  {
    fmt.println( "k:", k )
  }

  // loop over array
  for idx := 0; idx < len(arr_01); idx += 1
  {
    fmt.println( "idx:", idx, "arr_01[idx]:", arr_01[idx] )
  }

  fmt.println( "-- #reverse --" )
  // the #reverse directive make the loop go from len(arr)-1 -> 0

  arr_02 := [?]int{ 1, 2, 3, 4, 5, 6, 7, 8 }

  #reverse for value in arr_02
  {
    fmt.println( "value:", value )
  }

}
