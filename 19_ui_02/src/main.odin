package main

import     "core:os"
import     "core:fmt"
import     "core:math"
import     "core:time"
import str "core:strings"
import     "base:runtime"

import r "../external/raven/bindings/odin/raven"

Box_Right_Type :: enum 
{
  Widgets,
  Layout,
  Style,
}

data_t :: struct
{
  window    : r.Rid,
  box_main  : r.Rid,
  box_left  : r.Rid,
  box_right : r.Rid,
  box_right_type : Box_Right_Type,

  // tab widgets
  progress_bar    : r.Rid,
  tex_00          : r.Rid,
  txt_input       : r.Rid,
  txt_input_label : r.Rid,
  check_00        : r.Rid,
  check_01        : r.Rid,
  check_02        : r.Rid,
  label_check     : r.Rid,
  slider          : r.Rid,
  label_slider    : r.Rid,

  // tab layout
  scroll_box      : r.Rid,
}
data : data_t


btn_dummy_callback :: proc "c" (button: r.Rid, user_data: rawptr) 
{
  context = runtime.default_context()
  fmt.println( "clicked button" )
}


raven_error_callback :: proc "c" (code: r.RError, severity: r.RSeverity, detail: cstring) 
{
  context = runtime.default_context()

  fmt.printfln( "[Raven] %s (%s): %s", r.Rerror_to_string(code), r.Rseverity_to_string(severity), detail )
  os.exit( 1 )
}

BOX_LEFT_WIDTH :: 120

main :: proc() 
{
  desc: r.RInitDesc
	desc.backend = r.R_BACKEND_VULKAN;
	desc.app_name = "19_ui_02" 
  when ODIN_DEBUG { desc.enable_validation = true }

	r.Rerror_set_callback(raven_error_callback);
	if r.Rinit_ex( &desc ) == 0
  {
    fmt.println( desc.app_name, ": cannot start Raven" )
		return 
	}

  data.window = r.Rwindow_create( "raven example", 620, 420, r.R_WINDOW_DEFAULT )
  data.box_right_type = .Widgets
   
  // --- assets ---
  data.tex_00 = r.Rtexture_create_from_file( "../assets/raven_logo.png" )

  // --- layout ---
	data.box_main = r.Rwidget_create( r.R_WIDGET_HBOX )
	r.Rpanel_set_spacing( data.box_main, 12.0 )
	r.Rslot_set_halign(data.box_main, r.R_HALIGN_FILL )
	r.Rslot_set_valign(data.box_main, r.R_VALIGN_FILL )
	r.Rwindow_set_content(data.window, data.box_main)

	data.box_left = r.Rwidget_add_child(data.box_main, r.Rwidget_create( r.R_WIDGET_VBOX ))
	r.Rpanel_set_spacing( data.box_left, 0.0 )
	r.Rslot_set_halign(data.box_left, r.R_HALIGN_CENTER)
	r.Rslot_set_valign(data.box_left, r.R_VALIGN_TOP)
  r.Rwidget_set_size( data.box_left, BOX_LEFT_WIDTH, -1 )

	data.box_right = r.Rwidget_add_child(data.box_main, r.Rwidget_create( r.R_WIDGET_SCROLL_BOX ))
	r.Rpanel_set_spacing( data.box_right, 12.0 )
	r.Rslot_set_halign(data.box_right, r.R_HALIGN_LEFT)
	r.Rslot_set_valign(data.box_right, r.R_VALIGN_TOP)

  fill_left_box()

  fill_right_box()

	// the loop belongs to the application: Raven draws one frame per call,
	// and Rwait_frame sleeps until there is something to draw
  // for r.Rwait_frame(-1.0) == 1 
  total_secs := 0
  start := time.now()

  for r.Rdraw_frame() == 1 
  {
    // --- general stuff ---
    window_w, window_h : i32
    r.Rwindow_get_size( data.window, &window_w, &window_h )

    // --- box_right ---
    if r.Rwidget_is_valid( data.box_main) == 1 && r.Rwidget_is_valid( data.box_right ) == 1
    {
      spacing := r.Rpanel_get_spacing( data.box_main )
      lboxw := i32( BOX_LEFT_WIDTH + spacing )
      r.Rwidget_set_size( data.box_right, f32(window_w - lboxw), f32(window_h))
    }

    // --- progress bar ---
    now := time.now()
    secs := time.duration_seconds( time.diff( start, now ) )
    progress_val := ( math.sin( f32(secs) ) +1 ) /2
    if r.Rwidget_is_valid( data.progress_bar ) == 1   // need to check if valid bc. when changing to f.e. style tab
    {
      r.Rprogress_bar_set_value( data.progress_bar, progress_val )
    }

    // --- text input label ---
    if r.Rwidget_is_valid( data.txt_input ) == 1 && r.Rwidget_is_valid( data.txt_input_label ) == 1   // need to check if valid bc. when changing to f.e. style tab
    {
      txt_00 := r.Rtext_input_get_text( data.txt_input )
      r.Rlabel_set_text( data.txt_input_label, txt_00 )
    }

    // --- checkboxes ---
    if r.Rwidget_is_valid( data.check_00) == 1 && r.Rwidget_is_valid( data.check_01) == 1 && 
       r.Rwidget_is_valid( data.check_02) == 1 && r.Rwidget_is_valid( data.label_check ) == 1 // need to check if valid bc. when changing to f.e. style tab
    {
      check_00_checked := r.Rcheckbox_is_checked( data.check_00 ) == 1
      check_01_checked := r.Rcheckbox_is_checked( data.check_01 ) == 1
      check_02_checked := r.Rcheckbox_is_checked( data.check_02 ) == 1
      txt_01 := fmt.ctprintf( "check_00: %v, check_01: %v, check_02: %v", check_00_checked, check_01_checked, check_02_checked  )
      r.Rlabel_set_text( data.label_check, txt_01 )
    }

    // --- slider ---
    if r.Rwidget_is_valid( data.slider ) == 1 && r.Rwidget_is_valid( data.label_slider ) == 1  // need to check if valid bc. when changing to f.e. style tab
    {
      slider_val := r.Rslider_get_value( data.slider )
      txt_02 := fmt.ctprintf( "slider value: %v", slider_val )
      r.Rlabel_set_text( data.label_slider, txt_02 )
    }

    // --- end of frame general stuff ---
    free_all( context.temp_allocator )
  }
	return
}

