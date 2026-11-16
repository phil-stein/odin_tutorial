package main

import "core:fmt"
import "core:log"
import "core:debug/trace"

main :: proc()
{
  fmt.println( "--- debugging ---" )

  fmt.println( "-- tracking allocator --" )
  
  fmt.println( "-- logging --" )
  
  fmt.println( "-- stack trace --" )

}
