package main

import "core:fmt"


main :: proc()
{
  fmt.println( "--- functions ---" )

  no_args_no_return()

  i_00 := 12345
  args_no_return( i_00, 0.12345 )

  b_00 := args_single_return( 1234, 0.12345 )
  fmt.println( "b_00:", b_00 )  

  b_01 := args_single_named_return( 123, 1234.5 )
  fmt.println( "b_01:", b_01 )  

  b_02, i_01 := args_multiple_return( 123, 123.4 )
  fmt.println( "b_02:", b_02, "i_01:", i_01 )  

  b_03, i_02 := no_args_multiple_named_return()
  fmt.println( "b_03:", b_03, "i_02:", i_02 )  

  i_03 := variadic_args_of_specific_type( 1, 2, 3, 4, 5, 6, 7, 8, 9 )
  fmt.println( "i_03:", i_03 )

  variadic_args_of_any_type( 123, 0.1234, true, "string" )

  value : int = 0
  recursive_proc( &value )
}

no_args_no_return :: proc()
{
  // do stuff
  fmt.println( "called no_args_no_return()" )
}

args_no_return :: proc( arg_00: int, arg_01: f32 )
{
  // do stuff
  fmt.println( "called args_no_return()" )
}

args_single_return :: proc( arg_00: int, arg_01: f32  ) -> bool
{
  fmt.println( "called args_single_return()" )

  return f32(arg_00) > arg_01
}

args_single_named_return :: proc( arg_00: int, arg_01: f32  ) -> ( ret_name: bool)
{
  fmt.println( "called args_single_named_return()" )

  ret_name = f32(arg_00) > arg_01

  return  // auto returns ret_name
  // return ret_name -> also valid
}

args_multiple_return :: proc( arg_00: int, arg_01: f32  ) -> ( bool, int )
{
  fmt.println( "called args_multiple_return()" )

  b_00 := f32(arg_00) > arg_01
  
  i_00 := 10 + 1234

  return b_00, i_00
}

no_args_multiple_named_return :: proc() -> ( b_00: bool, i_00: int )
{
  fmt.println( "called no_args_multiple_named_return()" )

  b_00 = 0 < 123 
  
  i_00 = 10 + 1234

  return b_00, i_00
}

// variadic arguments means a variable amount of args
variadic_args_of_specific_type :: proc( args: ..int ) -> int
{
  fmt.println( "called variadic_args_of_specific_type()" )
  return_value : int

  // sums up all the given values
  for number in args
  {
    return_value += number
  }

  return return_value
}

variadic_args_of_any_type :: proc( args: ..any )
{
  fmt.println( "called variadic_args_of_any_type()" )

  for value in args
  {
    fmt.print( "value:", value, "| " )
  }
  fmt.println()
}

// recursive means function calls itself
// in this case it calls itself until arg is 10
// for pointer tutorial see ..\14_pointers\main.odin 
recursive_proc :: proc( arg: ^int )
{
  fmt.println( "called recursive_proc(), arg:", arg^ )

  if arg^ < 10
  {
    arg^ += 1
    recursive_proc( arg )
  }
  else 
  {
    fmt.println( "last call to recursive_proc()" )
  }
}
