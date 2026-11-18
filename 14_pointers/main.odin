package main

import "core:fmt"

// --------------------------------------------------------
// pointers are super useful and way easier to understand 
// than people make them out to be
// hope this is a good explanaition lol
// --------------------------------------------------------

// a pointer is just a variable whose value 
// is the memory adress of another variable
// f.e. 
//    value   :  int = 10
//    pointer : ^int = &value
//    pointer^ += 1
// 
// ^type      -> its a pointer type
// &variable  -> makes a pointer to variable
// pointer^   -> dereferences the pointer, explained below

main :: proc()
{
  fmt.println( "--- pointers ---" )
  // --- pointers ---
  // pointers are all initially nil until you set them to be the adress of another variable
  // while there nil you cant dereference them or you will get a runtime exception
  ptr_00 : ^int 
  fmt.println( "ptr_00:", ptr_00, "- pointers are all initialized to be nil, aka 0 aka 0x0" )

  val_00 : int = 1234

  ptr_00 = &val_00  // ptr_00 now points to val_00
  fmt.println( "ptr_00 adress:", ptr_00 )

  fmt.println( "-- dereferencing --" )
  // -- dereferencing --
  // dereferencing means getting the value stored at the pointers location
  fmt.println( "ptr_00^:", ptr_00^ )  // this prints 1234, the value of val_00

  // this adds to the variable the pointer points to
  ptr_00^ += 1
  fmt.println( "ptr_00^:", ptr_00^ )  // this prints 1235, the value of val_00
  fmt.println( "val_00:", val_00 )  

  fmt.println( "-- function without pointers --" )
  val_01 : int = 10
  fmt.println( "val_01:", val_01, "<- pre function call" )  
  int_increment( val_01 )
  fmt.println( "val_01:", val_01, "<- post function call" )  
  
  // val_01 stays at 10 even though its incremented in the function
  // bc. only a copy was passed to the function not the exact variable 
  // if we instead pass a pointer we can manipulate val_01 all we want
   
  fmt.println( "-- function with pointers --" )
  fmt.println( "val_01:", val_01, "<- pre function call" )  
  int_increment_ptr( &val_01 )
  fmt.println( "val_01:", val_01, "<- post function call" )  


  fmt.println( "-- slices --" )

  slice_00 := []int{ 1, 2, 3, 4, 5 }
  slice_01 := slice_00
  fmt.println( "slice_00:", slice_00 )
  fmt.println( "slice_01:", slice_01 )
  slice_01[0] = 69
  fmt.println( "after -> slice_01[0] = 69" )
  fmt.println( "slice_00:", slice_00 )
  fmt.println( "slice_01:", slice_01 )

  // both slices now have [0] set to 69
  // this is bc. slices are just pointers to
  // underlying arrays

}

int_increment :: proc( val: int )
{
  val := val  // need to do this as a hack to convince odin to even do this cause the compiler knows it doesnt work
  val += 1
}
int_increment_ptr :: proc( val: ^int )
{
  val^ += 1
}

