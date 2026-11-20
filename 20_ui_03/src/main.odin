package main

import     "core:os"
import     "core:fmt"
import     "core:log"
import     "core:math"
import str "core:strings"
import     "base:runtime"
import     "core:math/rand"
import     "core:debug/trace"

import r "../external/raven/bindings/odin/raven"


data_t :: struct
{
  // basic layout boxes & window
  window      : r.Rid,
  box_window  : r.Rid,
  box_main    : r.Rid,
  box_overlay : r.Rid,
  box_bg      : r.Rid,
  img_bg      : r.Rid,
  gradient_created : bool,
  gradient         : r.Rid,
  gradient_index   : int,

  // style
  border_col_r  : f32,
  border_col_g  : f32,
  border_col_b  : f32,
  border_col_a  : f32,
  border_shadow : f32,
  border_shadow_blur : f32,

  // general
  last_question_idx    : int,
  question_idx         : int,
  question_amount      : int,
  question_amount_cstr : cstring,
  score                : int,
  rounds               : int,
  answer_cstr          : cstring,

  // box_overlay
  score_label : r.Rid,
  score_label_cstr : cstring,

  // box_main
  title    : r.Rid,
  question : r.Rid,
  amount   : r.Rid,
}
data : data_t

MAIN_BUTTON_SIZE_W :: 150 
MAIN_BUTTON_SIZE_H :: 75
TRANSITION_TIME    :: 0.25  
BG_TEX_SIZE        :: 96
BG_TEX_INDEX_COUNT :: 9
BORDER_RADIUS      :: 10.0
// BORDER_BG_R        :: 1.0
// BORDER_BG_G        :: 1.0
// BORDER_BG_B        :: 1.0
// BORDER_BG_A        :: 0.5
BUTTON_TYPE        :: r.R_BUTTON_DEFAULT

question_t :: struct
{
  question:  cstring,
  answer:    int,
  range_min: int,
  range_max: int,
}

questions_arr := [?]question_t{
  question_t{ question="How many hairs does a normal person have ?", answer=100_000, range_min= 20_000, range_max=200_000},
  question_t{ question="Whats a Gigahertz ?",                        answer=1_000_000_000, range_min=1_000_000, range_max=1_000_000_000_000 },
  question_t{ question="How many cells are in the human body ?",     answer=30_000_000_000_000, range_min=250_000, range_max=1_000_000_000_000_000},
  question_t{ question="How many cards are in a deck of cards ?",    answer=54, range_min=24, range_max=87 },
  question_t{ question="How many countries are in the world ?",      answer=195, range_min=112, range_max=289 },
  question_t{ question="How many countries are in europe ?",         answer=44, range_min=17, range_max=67 },
  question_t{ question="How many people live in berlin ?",           answer=3_700_577, range_min=2_400_000, range_max=4_800_000 },
  question_t{ question="How high is the world population ?",         answer=8_300_000_000, range_min=7_400_000_000, range_max=9_500_000_000 },
}


