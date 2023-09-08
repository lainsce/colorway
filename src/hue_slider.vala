/**
 * Copyright (c) 2021-2022 Lains
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public
 * License along with this program; if not, write to the
 * Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301 USA
 *
 * Co-Authored by: Arvianto Dwi Wicaksono <arvianto.dwi@gmail.com>
 */

public class Colorway.HueSlider : Gtk.Scale {

    //  Signals
    public signal void on_value_changed (double hue);

    public HueSlider (double hue) {
        this.adjustment = new Gtk.Adjustment (hue, 0, 360, 1, 360, 0);
    }

    construct {
        //  Initialize parent's properties
        this.orientation = Gtk.Orientation.VERTICAL;
        this.draw_value = false;
        this.digits = 0;
        this.has_origin = false;

        this.add_css_class ("clr-hue");

        this.value_changed.connect (() => {
            double hue = this.adjustment.get_value () / 360;
            on_value_changed (hue);
        });
    }

}
