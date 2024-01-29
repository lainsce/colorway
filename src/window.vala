/* 
 * Copyright 2022 Lains
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
	public class MainWindow : He.ApplicationWindow {
	    [GtkChild]
	    unowned Gtk.MenuButton menu_button;
	    [GtkChild]
	    unowned Gtk.Box color_box;
	    [GtkChild]
	    unowned Gtk.Box props_box;
	    [GtkChild]
	    unowned He.OverlayButton color_picker_button;
	    [GtkChild]
	    unowned He.TextField color_label;
	    
	    public Chooser da;
	    public HueSlider hue_slider;

	    public Gtk.DropDown color_rule_dropdown;
	    public PaletteButton box;
	    public PaletteButton tbox;
	    public PaletteButton sbox;
	    public PaletteButton ubox;
	    public Gtk.Box mbox;

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
        public const string ACTION_EXPORT_TXT = "action_export_txt";
        public const string ACTION_EXPORT_PNG = "action_export_png";
        public static Gee.MultiMap<string, string> action_accelerators = new Gee.HashMultiMap<string, string> ();
        private const GLib.ActionEntry[] ACTION_ENTRIES = {
              {ACTION_ABOUT, action_about},
              {ACTION_EXPORT_TXT, action_export_txt},
              {ACTION_EXPORT_PNG, action_export_png},
        };

        public He.Application app { get; construct; }
		public MainWindow (He.Application app) {
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
            app.set_accels_for_action("win.action_export_txt", {"<Ctrl>e"});
            app.set_accels_for_action("win.action_export_png", {"<Shift><Ctrl>e"});

            weak Gtk.IconTheme default_theme = Gtk.IconTheme.get_for_display (Gdk.Display.get_default ());
            default_theme.add_resource_path ("/io/github/lainsce/Colorway");

            menu_button.get_popover ().has_arrow = false;
            
            color = "#72dec2";
            contrast = "#000000";

            var model = new Gtk.StringList ({_("Analogous"), _("Complementary"), _("Triadic"), _("Tetradic"), _("Monochromatic")});
            var expression = new Gtk.PropertyExpression(typeof(string), null, "value");
            
            color_rule_dropdown = new Gtk.DropDown (model, expression);
            color_rule_dropdown.set_size_request (150, -1);
            color_rule_dropdown.model = model;
            color_rule_dropdown.set_selected (3);
            color_rule_dropdown.set_halign (Gtk.Align.START);
            color_rule_dropdown.margin_bottom = 18;
          
            box = new PaletteButton ("#000000", false);
            sbox = new PaletteButton ("#000000", false);
            sbox.set_visible(false);
            tbox = new PaletteButton ("#000000", false);
            tbox.set_visible(false);
            ubox = new PaletteButton ("#000000", false);
            
            mbox = new He.SegmentedButton ();
            mbox.add_css_class ("clr-palette");
            mbox.remove_css_class ("segmented-button");
            mbox.set_size_request (150, -1);
            mbox.homogeneous = true;
            mbox.append (box);
            mbox.append (sbox);
            mbox.append (tbox);
            mbox.append (ubox);

            props_box.append (mbox);
            props_box.append (color_rule_dropdown);

            color_label.get_entry ().set_text (color.up());
            color_label.remove_css_class ("disclosure-button");

            color_picker_button.clicked.connect (() => {
                pick_color.begin ();
            });
            
            Gdk.RGBA gdkrgba = {0,0,0,1};
            gdkrgba.parse(color);
            active_color = gdkrgba;
            
            da = new Chooser(gdkrgba);
            hue_slider = new HueSlider (360);

            Gdk.RGBA clr = {};
            clr.parse(color_label.get_entry ().get_text());

            float ch,cs,cv,h,r,g,b;
            Gtk.rgb_to_hsv(clr.red, clr.green, clr.blue, out ch, out cs, out cv);
            Gtk.hsv_to_rgb(ch, cs, cv, out r, out g, out b);
            var pc = Utils.make_hex((float)Utils.make_srgb(r),
                                    (float)Utils.make_srgb(g),
                                    (float)Utils.make_srgb(b));

            hue_slider.scale.set_value(ch*360);
            
            color_box.append(da);
            color_box.append(hue_slider);
            
            da.on_sv_move.connect ((s, v) => {
                double hue = hue_slider.scale.get_value () / 360;
                Gtk.hsv_to_rgb ((float)hue, (float)s, (float)v, out active_color.red, out active_color.green, out active_color.blue);
                
                var pcda = Utils.make_hex((float)Utils.make_srgb(active_color.red),
                                        (float)Utils.make_srgb(active_color.green), 
                                        (float)Utils.make_srgb(active_color.blue));
                
                color_label.get_entry ().set_text (pcda.up());
                color = pcda.up();

                if (Utils.contrast_ratio(active_color, {0,0,0,1}) > Utils.contrast_ratio(active_color, {1,1,1,1}) + 3) {
                    contrast = "#000000";
                } else {
                    contrast = "#ffffff";
                }

                setup_color_rules.begin (color, contrast, hue, s, v, color_rule_dropdown, sbox, tbox);
            });
            
            hue_slider.on_value_changed.connect ((hue) => {
                double x, y, s, v;
                double sr, sg, sb;
                double rh, gh, bh;
                da.pos_to_sv (out s, out v);
                Gtk.hsv_to_rgb ((float)hue, 1, 1, out sr, out sg, out sb);
                Gtk.hsv_to_rgb ((float)hue, (float)s, (float)v, out rh, out gh, out bh);

                active_color = {(float)rh, (float)gh, (float)bh};
                da.active_color = {(float)rh, (float)gh, (float)bh};
                da.update_surface_color (sr, sg, sb);
                
                var pchs = Utils.make_hex((float)Utils.make_srgb(rh),
                                        (float)Utils.make_srgb(gh),
                                        (float)Utils.make_srgb(bh));
                
                color_label.get_entry ().set_text (pchs.up());
                color = pchs.up();

                if (Utils.contrast_ratio(active_color, {0,0,0,1}) > Utils.contrast_ratio(active_color, {1,1,1,1}) + 3) {
                    contrast = "#000000";
                } else {
                    contrast = "#ffffff";
                }

                setup_color_rules.begin (color, contrast, hue, s, v, color_rule_dropdown, sbox, tbox);
            });

            double hue = hue_slider.scale.get_value () / 360;
            double s, v;
            da.pos_to_sv (out s, out v);
            setup_color_rules.begin (color, contrast, hue, s, v, color_rule_dropdown, sbox, tbox);

            color_rule_dropdown.notify["selected"].connect(() => {
                Gdk.RGBA clrd = {};
                clrd.parse(color_label.get_entry ().get_text());

                float chd,csd,cvd,hd,rd,gd,bd;
                Gtk.rgb_to_hsv(clrd.red, clrd.green, clrd.blue, out chd, out csd, out cvd);
                Gtk.hsv_to_rgb(chd, csd, cvd, out rd, out gd, out bd);
                var pcd = Utils.make_hex((float)Utils.make_srgb(rd),
                                        (float)Utils.make_srgb(gd),
                                        (float)Utils.make_srgb(bd));

                color = pcd.up();
                color_label.get_entry ().set_text (pcd.up());

                if (Utils.contrast_ratio(active_color, {0,0,0,1}) > Utils.contrast_ratio(active_color, {1,1,1,1}) + 3) {
                    contrast = "#000000";
                } else {
                    contrast = "#ffffff";
                }

                setup_color_rules.begin (color, contrast, chd, csd, cvd, color_rule_dropdown, sbox, tbox);
            });

            color_label.get_entry ().activate.connect(() => {
                Gdk.RGBA clrl = {};
                clr.parse(color_label.get_entry ().get_text());

                float chl,csl,cvl,hl,rl,gl,bl;
                Gtk.rgb_to_hsv(clrl.red, clrl.green, clrl.blue, out chl, out csl, out cvl);
                Gtk.hsv_to_rgb(chl, csl, cvl, out rl, out gl, out bl);
                var pcl = Utils.make_hex((float)Utils.make_srgb(rl),
                                        (float)Utils.make_srgb(gl),
                                        (float)Utils.make_srgb(bl));

                active_color = {(float)clrl.red, (float)clrl.green, (float)clrl.blue};
                da.update_surface_color (clrl.red, clrl.green, clrl.blue);
                da.sv_to_pos (csl, cvl);
                da.queue_draw();

                hue_slider.scale.set_value(chl*360);

                color = pcl.up();
                color_label.get_entry ().set_text (pcl.up());

                if (Utils.contrast_ratio(active_color, {0,0,0,1}) > Utils.contrast_ratio(active_color, {1,1,1,1}) + 3) {
                    contrast = "#000000";
                } else {
                    contrast = "#ffffff";
                }

                setup_color_rules.begin (color, contrast, chl, csl, cvl, color_rule_dropdown, sbox, tbox);
            });

            this.set_size_request (360, 233);
			this.show ();
		}

		public async void setup_color_rules (string color, string contrast, double hue, double s, double v, Gtk.DropDown? crd, PaletteButton? sbox, PaletteButton? tbox) {
		    switch (crd.get_selected ()) {
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
                    var h = (hue_shift (hue_slider.scale.get_value (), 180.0)) / 360;
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
                    var ch1 = (hue_shift (hue_slider.scale.get_value (), 120.0)) / 360;
                    double cs1, cv1;
                    da.pos_to_sv (out cs1, out cv1);
                    Gtk.hsv_to_rgb ((float)ch1, (float)cs1, (float)cv1, out active_color.red, out active_color.green, out active_color.blue);
                    var c1 = Utils.make_hex((float)Utils.make_srgb(active_color.red),
                                            (float)Utils.make_srgb(active_color.green),
                                            (float)Utils.make_srgb(active_color.blue));

                    var ch2 = (hue_shift (hue_slider.scale.get_value (), 240.0)) / 360;
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
                    var ch1 = (hue_shift (hue_slider.scale.get_value (), 90.0)) / 360;
                    double cs1, cv1;
                    da.pos_to_sv (out cs1, out cv1);
                    Gtk.hsv_to_rgb ((float)ch1, (float)cs1, (float)cv1, out active_color.red, out active_color.green, out active_color.blue);
                    var c1 = Utils.make_hex((float)Utils.make_srgb(active_color.red),
                                            (float)Utils.make_srgb(active_color.green),
                                            (float)Utils.make_srgb(active_color.blue));

                    var ch2 = (hue_shift (hue_slider.scale.get_value (), 180.0)) / 360;
                    double cs2, cv2;
                    da.pos_to_sv (out cs2, out cv2);
                    Gtk.hsv_to_rgb ((float)ch2, (float)cs2, (float)cv2, out active_color.red, out active_color.green, out active_color.blue);
                    var c2 = Utils.make_hex((float)Utils.make_srgb(active_color.red),
                                            (float)Utils.make_srgb(active_color.green),
                                            (float)Utils.make_srgb(active_color.blue));

                    var ch3 = (hue_shift (hue_slider.scale.get_value (), 270.0)) / 360;
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

                        color_label.get_entry ().set_text (pc.up());
                        color = pc.up();
                        active_color = color_portal;
                        da.active_color = color_portal;

                        hue_slider.scale.set_value(h*360);

                        if (Utils.contrast_ratio(active_color, {0,0,0,1}) > Utils.contrast_ratio(active_color, {1,1,1,1}) + 3) {
                            contrast = "#000000";
                        } else {
                            contrast = "#ffffff";
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
            .clr-preview .overlay-button {
                background: %s;
                color: %s;
            }
            """.printf(color,
                       contrast);

            css_provider.load_from_data(style.data);

            Gtk.StyleContext.add_provider_for_display (
                Gdk.Display.get_default (),
                css_provider,
                Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION + 999
            );
        }

        public void action_export_txt () {
            string export_txt = "";

            export_txt += box.hex + "\n";
            export_txt += sbox.hex + "\n";

            uint selected = color_rule_dropdown.get_selected ();
            if (selected == 2) {
                export_txt += tbox.hex + "\n";
            } else if (selected >= 3) {
                export_txt += tbox.hex + "\n";
                export_txt += ubox.hex + "\n";
            }

            // Put this ext_txt in clipboard
            var display = Gdk.Display.get_default ();
            unowned var clipboard = display.get_clipboard ();
            clipboard.set_text (export_txt);
        }

        public void action_export_png () {
            var snap = new Gtk.Snapshot ();
            mbox.snapshot (snap);

            var sf = new Cairo.ImageSurface (Cairo.Format.ARGB32, 176, 44); // 260×32 is the color result box size;
            var cr = new Cairo.Context (sf);
            var node = snap.to_node ();
            node.draw(cr);

            var pb = Gdk.pixbuf_get_from_surface (sf, 0, 0, 176, 44);
            var mt = Gdk.Texture.for_pixbuf (pb);

            var display = Gdk.Display.get_default ();
            unowned var clipboard = display.get_clipboard ();
            clipboard.set_texture (mt);
        }

        public void action_about () {
            // TRANSLATORS: 'Name <email@domain.com>' or 'Name https://website.example'
            string translators = (_(""));

            var about = new He.AboutWindow (
                this,
                "Colorway",
                Config.APP_ID,
                Config.VERSION,
                Config.APP_ID,
                "https://github.com/lainsce/colorway/tree/main/po",
                "https://github.com/lainsce/colorway/issues/new",
                "https://github.com/lainsce/colorway",
                {translators},
                {"Paulo \"Lains\" Galardi"},
                2018, // Year of first publication.
                He.AboutWindow.Licenses.GPLV3,
                He.Colors.GREEN
            );
            about.present ();
        }
	}
}