// taken from: https://github.com/oscar-soirey/Raven/blob/main/examples/glass/main.c
// A small picture for a card: two colors melted together with a bright spot.
// not sure how it works yet exactly but makes pretty textures :)
create_gradient_bg_texture :: proc( index, size_w, size_h: int )
{
  // fmt.println( "size_w:",size_w,"size_h:",size_h, "index:", index )

  if data.gradient_created
  {
    r.Rtexture_destroy( data.gradient )
  }

  colors := [BG_TEX_INDEX_COUNT][6]f32{ // { 1.00, 0.60, 0.20, 0.95, 0.20, 0.45 }
  { 1.00, 0.60, 0.20, 0.95, 0.20, 0.45 }, 
    { 0.05, 0.30, 0.75, 0.10, 0.80, 0.85 },
  { 0.98, 0.85, 0.15, 0.40, 0.85, 0.25 }, 
    { 0.65, 0.25, 0.90, 0.98, 0.45, 0.75 },
  { 0.55, 0.85, 1.00, 0.20, 0.35, 0.80 }, 
    { 0.90, 0.20, 0.10, 1.00, 0.70, 0.15 },
  { 0.20, 0.70, 0.35, 0.75, 0.95, 0.45 }, 
    { 0.25, 0.15, 0.55, 0.95, 0.45, 0.35 },
  { 1.00, 0.45, 0.40, 1.00, 0.80, 0.60 }
	}
  pixels := make( []u8, size_w * size_h * 4 )
  c := &colors[index]
  x, y, k : int

  index := 0

	for y = 0; y < size_h; y += 1 
  {
		for x = 0; x < size_w; x += 1 
    {
      u : f32 = f32(x) / f32(size_w - 1)
      v := f32(y) / f32(size_h - 1)

			// a diagonal blend, bent by a wave so that no two cards look alike
			t : f32 = 0.5 * (u + v) + 0.18 * math.sin(u * 5.0 + f32(index) ) * math.cos(v * 4.0 - f32(index) * 0.7)
			du : f32 = u - 0.72
      dv : f32 = v - 0.28
			spot : f32 = math.exp(-(du * du + dv * dv) * 9.0) * 0.45
			idx := (y * size_w + x) * 4   // idk maybe size_h
			t = t < 0.0 ? 0.0 : (t > 1.0 ? 1.0 : t)
			for k = 0; k < 3; k += 1
      {
        value : f32 = c[k] + (c[k + 3] - c[k]) * t + spot
				pixels[idx + k] = u8(255.0 * (value > 1.0 ? 1.0 : value))
			}
			pixels[idx + 3] = 255
		}
	}
	data.gradient = r.Rtexture_create_from_pixels( raw_data(pixels[:]), i32(size_w), i32(size_h) )
  data.gradient_created = true
  r.Rimage_set_texture( data.img_bg, data.gradient )
}


btn_dummy_callback :: proc "c" (button: r.Rid, user_data: rawptr) 
{
  context = runtime.default_context()
  fmt.println( "clicked button" )
}

btn_quit_callback :: proc "c" ( button: r.Rid, user_data: rawptr) 
{
	r.Rquit(0)
}

raven_error_callback :: proc "c" (code: r.RError, severity: r.RSeverity, detail: cstring) 
{
  context = runtime.default_context()
  fmt.printfln( "[Raven] %s (%s): %s", r.Rerror_to_string(code), r.Rseverity_to_string(severity), detail )
}
raven_window_resize_callback :: proc "c" ( window: r.Rid, width, height: i32, user_data: rawptr )
{
  context = runtime.default_context()
  fmt.println( "resize" )

  create_gradient_bg_texture( data.gradient_index, int(width), int(height) )
}

