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

	    public Gtk.ComboBoxText color_rule_dropdown;
	    public Gtk.Box tbox;
	    public Gtk.Box sbox;

	    public signal void clicked ();
	    public signal void toggled ();
	    
	    public string color;
	    public string rule_color;
	    public string rule_color1;
	    public string rule_color2;
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
            
            color = "#FF0000";
            
            // Icon intentionally null so it becomes a badge instead.
            icon.halign = Gtk.Align.START;
            icon.valign = Gtk.Align.CENTER;
            
            color_rule_dropdown = new Gtk.ComboBoxText ();
            color_rule_dropdown.append_text("Analogous");
            color_rule_dropdown.append_text("Complementary");
            color_rule_dropdown.append_text("Triadic");
            color_rule_dropdown.append_text("Tetradic");
            color_rule_dropdown.append_text("Monochrome");
            color_rule_dropdown.set_active(0);
            color_rule_dropdown.margin_start = color_rule_dropdown.margin_end = 12;
            color_rule_dropdown.margin_top = 30;
            color_box.append (color_rule_dropdown);
          
            var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            box.set_size_request(64, 32);
            box.set_halign(Gtk.Align.CENTER);
            box.get_style_context ().add_class ("clr-preview-rule-left");
            sbox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            sbox.set_size_request(64, 32);
            sbox.set_halign(Gtk.Align.CENTER);
            sbox.set_visible(false);
            sbox.get_style_context ().add_class ("clr-preview-rule-middle1");
            tbox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            tbox.set_size_request(64, 32);
            tbox.set_halign(Gtk.Align.CENTER);
            tbox.set_visible(false);
            tbox.get_style_context ().add_class ("clr-preview-rule-middle2");
            var ubox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            ubox.set_size_request(64, 32);
            ubox.set_halign(Gtk.Align.CENTER);
            ubox.get_style_context ().add_class ("clr-preview-rule-right");
            
            var mbox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            mbox.set_halign(Gtk.Align.CENTER);
            mbox.append (box);
            mbox.append (sbox);
            mbox.append (tbox);
            mbox.append (ubox);
            
            color_box.append (mbox);
            color_label.set_label (color.up());
            
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
                setup_color_rules.begin (color, hue, s, v, color_rule_dropdown, sbox, tbox);
            });
            
            hue_slider.on_value_changed.connect ((hue) => {
                double x, y, s, v;
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

                setup_color_rules.begin (color, hue, s, v, color_rule_dropdown, sbox, tbox);
            });

            double hue = hue_slider.get_value () / 360;
            double s, v;
            da.pos_to_sv (out s, out v);
            setup_color_rules.begin (color, hue, s, v, color_rule_dropdown, sbox, tbox);

            color_rule_dropdown.changed.connect(() => {
                setup_color_rules.begin (color, hue, s, v, color_rule_dropdown, sbox, tbox);
            });

            this.set_size_request (360, 360);
            var adwsm = Adw.StyleManager.get_default ();
            adwsm.set_color_scheme (Adw.ColorScheme.PREFER_LIGHT);
			this.show ();
		}

		public async void setup_color_rules (string color, double hue, double s, double v, Gtk.ComboBoxText? crd, Gtk.Box? sbox, Gtk.Box? tbox) {
		    switch (crd.get_active ()) {
                case 0:
                    da.pos_to_sv (out s, out v);
                    if (hue <= 0.5) {
                        Gtk.hsv_to_rgb ((float)hue+(float)0.1, (float)s, (float)v, out active_color.red, out active_color.green, out active_color.blue);
                        var pc = Utils.make_hex((float)Utils.make_srgb(active_color.red),
                                                (float)Utils.make_srgb(active_color.green),
                                                (float)Utils.make_srgb(active_color.blue));
                        update_theme(color.up(), pc.up(), pc.up(), pc.up());
                    } else if (hue > 0.5) {
                        Gtk.hsv_to_rgb ((float)hue-(float)0.1, (float)s, (float)v, out active_color.red, out active_color.green, out active_color.blue);
                        var pc = Utils.make_hex((float)Utils.make_srgb(active_color.red),
                                                (float)Utils.make_srgb(active_color.green),
                                                (float)Utils.make_srgb(active_color.blue));
                        update_theme(color.up(), pc.up(), pc.up(), pc.up());
                    } else if (hue == 0.0) {
                        Gtk.hsv_to_rgb ((float)hue+(float)0.1, (float)s, (float)v, out active_color.red, out active_color.green, out active_color.blue);
                        var pc = Utils.make_hex((float)Utils.make_srgb(active_color.red),
                                                (float)Utils.make_srgb(active_color.green),
                                                (float)Utils.make_srgb(active_color.blue));
                        update_theme(color.up(), pc.up(), pc.up(), pc.up());
                    } else if (hue == 1.0) {
                        Gtk.hsv_to_rgb ((float)hue-(float)0.1, (float)s, (float)v, out active_color.red, out active_color.green, out active_color.blue);
                        var pc = Utils.make_hex((float)Utils.make_srgb(active_color.red),
                                                (float)Utils.make_srgb(active_color.green),
                                                (float)Utils.make_srgb(active_color.blue));
                        update_theme(color.up(), pc.up(), pc.up(), pc.up());
                    }
                    sbox.set_visible (false);
                    tbox.set_visible (false);
                    break;
                case 1:
                    var h = (hue_shift (hue_slider.get_value (), 180.0)) / 360;
                    double cs, cv;
                    da.pos_to_sv (out cs, out cv);
                    Gtk.hsv_to_rgb ((float)h, (float)cs, (float)cv, out active_color.red, out active_color.green, out active_color.blue);
                    var pc = Utils.make_hex((float)Utils.make_srgb(active_color.red),
                                            (float)Utils.make_srgb(active_color.green),
                                            (float)Utils.make_srgb(active_color.blue));

                    update_theme(color.up(), pc.up(), pc.up(), pc.up());
                    sbox.set_visible (false);
                    tbox.set_visible (false);
                    break;
                case 2:
                    double cs, cv, r, g, b;
                    string c1 = "";
                    string c2 = "";
                    da.pos_to_sv (out cs, out cv);
                    Gtk.hsv_to_rgb ((float)hue, (float)s, (float)v, out r, out g, out b);

                    if (r <= 0.5) {
                        c1 = color_mixer(r, r+0.5, g, 0.5, b, 0.0);
                    } else if (r > 0.5) {
                        c1 = color_mixer(r, r-0.5, g, 0.5, b, 0.0);
                    } else if (r == 0.0) {
                        c1 = color_mixer(r, r+0.5, g, 0.5, b, 0.0);
                    } else if (r == 1.0) {
                        c1 = color_mixer(r, r-0.5, g, 0.5, b, 0.0);
                    }

                    if (g <= 0.5) {
                        c2 = color_mixer(r, 0.0, g, g+0.5, b, 0.5);
                    } else if (g > 0.5) {
                        c2 = color_mixer(r, 0.0, g, g-0.5, b, 0.5);
                    } else if (g == 0.0) {
                        c2 = color_mixer(r, 0.0, g, g+0.5, b, 0.5);
                    } else if (g == 1.0) {
                        c2 = color_mixer(r, 0.0, g, g-0.5, b, 0.5);
                    }

                    sbox.set_visible (true);
                    tbox.set_visible (false);
                    update_theme(color.up(), c2.up(), c1.up(), c1.up());
                    break;
                case 3:
                    double cs, cv, r, g, b;
                    string c1 = "";
                    string c2 = "";
                    string c3 = "";
                    da.pos_to_sv (out cs, out cv);
                    Gtk.hsv_to_rgb ((float)hue, (float)s, (float)v, out r, out g, out b);

                    if (r <= 0.5) {
                        c1 = color_mixer(r, r+0.5, g, 0.0, b, 0.0);
                    } else if (r > 0.5) {
                        c1 = color_mixer(r, r-0.5, g, 0.0, b, 0.0);
                    } else if (r == 0.0) {
                        c1 = color_mixer(r, r+0.5, g, 0.0, b, 0.0);
                    } else if (r == 1.0) {
                        c1 = color_mixer(r, r-0.5, g, 0.0, b, 0.0);
                    }

                    if (g <= 0.5) {
                        c2 = color_mixer(r, 0.0, g, g+0.5, b, 0.0);
                    } else if (g > 0.5) {
                        c2 = color_mixer(r, 0.0, g, g-0.5, b, 0.0);
                    } else if (g == 0.0) {
                        c2 = color_mixer(r, 0.0, g, g+0.5, b, 0.0);
                    } else if (g == 1.0) {
                        c2 = color_mixer(r, 0.0, g, g-0.5, b, 0.0);
                    }

                    if (b <= 0.5) {
                        c3 = color_mixer(r, 0.0, g, 0.0, b, b+0.5);
                    } else if (b > 0.5) {
                        c3 = color_mixer(r, 0.0, g, 0.0, b, b-0.5);
                    } else if (b == 0.0) {
                        c3 = color_mixer(r, 0.0, g, 0.0, b, b+0.5);
                    } else if (b == 1.0) {
                        c3 = color_mixer(r, 0.0, g, 0.0, b, b-0.5);
                    }

                    sbox.set_visible (true);
                    tbox.set_visible (true);
                    update_theme(color.up(), c2.up(), c3.up(), c1.up());
                    break;
                case 4:
                    double cs, cv, r, g, b;
                    da.pos_to_sv (out cs, out cv);
                    Gtk.hsv_to_rgb ((float)hue, (float)s, (float)v, out r, out g, out b);

                    var c1 = color_mixer(r, 1.0, g, 1.0, b, 1.0);
                    var c2 = color_mixer(r, 0.5, g, 0.5, b, 0.5);
                    var c3 = color_mixer(r, 0.0, g, 0.0, b, 0.0);

                    sbox.set_visible (true);
                    tbox.set_visible (true);
                    update_theme(color.up(), c2.up(), c3.up(), c1.up());
                    break;
            }
		}

		public double hue_shift (double h, double s) {
            h += s; while (h >= 360.0) h -= 360.0; while (h < 0.0) h += 360.0; return h;
        }

        public string color_mixer(double red, double red2, double green, double green2, double blue, double blue2) {
            string r_hex = "%02x".printf ((uint) (((red + red2)/2) * 255));
            string g_hex = "%02x".printf ((uint) (((green + green2)/2) * 255));
            string b_hex = "%02x".printf ((uint) (((blue + blue2)/2) * 255));

            return @"#$r_hex$g_hex$b_hex".up ();
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

                        float h,s,v,sr,sg,sb,r,g,b;
                        Gtk.rgb_to_hsv(color_portal.red, color_portal.green, color_portal.blue, out h, out s, out v);
                        Gtk.hsv_to_rgb (h, 1, 1, out sr, out sg, out sb);
                        Gtk.hsv_to_rgb (h, s, v, out r, out g, out b);
                        da.update_surface_color (sr, sg, sb);
                        da.sv_to_pos (s, v);
                        da.queue_draw();
                        
                        var pc = Utils.make_hex((float)Utils.make_srgb(r),
                                                (float)Utils.make_srgb(g), 
                                                (float)Utils.make_srgb(b));

                        color_label.set_label (pc.up());
                        color = pc.up();
                        active_color = color_portal;
                        da.active_color = color_portal;

                        hue_slider.set_value(h*360);

                        setup_color_rules.begin (color, h, s, v, this.color_rule_dropdown, this.sbox, this.tbox);

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
        
        public void update_theme(string? color, string? rule_color1, string? rule_color2, string? rule_color) {
            var css_provider = new Gtk.CssProvider();
            string style = null;
            style = """
            .clr-preview {
                background: %s;
                border: 1px solid @borders;
                border-radius: 9999px;
            }
            .clr-preview-rule-left {
                background: %s;
                border-radius: 8px 0 0 8px;
                min-height: 32px;
	            min-width: 32px;
	            outline: 1px solid @borders;
            }
            .clr-preview-rule-middle1 {
                background: %s;
                border-radius: 0;
                min-height: 32px;
	            min-width: 32px;
	            outline: 1px solid @borders;
            }
            .clr-preview-rule-middle2 {
                background: %s;
                border-radius: 0;
                min-height: 32px;
	            min-width: 32px;
	            outline: 1px solid @borders;
            }
            .clr-preview-rule-right {
                background: %s;
                border-radius: 0 8px 8px 0;
                min-height: 32px;
	            min-width: 32px;
	            outline: 1px solid @borders;
            }
            """.printf(color,
                       color,
                       rule_color1,
                       rule_color2,
                       rule_color);

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
