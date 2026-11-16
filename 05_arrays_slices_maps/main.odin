package main

import "core:fmt"


main :: proc()
{
  fmt.println( "--- arrays ---" )

  fmt.println( "-- declare --" )
  arr_i_00 :  [10]int
  arr_i_01 := [8]int{ 1, 2, 3, 4, 5, 6, 7, 8 }  // len(arr_i_01) -> 8
  arr_i_02 := [?]int{ 1, 2, 3, 4, 5, 6, 7, 8 }  // len(arr_i_01) -> 8, ? auto calculates the length of the array literal
  const_arr_i_00 :: [?]int{ 1, 2, 3, 4, 5, 6 }

  fmt.println( "arr_i_00:", arr_i_00, "len(arr_i_00):", len(arr_i_00) )
  fmt.println( "arr_i_01:", arr_i_01, "len(arr_i_01):", len(arr_i_01) )
  fmt.println( "arr_i_02:", arr_i_02, "len(arr_i_02):", len(arr_i_02) )
  fmt.println( "const_arr_i_00:", const_arr_i_00, "len(const_arr_i_00):", len(const_arr_i_00) )

  fmt.println( "-- access --" )
  // because len(arr_i_00) -> 10
  // the first element always is 0
  // the last element is len(arr_i_00) -1 -> 9
  // accessing a len(arr): 10 array with 10 aka. arr[len(arr)] causes a crash bc. 10 is outside 0-9

  arr_i_00[0] = 0
  arr_i_00[1] = 1
  arr_i_00[2] = 2
  arr_i_00[3] = 3
  arr_i_00[4] = 4
  arr_i_00[5] = 5
  arr_i_00[6] = 6
  arr_i_00[7] = 7
  arr_i_00[8] = 8
  arr_i_00[9] = 9
  fmt.println( "arr_i_00:", arr_i_00 )

  fmt.println( "--- slices ---" )
  // slices are excerpts out of arrays, under the hood they are just pointers, with a length value
  // you create them using the arr[start:end] syntax
  // start is inclusive, but end is exclusive 
  // bc. end is exclusive setting it to len(arr) is valid

  slice_i_00 : []int  // slice types dont have number or ? in their square brackets ( [] )
  fmt.println( "slice_i_00:", slice_i_00 )

  slice_i_01 := arr_i_01[0:3]
  fmt.println( "slice_i_01:", slice_i_01 )

  // this creates a slice of the whole array
  slice_i_02 := arr_i_00[0:len(arr_i_00)]
  fmt.println( "slice_i_02:", slice_i_02 )

  fmt.println( "-- shorthands --" )

  slice_i_03 := arr_i_00[:3]    // arr[:end] is equal to arr[0:end]
  assert( len(slice_i_03) == len(slice_i_01) )
  fmt.println( "slice_i_03:", slice_i_03 )

  slice_i_04 := arr_i_00[:]    // arr[:] is equal to arr[0:len(arr)], aka. the entire array
  assert( len(slice_i_04) == len(slice_i_02) )
  fmt.println( "slice_i_04:", slice_i_04 )

  slice_i_05 := arr_i_00[3:]    // arr[start:] is equal to arr[start:len(arr)]
  fmt.println( "slice_i_05:", slice_i_05 )


  fmt.println( "--- maps ---" )
  // maps store value & key pairs, using the key you can get back the value
  // value & key dont need to be the same type 
	
  // make allocates so we have to delete/free the memory once we no longer need it
  map_00 := make(map[string]int)
	defer delete(map_00) // defer statement executes the function call after it at the end of a scope, in this case the scope is the proc main

	map_00["Alice"] = 1
	map_00["Bob"] = 2

	fmt.println( "map_00[\"Alice\"]:", map_00["Alice"] )
	fmt.println( "map_00[\"Bob\"]:", map_00["Bob"] )
  fmt.println( "map_00:", map_00 )
  fmt.println( "len(map_00):", len(map_00) )
	
  // check if a key exists for a map
	alice_exists := "Alice" in map_00
  fmt.println( "alice_exists:", alice_exists )
	
  // remove a value associated with a key
	deleted_key, deleted_value := delete_key(&map_00, "Alice")
  fmt.println( "deleted_key:", deleted_key, "deleted_value:", deleted_value )

  // check if a key exists for a map
	alice_exists = "Alice" in map_00
  fmt.println( "alice_exists:", alice_exists )
	
  // empty the whole map using clear()
	clear(&map_00)
  fmt.println( "after clear() len(map_00):", len(map_00) )

  // you can use arbitrary types for maps, even structs (which will be explained in a following section) 
  map_01 := make( map[int]bool )
  defer delete( map_01 ) // see above for defer explanation

  fmt.println( "map_01:", map_01 )
  map_01[0] = false
  map_01[1] = true
  fmt.println( "map_01:", map_01 )
  
}
