/*
 * Copyright 2022 Lains <lainsce@airmail.cc>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */
public class Colorway.PaletteButton : Gtk.Button {
	private Gtk.CssProvider provider = new Gtk.CssProvider();
	private string _hex = "";
	private Gtk.Stack image_stack = new Gtk.Stack();
	private uint timeout_id = 0;

	public string title { get; set; }

	public string hex {
		get {
			return _hex;
		}

		construct set {
			_hex = value;
			tooltip_text = value;
			provider.load_from_data ((uint8[]) "* { background: %s; }".printf (value));
		}
	}

	public bool light {
		get {
			return has_css_class("light");
		}

		set {
			if (value) {
				add_css_class("light");
			} else {
				remove_css_class("light");
			}
		}
	}

	construct {
		visible = true;

		width_request = 64;
		height_request = 32;

		hexpand = true;
		vexpand = true;

		// We really want to set the background
		get_style_context().add_provider(provider, Gtk.STYLE_PROVIDER_PRIORITY_USER);

		image_stack.transition_type = SLIDE_UP;
		image_stack.add_named (new Gtk.Box (VERTICAL, 0), "empty");
		image_stack.add_named (new Gtk.Image.from_icon_name ("emblem-ok-symbolic"), "ok");
		image_stack.add_named (new Gtk.Image.from_icon_name ("edit-copy-symbolic"), "copy");
		image_stack.visible_child_name = "empty";
		image_stack.set_opacity (0.88);
		set_child (image_stack);

		var motion = new Gtk.EventControllerMotion ();
		motion.enter.connect (() => {
			image_stack.set_visible_child_full ("copy", SLIDE_UP);
			enter ();
		});
		motion.leave.connect (() => {
			image_stack.set_visible_child_full ("empty", SLIDE_DOWN);
			leave ();
		});
		add_controller (motion);

		var drag = new Gtk.DragSource ();
		drag.prepare.connect (() => {
		    Gdk.RGBA colour;
		    colour.parse (_hex);

		    drag.set_state (CLAIMED);

            return new Gdk.ContentProvider.for_value (colour);
		});
		drag.drag_begin.connect (() => {
	        drag.set_icon (new Gtk.WidgetPaintable (this), 0, 0);
		});
		add_controller (drag);
	}

	public PaletteButton (string hex, bool light) {
		Object (hex: hex, light: light);
	}

	public signal void enter ();
	public signal void leave ();

	public override void clicked () {
		image_stack.set_visible_child_name("ok");
		if (timeout_id != 0) {
			Source.remove(timeout_id);
		}
		timeout_id = Timeout.add_seconds(3, () => {
			image_stack.set_visible_child_full("empty", OVER_UP);
			timeout_id = 0;
			return Source.REMOVE;
		});
		get_display().get_clipboard().set_value(hex);
	}
}