main :: proc() 
{
  when ODIN_DEBUG 
  {
    track: trace.Tracking_Allocator
    trace.tracking_allocator_init(&track, context.allocator)
	  context.allocator = trace.tracking_allocator(&track)
  }
  context.logger = log.create_console_logger()
  context.assertion_failure_proc = trace.assertion_failure_proc

  desc: r.RInitDesc
	desc.backend = r.R_BACKEND_VULKAN;
	desc.app_name = "20_ui_03"
  when ODIN_DEBUG { desc.enable_validation = true }

	r.Rerror_set_callback(raven_error_callback);
	if r.Rinit_ex( &desc ) == 0
  {
    fmt.println( desc.app_name, ": cannot start Raven" )
		return 
	}

	data.window = r.Rwindow_create( "Higher Lower Game", 620, 420, r.R_WINDOW_DEFAULT )

  data.last_question_idx = -1 // doesnt exists so first call to set_new_question() can create any idx

  r.Rtheme_apply( r.R_THEME_GLASS_DARK )  // r.R_THEME_DARK
  r.Rtheme_set_material( r.R_MATERIAL_FROSTED_GLASS )

  r.Rtheme_get_color( r.R_COLOR_CONTROL, &data.border_col_r, &data.border_col_g, &data.border_col_b, &data.border_col_a )
  data.border_shadow = r.Rtheme_get_metric( r.R_METRIC_GLASS_SHADOW )
  data.border_shadow_blur = 4 // idk just guessing
  // fmt.println( "data.border_shadow:", data.border_shadow )

  window_w, window_h : i32
  r.Rwindow_get_size( data.window, &window_w, &window_h )

  // 7, 3, 1, 5 is nice and readable
  // 4, 0, 6 is kinda good kinda unreadable though
  // 8, 2 isnt
  // data.gradient_index = rand.int_range( 0, BG_TEX_INDEX_COUNT )
  data.gradient_index = rand.choice( []int{ 1, 3, 5, 7 } )
  fmt.println( "choose data.gradient_index:", data.gradient_index )
  
  create_gradient_bg_texture( data.gradient_index, int(window_w), int(window_h) )

  r.Rwindow_set_resize_callback( data.window, raven_window_resize_callback, nil )


  // --- layout ---
	data.box_window = r.Rwidget_create( r.R_WIDGET_OVERLAY )
	r.Rslot_set_halign(data.box_window, r.R_HALIGN_FILL )
	r.Rslot_set_valign(data.box_window, r.R_VALIGN_FILL )
	r.Rwindow_set_content(data.window, data.box_window )

  data.box_bg = r.Rwidget_add_child( data.box_window, r.Rwidget_create( r.R_WIDGET_VBOX ) )
	r.Rpanel_set_spacing( data.box_bg, 0.0 )
	r.Rslot_set_halign( data.box_bg, r.R_HALIGN_FILL )
	r.Rslot_set_valign( data.box_bg, r.R_VALIGN_FILL )

  data.img_bg = r.Rwidget_add_child( data.box_bg, r.Rwidget_create( r.R_WIDGET_IMAGE ) )

  r.Rimage_set_texture( data.img_bg, data.gradient )
  r.Rwidget_set_size( data.img_bg, f32(window_w), f32(window_h) )
  // r.Rimage_set_corner_radius( img_00, 0.5 )
	// r.Rwidget_set_tooltip( img_00, "this is an image" )
  
	data.box_main = r.Rwidget_add_child( data.box_window, r.Rwidget_create( r.R_WIDGET_VBOX ) )
	r.Rpanel_set_spacing( data.box_main, 12.0 )
	r.Rslot_set_halign(data.box_main, r.R_HALIGN_FILL )
	r.Rslot_set_valign(data.box_main, r.R_VALIGN_FILL )
	// r.Rwindow_set_content(data.window, data.box_main)

	data.box_overlay = r.Rwidget_add_child( data.box_window, r.Rwidget_create( r.R_WIDGET_VBOX ) )
	r.Rpanel_set_spacing( data.box_overlay, 12.0 )
	r.Rslot_set_halign(data.box_overlay, r.R_HALIGN_FILL )
	r.Rslot_set_valign(data.box_overlay, r.R_VALIGN_FILL )

  fill_box_main()
  fill_box_overlay()

	// the loop belongs to the application: Raven draws one frame per call,
	// and Rwait_frame sleeps until there is something to draw 
  // for r.Rwait_frame(-1.0) == 1 
  for r.Rdraw_frame() == 1 
  {
    // --- general stuff ---
    // window_w, window_h : i32
    r.Rwindow_get_size( data.window, &window_w, &window_h )

    if r.Rwidget_is_valid( data.box_main ) == 1
    {
      r.Rwidget_set_size( data.box_main, f32(window_w), f32(window_h) )
    }

    if r.Rwidget_is_valid( data.img_bg ) == 1
    {
      r.Rwidget_set_size( data.img_bg, f32(window_w), f32(window_h) )
    }
  }

  when ODIN_DEBUG 
  {
	  trace.tracking_allocator_destroy(&track)
	  trace.tracking_allocator_print_results(&track)
  }
	return
}
fill_box_overlay :: proc()
{
  bo := data.box_overlay
  r.Rwidget_clear_children( bo )

  size_box := r.Rwidget_add_child( bo, r.Rwidget_create( r.R_WIDGET_SIZE_BOX ) )
  r.Rslot_set_padding( size_box, 12.0, 12.0, 12.0, 12.0 )
  r.Rwidget_set_min_size( size_box, 120, 45 )
  // r.Rwidget_set_max_size( size_box, 80, 40 )
  // r.Rsize_box_set_aspect_ratio( size_box, 4.0 )
	r.Rslot_set_halign( size_box, r.R_HALIGN_LEFT )
	r.Rslot_set_valign( size_box, r.R_VALIGN_TOP )
  
  border := r.Rwidget_add_child( size_box, r.Rwidget_create( r.R_WIDGET_BORDER ) )
  r.Rborder_set_padding( border, 10, 10, 10, 10 )
  // r.Rborder_set_background( border, 0.44, 0.52, 0.98, 1.0 )
  // r.Rborder_set_background( border, 0.91, 0.59, 0.60, 1.0 )
  // r.Rborder_set_outline( border, 3.0, 1.0, 1.0, 1.0, 1.0 )
  r.Rborder_set_background( border, data.border_col_r, data.border_col_g, data.border_col_b, data.border_col_a )
  r.Rborder_set_corner_radius( border, BORDER_RADIUS, BORDER_RADIUS, BORDER_RADIUS, BORDER_RADIUS )
  r.Rborder_set_material( border, r.R_MATERIAL_GLASS )
  // r.Rborder_set_shadow( border, 1.0, 10, 10 ) // idk if this does anything
  r.Rwidget_set_transition( border, r.R_TRANSITION_FLY_DOWN, TRANSITION_TIME )
  r.Rborder_set_shadow( border, data.border_shadow_blur, data.border_shadow, data.border_shadow )

  data.score_label = r.Rwidget_add_child( border, r.Rlabel_create( "Score: 0" ) )
	r.Rlabel_set_text_size( data.score_label, 30.0 )
	r.Rslot_set_halign( data.score_label, r.R_HALIGN_LEFT )
  r.Rwidget_set_transition( data.score_label, r.R_TRANSITION_FLY_DOWN, TRANSITION_TIME )

  score_label_set_text()
}
score_label_set_text :: proc()
{
  if len(data.score_label_cstr) > 0 do delete( data.score_label_cstr )
  data.score_label_cstr = fmt.caprintf( "Score: %v / %v", data.score, data.rounds )
  r.Rlabel_set_text( data.score_label, data.score_label_cstr )
  r.Rwidget_play_transition( data.score_label, r.R_TRANSITION_POP, TRANSITION_TIME )
}

