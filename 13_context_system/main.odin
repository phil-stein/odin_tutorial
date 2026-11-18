package main

import     "core:fmt"
import     "core:log"
import     "base:runtime"
import str "core:strings"
import     "core:math/rand"
import     "core:debug/trace"


// this is the struct of the context variable, its defined in base:runtime
// Context :: struct {
// 	allocator:              Allocator,
// 	temp_allocator:         Allocator,
// 	assertion_failure_proc: Assertion_Failure_Proc,
// 	logger:                 Logger,
// 	random_generator:       Random_Generator,
// 	user_ptr:               rawptr,
// 	user_index:             int,
// 	// Internal use only
// 	_internal:              rawptr,
// }

data_t :: struct{
  i_00 : int,
  f_00 : f32,
  b_00 : bool,
}


main :: proc()
{
  fmt.println( "--- context system ---" )
  // the context is passed between functions implicitly
  // functions need speciall "c" or "contextless" attributes to not have a context
  // see no_context_proc()

  no_context_proc() // this function doesnt take a context

  fmt.println( "-- allocator --" )
  // the standard library functions use context.allocator, unless you pass a different allocator in
  // you can overwrite context.allocator to use a different allocator, see ..\16_debug\main.odin 

  str_00 := "hello there"
  str_01 := str.clone( str_00 )
  defer delete( str_01 )
  // no need to free str_02, see -- temp allocator --
  str_02 := str.clone( str_00, context.temp_allocator )

  fmt.println( "str_00:", str_00 )
  fmt.println( "str_01:", str_01 )
  fmt.println( "str_02:", str_02 )
  

  fmt.println( "-- temp allocator --" )
  // the temp_allocator is a arena allocator and gets freed in bulk
  // this means you can allocate as much as you want (sort of) 
  // and all your allocations remain solid until the next free_all(context.temp_allocator) call
  // this is a lot faster than using context.allocator so you should use it as much as possible
  // example for usage:
  //    in a game u could call free_all( context.temp_allocator ) after every frame, 
  //    so you know when alliocating a variable that if it doesnt persist between frames you can use the temp_allocator
  // also some standard library functions use the temp_allocator, see below
  
  // fmt.tprintf() allocates using the context.temp_allocator
  str_03 := fmt.tprintf( "hello there: %v", str_02 )
  fmt.println( "str_03:", str_03 )  // str_03: hello there: hello there

  fmt.println( "free_all( context.temp_allocator )" )
  free_all( context.temp_allocator )
  
  fmt.println( "str_03:", str_03 )  // str_03: 

  fmt.println( "-- logging --" )

  log.debug( "debug pre init logger" )
  log.info( "info pre init logger" )
  log.warn( "warning pre init logger" )
  log.error( "error pre init logger" )
	
  context.logger = log.create_console_logger()

  log.debug( "debug post init logger" )
  log.info( "info post init logger" )
  log.warn( "warning post init logger" )
  log.error( "error post init logger" )

  fmt.println( "-- data pointer --" )

  data : data_t
  fmt.println( "data:", data )

  context.user_ptr = &data

  context_user_ptr_proc()

  fmt.println( "data:", data )
  
  fmt.println( "-- random generator --" )

  fmt.println( "rand.float32():", rand.float32() )

  // doesnt actually change anything cause context.random_generator is already == runtime.default_random_generator()
  context.random_generator = runtime.default_random_generator()

  fmt.println( "rand.float32():", rand.float32() )
  
  fmt.println( "-- assertion failure proc --" )

  context.assertion_failure_proc = trace.assertion_failure_proc

  // uncomment to see effect
  assert( 0 == 1 )
}

context_user_ptr_proc :: proc()
{
  data : ^data_t = (^data_t)(context.user_ptr)
  fmt.println( "in context_user_ptr_proc()" )

  data.i_00 = 12345678
  data.f_00 = 1.2345678
  data.b_00 = true
}

no_context_proc :: proc "contextless" ()
{
  // cant call fmt.println() bc. no context
  context = runtime.default_context()
  // can call fmt.println() bc. we set context

  fmt.println( "hello from no_context_proc()" )

}
