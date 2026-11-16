package main


import     "core:os"        // os.read() -> read console input
import     "core:fmt"
import str "core:strings"   // package renamed to str instead of strings
import     "core:math/rand" // rand.float32() -> random number between 0-1 


main :: proc()
{

  MAX_QUESTIONS :: 3
  q : int = int( rand.float32() * f32(MAX_QUESTIONS) )

  if q == 0 
  {
    fmt.println( "[0] whats the capital of germany ?" )
  } 
  else if q == 1
  {
    fmt.println( "[1] whats 2 * 4 + 8 ?" )
  } 
  else if q == 2
  {
    fmt.println( "[2] whats H on the periodic table ?" )
  } 
  else 
  {
    fmt.println( "[ERROR] q:", q, "is bigger than the amount of questions !!!" ) 
  }

  // read input from command line 
  fmt.print( "Enter Answer:" )
	buf: [256]byte
	n, err := os.read(os.stdin, buf[:])
	if err != nil 
  {
		fmt.eprintln( "[ERROR] reading: ", err )
		return
	}
	answer := string(buf[:n])
	// fmt.printfln( "answer: \"%v\"", answer )

  answer_correct := false
  switch q 
  {
    case 0: answer_correct = str.contains( answer, "berlin") || str.contains( answer, "Berlin" ) || str.contains( answer, "BERLIN" )
    case 1: answer_correct = str.contains( answer, "16" )
    case 2: answer_correct = str.contains( answer, "hydrogen" ) || str.contains( answer, "Hydrogen" ) || str.contains( answer, "HYDROGEN" )
    case: fmt.println( "[ERROR] q:", q, "is bigger than the amount of questions !!!" ) 
  }

  fmt.println( "answer_correct:", answer_correct )

}