fill_box_main :: proc()
{
  bm := data.box_main
  r.Rwidget_clear_children( bm )

  title_size_box := r.Rwidget_add_child( bm, r.Rwidget_create( r.R_WIDGET_SIZE_BOX ) )
  r.Rslot_set_padding( title_size_box, 12.0, 12.0, 12.0, 12.0 )
  r.Rwidget_set_min_size( title_size_box, 200, 45 )
	r.Rslot_set_halign( title_size_box, r.R_HALIGN_CENTER )
	r.Rslot_set_valign( title_size_box, r.R_VALIGN_TOP )

  title_border := r.Rwidget_add_child( title_size_box, r.Rwidget_create( r.R_WIDGET_BORDER ) )
  r.Rborder_set_padding( title_border, 10, 10, 10, 10 )
  // r.Rborder_set_background( title_border, BORDER_BG_R, BORDER_BG_G, BORDER_BG_B, BORDER_BG_A )
  r.Rborder_set_background( title_border, data.border_col_r, data.border_col_g, data.border_col_b, data.border_col_a )
  r.Rborder_set_corner_radius( title_border, BORDER_RADIUS, BORDER_RADIUS, BORDER_RADIUS, BORDER_RADIUS )
  r.Rborder_set_material( title_border, r.R_MATERIAL_GLASS )
  r.Rwidget_set_transition( title_border, r.R_TRANSITION_FLY_DOWN, TRANSITION_TIME )
  r.Rborder_set_shadow( title_border, data.border_shadow_blur, data.border_shadow, data.border_shadow )

  data.title = r.Rwidget_add_child( title_border, r.Rlabel_create("Higher or Lower") )
	r.Rlabel_set_text_size( data.title, 30.0 )
	r.Rslot_set_halign( data.title, r.R_HALIGN_CENTER )
  r.Rwidget_set_transition( data.title, r.R_TRANSITION_FLY_DOWN, TRANSITION_TIME )

  spacer_00 := r.Rwidget_add_child( bm, r.Rwidget_create( r.R_WIDGET_SPACER ) )
  r.Rspacer_set_size( spacer_00, 100, 100 )

  question_size_box := r.Rwidget_add_child( bm, r.Rwidget_create( r.R_WIDGET_SIZE_BOX ) )
  r.Rslot_set_padding( question_size_box, 12.0, 12.0, 12.0, 12.0 )
  r.Rwidget_set_min_size( question_size_box, 200, 45 )
	r.Rslot_set_halign( question_size_box, r.R_HALIGN_CENTER )
	r.Rslot_set_valign( question_size_box, r.R_VALIGN_TOP )

  question_border := r.Rwidget_add_child( question_size_box, r.Rwidget_create( r.R_WIDGET_BORDER ) )
  r.Rborder_set_padding( question_border, 10, 10, 10, 10 )
  // r.Rborder_set_background( question_border, BORDER_BG_R, BORDER_BG_G, BORDER_BG_B, BORDER_BG_A )
  r.Rborder_set_background( question_border, data.border_col_r, data.border_col_g, data.border_col_b, data.border_col_a )
  r.Rborder_set_corner_radius( question_border, BORDER_RADIUS, BORDER_RADIUS, BORDER_RADIUS, BORDER_RADIUS )
  r.Rborder_set_material( question_border, r.R_MATERIAL_GLASS )
  r.Rwidget_set_transition( question_border, r.R_TRANSITION_FLY_DOWN, TRANSITION_TIME )
  r.Rborder_set_shadow( question_border, data.border_shadow_blur, data.border_shadow, data.border_shadow )

  data.question = r.Rwidget_add_child( question_border, r.Rlabel_create("Question") )
	r.Rlabel_set_text_size( data.question, 20.0 )
	r.Rslot_set_halign( data.question, r.R_HALIGN_CENTER )
  r.Rwidget_set_transition( data.question, r.R_TRANSITION_FLY_DOWN, TRANSITION_TIME )
  r.Rlabel_set_wrap( data.question, r.R_TRUE )

  spacer_01 := r.Rwidget_add_child( bm, r.Rwidget_create( r.R_WIDGET_SPACER ) )
  r.Rspacer_set_size( spacer_01, 15, 15 )


  amount_size_box := r.Rwidget_add_child( bm, r.Rwidget_create( r.R_WIDGET_SIZE_BOX ) )
  r.Rslot_set_padding( amount_size_box, 12.0, 12.0, 12.0, 12.0 )
  r.Rwidget_set_min_size( amount_size_box, 200, 45 )
	r.Rslot_set_halign( amount_size_box, r.R_HALIGN_CENTER )
	r.Rslot_set_valign( amount_size_box, r.R_VALIGN_TOP )

  amount_border := r.Rwidget_add_child( amount_size_box, r.Rwidget_create( r.R_WIDGET_BORDER ) )
  r.Rborder_set_padding( amount_border, 10, 10, 10, 10 )
  // r.Rborder_set_background( amount_border, BORDER_BG_R, BORDER_BG_G, BORDER_BG_B, BORDER_BG_A )
  r.Rborder_set_background( amount_border, data.border_col_r, data.border_col_g, data.border_col_b, data.border_col_a )
  r.Rborder_set_corner_radius( amount_border, BORDER_RADIUS, BORDER_RADIUS, BORDER_RADIUS, BORDER_RADIUS )
  r.Rborder_set_material( amount_border, r.R_MATERIAL_GLASS )
  r.Rwidget_set_transition( amount_border, r.R_TRANSITION_FLY_DOWN, TRANSITION_TIME )
  r.Rborder_set_shadow( amount_border, data.border_shadow_blur, data.border_shadow, data.border_shadow )

  data.amount = r.Rwidget_add_child( amount_border, r.Rlabel_create("Amount") )
	r.Rlabel_set_text_size( data.amount, 20.0 )
	r.Rslot_set_halign( data.amount, r.R_HALIGN_CENTER )
  r.Rwidget_set_transition( data.amount, r.R_TRANSITION_FLY_DOWN, TRANSITION_TIME )
  r.Rlabel_set_wrap( data.amount, r.R_TRUE )

  spacer_02 := r.Rwidget_add_child( bm, r.Rwidget_create( r.R_WIDGET_SPACER ) )
  r.Rspacer_set_size( spacer_02, 50, 50 )

  row_00 := r.Rwidget_add_child( bm, r.Rwidget_create( r.R_WIDGET_HBOX ) )
	r.Rpanel_set_spacing( row_00, 12.0 )
	r.Rslot_set_halign( row_00, r.R_HALIGN_CENTER )
	r.Rslot_set_valign( row_00, r.R_VALIGN_CENTER )

  btn_00 := r.Rwidget_add_child( row_00, r.Rbutton_create( "Higher" ));
	r.Rbutton_set_style( btn_00, BUTTON_TYPE )
	r.Rbutton_set_clicked_callback( btn_00, btn_higher_callback, nil);
	r.Rwidget_set_tooltip( btn_00, "You think the amount is higher");
  r.Rwidget_set_min_size( btn_00, MAIN_BUTTON_SIZE_W, MAIN_BUTTON_SIZE_H )
  r.Rwidget_set_transition( btn_00, r.R_TRANSITION_FLY_DOWN, TRANSITION_TIME )


  btn_01 := r.Rwidget_add_child( row_00, r.Rbutton_create( "Lower" ));
	r.Rbutton_set_style(btn_01, BUTTON_TYPE )
	r.Rbutton_set_clicked_callback(btn_01, btn_lower_callback, nil);
	r.Rwidget_set_tooltip(btn_01, "You think the amount is lower");
  r.Rwidget_set_min_size( btn_01, MAIN_BUTTON_SIZE_W, MAIN_BUTTON_SIZE_H )
  r.Rwidget_set_transition( btn_01, r.R_TRANSITION_FLY_DOWN, TRANSITION_TIME )

  set_new_question()
}