fill_left_box :: proc()
{
  BTN_PADDING :: 8.0

  btn_widgets := r.Rwidget_add_child(data.box_left, r.Rbutton_create("Widgets"));
	r.Rbutton_set_style(btn_widgets, r.R_BUTTON_PRIMARY);
	r.Rbutton_set_clicked_callback(btn_widgets, btn_widgets_callback, nil);
	r.Rwidget_set_tooltip(btn_widgets, "opens widget panel");
  r.Rslot_set_padding( btn_widgets, BTN_PADDING, BTN_PADDING, BTN_PADDING, BTN_PADDING )

  btn_layout := r.Rwidget_add_child(data.box_left, r.Rbutton_create("Layout"));
	r.Rbutton_set_style(btn_layout, r.R_BUTTON_PRIMARY);
	r.Rbutton_set_clicked_callback(btn_layout, btn_layout_callback, nil);
	r.Rwidget_set_tooltip(btn_layout, "opens layout panel");
  r.Rslot_set_padding( btn_layout, BTN_PADDING, BTN_PADDING, BTN_PADDING, BTN_PADDING )

  btn_style := r.Rwidget_add_child(data.box_left, r.Rbutton_create("Style"));
	r.Rbutton_set_style(btn_style, r.R_BUTTON_PRIMARY);
	r.Rbutton_set_clicked_callback(btn_style, btn_style_callback, nil);
	r.Rwidget_set_tooltip(btn_style, "opens style panel");
  r.Rslot_set_padding( btn_style, BTN_PADDING, BTN_PADDING, BTN_PADDING, BTN_PADDING )

  r.Rwidget_add_child( data.box_left, r.Rwidget_create( r.R_WIDGET_SEPARATOR ) )

  btn_quit := r.Rwidget_add_child(data.box_left, r.Rbutton_create("Quit"));
	r.Rbutton_set_clicked_callback(btn_quit, btn_quit_callback, nil);
  r.Rslot_set_padding( btn_quit, BTN_PADDING, BTN_PADDING, BTN_PADDING, BTN_PADDING )
}
btn_widgets_callback :: proc "c" (button: r.Rid, user_data: rawptr) 
{
  context = runtime.default_context()
  data.box_right_type = .Widgets 
  fill_right_box()
  fmt.println( "clicked button widgets" )
}
btn_layout_callback :: proc "c" (button: r.Rid, user_data: rawptr) 
{
  context = runtime.default_context()
  data.box_right_type = .Layout
  fill_right_box()
  fmt.println( "clicked button layout" )
}
btn_style_callback :: proc "c" (button: r.Rid, user_data: rawptr) 
{
  context = runtime.default_context()
  data.box_right_type = .Style
  fill_right_box()
  fmt.println( "clicked button style" )
}
btn_quit_callback :: proc "c" ( button: r.Rid, user_data: rawptr) 
{
	r.Rquit(0)
}

fill_right_box :: proc()
{
  r.Rwidget_clear_children( data.box_right )

  switch data.box_right_type 
  {
    case .Widgets: fill_right_box_widgets( data.box_right )
    case .Layout:  fill_right_box_layout( data.box_right )
    case .Style:   fill_right_box_style( data.box_right )
  }
}

