package main


import     "core:os"
import     "core:fmt"
import str "core:strings" // renamed strings package to str
import     "core:math/rand" // rand.float32() -> random number between 0-1 


main :: proc()
{
  questions_arr := [?]string{ "whats the capital of germany ?", "whats 2 * 4 + 8 ?", "whats H on the periodic table ?", "whats the name of this programming language ?", "whats the maximum value of uint8 ?", "whats the maximum value of int8 ?", "whats the minimum value of int8 ?" }
  answers_arr   := [?]string{ "berlin", "16", "hydrogen", "go", "255", "127", "-128" }

  if len(questions_arr) != len(answers_arr) 
  {
    fmt.println( "[ERROR] questions and answers arrays are different length !!!" )
    return
  }
  q_idx : int = int( rand.float32() * f32(len(questions_arr)) )

  fmt.println( "answers all lower case !!!" )

  fmt.printf( "[%v] %v\n", q_idx, questions_arr[q_idx] )

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

  answer_correct : bool = str.contains( answer, answers_arr[q_idx] )
  fmt.println( "answer_correct:", answer_correct )

  if !answer_correct 
  {
    fmt.println( "answer is:", answers_arr[q_idx] )
  }

}
