package main

import "core:fmt"


Example_Type :: enum
{
  First,
  Hello,
  Another,
  Last,
}

main :: proc()
{
  fmt.println( "--- enums ---" )

  enum_00 : Example_Type = .First
  enum_01 := Example_Type.Hello

  fmt.println( "enum_00:", enum_00 )
  fmt.println( "enum_01:", enum_01 )

  // printing with complete type
  fmt.println( "enum_00: ", typeid_of(type_of(enum_00)), ".", enum_00, sep="" ) // sep="", means the seperator is set to "" instead of " "

  fmt.println( "-- switch statements --" )
  // switch statements on enums must handle all cases or be marked #partial

  switch enum_00
  {
    case .First:   fmt.println( "enum_00 is .First" )
    case .Hello:   fmt.println( "enum_00 is .Hello" )
    case .Another: fmt.println( "enum_00 is .Another" )
    case .Last:    fmt.println( "enum_00 is .Last" )
  }
  // only use #partial switch statements during prototyping and even then i recommend just using normal switch statements
  #partial switch enum_01
  {
    case .First: fmt.println( "enum_01 is .First" )
    case .Hello: fmt.println( "enum_01 is .Hello" )
    case:        fmt.println( "enum_01 isnt .First or .Hello" )
  }
}
