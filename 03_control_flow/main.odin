package main

import "core:fmt"

main :: proc()
{
  fmt.println( "--- control flow ---" )
  
  fmt.println( "-- if statements --" )

  x := 0
  y := 1

  // single line and single command if statement 
  if x == y do fmt.println( "x == y" )

  if x == y // equal to
  {
    fmt.println( "x == y" )
  }

  if x != y // not equal to
  {
    fmt.println( "x != y" )
  }
  else  
  {
    fmt.println( "x == y" )
  }

  if x < y  // less than
  {
    fmt.println( "x < y" )
  }
  else if x <= y  // less than or equals 
  {
    fmt.println( "x <= y" )
  }
  else if x > y   // more than
  {
    fmt.println( "x > y" )
  }
  else if x >= y  // more than or equals 
  {
    fmt.println( "x >= y" )
  }
  else 
  {
    fmt.println( "idk man" )
  }

  fmt.println( "-- switch statements --" )

  fmt.println( "- switch with no args -" ) 
  switch {
    case x == 0:
      fmt.println( "x == 0" )
    case x != 0:
      fmt.println( "x != 0" )
    case:
      fmt.println( "no case was true, in this case imposible" )
  }

  fmt.println( "- switch with args -" ) 
  switch x {
    case 0:
      fmt.println( "x == 0" )
    case 1:
      fmt.println( "x == 1" )
    case:
      fmt.println( "no case was true, x isnt 0 or 1" )
  }

  fmt.println( "- switch with declare -" ) 
  switch arch := ODIN_ARCH; arch {
    case .i386, .wasm32, .arm32:
    	fmt.println("32 bit")
    case .amd64, .wasm64p32, .arm64, .riscv64:
    	fmt.println("64 bit")
    case .Unknown:
    	fmt.println("Unknown architecture")
  }

}
