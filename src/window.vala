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
	    unowned Gtk.Box props_box;
	    [GtkChild]
	    unowned Gtk.Button color_picker_button;
	    [GtkChild]
	    unowned Gtk.Entry color_label;
	    
	    public Chooser da;
	    public HueSlider hue_slider;

	    public Gtk.ComboBoxText color_rule_dropdown;
	    public PaletteButton box;
	    public PaletteButton tbox;
	    public PaletteButton sbox;
	    public PaletteButton ubox;
	    public Gtk.Box mbox;
	    public Gtk.Label color_exported_label;

	    public signal void clicked ();
	    public signal void toggled ();
	    
	    public string color;
	    public string contrast;
	    public string rule_color;
	    public string rule_color1;
	    public string rule_color2;
	    public Gdk.RGBA active_color;
	    
	    public SimpleActionGroup actions { get; construct; }
        public const string ACTION_PREFIX = "win.";
        public const string ACTION_ABOUT = "action_about";
        public const string ACTION_KEYS = "action_keys";
        public const string ACTION_EXPORT = "action_export";
        public static Gee.MultiMap<string, string> action_accelerators = new Gee.HashMultiMap<string, string> ();
        private const GLib.ActionEntry[] ACTION_ENTRIES = {
              {ACTION_ABOUT, action_about},
              {ACTION_KEYS, action_keys},
              {ACTION_EXPORT, action_export},
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
            app.set_accels_for_action("win.action_keys", {"<Ctrl>question"});
            app.set_accels_for_action("win.action_export", {"<Ctrl>e"});

            weak Gtk.IconTheme default_theme = Gtk.IconTheme.get_for_display (Gdk.Display.get_default ());
            default_theme.add_resource_path ("/io/github/lainsce/Colorway");

            var builder = new Gtk.Builder.from_resource ("/io/github/lainsce/Colorway/menu.ui");
            menu_button.menu_model = (MenuModel)builder.get_object ("menu");
            
            color = "#ff0000";
            contrast = "#000000";
            
            color_rule_dropdown = new Gtk.ComboBoxText ();
            color_rule_dropdown.append_text(_("Analogous"));
            color_rule_dropdown.append_text(_("Complementary"));
            color_rule_dropdown.append_text(_("Triadic"));
            color_rule_dropdown.append_text(_("Tetradic"));
            color_rule_dropdown.append_text(_("Monochromatic"));
            color_rule_dropdown.set_active(0);
            color_rule_dropdown.margin_start = color_rule_dropdown.margin_end = 18;
            props_box.append (color_rule_dropdown);
          
            box = new PaletteButton ("#000", false);
            box.set_size_request(64, 32);
            box.get_style_context ().add_class ("clr-first");
            sbox = new PaletteButton ("#000", false);
            sbox.set_size_request(64, 32);
            sbox.set_visible(false);
            sbox.get_style_context ().add_class ("clr-second");
            tbox = new PaletteButton ("#000", false);
            tbox.set_size_request(64, 32);
            tbox.set_visible(false);
            tbox.get_style_context ().add_class ("clr-third");
            ubox = new PaletteButton ("#000", false);
            ubox.set_size_request(64, 32);
            ubox.get_style_context ().add_class ("clr-fourth");
            
            mbox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            mbox.set_halign(Gtk.Align.CENTER);
            mbox.set_homogeneous(true);
            mbox.width_request = 260;
            mbox.set_margin_end (18);
            mbox.set_margin_start (18);
            mbox.get_style_context ().add_class ("clr-palette");
            mbox.append (box);
            mbox.append (sbox);
            mbox.append (tbox);
            mbox.append (ubox);
            
            props_box.append (mbox);

            color_exported_label = new Gtk.Label ("");
            color_exported_label.get_style_context ().add_class ("dim-label");
            color_exported_label.get_style_context ().add_class ("clr-props-message");

            props_box.append (color_exported_label);

            color_label.set_text (color.up());
            
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
                
                color_label.set_text (pc.up());
                color = pc.up();

                if (Utils.contrast_ratio(active_color, {0,0,0,1}) > Utils.contrast_ratio(active_color, {1,1,1,1}) + 3) {
                    contrast = "#000000";
                } else {
                    contrast = "#FFFFFF";
                }

                setup_color_rules.begin (color, contrast, hue, s, v, color_rule_dropdown, sbox, tbox);
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
                
                color_label.set_text (pc.up());
                color = pc.up();

                if (Utils.contrast_ratio(active_color, {0,0,0,1}) > Utils.contrast_ratio(active_color, {1,1,1,1}) + 3) {
                    contrast = "#000000";
                } else {
                    contrast = "#FFFFFF";
                }

                setup_color_rules.begin (color, contrast, hue, s, v, color_rule_dropdown, sbox, tbox);
            });

            double hue = hue_slider.get_value () / 360;
            double s, v;
            da.pos_to_sv (out s, out v);
            setup_color_rules.begin (color, contrast, hue, s, v, color_rule_dropdown, sbox, tbox);

            color_rule_dropdown.changed.connect(() => {
                Gdk.RGBA clr = {};
                clr.parse(color_label.get_text());

                float ch,cs,cv,h,r,g,b;
                Gtk.rgb_to_hsv(clr.red, clr.green, clr.blue, out ch, out cs, out cv);
                Gtk.hsv_to_rgb(ch, cs, cv, out r, out g, out b);
                var pc = Utils.make_hex((float)Utils.make_srgb(r),
                                        (float)Utils.make_srgb(g),
                                        (float)Utils.make_srgb(b));

                color = pc.up();
                color_label.set_text (pc.up());

                if (Utils.contrast_ratio(active_color, {0,0,0,1}) > Utils.contrast_ratio(active_color, {1,1,1,1}) + 3) {
                    contrast = "#000000";
                } else {
                    contrast = "#FFFFFF";
                }

                setup_color_rules.begin (color, contrast, ch, cs, cv, color_rule_dropdown, sbox, tbox);
            });

            color_label.activate.connect(() => {
                Gdk.RGBA clr = {};
                clr.parse(color_label.get_text());

                float ch,cs,cv,h,r,g,b;
                Gtk.rgb_to_hsv(clr.red, clr.green, clr.blue, out ch, out cs, out cv);
                Gtk.hsv_to_rgb(ch, cs, cv, out r, out g, out b);
                var pc = Utils.make_hex((float)Utils.make_srgb(r),
                                        (float)Utils.make_srgb(g),
                                        (float)Utils.make_srgb(b));

                active_color = {(float)clr.red, (float)clr.green, (float)clr.blue};
                da.active_color = {(float)clr.red, (float)clr.green, (float)clr.blue};
                da.update_surface_color (clr.red, clr.green, clr.blue);
                da.sv_to_pos (cs, cv);
                da.queue_draw();

                hue_slider.set_value(ch*360);

                color = pc.up();
                color_label.set_text (pc.up());

                if (Utils.contrast_ratio(active_color, {0,0,0,1}) > Utils.contrast_ratio(active_color, {1,1,1,1}) + 3) {
                    contrast = "#000000";
                } else {
                    contrast = "#FFFFFF";
                }

                setup_color_rules.begin (color, contrast, ch, cs, cv, color_rule_dropdown, sbox, tbox);
            });

            this.set_size_request (360, 360);
            var adwsm = Adw.StyleManager.get_default ();
            adwsm.set_color_scheme (Adw.ColorScheme.PREFER_LIGHT);
			this.show ();
		}

		public async void setup_color_rules (string color, string contrast, double hue, double s, double v, Gtk.ComboBoxText? crd, PaletteButton? sbox, PaletteButton? tbox) {
		    switch (crd.get_active ()) {
                case 0:
                    da.pos_to_sv (out s, out v);
                    if (hue <= 0.5) {
                        Gtk.hsv_to_rgb ((float)hue+(float)0.1, (float)s, (float)v, out active_color.red, out active_color.green, out active_color.blue);
                        var pc = Utils.make_hex((float)Utils.make_srgb(active_color.red),
                                                (float)Utils.make_srgb(active_color.green),
                                                (float)Utils.make_srgb(active_color.blue));
                        update_theme(color.up(), contrast.up(), pc.up(), pc.up(), pc.up());
                    } else if (hue > 0.5) {
                        Gtk.hsv_to_rgb ((float)hue-(float)0.1, (float)s, (float)v, out active_color.red, out active_color.green, out active_color.blue);
                        var pc = Utils.make_hex((float)Utils.make_srgb(active_color.red),
                                                (float)Utils.make_srgb(active_color.green),
                                                (float)Utils.make_srgb(active_color.blue));
                        update_theme(color.up(), contrast.up(), pc.up(), pc.up(), pc.up());
                    } else if (hue == 0.0) {
                        Gtk.hsv_to_rgb ((float)hue+(float)0.1, (float)s, (float)v, out active_color.red, out active_color.green, out active_color.blue);
                        var pc = Utils.make_hex((float)Utils.make_srgb(active_color.red),
                                                (float)Utils.make_srgb(active_color.green),
                                                (float)Utils.make_srgb(active_color.blue));
                        update_theme(color.up(), contrast.up(), pc.up(), pc.up(), pc.up());
                    } else if (hue == 1.0) {
                        Gtk.hsv_to_rgb ((float)hue-(float)0.1, (float)s, (float)v, out active_color.red, out active_color.green, out active_color.blue);
                        var pc = Utils.make_hex((float)Utils.make_srgb(active_color.red),
                                                (float)Utils.make_srgb(active_color.green),
                                                (float)Utils.make_srgb(active_color.blue));
                        update_theme(color.up(), contrast.up(), pc.up(), pc.up(), pc.up());
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

                    update_theme(color.up(), contrast.up(), pc.up(), pc.up(), pc.up());
                    sbox.set_visible (false);
                    tbox.set_visible (false);

                    break;
                case 2:
                    var ch1 = (hue_shift (hue_slider.get_value (), 120.0)) / 360;
                    double cs1, cv1;
                    da.pos_to_sv (out cs1, out cv1);
                    Gtk.hsv_to_rgb ((float)ch1, (float)cs1, (float)cv1, out active_color.red, out active_color.green, out active_color.blue);
                    var c1 = Utils.make_hex((float)Utils.make_srgb(active_color.red),
                                            (float)Utils.make_srgb(active_color.green),
                                            (float)Utils.make_srgb(active_color.blue));

                    var ch2 = (hue_shift (hue_slider.get_value (), 240.0)) / 360;
                    double cs2, cv2;
                    da.pos_to_sv (out cs2, out cv2);
                    Gtk.hsv_to_rgb ((float)ch2, (float)cs2, (float)cv2, out active_color.red, out active_color.green, out active_color.blue);
                    var c2 = Utils.make_hex((float)Utils.make_srgb(active_color.red),
                                            (float)Utils.make_srgb(active_color.green),
                                            (float)Utils.make_srgb(active_color.blue));

                    sbox.set_visible (true);
                    tbox.set_visible (false);
                    update_theme(color.up(), contrast.up(), c2.up(), c1.up(), c1.up());

                    break;
                case 3:
                    var ch1 = (hue_shift (hue_slider.get_value (), 90.0)) / 360;
                    double cs1, cv1;
                    da.pos_to_sv (out cs1, out cv1);
                    Gtk.hsv_to_rgb ((float)ch1, (float)cs1, (float)cv1, out active_color.red, out active_color.green, out active_color.blue);
                    var c1 = Utils.make_hex((float)Utils.make_srgb(active_color.red),
                                            (float)Utils.make_srgb(active_color.green),
                                            (float)Utils.make_srgb(active_color.blue));

                    var ch2 = (hue_shift (hue_slider.get_value (), 180.0)) / 360;
                    double cs2, cv2;
                    da.pos_to_sv (out cs2, out cv2);
                    Gtk.hsv_to_rgb ((float)ch2, (float)cs2, (float)cv2, out active_color.red, out active_color.green, out active_color.blue);
                    var c2 = Utils.make_hex((float)Utils.make_srgb(active_color.red),
                                            (float)Utils.make_srgb(active_color.green),
                                            (float)Utils.make_srgb(active_color.blue));

                    var ch3 = (hue_shift (hue_slider.get_value (), 270.0)) / 360;
                    double cs3, cv3;
                    da.pos_to_sv (out cs3, out cv3);
                    Gtk.hsv_to_rgb ((float)ch3, (float)cs3, (float)cv3, out active_color.red, out active_color.green, out active_color.blue);
                    var c3 = Utils.make_hex((float)Utils.make_srgb(active_color.red),
                                            (float)Utils.make_srgb(active_color.green),
                                            (float)Utils.make_srgb(active_color.blue));

                    sbox.set_visible (true);
                    tbox.set_visible (true);
                    update_theme(color.up(), contrast.up(), c2.up(), c3.up(), c1.up());

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
                    update_theme(color.up(), contrast.up(), c2.up(), c3.up(), c1.up());

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

                        color_label.set_text (pc.up());
                        color = pc.up();
                        active_color = color_portal;
                        da.active_color = color_portal;

                        hue_slider.set_value(h*360);

                        if (Utils.contrast_ratio(active_color, {0,0,0,1}) > Utils.contrast_ratio(active_color, {1,1,1,1}) + 3) {
                            contrast = "#000000";
                        } else {
                            contrast = "#FFFFFF";
                        }

                        setup_color_rules.begin (color, contrast, h, s, v, this.color_rule_dropdown, this.sbox, this.tbox);

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
        
        public void update_theme(string? color, string? contrast, string? rule_color1, string? rule_color2, string? rule_color) {
            this.color = color;
            this.contrast = contrast;
            this.rule_color = rule_color;
            this.rule_color1 = rule_color1;
            this.rule_color2 = rule_color2;

            box.hex = color;
            sbox.hex = rule_color1;
            tbox.hex = rule_color2;
            ubox.hex = rule_color;

            Gdk.RGBA gcolor = {};
            gcolor.parse(color);
            Gdk.RGBA grcolor = {};
            grcolor.parse(rule_color);
            Gdk.RGBA grcolor1 = {};
            grcolor1.parse(rule_color1);
            Gdk.RGBA grcolor2 = {};
            grcolor2.parse(rule_color2);

            if (Utils.contrast_ratio(gcolor, {0,0,0,1}) > Utils.contrast_ratio(gcolor, {1,1,1,1}) + 3) {
                box.light = true;
            } else {
                box.light = false;
            }

            if (Utils.contrast_ratio(grcolor1, {0,0,0,1}) > Utils.contrast_ratio(grcolor1, {1,1,1,1}) + 3) {
                sbox.light = true;
            } else {
                sbox.light = false;
            }

            if (Utils.contrast_ratio(grcolor2, {0,0,0,1}) > Utils.contrast_ratio(grcolor2, {1,1,1,1}) + 3) {
                tbox.light = true;
            } else {
                tbox.light = false;
            }

            if (Utils.contrast_ratio(grcolor, {0,0,0,1}) > Utils.contrast_ratio(grcolor, {1,1,1,1}) + 3) {
                ubox.light = true;
            } else {
                ubox.light = false;
            }

            var css_provider = new Gtk.CssProvider();
            string style = null;
            style = """
            .clr-preview {
                background: %s;
                color: %s;
                border: 1px solid @borders;
                border-radius: 9999px;
            }
            """.printf(color,
                       contrast);

            css_provider.load_from_data(style.data);

            Gtk.StyleContext.add_provider_for_display (
                Gdk.Display.get_default (),
                css_provider,
                Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
            );
        }

        public void action_export () {
            var snap = new Gtk.Snapshot ();
            mbox.snapshot (snap);

            var sf = new Cairo.ImageSurface (Cairo.Format.ARGB32, 260, 32); // 260×32 is the color result box size;
            var cr = new Cairo.Context (sf);
            var node = snap.to_node ();
            node.draw(cr);

            var pb = Gdk.pixbuf_get_from_surface (sf, 0, 0, 260, 32);
            var mt = Gdk.Texture.for_pixbuf (pb);

            var display = Gdk.Display.get_default ();
            unowned var clipboard = display.get_clipboard ();
            clipboard.set_texture (mt);

            color_exported_label.set_sensitive(true);
            color_exported_label.set_text(_("Colors exported to clipboard."));

            Timeout.add(800, () => {
                color_exported_label.set_text("");
                color_exported_label.set_sensitive(false);
                return false;
            });
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
