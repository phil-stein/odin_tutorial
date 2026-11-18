package main

import     "core:os"
import     "core:fmt"
import     "core:log"
import     "core:time"
import str "core:strings"
import     "base:runtime"
import     "core:debug/trace"
import     "core:terminal/ansi"

main :: proc()
{
  fmt.println( "--- debugging ---" )
  // using -debug on odin command to set debug build
  // f.e. `odin run . -debug`

  // code inside this statement only executes when were running in debug mode
  when ODIN_DEBUG 
  {
    fmt.println( "running in debug mode" )
  }

  fmt.println( "-- tracking allocator --" )

  track: trace.Tracking_Allocator
  trace.tracking_allocator_init(&track, context.allocator)
	context.allocator = trace.tracking_allocator(&track)
	defer trace.tracking_allocator_destroy(&track)
	defer trace.tracking_allocator_print_results(&track)

  str_00 := fmt.aprint( "hello there :)" )  // allocates using context.allocator
  // for demonstartion purposes were not gonna free
  // defer delete(str_00)
  
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

  fmt.println( "-- asssertion failure proc --" )
  
  // uncomment to see normal assertion failure proc
  // assert( 0 == 1 )
  // C:/workspace/odin/odin_tutorial/16_debug/main.odin(48:3) runtime assertion: 0 == 1

  context.assertion_failure_proc = trace.assertion_failure_proc
  
  // uncomment to see effect
  // assert( 0 == 1 )
  // [back trace]
  //         #0 runtime::assert.internal-0 at C:\odin\base\runtime\core_builtin.odin(1678)
  //         #1 runtime::assert at C:\odin\base\runtime\core_builtin.odin(1680)
  //         #2 main::main at C:\workspace\odin\odin_tutorial\16_debug\main.odin(55)
  //         #3 main at C:\odin\base\runtime\entry_windows.odin(77)
  //         #4 __scrt_common_main_seh at D:\a\_work\1\s\src\vctools\crt\vcsartup\src\startup\exe_common.inl(288)
  //         #5 BaseThreadInitThunk at 0x7ff8b15bdda6
  //         #6 RtlUserThreadStart at 0x7ff8b29b9c5b
  // C:/workspace/odin/odin_tutorial/16_debug/main.odin(55:3) runtime assertion: 0 == 1
  
  fmt.println( "-- stack trace --" )

  capture := trace.capture()
	locations, err := trace.resolve(capture)
	if err != nil {
		fmt.eprintfln("trace error: %v", err)
		return
	}
	defer trace.locations_destroy(locations)
	trace.print(locations)

  fmt.println( "-- other failure conditions --" )

  arr_00 := [?]int{ 1, 2, 3, 4, 5 }
  idx_00 := 5
  arr_00[idx_00] = 10
  // -> C:/workspace/odin/odin_tutorial/16_debug/main.odin(71:10) Index 5 is outof range 0..<5

}