set_new_question :: proc()
{
  data.question_idx = rand.int_range( 0, len(questions_arr) )
  for data.question_idx == data.last_question_idx
  {
    data.question_idx = rand.int_range( 0, len(questions_arr) )
  }
  data.last_question_idx = data.question_idx

  r.Rlabel_set_text( data.question, questions_arr[data.question_idx].question )

  data.question_amount = rand.int_range( questions_arr[data.question_idx].range_min, questions_arr[data.question_idx].range_max )
  for data.question_amount == questions_arr[data.question_idx].answer
  {
    data.question_amount = rand.int_range( questions_arr[data.question_idx].range_min, questions_arr[data.question_idx].range_max )
  }

  if len(data.question_amount_cstr) > 0 do delete(data.question_amount_cstr)
  data.question_amount_cstr = fmt.caprint( data.question_amount )
  r.Rlabel_set_text( data.amount, data.question_amount_cstr )
}

btn_higher_callback :: proc "c" (button: r.Rid, user_data: rawptr) 
{
  context = runtime.default_context()

  data.rounds += 1

  // if answers_arr[data.question_idx] == true
  if questions_arr[data.question_idx].answer > data.question_amount
  {
    data.score += 1
    score_label_set_text()
    fill_box_main_game_done( true )
  }
  else  // false
  {
    fill_box_main_game_done( false )
  }
}
btn_lower_callback :: proc "c" (button: r.Rid, user_data: rawptr) 
{
  context = runtime.default_context()

  data.rounds += 1

  // if answers_arr[data.question_idx] == true
  if questions_arr[data.question_idx].answer > data.question_amount
  {
    fill_box_main_game_done( false )
  }
  else  // false
  {
    data.score += 1
    score_label_set_text()
    fill_box_main_game_done( true )
  }
}
btn_new_question_callback :: proc "c" (button: r.Rid, user_data: rawptr) 
{
  context = runtime.default_context()
  fill_box_main()
}

