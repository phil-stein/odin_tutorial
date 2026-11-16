package main

import    "core:fmt"
import    "core:math/rand"
import rl "vendor:raylib"

main :: proc() 
{
  // --- game state ---
  current_score   := 0
  font_size_main  :: 30
  font_size_score :: 60
  window_width    :: 1200
  window_height   :: 800

  rl.InitWindow(i32(window_width), i32(window_height), "falling cubes game window title")
  // defer puts function call at the end of the scope, in this case the proc main
  defer rl.CloseWindow()

  rl.SetTargetFPS(60)

  // --- sphere ---
  sphere_speed  :: 400
  sphere_radius :: 30.0
  sphere_pos_x : int = int(sphere_radius) 
  sphere_pos_y : int = window_height

  // --- cube ---
  cube_size  :: 150
  cube_speed :: 400
  cube_pos_y :: window_height - cube_size
  cube_pos_x := window_width / 2 - ( cube_size / 2 )

  for !rl.WindowShouldClose() 
  {
    rl.BeginDrawing()

    rl.ClearBackground( rl.RAYWHITE )

    // --- sphere logic ---

    // move sphere down at sphere_speed * delta_t, framerate independant
    sphere_pos_y += int( f32(sphere_speed) * rl.GetFrameTime() )

    // check if sphere reached the bottom and reset its position
    if sphere_pos_y >= window_height - int(sphere_radius) 
    {
      // check if sphere was in cube
      if sphere_pos_x >= cube_pos_x &&
         sphere_pos_x <= cube_pos_x + cube_size {
        current_score += 1
      }

      // reset y position back to top
      sphere_pos_y = 0
      // rng the sphere pos x
      sphere_pos_x = int( rand.float32() * f32(window_width) )

      // clamp between sphere_radius and window_width - sphere_radius
      if sphere_pos_x < int(sphere_radius)
      {
        sphere_pos_x = int(sphere_radius)
      } 
      else if sphere_pos_x > int(f32(window_width) - sphere_radius)
      {
        sphere_pos_x = int(f32(window_width) - sphere_radius)
      }
    }

    // --- cube logic ---

    // check keyboard input
    if rl.IsKeyDown( .RIGHT ) 
    {
      cube_pos_x += int( f32(cube_speed) * rl.GetFrameTime() )
    }
    else if rl.IsKeyDown( .LEFT ) 
    {
      cube_pos_x -= int( f32(cube_speed) * rl.GetFrameTime() )
    }
    // clamp to 0 - window_width
    if cube_pos_x < 0 
    {
      cube_pos_x = 0
    } 
    else if cube_pos_x > window_width - cube_size 
    {
      cube_pos_x = window_width - cube_size
    }

    // --- rendering --- 

    // draw main rectangle
    rl.DrawRectangle( i32(cube_pos_x), i32(cube_pos_y), i32(cube_size), i32(cube_size), rl.BLUE )
    // draw sphere
    rl.DrawCircle( i32(sphere_pos_x), i32(sphere_pos_y), sphere_radius, rl.RED )
    // draw another rectangle slightly below the main rectangle to the sphere disapears  
    rl.DrawRectangle( i32(cube_pos_x), i32(cube_pos_y + (cube_size / 2) ), i32(cube_size), i32(cube_size), rl.DARKBLUE )

    rl.DrawText("catch the falling sphere", i32(window_width) - 400, 50, i32(font_size_main), rl.LIGHTGRAY)
    
    score_str := fmt.ctprintf( "score: %v", current_score )
    // unsigned int TextLength(const char *text);
    rl.DrawText( score_str, i32(window_width / 2 - ( len(score_str) * (font_size_score / 2) ) ), 25, i32(font_size_score), rl.ORANGE )

    rl.EndDrawing()
  }
}
