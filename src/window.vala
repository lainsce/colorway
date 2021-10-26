/* 
 * Copyright 2021 Lains
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
 */

namespace Colorway {
	[GtkTemplate (ui = "/io/github/lainsce/Colorway/window.ui")]
	public class MainWindow : Adw.ApplicationWindow {
	    [GtkChild]
	    unowned Gtk.MenuButton menu_button;
	    [GtkChild]
	    unowned Gtk.Box color_box;
	    [GtkChild]
	    unowned Gtk.Box icon;
	    [GtkChild]
	    unowned Gtk.Button color_picker_button;
	    [GtkChild]
	    unowned Gtk.Label color_label;
	    
	    public Chooser da;
	    public HueSlider hue_slider;

	    public signal void clicked ();
	    public signal void toggled ();
	    
	    public string color;
	    public Gdk.RGBA active_color;
	    
	    public SimpleActionGroup actions { get; construct; }
        public const string ACTION_PREFIX = "win.";
        public const string ACTION_ABOUT = "action_about";
        public const string ACTION_KEYS = "action_keys";
        public static Gee.MultiMap<string, string> action_accelerators = new Gee.HashMultiMap<string, string> ();
        private const GLib.ActionEntry[] ACTION_ENTRIES = {
              {ACTION_ABOUT, action_about},
              {ACTION_KEYS, action_keys},
        };

        public Adw.Application app { get; construct; }
		public MainWindow (Adw.Application app) {
			Object (
			    application: app,
			    app: app
			);
		}

		static construct {
		}

        construct {
            actions = new SimpleActionGroup ();
            actions.add_action_entries (ACTION_ENTRIES, this);
            insert_action_group ("win", actions);

            foreach (var action in action_accelerators.get_keys ()) {
                var accels_array = action_accelerators[action].to_array ();
                accels_array += null;

                app.set_accels_for_action (ACTION_PREFIX + action, accels_array);
            }
            app.set_accels_for_action("app.quit", {"<Ctrl>q"});

            weak Gtk.IconTheme default_theme = Gtk.IconTheme.get_for_display (Gdk.Display.get_default ());
            default_theme.add_resource_path ("/io/github/lainsce/Colorway");

            var builder = new Gtk.Builder.from_resource ("/io/github/lainsce/Colorway/menu.ui");
            menu_button.menu_model = (MenuModel)builder.get_object ("menu");
            
            // Icon intentionally null so it becomes a badge instead.
            icon.halign = Gtk.Align.START;
            icon.valign = Gtk.Align.CENTER;
            
            var color_rule_dropdown = new Gtk.DropDown.from_strings ({"Analogous",
                                                                  "Complementary",
                                                                  "Triadic",
                                                                  "Quadratic",
                                                                  "Monochrome"});
            color_rule_dropdown.margin_start = color_rule_dropdown.margin_end = 12;
            color_rule_dropdown.margin_top = 30;
            color_box.append (color_rule_dropdown);
            
            color = "#FF0000";
            color_label.set_label (color.up());
            update_theme(color.up());
            
            color_picker_button.clicked.connect (() => {
                pick_color.begin ();
            });
            
            Gdk.RGBA gdkrgba = {0,0,0,1};
            gdkrgba.parse(color);
            active_color = gdkrgba;
            
            da = new Chooser(gdkrgba);
            hue_slider = new HueSlider (360);
            color_box.prepend(hue_slider);
            color_box.prepend(da);
            
            da.on_sv_move.connect ((s, v) => {
                double hue = hue_slider.get_value () / 360;
                Gtk.hsv_to_rgb ((float)hue, (float)s, (float)v, out active_color.red, out active_color.green, out active_color.blue);
                
                var pc = Utils.make_hex((float)Utils.make_srgb(active_color.red),
                                        (float)Utils.make_srgb(active_color.green), 
                                        (float)Utils.make_srgb(active_color.blue));
                
                color_label.set_label (pc.up());
                color = pc.up();
                update_theme(pc.up());
            });
            
            hue_slider.on_value_changed.connect ((hue) => {
                double s, v, x, y;
                double sr, sg, sb;
                double r, g, b;
                da.pos_to_sv (out s, out v);
                Gtk.hsv_to_rgb ((float)hue, 1, 1, out sr, out sg, out sb);
                Gtk.hsv_to_rgb ((float)hue, (float)s, (float)v, out r, out g, out b);

                active_color = {(float)r, (float)g, (float)b};
                da.active_color = {(float)r, (float)g, (float)b};
                da.update_surface_color (sr, sg, sb);
                
                var pc = Utils.make_hex((float)Utils.make_srgb(r),
                                        (float)Utils.make_srgb(g), 
                                        (float)Utils.make_srgb(b));
                
                color_label.set_label (pc.up());
                color = pc.up();
                update_theme(pc.up());
            });

            this.set_size_request (360, 360);
            var adwsm = Adw.StyleManager.get_default ();
            adwsm.set_color_scheme (Adw.ColorScheme.PREFER_LIGHT);
			this.show ();
		}
		