fill_right_box_widgets :: proc( box_right: r.Rid )
{
  label_00 := r.Rwidget_add_child(box_right, r.Rlabel_create("label - 24.0"));
	r.Rlabel_set_text_size(label_00, 24.0);
	r.Rslot_set_halign(label_00, r.R_HALIGN_CENTER);

  label_01 := r.Rwidget_add_child(box_right, r.Rlabel_create("label - 10.0"));
	r.Rlabel_set_text_size(label_01, 10.0);
	r.Rslot_set_halign(label_01, r.R_HALIGN_CENTER);

  label_02 := r.Rwidget_add_child(box_right, r.Rlabel_create("label 15.0 wrap:true - Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet."));
	r.Rlabel_set_text_size(label_02, 15.0);
	r.Rslot_set_halign(label_02, r.R_HALIGN_LEFT);
  r.Rlabel_set_wrap( label_02, r.R_TRUE )

  btn_00 := r.Rwidget_add_child(box_right, r.Rbutton_create("Button Primary"));
	r.Rbutton_set_style(btn_00, r.R_BUTTON_PRIMARY);
	r.Rbutton_set_clicked_callback(btn_00, btn_dummy_callback, nil);
	r.Rwidget_set_tooltip(btn_00, "this is a button");

  btn_01 := r.Rwidget_add_child(box_right, r.Rbutton_create("Button Default"));
	r.Rbutton_set_style(btn_01, r.R_BUTTON_DEFAULT)
	r.Rbutton_set_clicked_callback(btn_01, btn_dummy_callback, nil);
	r.Rwidget_set_tooltip(btn_01, "this is a button");

  btn_02 := r.Rwidget_add_child(box_right, r.Rbutton_create("Button Flat"));
	r.Rbutton_set_style(btn_02, r.R_BUTTON_FLAT)
	r.Rbutton_set_clicked_callback(btn_02, btn_dummy_callback, nil);
	r.Rwidget_set_tooltip(btn_02, "this is a button");

  data.check_00 = r.Rwidget_add_child(box_right, r.Rcheckbox_create("checkbox"));
	r.Rcheckbox_set_style(data.check_00, r.R_CHECKBOX_CHECK)
	r.Rwidget_set_tooltip(data.check_00, "this is a checkbox");

  data.check_01 = r.Rwidget_add_child(box_right, r.Rcheckbox_create("checkbox - radio"));
	r.Rcheckbox_set_style(data.check_01, r.R_CHECKBOX_RADIO)
	r.Rwidget_set_tooltip(data.check_01, "this is a checkbox");

  data.check_02 = r.Rwidget_add_child(box_right, r.Rcheckbox_create("checkbox - switch"));
	r.Rcheckbox_set_style(data.check_02, r.R_CHECKBOX_SWITCH)
	r.Rwidget_set_tooltip(data.check_02, "this is a checkbox");

  data.label_check = r.Rwidget_add_child(box_right, r.Rlabel_create(""));

  data.slider = r.Rwidget_add_child(box_right, r.Rwidget_create( r.R_WIDGET_SLIDER ));
	r.Rwidget_set_tooltip(data.slider, "this is a slider");

  data.label_slider = r.Rwidget_add_child(box_right, r.Rlabel_create(""));

  data.progress_bar = r.Rwidget_add_child( box_right, r.Rwidget_create( r.R_WIDGET_PROGRESSBAR ) )
	r.Rwidget_set_tooltip( data.progress_bar, "this is a progress bar" )

  img_00 := r.Rwidget_add_child( box_right, r.Rwidget_create( r.R_WIDGET_IMAGE ) )
  r.Rimage_set_texture( img_00, data.tex_00 )
  r.Rwidget_set_size( img_00, 100, 100 )
  r.Rimage_set_corner_radius( img_00, 0.5 )
	r.Rwidget_set_tooltip( img_00, "this is an image" )


  data.txt_input = r.Rwidget_add_child( box_right, r.Rwidget_create( r.R_WIDGET_TEXT_INPUT ) )
	r.Rwidget_set_tooltip( data.txt_input, "this is a text input form" )
  r.Rtext_input_set_placeholder( data.txt_input, "type here..." )
  
  data.txt_input_label = r.Rwidget_add_child(box_right, r.Rlabel_create(""));

  spin_box_00 := r.Rwidget_add_child( box_right, r.Rwidget_create( r.R_WIDGET_SPIN_BOX ) )

  combo_box_00 := r.Rwidget_add_child( box_right, r.Rwidget_create( r.R_WIDGET_COMBO_BOX ) )
  r.Rcombo_box_add_item( combo_box_00, "item 00" )
  r.Rcombo_box_add_item( combo_box_00, "item 01" )
  r.Rcombo_box_add_item( combo_box_00, "item 02" )
  r.Rcombo_box_add_item( combo_box_00, "item 03" )

  sep_00 := r.Rwidget_add_child( box_right, r.Rwidget_create( r.R_WIDGET_SEPARATOR ) )

  list_view_00 := r.Rwidget_add_child( box_right, r.Rwidget_create( r.R_WIDGET_LIST_VIEW ) )
  r.Rlist_view_add_item( list_view_00, "item 00" )
  r.Rlist_view_add_item( list_view_00, "item 01" )
  r.Rlist_view_add_item( list_view_00, "item 02" )
  r.Rlist_view_add_item( list_view_00, "item 03" )

  tree_view_00 := r.Rwidget_add_child( box_right, r.Rwidget_create( r.R_WIDGET_TREE_VIEW ) )
  tree_view_00_parent_00 := r.Rtree_view_add_item( tree_view_00, r.R_INVALID_ID, "parent" )
  tree_view_00_child_00 := r.Rtree_view_add_item( tree_view_00, tree_view_00_parent_00, "child_00" )
  tree_view_00_child_01 := r.Rtree_view_add_item( tree_view_00, tree_view_00_parent_00, "child_01" )
  tree_view_00_child_03 := r.Rtree_view_add_item( tree_view_00, tree_view_00_child_00, "child_03" )

  menu_bar_00 := r.Rwidget_add_child( box_right, r.Rwidget_create( r.R_WIDGET_MENU_BAR ) )
  menu_00 := r.Rmenu_add_menu( menu_bar_00, "menu00" )
  r.Rmenu_add_item( menu_00, "menu option 00" )
  r.Rmenu_add_item( menu_00, "menu option 01" )
  r.Rmenu_add_item( menu_00, "menu option 02" )
  menu_01 := r.Rmenu_add_menu( menu_bar_00, "menu01" )
  r.Rmenu_add_item( menu_01, "menu option 00" )
  r.Rmenu_add_item( menu_01, "menu option 01" )
  r.Rmenu_add_separator( menu_01 )
  r.Rmenu_add_item( menu_01, "menu option 02" )

  text_editor_00 := r.Rwidget_add_child( box_right, r.Rwidget_create( r.R_WIDGET_TEXT_EDITOR ) )

  header_bar_00 := r.Rwidget_add_child( box_right, r.Rwidget_create( r.R_WIDGET_HEADER_BAR ) )
  
  dock_area_00 := r.Rwidget_add_child( box_right, r.Rwidget_create( r.R_WIDGET_DOCK_AREA ) )

  island_00 := r.Rwidget_add_child( box_right, r.Rwidget_create( r.R_WIDGET_ISLAND ) )
  
  file_browser_00 := r.Rwidget_add_child( box_right, r.Rwidget_create( r.R_WIDGET_FILE_BROWSER ) )

  bg_blur_00 := r.Rwidget_add_child( box_right, r.Rwidget_create( r.R_WIDGET_BACKGROUND_BLUR ) )
  
  color_picker_00 := r.Rwidget_add_child( box_right, r.Rwidget_create( r.R_WIDGET_COLOR_PICKER ) )

  timeline_00 := r.Rwidget_add_child( box_right, r.Rwidget_create( r.R_WIDGET_TIMELINE ) )
  r.Rtimeline_set_duration( timeline_00, 60 )
  r.Rtimeline_set_playing( timeline_00, 1 )
  r.Rtimeline_set_loop( timeline_00, 1 )
  track_00 := r.Rtimeline_add_track( timeline_00, "track 00" )
  track_01 := r.Rtimeline_add_track( timeline_00, "track 01" )
  r.Rtimeline_add_clip( timeline_00, track_00, 0.0, 30.0, "label 00" )
  r.Rtimeline_add_clip( timeline_00, track_01, 30.0, 15.0, "label 01" )
  r.Rtimeline_add_clip( timeline_00, track_00, 45.0, 10.0, "label 02" )
  r.Rtimeline_add_marker( timeline_00, 20.0, "marker 00" )
  r.Rtimeline_add_key( timeline_00, track_01, 45.0 )

  node_graph_00 := r.Rwidget_add_child( box_right, r.Rwidget_create( r.R_WIDGET_NODE_GRAPH ) )
  r.Rnode_graph_add_node( node_graph_00, "node 00", 0, 0 )
  btn_node_00 := r.Rwidget_add_child(box_right, r.Rbutton_create("Button Node"));
	r.Rbutton_set_style(btn_node_00, r.R_BUTTON_PRIMARY);
	r.Rbutton_set_clicked_callback(btn_node_00, btn_dummy_callback, nil);
  node_01 := r.Rnode_graph_add_node( node_graph_00, "node 01", 100, 100 )
  r.Rnode_graph_set_node_content( node_graph_00, node_01, btn_node_00 )
  r.Rnode_graph_add_output( node_graph_00, node_01, "pin 00", nil )
  node_02 := r.Rnode_graph_add_node( node_graph_00, "node 02", 300, 100 )
  r.Rnode_graph_add_input( node_graph_00, node_02, "pin 01", nil )

  tile_view_00 := r.Rwidget_add_child( box_right, r.Rwidget_create( r.R_WIDGET_TILE_VIEW ) )
  r.Rtile_view_set_items(tile_view_00, 10, tile_item_callback, nil )

  block_editor_00 := r.Rwidget_add_child( box_right, r.Rwidget_create( r.R_WIDGET_BLOCK_EDITOR ) )
  r.Rblock_editor_add_kind( block_editor_00, "statementA", "statement", r.R_BLOCK_STATEMENT, "category:A" )
  r.Rblock_editor_add_kind( block_editor_00, "hatA",       "hat",       r.R_BLOCK_HAT,       "category:A" )
  r.Rblock_editor_add_kind( block_editor_00, "capA",       "cap",       r.R_BLOCK_CAP,       "category:A" )
  r.Rblock_editor_add_kind( block_editor_00, "cA",         "c",         r.R_BLOCK_C,         "category:A" )
  r.Rblock_editor_add_kind( block_editor_00, "reporterA",  "reporter",  r.R_BLOCK_REPORTER,  "category:A" )
  r.Rblock_editor_add_kind( block_editor_00, "booleanA",   "boolean",   r.R_BLOCK_BOOLEAN,   "category:A" )
  r.Rblock_editor_add_kind( block_editor_00, "statementB", "statement", r.R_BLOCK_STATEMENT, "category:B" )
  r.Rblock_editor_add_kind( block_editor_00, "hatB",       "hat",       r.R_BLOCK_HAT,       "category:B" )
  r.Rblock_editor_add_kind( block_editor_00, "capB",       "cap",       r.R_BLOCK_CAP,       "category:B" )
  r.Rblock_editor_add_kind( block_editor_00, "cB",         "c",         r.R_BLOCK_C,         "category:B" )
  r.Rblock_editor_add_kind( block_editor_00, "reporterB",  "reporter",  r.R_BLOCK_REPORTER,  "category:B" )
  r.Rblock_editor_add_kind( block_editor_00, "booleanB",   "boolean",   r.R_BLOCK_BOOLEAN,   "category:B" )

  // --- context menu --
  label_03 := r.Rwidget_add_child(box_right, r.Rlabel_create("Menu is kindy fucky idk how to create menu without it showing up, or why its doubled, idk man"));
  r.Rlabel_set_wrap( label_03, r.R_TRUE )

  btn_03 := r.Rwidget_add_child(box_right, r.Rbutton_create("Button - Right Click"));
	r.Rbutton_set_style(btn_03, r.R_BUTTON_PRIMARY);
	r.Rbutton_set_clicked_callback(btn_03, btn_dummy_callback, nil);
	r.Rwidget_set_tooltip(btn_03, "this is a button");
  // menu_02 := r.Rmenu_add_menu( menu_bar_00, "menu01" )
  menu_02 := r.Rwidget_add_child( box_right, r.Rwidget_create( r.R_WIDGET_MENU ) )
  r.Rmenu_add_item( menu_02, "menu option 00" )
  r.Rmenu_add_item( menu_02, "menu option 01" )
  r.Rmenu_add_separator( menu_02 )
  r.Rmenu_add_item( menu_02, "menu option 02" )
  // r.Rwidget_set_visibility( menu_02, r.R_COLLAPSED )
  r.Rwidget_set_context_menu( btn_03, menu_02)

}
tile_item_callback :: proc "c" (tile_view: r.Rid, index: i32, item: ^r.RTileItem, user_data: rawptr)
{
  item.text   = "item 00"
  item.detail = "item detail" // or nil
  item.badge  = "badge"       // or nil
  item.icon   = data.tex_00   // or r.R_INVALID_ID 
  // item.uv          // f32[4]
  // item.tint        // f32[4]
  // item.icon_radius // f32
  // item.text_color  // f32[3]
}

