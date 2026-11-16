package main

import     "core:fmt"
import str "core:strings" // rename package on import to str instead of strings
import     "core:unicode/utf8"

main :: proc()
{
  fmt.println( "--- strings ---" )

  fmt.println( "-- string escape codes --" )

  str_escape_codes_01 := "hello\nthere\\\"quotation marks\"\ttab" // '\n' -> new line, '\\' -> \, '\"' -> ", '\t' -> tab
  fmt.println( "str_escape_codes_01:", str_escape_codes_01 )

  fmt.println( "-- constant strings --" )

  const_str_00 :: "hello"
  const_str_01 :: "there"
  const_str_02 :: const_str_00 + " " + const_str_01   // only constant strings can be '+' concatenated
  fmt.println( "const_str_00:", const_str_00 )
  fmt.println( "const_str_01:", const_str_01 )
  fmt.println( "const_str_02:", const_str_02 )

  fmt.println( "-- comparison --" )

  str_00 := "hello"
  str_01 := "there"

  if str_00 == "hello"
  {
    fmt.println( "str_00 == \"hello\"" )
  }
  else if str_00 == str_01
  {
    fmt.println( "str_00 == str_01" )
  }

  if str.contains( str_00, "hell" )   // checks if given string is contained anwhere in str_00, "'hell'o"
  {
    fmt.println( "found \"hell\" inside str_00" )
  }

	is_equal := str.compare( str_00, str_01 )

	if is_equal == 0 
  {
		fmt.println("The names match!")
	} 
  else 
  {
		fmt.println("The names do not match!")
  }

  fmt.println( "-- concatenation --" )

  str_02 := "massive"
  str_03 := "dingdong"

  str_04 := str.concatenate( []string{ str_02, str_03 } )
  defer delete( str_04 )  // bc. str.contatenate() allocates we need to free the result

  str_05, err_00 := str.concatenate( []string{ str_02, " ", str_03 } )  // handle the optional allocation error
  if err_00 != nil
  {
    fmt.println( "[ERROR] in concatenation" )
    return
  }
  defer delete( str_05 )  // bc. str.contatenate() allocates we need to free the result

  fmt.println( "str_02:", str_02 )
  fmt.println( "str_03:", str_03 )
  fmt.println( "str_04:", str_04 )
  fmt.println( "str_05:", str_05 )

  fmt.println( "-- cstring --" )
  // cstring is a null-termianted string, without a length variable, its meant to be used when interoperating wit c

  cstr_00 : cstring = "message here"
  str_06  : string  = string(cstr_00)   // <- from cstring to string
  str_07  : string  = "originally string"
  cstr_01 : cstring = str.clone_to_cstring( str_07 )  // <- from string to cstring
  defer delete( cstr_01 ) // str.clone_to_cstring() allocates so we need to free using delete()

  fmt.println( "cstr_00:", cstr_00 )
  fmt.println( "str_06:", str_06 )
  fmt.println( "str_07:", str_07 )
  fmt.println( "cstr_01:", cstr_01 )

  fmt.println( "-- string builder --" )
  // string builder allows careful construction of strings, much faster than doing it using str.concatenate()

  sb : str.Builder = str.builder_make()

  str.write_string( &sb, "hi" )
  str.write_string( &sb, " " )
  str.write_string( &sb, "there" )
  str.write_rune( &sb, ' ' )
  str.write_rune( &sb, '😊' )

  str_08 := str.clone( str.to_string( sb ) )  // need to clone as the return value of str.to_string() is just a "pointer" to the buffer in sb
  defer delete( str_08 )  // str.clone() sllocates so we need to free the memory
  
  str.builder_reset( &sb )  // reset the contents of the string builder without destroying it

  str.write_string( &sb, "whats" )
  str.write_string( &sb, " " )
  str.write_string( &sb, "up" )

  str_09 := str.to_string( sb )

  str.builder_destroy( &sb )  // "free's" the memory of the string builder

  fmt.println( "str_08:", str_08 )
  fmt.println( "str_09:", str_09 )


  fmt.println( "--- runes ---" )
  // runes are utf8 characters so they can be letters, number, symbols, letters of non latin alphabets, emoji, etc.

  r_00 : rune = 'a' // simple letter
  r_01 := '🌈'      // emoji
  r_02 := 'ॐ'       // sanskrit character

  fmt.println( "r_00:", r_00 )
  fmt.println( "r_01:", r_01 )
  fmt.println( "r_02:", r_02 )

  fmt.println( "-- arrays of runes --" )

  r_arr_00 := [?]rune{ 'â', 'b', 'c', 'ॐ', '🌈', '&', ' ', 'h', 'e', 'l', 'l', 'o' }

  for r in r_arr_00
  {
    fmt.print( r )
  }
  fmt.println()

  str_10, err_01 := utf8.runes_to_string( r_arr_00[:] ) // arguemnt takes a slice, not an array so we need to use the [:] operator
  if err_01 != nil
  {
    fmt.println( "[ERROR] copying runes to string, err:", err_01 )
  }
  defer delete( str_10 )  // utf8.runes_to_string() allocates so we need to free the return value

  fmt.println( "str_10:", str_10 )

}