fill_box_main_game_done :: proc( won: bool )
{
  bm := data.box_main
  r.Rwidget_clear_children( bm )

  @TODO: add size_box & border

  data.title = r.Rwidget_add_child( bm, r.Rlabel_create( won ? "You Won !!!" : "You Lost") )
	r.Rlabel_set_text_size( data.title, 30.0 )
	r.Rslot_set_halign( data.title, r.R_HALIGN_CENTER )
  r.Rwidget_set_transition( data.title, r.R_TRANSITION_FLY_DOWN, 0.5 )

  spacer_00 := r.Rwidget_add_child( bm, r.Rwidget_create( r.R_WIDGET_SPACER ) )
  r.Rspacer_set_size( spacer_00, 50, 50 )

  data.question = r.Rwidget_add_child( bm, r.Rlabel_create("Question") )
	r.Rlabel_set_text_size( data.question, 20.0 )
	r.Rslot_set_halign( data.question, r.R_HALIGN_CENTER )
  r.Rwidget_set_transition( data.question, r.R_TRANSITION_FLY_DOWN, 0.5 )
  r.Rlabel_set_wrap( data.question, r.R_TRUE )
  // question_cstr := str.clone_to_cstring( questions_arr[data.question_idx] )
  r.Rlabel_set_text( data.question, questions_arr[data.question_idx].question )


  spacer_01 := r.Rwidget_add_child( bm, r.Rwidget_create( r.R_WIDGET_SPACER ) )
  r.Rspacer_set_size( spacer_01, 15, 15 )

  data.amount = r.Rwidget_add_child( bm, r.Rlabel_create("Amount") )
	r.Rlabel_set_text_size( data.amount, 20.0 )
	r.Rslot_set_halign( data.amount, r.R_HALIGN_CENTER )
  r.Rwidget_set_transition( data.amount, r.R_TRANSITION_FLY_DOWN, 0.5 )
  r.Rlabel_set_wrap( data.amount, r.R_TRUE )
  // answer_cstr := str.clone_to_cstring( answer_str_arr[data.question_idx] )
  if len(data.answer_cstr) > 0 do delete( data.answer_cstr )
  data.answer_cstr = fmt.caprintf( "Answer: %v %v %v", questions_arr[data.question_idx].answer, questions_arr[data.question_idx].answer < data.question_amount ? "<" : ">", data.question_amount )
  r.Rlabel_set_text( data.amount, data.answer_cstr )

  spacer_02 := r.Rwidget_add_child( bm, r.Rwidget_create( r.R_WIDGET_SPACER ) )
  r.Rspacer_set_size( spacer_02, 100, 100 )

  row_00 := r.Rwidget_add_child( bm, r.Rwidget_create( r.R_WIDGET_HBOX ) )
  r.Rslot_set_halign( row_00, r.R_HALIGN_CENTER )
  r.Rslot_set_valign( row_00, r.R_VALIGN_CENTER )

  btn_00 := r.Rwidget_add_child( row_00, r.Rbutton_create( "Next Question" ));
	r.Rbutton_set_style( btn_00, BUTTON_TYPE )
	r.Rbutton_set_clicked_callback( btn_00, btn_new_question_callback, nil);
	r.Rwidget_set_tooltip( btn_00, "click for next question");
  r.Rwidget_set_min_size( btn_00, MAIN_BUTTON_SIZE_W, MAIN_BUTTON_SIZE_H )
  r.Rwidget_set_max_size( btn_00, 200, 100 )
  r.Rwidget_set_transition( btn_00, r.R_TRANSITION_FLY_DOWN, 0.5 )
}