fill_right_box_layout :: proc( box_right: r.Rid )
{
  // --- hbox ---
  r.Rwidget_add_child(box_right, r.Rlabel_create("HBOX:"))
  hbox := r.Rwidget_add_child(box_right, r.Rwidget_create(r.R_WIDGET_HBOX));
	r.Rpanel_set_spacing( hbox, 8.0 )
	r.Rslot_set_halign( hbox, r.R_HALIGN_LEFT )
  for i in 0..<5
  {
    r.Rwidget_add_child( hbox, r.Rbutton_create("Button"));
  }
  // --- vbox ---
  r.Rwidget_add_child(box_right, r.Rlabel_create("VBOX:"))
  vbox := r.Rwidget_add_child(box_right, r.Rwidget_create(r.R_WIDGET_VBOX));
	r.Rpanel_set_spacing( vbox, 8.0 )
	r.Rslot_set_valign( vbox, r.R_VALIGN_TOP )
  for i in 0..<5
  {
    r.Rwidget_add_child( vbox, r.Rbutton_create("Button"));
  }

  // --- row ---
  r.Rwidget_add_child(box_right, r.Rlabel_create("row aka just vbox:"))
  
  row := r.Rwidget_add_child(box_right, r.Rwidget_create(r.R_WIDGET_HBOX));
	r.Rpanel_set_spacing(row, 8.0);
	r.Rslot_set_halign(row, r.R_HALIGN_CENTER);

  btn_00 := r.Rwidget_add_child(row, r.Rbutton_create("Button"));
	r.Rbutton_set_style(btn_00, r.R_BUTTON_PRIMARY);
	r.Rbutton_set_clicked_callback(btn_00, btn_dummy_callback, nil);
	r.Rwidget_set_tooltip(btn_00, "this is a button");

  btn_01 := r.Rwidget_add_child(row, r.Rbutton_create("Button"));
	r.Rbutton_set_style(btn_01, r.R_BUTTON_PRIMARY);
	r.Rbutton_set_clicked_callback(btn_01, btn_dummy_callback, nil);
	r.Rwidget_set_tooltip(btn_01, "this is a button");

  // --- border ---
  r.Rwidget_add_child( box_right, r.Rwidget_create( r.R_WIDGET_SEPARATOR ) )
  r.Rwidget_add_child(box_right, r.Rlabel_create("border:"));

  border := r.Rwidget_add_child(box_right, r.Rwidget_create( r.R_WIDGET_BORDER ))
  r.Rborder_set_padding( border, 10, 10, 10, 10 )
  // r.Rborder_set_background( border, 0.44, 0.52, 0.98, 1.0 )
  r.Rborder_set_background( border, 0.91, 0.59, 0.60, 1.0 )
  r.Rborder_set_outline( border, 3.0, 1.0, 1.0, 1.0, 1.0 )
  BORDER_RADIUS :: 10.0
  r.Rborder_set_corner_radius( border, BORDER_RADIUS, BORDER_RADIUS, BORDER_RADIUS, BORDER_RADIUS )
  r.Rborder_set_material( border, r.R_MATERIAL_GLASS )
  r.Rborder_set_shadow( border, 1.0, 10, 10 ) // idk if this does anything

  btn_02 := r.Rwidget_add_child( border, r.Rbutton_create("Button") )
	r.Rbutton_set_style(btn_02, r.R_BUTTON_PRIMARY);
	r.Rbutton_set_clicked_callback(btn_02, btn_dummy_callback, nil);
	r.Rwidget_set_tooltip(btn_02, "this is a button");

  // --- grid ---
  r.Rwidget_add_child( box_right, r.Rwidget_create( r.R_WIDGET_SEPARATOR ) )
  r.Rwidget_add_child(box_right, r.Rlabel_create("grid:"));

  grid := r.Rwidget_add_child(box_right, r.Rwidget_create( r.R_WIDGET_GRID ))
  grid_c_00 := r.Rwidget_add_child( grid, r.Rbutton_create("Button 00") )
  r.Rslot_set_grid( grid_c_00, 0, 0 )
  grid_c_01 := r.Rwidget_add_child( grid, r.Rbutton_create("Button 01") )
  r.Rslot_set_grid( grid_c_01, 1, 0 )
  grid_c_02 := r.Rwidget_add_child( grid, r.Rbutton_create("Button 02") )
  r.Rslot_set_grid( grid_c_02, 2, 0 )
  grid_c_03 := r.Rwidget_add_child( grid, r.Rbutton_create("Button 03") )
  r.Rslot_set_grid( grid_c_03, 0, 1 )
  grid_c_04 := r.Rwidget_add_child( grid, r.Rbutton_create("Button 04") )
  r.Rslot_set_grid( grid_c_04, 1, 1 )

  // --- uniform grid ---
  r.Rwidget_add_child( box_right, r.Rwidget_create( r.R_WIDGET_SEPARATOR ) )
  r.Rwidget_add_child(box_right, r.Rlabel_create("uniform grid:"));

  u_grid := r.Rwidget_add_child(box_right, r.Rwidget_create( r.R_WIDGET_UNIFORM_GRID ))
  ugrid_c_00 := r.Rwidget_add_child( u_grid, r.Rbutton_create("Button 00") )
  r.Rslot_set_grid( ugrid_c_00, 0, 0 )
  ugrid_c_01 := r.Rwidget_add_child( u_grid, r.Rbutton_create("Button 01") )
  r.Rslot_set_grid( ugrid_c_01, 1, 0 )
  ugrid_c_02 := r.Rwidget_add_child( u_grid, r.Rbutton_create("Button 02") )
  r.Rslot_set_grid( ugrid_c_02, 2, 0 )
  ugrid_c_03 := r.Rwidget_add_child( u_grid, r.Rbutton_create("Button 03") )
  r.Rslot_set_grid( ugrid_c_03, 0, 1 )
  ugrid_c_04 := r.Rwidget_add_child( u_grid, r.Rbutton_create("Button 04") )
  r.Rslot_set_grid( ugrid_c_04, 1, 1 )

  // --- scroll box ---
  r.Rwidget_add_child( box_right, r.Rwidget_create( r.R_WIDGET_SEPARATOR ) )
  r.Rwidget_add_child(box_right, r.Rlabel_create("scroll box:"));

  data.scroll_box = r.Rwidget_add_child(box_right, r.Rwidget_create( r.R_WIDGET_SCROLL_BOX ))
  r.Rscroll_box_set_orientation( data.scroll_box, r.R_HORIZONTAL ) // or r.R_VERTICAL
  w, h : i32
  r.Rwindow_get_size( data.window, &w, &h )
  r.Rwidget_set_max_size( data.scroll_box, -1, f32(h) )
  r.Rwidget_set_min_size( data.scroll_box, -1, 40 )
  // r.Rscroll_box_set_scroll_both( scroll_box, 1 )
  // r.Rscroll_box_scroll_to_end( scroll_box ) 
  for i in 0..<25
  {
    r.Rwidget_add_child( data.scroll_box, r.Rbutton_create( fmt.caprintf("Button %v", i) ) )
  }

  // --- overlay ---
  r.Rwidget_add_child( box_right, r.Rwidget_create( r.R_WIDGET_SEPARATOR ) )
  r.Rwidget_add_child( box_right, r.Rlabel_create("overlay:") )

  overlay := r.Rwidget_add_child(box_right, r.Rwidget_create( r.R_WIDGET_OVERLAY ))
  r.Rwidget_add_child( overlay, r.Rbutton_create( "Button 00" ) )
  r.Rwidget_add_child( overlay, r.Rbutton_create( "Button 01" ) )
  
  r.Rwidget_add_child(box_right, r.Rlabel_create("overlay has two buttons but only one shows up, idk what this is for"));

  // --- size box ---
  r.Rwidget_add_child( box_right, r.Rwidget_create( r.R_WIDGET_SEPARATOR ) )
  r.Rwidget_add_child( box_right, r.Rlabel_create("size box:") )

  size_box := r.Rwidget_add_child(box_right, r.Rwidget_create( r.R_WIDGET_SIZE_BOX ))
  r.Rwidget_set_min_size( size_box, 60, 20 )
  r.Rwidget_set_max_size( size_box, 80, 40 )
  // r.Rsize_box_set_aspect_ratio( size_box, 4.0 )
	r.Rslot_set_halign( size_box, r.R_HALIGN_LEFT )
	r.Rslot_set_valign( size_box, r.R_VALIGN_TOP )
  r.Rwidget_add_child( size_box, r.Rbutton_create( "Button" ) )


  // --- spacer ---
  r.Rwidget_add_child( box_right, r.Rwidget_create( r.R_WIDGET_SEPARATOR ) )
  r.Rwidget_add_child( box_right, r.Rlabel_create("spacer:") )

  spacer := r.Rwidget_add_child( box_right, r.Rwidget_create( r.R_WIDGET_SPACER ) )
  r.Rspacer_set_size( spacer, 100, 100 )

  // --- splitter ---
  r.Rwidget_add_child( box_right, r.Rwidget_create( r.R_WIDGET_SEPARATOR ) )
  r.Rwidget_add_child( box_right, r.Rlabel_create("splitter:") )

  splitter := r.Rwidget_add_child( box_right, r.Rwidget_create( r.R_WIDGET_SPLITTER ) )
  r.Rsplitter_set_orientation( splitter, r.R_HORIZONTAL ) // or r.R_VERTICAL
  r.Rsplitter_set_min_pane_size( splitter, 80 )
  r.Rwidget_add_child( splitter, r.Rbutton_create( "Button 00" ) )
  r.Rwidget_add_child( splitter, r.Rbutton_create( "Button 01" ) )
  r.Rwidget_add_child( splitter, r.Rbutton_create( "Button 02" ) )
  r.Rwidget_add_child( splitter, r.Rbutton_create( "Button 03" ) )

  // --- wrap box ---
  r.Rwidget_add_child( box_right, r.Rwidget_create( r.R_WIDGET_SEPARATOR ) )
  r.Rwidget_add_child( box_right, r.Rlabel_create("wrap box:") )

  wrap_box := r.Rwidget_add_child( box_right, r.Rwidget_create( r.R_WIDGET_WRAP_BOX ) )
  for i in 0..<25
  {
    r.Rwidget_add_child( wrap_box, r.Rbutton_create( fmt.caprintf("Button %v", i) ) )
  }

  // --- canvas ---
  r.Rwidget_add_child( box_right, r.Rwidget_create( r.R_WIDGET_SEPARATOR ) )
  r.Rwidget_add_child( box_right, r.Rlabel_create("canvas:") )

  canvas := r.Rwidget_add_child( box_right, r.Rwidget_create( r.R_WIDGET_CANVAS ) )
  canvas_c_00 := r.Rwidget_add_child( canvas, r.Rbutton_create( "Button 0.5" ) )
  r.Rslot_set_anchors( canvas_c_00, 0.5, 0.5, 0.5, 0.5 )
  canvas_c_01 := r.Rwidget_add_child( canvas, r.Rbutton_create( "Button 0.25" ) )
  r.Rslot_set_anchors( canvas_c_01, 0.25, 0.25, 0.25, 0.25 )

  spacer_01 := r.Rwidget_add_child( box_right, r.Rwidget_create( r.R_WIDGET_SPACER ) )
  r.Rspacer_set_size( spacer_01, 100, 100 )


  // --- dock area ---
  r.Rwidget_add_child( box_right, r.Rwidget_create( r.R_WIDGET_SEPARATOR ) )
  r.Rwidget_add_child( box_right, r.Rlabel_create("dock area:") )

  row_01 := r.Rwidget_add_child(box_right, r.Rwidget_create(r.R_WIDGET_HBOX));
	r.Rpanel_set_spacing( row_01, 8.0 )
	r.Rslot_set_halign( row_01, r.R_HALIGN_FILL )
	r.Rslot_set_valign( row_01, r.R_VALIGN_FILL )

  dock_area_00 := r.Rwidget_add_child( row_01, r.Rwidget_create( r.R_WIDGET_DOCK_AREA ) )
  dock_area_01 := r.Rwidget_add_child( row_01, r.Rwidget_create( r.R_WIDGET_DOCK_AREA ) )
  dock_area_02 := r.Rwidget_add_child( row_01, r.Rwidget_create( r.R_WIDGET_DOCK_AREA ) )
  DOCK_AREA_SIZE :: 100
  r.Rwidget_set_min_size( dock_area_00, DOCK_AREA_SIZE * 2, DOCK_AREA_SIZE )
  r.Rwidget_set_min_size( dock_area_01, DOCK_AREA_SIZE * 2, DOCK_AREA_SIZE )
  r.Rwidget_set_min_size( dock_area_02, DOCK_AREA_SIZE * 2, DOCK_AREA_SIZE )

	panel_00 := r.Rwidget_add_child( dock_area_00, r.Rwidget_create( r.R_WIDGET_VBOX ) )
	r.Rpanel_set_spacing( panel_00, 12.0 )
	r.Rslot_set_halign(panel_00, r.R_HALIGN_FILL )
	r.Rslot_set_valign(panel_00, r.R_VALIGN_FILL )
  r.Rslot_set_title( panel_00, "Panel 00" )
  r.Rwidget_add_child( panel_00, r.Rlabel_create("Label") )
  r.Rwidget_add_child( panel_00, r.Rbutton_create("Button") )

	panel_01 := r.Rwidget_add_child( dock_area_00, r.Rwidget_create( r.R_WIDGET_VBOX ) )
	r.Rpanel_set_spacing( panel_01, 12.0 )
	r.Rslot_set_halign(panel_01, r.R_HALIGN_FILL )
	r.Rslot_set_valign(panel_01, r.R_VALIGN_FILL )
  r.Rslot_set_title( panel_01, "Panel 01" )
  r.Rwidget_add_child( panel_01, r.Rlabel_create("Label") )
  r.Rwidget_add_child( panel_01, r.Rbutton_create("Button") )

	panel_02 := r.Rwidget_add_child( dock_area_01, r.Rwidget_create( r.R_WIDGET_VBOX ) )
	r.Rpanel_set_spacing( panel_02, 12.0 )
	r.Rslot_set_halign(panel_02, r.R_HALIGN_FILL )
	r.Rslot_set_valign(panel_02, r.R_VALIGN_FILL )
  r.Rslot_set_title( panel_02, "Panel 02" )
  r.Rwidget_add_child( panel_02, r.Rlabel_create("Label") )
  r.Rwidget_add_child( panel_02, r.Rbutton_create("Button") )

	label_00 := r.Rwidget_add_child( box_right, r.Rlabel_create( "Docking doesnt work properly, dont know if its broken or if im doing it wrong" ) )
	r.Rlabel_set_text_size( label_00, 15.0 )
	r.Rlabel_set_color( label_00, 1.0, 0.0, 0.0, 1.0 )
	r.Rslot_set_halign( label_00, r.R_HALIGN_LEFT )
  r.Rlabel_set_wrap( label_00, r.R_TRUE )
}

