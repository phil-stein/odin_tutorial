package main
/**
 * Raven example - hello
 * The smallest program: a window built with the C API, a label and a button.
 *
 * Every object is an opaque handle (Rid). Layout follows Slate: a panel
 * arranges its children, and each child carries a *slot* that tells the panel
 * how to place it (padding, alignment, auto or fill size).
 */

import "base:runtime"
import "core:fmt"
import "core:os"

import r "../external/raven/bindings/odin/raven"

g_label : r.Rid
g_clicks : int

btn_click_callback :: proc "c" (button: r.Rid, user_data: rawptr) 
{
  context = runtime.default_context()

  g_clicks += 1
  text := fmt.ctprintf( "Clicked %d times", g_clicks )
	r.Rlabel_set_text(g_label, text);
}

btn_quit_callback :: proc "c" ( button: r.Rid, user_data: rawptr) 
{
  context = runtime.default_context()

	r.Rquit(0)
}

raven_error_callback :: proc "c" (code: r.RError, severity: r.RSeverity, detail: cstring) 
{
  context = runtime.default_context()

  fmt.printfln( "[Raven] %s (%s): %s", r.Rerror_to_string(code), r.Rseverity_to_string(severity), detail )
}

main :: proc() 
{
	window, box, title, row, button, quit : r.Rid

  desc: r.RInitDesc
	desc.backend = r.R_BACKEND_VULKAN;
	desc.app_name = "my_app_name"
  when ODIN_DEBUG { desc.enable_validation = true }

	r.Rerror_set_callback(raven_error_callback);
	if r.Rinit_ex( &desc ) == 0
  {
    fmt.println( desc.app_name, ": cannot start Raven" )
		return 
	}

	// window = r.Rwindow_create( "Hello Raven", 420, 220, r.R_WINDOW_DEFAULT )
	window = r.Rwindow_create( "Hello Raven", 620, 420, r.R_WINDOW_DEFAULT )

	/* a vertical box centered in the window */
	box = r.Rwidget_create( r.R_WIDGET_VBOX );
	r.Rpanel_set_spacing( box, 12.0 );
	r.Rslot_set_halign(box, r.R_HALIGN_CENTER);
	r.Rslot_set_valign(box, r.R_VALIGN_CENTER);
	r.Rwindow_set_content(window, box);

	title = r.Rwidget_add_child(box, r.Rlabel_create("Hello from Raven"));
	r.Rlabel_set_text_size(title, 24.0);
	r.Rslot_set_halign(title, r.R_HALIGN_CENTER);

	g_label = r.Rwidget_add_child(box, r.Rlabel_create("Press the button"));
	r.Rslot_set_halign(g_label, r.R_HALIGN_CENTER);

	row = r.Rwidget_add_child(box, r.Rwidget_create(r.R_WIDGET_HBOX));
	r.Rpanel_set_spacing(row, 8.0);
	r.Rslot_set_halign(row, r.R_HALIGN_CENTER);

	button = r.Rwidget_add_child(row, r.Rbutton_create("Click me"));
	r.Rbutton_set_style(button, r.R_BUTTON_PRIMARY);
	r.Rbutton_set_clicked_callback(button, btn_click_callback, nil);
	r.Rwidget_set_tooltip(button, "Counts the clicks");

	quit = r.Rwidget_add_child(row, r.Rbutton_create("Quit"));
	r.Rbutton_set_clicked_callback(quit, btn_quit_callback, nil);

	/* the loop belongs to the application: Raven draws one frame per call,
	 * and Rwait_frame sleeps until there is something to draw */
  for r.Rwait_frame(-1.0) == 1 
  {
    // if (frame) frame();
  }
	return
}

