package main

import "core:fmt"


player_t :: struct
{
  health     : int,
  max_health : int,
  mana       : u8,
}

enemy_t :: struct
{
  health     : int,
  max_health : int,
  power      : f32,
}

MAX_ENEMIES :: 3

game_state_t :: struct
{
  is_running : bool,
  player     : player_t,
  enemies    : [MAX_ENEMIES]enemy_t,
}


main :: proc()
{
  fmt.println( "--- structs ---" )
  // structs are types like int or f32 are but they contain multiple variables of potentially diffrent types, even structs in structs
  // to access these member variables use the syntax struct.member 

  gs : game_state_t
  fmt.println( "gs:", gs )

  gs.is_running = true

  // struct literal
  gs.player = player_t{ health=80, max_health=100, mana=255 }

  for i in 0..<len(gs.enemies)
  {
    gs.enemies[i].health     = 20
    gs.enemies[i].max_health = 100
    gs.enemies[i].power      = f32( i * 10 )
  }
  
  fmt.println( "gs:", gs )

  for gs.is_running
  {
    if game_state_attack_valid( gs )
    {
      gs.player.health -= 10
      fmt.println( "player took 10 damage, player-health:", gs.player.health )

      if gs.player.health <= 0
      {
        fmt.println( "player died - ending game" )
        gs.is_running = false
        break
      }
    }
  }

}
game_state_attack_valid :: proc( gs: game_state_t ) -> bool
{
  if gs.player.health >= 0 
  {
    return true
  } 
  else 
  {
    return false
  }
}
