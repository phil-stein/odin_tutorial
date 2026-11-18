package main

import     "core:fmt"
import     "core:os"
import str "core:strings"
import     "core:strconv"

data_shader_paths_t :: struct
{
  basic  : string,
  pbr    : string,
  screen : string,
}

data_t :: struct
{
  font_size     : f32, 
  frame_rate    : int,
  window_title  : string,
  vsync_enabled : bool,

  shader_paths : data_shader_paths_t,
}


main :: proc()
{
  fmt.println( "--- reading file from disk ---" )
  // --- reading file from disk ---
  
  path : string = "../assets/custom_00.format"
  f_data, err := os.read_entire_file_from_path( path, context.allocator )
  if err != nil 
  {
    fmt.println( "[ERROR] failed reading file at:", path )
    return
  }
  defer delete( f_data )
  txt : string = string(f_data) 
  fmt.println( "txt: --------------------------" )
  fmt.println( txt )
  fmt.println( "-------------------------------" )

  tokens := parse_string_to_tokens( &txt )

  for t, idx in tokens
  {
    fmt.println( "t[", idx, "]:", t, "t.val:", t.val )
  }

  data : data_t 
  fmt.println( "-------------------------------" )
  data_print( data )

  parse_tokens( &data, tokens )
  
  fmt.println( "-------------------------------" )
  data_print( data )

  // technically should free all the str.clone(), etc. here
  // but the operating system (windows), does it for us when the programm exits
  // so freeing here would only slow down the exit process 
  // if the program were to keep going at this point, we should free the data

}

data_print :: proc( d: data_t )
{
  fmt.println( "font_size",     d.font_size )
  fmt.println( "frame_rate",    d.frame_rate )
  fmt.println( "window_title",  d.window_title )
  fmt.println( "vsync_enabled", d.vsync_enabled )
  fmt.println( "shader_paths {" )
  fmt.println( "  basic",  d.shader_paths.basic )
  fmt.println( "  pbr",    d.shader_paths.pbr )
  fmt.println( "  screen", d.shader_paths.screen )
  fmt.println( "}" )
}

Tok_Type :: enum 
{
  Tok_Null,
  Tok_Square_Bracket_Open,
  Tok_Square_Bracket_Closed,
  Tok_Curly_Bracket_Open,
  Tok_Curly_Bracket_Closed,
  Tok_String, 
}
token_t :: struct
{
  type : Tok_Type,
  val : string,
}

parse_string_to_tokens :: proc( txt:  ^string ) -> [dynamic]token_t 
{
  ret : [dynamic]token_t

  str_builder :=  str.builder_make()

  skip_to_end_of_line : bool = false

  in_string : bool = false

  // for idx, r := range *txt {
  for r, idx in txt^
  {
    if skip_to_end_of_line 
    {
      if r == '\n' 
      {
        skip_to_end_of_line = false
      } 
      else 
      {
        continue
      }
    }

    if in_string 
    {
      if r == '"' 
      {
        in_string = false
        str_00 :  string = str.to_string( str_builder )
        append( &ret, token_t{ val=str.clone( str_00 ), type=.Tok_String } )
        str.builder_reset( &str_builder )
        fmt.println( "str_00:", str_00 )
        continue
      } 
      else if r == '\n' 
      {
        fmt.println( "[ERROR] string not terminalted via '\"' at end of line" )
        return ret
      }
      str.write_rune( &str_builder, r )
      continue
    }

    if str.is_space( r ) 
    {
      continue
    }

    if r == '/' && idx +1 < len(txt^) && (txt^)[idx +1] == '/' 
    {
      skip_to_end_of_line = true
      continue
    }

    if r == '"' 
    {
      in_string = true
      continue
    }
    else if r == '[' 
    {
      append( &ret, token_t{ val="[", type=.Tok_Square_Bracket_Open } )
    } 
    else if r == ']' 
    {
      append( &ret, token_t{ val="]", type=.Tok_Square_Bracket_Closed } )
    } 
    else if r == '{' 
    {
      append( &ret, token_t{ val="{", type=.Tok_Curly_Bracket_Open } )
    } 
    else if r == '}' 
    {
      append( &ret, token_t{ val="}", type=.Tok_Curly_Bracket_Closed } )
    }
    else // if r != ' ' && r != '\t' && r != '\n' 
    { 
      str.write_rune( &str_builder, r )
      if len(txt^) >= idx +1 
      {
        if !is_alpha_numeric_extra( rune((txt^)[idx +1]) ) || (txt^)[idx +1] == ']' 
        {
          str_00 : string = str.to_string( str_builder )
          append( &ret, token_t{ val=str.clone( str_00 ), type=.Tok_String } )
          str.builder_reset( &str_builder )
          fmt.println( "str_00:", str_00 )
        }
      }
    }
  }

  return ret
}

