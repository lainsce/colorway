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
    public class Application : He.Application {
        public static GLib.Settings gsettings;
        private const GLib.ActionEntry app_entries[] = {
            { "quit", quit },
        };

        public Application () {
            Object (
                flags: ApplicationFlags.FLAGS_NONE,
                application_id: Config.APP_ID
            );
            add_action_entries(app_entries, this);
        }
        static construct {
            gsettings = new GLib.Settings ("io.github.lainsce.Colorway");
        }

        construct {
            Intl.setlocale (LocaleCategory.ALL, "");
            Intl.bindtextdomain (Config.GETTEXT_PACKAGE, Config.LOCALEDIR);
            Intl.textdomain (Config.GETTEXT_PACKAGE);
        }
        protected override void activate () {
            this.active_window ? .present ();
        }
        public override void startup () {
            Gdk.RGBA accent_color = { 0 };
            accent_color.parse ("#75DEC2");
            default_accent_color = He.from_gdk_rgba (accent_color);
            is_mono = true;
    
            resource_base_path = "/io/github/lainsce/Colorway";
    
            base.startup ();
    
            add_action_entries (app_entries, this);
    
            new MainWindow (this);
        }
        public static int main (string[] args) {
            var app = new Colorway.Application ();
            return app.run (args);
        }
    }
}