		public async void pick_color () {
            try {
                var bus = yield Bus.get(BusType.SESSION);
                var shot = yield bus.get_proxy<org.freedesktop.portal.Screenshot>("org.freedesktop.portal.Desktop", 
                                                                                  "/org/freedesktop/portal/desktop");
                var options = new GLib.HashTable<string, GLib.Variant>(str_hash, str_equal);
                var handle = shot.pick_color ("", options);
                var request = yield bus.get_proxy<org.freedesktop.portal.Request>("org.freedesktop.portal.Desktop",
                                                                                  handle);

                request.response.connect ((response, results) => {
                    if (response == 0) {
                        debug ("User picked a color.");
                        Gdk.RGBA color_portal = {};
                        double cr, cg, cb = 0.0;
                        results.@get("color").get ("(ddd)", out cr, out cg, out cb);
                        color_portal = {(float)cr, (float)cg, (float)cb, 1};

                        var pc = Utils.make_hex((float)Utils.make_srgb(color_portal.red),
                                                (float)Utils.make_srgb(color_portal.green), 
                                                (float)Utils.make_srgb(color_portal.blue));

                        color_label.set_label (pc.up());
                        color = pc.up();
                        active_color = color_portal;
                        update_theme(pc.up());

                        pick_color.callback();
                    } else {
                       debug ("User didn't pick a color.");
                       return;
                    }
                });

                yield;
            } catch (GLib.Error error) {
                warning ("Failed to request color: %s", error.message);
            }
        }
        
        public void update_theme(string? color) {
            var css_provider = new Gtk.CssProvider();
            string style = null;
            style = """
            .clr-preview {
                background: %s;
                border: 1px solid @borders;
                border-radius: 9999px;
            }
            """.printf(color);

            css_provider.load_from_data(style.data);

            Gtk.StyleContext.add_provider_for_display (
                Gdk.Display.get_default (),
                css_provider,
                Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
            );
        }

        public void action_keys () {
            try {
                var build = new Gtk.Builder ();
                build.add_from_resource ("/io/github/lainsce/Colorway/keys.ui");
                var window =  (Gtk.ShortcutsWindow) build.get_object ("shortcuts-colorway");
                window.set_transient_for (this);
                window.show ();
            } catch (Error e) {
                warning ("Failed to open shortcuts window: %s\n", e.message);
            }
        }

        public void action_about () {
            const string COPYRIGHT = "Copyright \xc2\xa9 2021 Paulo \"Lains\" Galardi\n";

            const string? AUTHORS[] = {
                "Paulo \"Lains\" Galardi",
                null
            };

            var program_name = Config.NAME_PREFIX + _("Colorway");
            Gtk.show_about_dialog (this,
                                   "program-name", program_name,
                                   "logo-icon-name", Config.APP_ID,
                                   "version", Config.VERSION,
                                   "comments", _("Generate color pairings."),
                                   "copyright", COPYRIGHT,
                                   "authors", AUTHORS,
                                   "artists", null,
                                   "license-type", Gtk.License.GPL_3_0,
                                   "wrap-license", false,
                                   "translator-credits", _("translator-credits"),
                                   null);
        }
	}
}