// checks if numeric aka. if r is 0-9
// or if r is alpha aka. a letter 65-90 and 97-122
// extra bc also allows '_' 
is_alpha_numeric_extra :: proc( r: rune ) -> bool 
{
  // look at https://www.ascii-code.com/
  // runes are technically utf8 but the first 127 runes are the same as ascii
  // 48 - 57 is numeric
  // 65 - 90 is upper case alpha
  // 97 - 122 is lower case alpha
  return ( r >= 48 && r <= 57 ) || ( r >= 65 && r <= 90 ) || ( r >= 97 && r <= 122 ) || ( r == '_' )
}

// replaced by str.is_space()
// // checks if space character
// // aka. space -> ' ', tab -> '\t', newline -> '\n', etc.
// func is_space( r rune ) bool {
//   return r <= 32
// }


parser_state_t :: struct 
{
  in_shader_paths : bool,
}

parse_tokens :: proc( data: ^data_t, tokens: [dynamic]token_t ) 
{
  parser_state : parser_state_t
  parser_state.in_shader_paths = false

  // for t, idx in tokens
  // for idx in 0..<len(tokens)
  for idx := 0; idx < len(tokens); idx += 1
  {
    t := tokens[idx]

    if t.type == .Tok_Curly_Bracket_Closed 
    {
      parser_state.in_shader_paths = false
      continue

    } // check if [ string ] string, bc. thats a variable assignment
    else if t.type == .Tok_Square_Bracket_Open && idx+3 < len(tokens) && 
       tokens[idx +1].type == .Tok_String && tokens[idx +2].type == .Tok_Square_Bracket_Closed &&
       tokens[idx +3].type == .Tok_String 
    {
      parse_tokens_parse_variable_name_value( data, &parser_state, tokens[idx +1].val, tokens[idx +3].val )
      idx += 3
      continue

    } else if t.type == .Tok_Square_Bracket_Open && idx+3 < len(tokens) && 
       tokens[idx +1].type == .Tok_String && tokens[idx +2].type == .Tok_Square_Bracket_Closed &&
       tokens[idx +3].type == .Tok_Curly_Bracket_Open 
    {
      parse_tokens_parse_struct_enter( data, &parser_state, tokens[idx +1].val  )
      idx += 3
      continue
    }
  }

}

parse_tokens_parse_struct_enter :: proc( data: ^data_t, parser_state: ^parser_state_t, var_name: string  ) 
{
  if var_name == "shader_paths"
  {
    (parser_state^).in_shader_paths = true
    return
  }
  else
  {
    fmt.println( "[ERROR] unknown struct:", var_name )
  }
}

parse_tokens_parse_variable_name_value :: proc( data: ^data_t, parser_state: ^parser_state_t, var_name: string, value: string ) 
{
  if var_name == "font_size" 
  {
    v, ok := strconv.parse_f32( value )
    if !ok
    {
      fmt.println( "[ERROR] parsing value for", var_name, ", value:", value )
      return
    }
    (data^).font_size = v
  } 
  else if var_name == "frame_rate"
  {
    v, ok := strconv.parse_int( value, 10 )
    if !ok
    {
      fmt.println( "[ERROR] parsing value for", var_name, ", value:", value )
      return
    }
    (data^).frame_rate = v
  } 
  else if var_name == "window_title"
  {
    (data^).window_title = str.clone(value) 
  } 
  else if var_name == "vsync_enabled"
  {
    v, ok := strconv.parse_bool( value )
    if !ok
    {
      fmt.println( "[ERROR] parsing value for", var_name, ", value:", value )
      return
    }
    (data^).vsync_enabled = v
  } 
  else if (parser_state^).in_shader_paths &&
            var_name == "basic"
  {
    (data^).shader_paths.basic = str.clone(value) 
  } 
  else if (parser_state^).in_shader_paths &&
            var_name == "pbr"
  {
    (data^).shader_paths.pbr = str.clone(value) 
  } 
  else if (parser_state^).in_shader_paths &&
            var_name == "screen"
  {
    (data^).shader_paths.screen = str.clone(value) 
  }
  else 
  {
    fmt.println( "[ERROR] unknown variable name:", var_name )
  }
}