fill_right_box_style :: proc( box_right: r.Rid )
{
  row_00 := r.Rwidget_add_child(box_right, r.Rwidget_create(r.R_WIDGET_HBOX));
	r.Rpanel_set_spacing(row_00, 8.0);
	r.Rslot_set_halign(row_00, r.R_HALIGN_CENTER);

  btn_00 := r.Rwidget_add_child(row_00, r.Rbutton_create("Theme Dark"));
	r.Rbutton_set_style(btn_00, r.R_BUTTON_PRIMARY);
	r.Rbutton_set_clicked_callback(btn_00, btn_theme_dark_callback, nil);
	r.Rwidget_set_tooltip(btn_00, "this is a button");
  r.Rwidget_set_theme( btn_00, "Dark" )

  btn_01 := r.Rwidget_add_child( row_00, r.Rbutton_create("Theme Light"));
	r.Rbutton_set_style(btn_01, r.R_BUTTON_PRIMARY);
	r.Rbutton_set_clicked_callback(btn_01, btn_theme_light_callback, nil);
	r.Rwidget_set_tooltip(btn_01, "this is a button");
  r.Rwidget_set_theme( btn_01, "Light" )

  row_01 := r.Rwidget_add_child(box_right, r.Rwidget_create(r.R_WIDGET_HBOX));
	r.Rpanel_set_spacing(row_01, 8.0);
	r.Rslot_set_halign(row_01, r.R_HALIGN_CENTER);

  btn_02 := r.Rwidget_add_child(row_01, r.Rbutton_create("Theme Glass Dark"));
	r.Rbutton_set_style(btn_02, r.R_BUTTON_PRIMARY);
	r.Rbutton_set_clicked_callback(btn_02, btn_theme_glass_dark_callback, nil);
	r.Rwidget_set_tooltip(btn_02, "this is a button");
  r.Rwidget_set_theme( btn_02, "GlassDark" )

  btn_03 := r.Rwidget_add_child(row_01, r.Rbutton_create("Theme Glass Light"));
	r.Rbutton_set_style(btn_03, r.R_BUTTON_PRIMARY);
	r.Rbutton_set_clicked_callback(btn_03, btn_theme_glass_light_callback, nil);
	r.Rwidget_set_tooltip(btn_03, "this is a button");
  r.Rwidget_set_theme( btn_03, "GlassLight" )

  row_02 := r.Rwidget_add_child(box_right, r.Rwidget_create(r.R_WIDGET_HBOX));
	r.Rpanel_set_spacing(row_02, 8.0);
	r.Rslot_set_halign(row_02, r.R_HALIGN_CENTER);

  btn_04 := r.Rwidget_add_child(row_02, r.Rbutton_create("Theme High Contrast Dark"));
	r.Rbutton_set_style(btn_04, r.R_BUTTON_PRIMARY);
	r.Rbutton_set_clicked_callback(btn_04, btn_theme_high_contrast_dark_callback, nil);
	r.Rwidget_set_tooltip(btn_04, "this is a button");
  r.Rwidget_set_theme( btn_04, "HighContrastDark" )

  btn_05 := r.Rwidget_add_child(row_02, r.Rbutton_create("Theme High Contrast Light"));
	r.Rbutton_set_style(btn_05, r.R_BUTTON_PRIMARY);
	r.Rbutton_set_clicked_callback(btn_05, btn_theme_high_contrast_light_callback, nil);
	r.Rwidget_set_tooltip(btn_05, "this is a button");
  r.Rwidget_set_theme( btn_05, "HighContrastLight" )

  r.Rwidget_add_child( box_right, r.Rwidget_create( r.R_WIDGET_SEPARATOR ) )

  btn_06 := r.Rwidget_add_child(box_right, r.Rbutton_create("Transition - Fade"));
	r.Rbutton_set_style(btn_06, r.R_BUTTON_PRIMARY);
	r.Rbutton_set_clicked_callback(btn_06, btn_transition_fade_callback, nil);
	r.Rwidget_set_tooltip(btn_06, "this is a button");
  r.Rwidget_set_transition( btn_06, r.R_TRANSITION_FADE, 0.5 )

  btn_07 := r.Rwidget_add_child(box_right, r.Rbutton_create("Transition - Pop"));
	r.Rbutton_set_style(btn_07, r.R_BUTTON_PRIMARY);
	r.Rbutton_set_clicked_callback(btn_07, btn_transition_pop_callback, nil);
	r.Rwidget_set_tooltip(btn_07, "this is a button");
  r.Rwidget_set_transition( btn_07, r.R_TRANSITION_POP, 0.5 )

  btn_08 := r.Rwidget_add_child(box_right, r.Rbutton_create("Transition - Zoom"));
	r.Rbutton_set_style(btn_08, r.R_BUTTON_PRIMARY);
	r.Rbutton_set_clicked_callback(btn_08, btn_transition_zoom_callback, nil);
	r.Rwidget_set_tooltip(btn_08, "this is a button");
  r.Rwidget_set_transition( btn_08, r.R_TRANSITION_ZOOM, 0.5 )


  row_03 := r.Rwidget_add_child(box_right, r.Rwidget_create(r.R_WIDGET_HBOX));
	r.Rpanel_set_spacing(row_03, 8.0);
	r.Rslot_set_halign(row_03, r.R_HALIGN_CENTER);

  btn_09 := r.Rwidget_add_child(row_03, r.Rbutton_create("Transition - Fly Up"));
	r.Rbutton_set_style(btn_09, r.R_BUTTON_PRIMARY);
	r.Rbutton_set_clicked_callback(btn_09, btn_transition_fly_up_callback, nil);
	r.Rwidget_set_tooltip(btn_09, "this is a button");
  r.Rwidget_set_transition( btn_09, r.R_TRANSITION_FLY_UP, 0.5 )

  btn_10 := r.Rwidget_add_child(row_03, r.Rbutton_create("Transition - Fly Down"));
	r.Rbutton_set_style(btn_10, r.R_BUTTON_PRIMARY);
	r.Rbutton_set_clicked_callback(btn_10, btn_transition_fly_down_callback, nil);
	r.Rwidget_set_tooltip(btn_10, "this is a button");
  r.Rwidget_set_transition( btn_10, r.R_TRANSITION_FLY_DOWN, 0.5 )

  btn_11 := r.Rwidget_add_child(row_03, r.Rbutton_create("Transition - Fly Left"));
	r.Rbutton_set_style(btn_11, r.R_BUTTON_PRIMARY);
	r.Rbutton_set_clicked_callback(btn_11, btn_transition_fly_left_callback, nil);
	r.Rwidget_set_tooltip(btn_11, "this is a button");
  r.Rwidget_set_transition( btn_11, r.R_TRANSITION_FLY_LEFT, 0.5 )

  btn_12 := r.Rwidget_add_child(row_03, r.Rbutton_create("Transition - Fly Right"));
	r.Rbutton_set_style(btn_12, r.R_BUTTON_PRIMARY);
	r.Rbutton_set_clicked_callback(btn_12, btn_transition_fly_right_callback, nil);
	r.Rwidget_set_tooltip(btn_12, "this is a button");
  r.Rwidget_set_transition( btn_12, r.R_TRANSITION_FLY_RIGHT, 0.5 )

  btn_13 := r.Rwidget_add_child(box_right, r.Rbutton_create("Transition - Drop"));
	r.Rbutton_set_style(btn_13, r.R_BUTTON_PRIMARY);
	r.Rbutton_set_clicked_callback(btn_13, btn_transition_drop_callback, nil);
	r.Rwidget_set_tooltip(btn_13, "this is a button");
  r.Rwidget_set_transition( btn_13, r.R_TRANSITION_DROP, 0.5 )

  row_04 := r.Rwidget_add_child(box_right, r.Rwidget_create(r.R_WIDGET_HBOX));
	r.Rpanel_set_spacing(row_04, 8.0);
	r.Rslot_set_halign(row_04, r.R_HALIGN_CENTER);

  btn_14 := r.Rwidget_add_child(row_04, r.Rbutton_create("Transition - Slide Left"));
	r.Rbutton_set_style(btn_14, r.R_BUTTON_PRIMARY);
	r.Rbutton_set_clicked_callback(btn_14, btn_transition_slide_left_callback, nil);
	r.Rwidget_set_tooltip(btn_14, "this is a button");
  r.Rwidget_set_transition( btn_14, r.R_TRANSITION_SLIDE_LEFT, 0.5 )

  btn_15 := r.Rwidget_add_child(row_04, r.Rbutton_create("Transition - Slide Right"));
	r.Rbutton_set_style(btn_15, r.R_BUTTON_PRIMARY);
	r.Rbutton_set_clicked_callback(btn_15, btn_transition_slide_right_callback, nil);
	r.Rwidget_set_tooltip(btn_15, "this is a button");
  r.Rwidget_set_transition( btn_15, r.R_TRANSITION_SLIDE_RIGHT, 0.5 )

  // --- material ---

  row_05 := r.Rwidget_add_child(box_right, r.Rwidget_create(r.R_WIDGET_HBOX));
	r.Rpanel_set_spacing(row_05, 8.0);
	r.Rslot_set_halign(row_05, r.R_HALIGN_CENTER);

  btn_16 := r.Rwidget_add_child(row_05, r.Rbutton_create("Material - Solid"));
	r.Rbutton_set_style(btn_16, r.R_BUTTON_PRIMARY);
	r.Rbutton_set_clicked_callback(btn_16, btn_material_solid_callback, nil);
	r.Rwidget_set_tooltip(btn_16, "this is a button");
  r.Rwidget_set_material( btn_16, r.R_MATERIAL_SOLID )

  btn_17 := r.Rwidget_add_child(row_05, r.Rbutton_create("Material - Glass"));
	r.Rbutton_set_style(btn_17, r.R_BUTTON_PRIMARY);
	r.Rbutton_set_clicked_callback(btn_17, btn_material_glass_callback, nil);
	r.Rwidget_set_tooltip(btn_17, "this is a button");
  r.Rwidget_set_material( btn_17, r.R_MATERIAL_GLASS )

  btn_18 := r.Rwidget_add_child(row_05, r.Rbutton_create("Material - Frosted Glass"));
	r.Rbutton_set_style(btn_18, r.R_BUTTON_PRIMARY);
	r.Rbutton_set_clicked_callback(btn_18, btn_material_frosted_glass_callback, nil);
	r.Rwidget_set_tooltip(btn_18, "this is a button");
  r.Rwidget_set_material( btn_18, r.R_MATERIAL_FROSTED_GLASS )

  btn_19 := r.Rwidget_add_child(row_05, r.Rbutton_create("Material - Tinted"));
	r.Rbutton_set_style(btn_19, r.R_BUTTON_PRIMARY);
	r.Rbutton_set_clicked_callback(btn_19, btn_material_tinted_glass_callback, nil);
	r.Rwidget_set_tooltip(btn_19, "this is a button");
  r.Rwidget_set_material( btn_19, r.R_MATERIAL_TINTED_GLASS )

  // --- background blur ---
  r.Rwidget_add_child( box_right, r.Rwidget_create( r.R_WIDGET_SEPARATOR ) )
  r.Rwidget_add_child( box_right, r.Rlabel_create("background blur:") )

  bg_blur := r.Rwidget_add_child( box_right, r.Rwidget_create( r.R_WIDGET_BACKGROUND_BLUR ) )
  r.Rbackground_blur_set_style( bg_blur, r.R_BLUR_FROSTED ) // also R_BLUR_PLAIN, R_BLUR_GLASS, R_BLUR_NATIVE
  // r.Rwidget_add_child( bg_blur, r.Rbutton_create( "Button" ) )
  r.Rwidget_add_child( bg_blur, r.Rlabel_create( "Text" ) )

}
btn_theme_dark_callback                :: proc "c" (button: r.Rid, user_data: rawptr) { r.Rtheme_apply( r.R_THEME_DARK) }
btn_theme_light_callback               :: proc "c" (button: r.Rid, user_data: rawptr) { r.Rtheme_apply( r.R_THEME_LIGHT) }
btn_theme_glass_dark_callback          :: proc "c" (button: r.Rid, user_data: rawptr) { r.Rtheme_apply( r.R_THEME_GLASS_DARK) }
btn_theme_glass_light_callback         :: proc "c" (button: r.Rid, user_data: rawptr) { r.Rtheme_apply( r.R_THEME_GLASS_LIGHT) }
btn_theme_high_contrast_dark_callback  :: proc "c" (button: r.Rid, user_data: rawptr) { r.Rtheme_apply( r.R_THEME_HIGH_CONTRAST_DARK) }
btn_theme_high_contrast_light_callback :: proc "c" (button: r.Rid, user_data: rawptr) { r.Rtheme_apply( r.R_THEME_HIGH_CONTRAST_LIGHT) }
btn_transition_fade_callback :: proc "c" (button: r.Rid, user_data: rawptr) { r.Rwidget_play_transition( button, r.R_TRANSITION_FADE, 1.0) }
btn_transition_pop_callback :: proc "c" (button: r.Rid, user_data: rawptr) { r.Rwidget_play_transition( button, r.R_TRANSITION_POP, 1.0) }
btn_transition_zoom_callback :: proc "c" (button: r.Rid, user_data: rawptr) { r.Rwidget_play_transition( button, r.R_TRANSITION_ZOOM, 1.0) }
btn_transition_fly_up_callback :: proc "c" (button: r.Rid, user_data: rawptr) { r.Rwidget_play_transition( button, r.R_TRANSITION_FLY_UP, 1.0) }
btn_transition_fly_down_callback :: proc "c" (button: r.Rid, user_data: rawptr) { r.Rwidget_play_transition( button, r.R_TRANSITION_FLY_DOWN, 1.0) }
btn_transition_fly_left_callback :: proc "c" (button: r.Rid, user_data: rawptr) { r.Rwidget_play_transition( button, r.R_TRANSITION_FLY_LEFT, 1.0) }
btn_transition_fly_right_callback :: proc "c" (button: r.Rid, user_data: rawptr) { r.Rwidget_play_transition( button, r.R_TRANSITION_FLY_RIGHT, 1.0) }
btn_transition_drop_callback :: proc "c" (button: r.Rid, user_data: rawptr) { r.Rwidget_play_transition( button, r.R_TRANSITION_DROP, 1.0) }
btn_transition_slide_left_callback :: proc "c" (button: r.Rid, user_data: rawptr) { r.Rwidget_play_transition( button, r.R_TRANSITION_SLIDE_LEFT, 1.0) }
btn_transition_slide_right_callback :: proc "c" (button: r.Rid, user_data: rawptr) { r.Rwidget_play_transition( button, r.R_TRANSITION_SLIDE_RIGHT, 1.0) }
btn_material_solid_callback :: proc "c" (button: r.Rid, user_data: rawptr) { r.Rtheme_set_material( r.R_MATERIAL_SOLID ) }
btn_material_glass_callback :: proc "c" (button: r.Rid, user_data: rawptr) { r.Rtheme_set_material( r.R_MATERIAL_GLASS ) }
btn_material_frosted_glass_callback :: proc "c" (button: r.Rid, user_data: rawptr) { r.Rtheme_set_material( r.R_MATERIAL_FROSTED_GLASS ) }
btn_material_tinted_glass_callback :: proc "c" (button: r.Rid, user_data: rawptr) { r.Rtheme_set_material( r.R_MATERIAL_TINTED_GLASS ) }
// btn_material_default_callback :: proc "c" (button: r.Rid, user_data: rawptr) { r.Rtheme_set_material( r.R_MATERIAL_DEFAULT ) }
