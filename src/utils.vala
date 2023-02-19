/*
 * Copyright (c) 2021-2022 Lains
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation; either
 * version 3 of the License, or (at your option) any later version.
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
 */
namespace Colorway.Utils {
    public string make_hex (float red, float green, float blue) {
        return "#" + "%02x%02x%02x".printf ((uint)Math.roundf(red), (uint)Math.roundf(green), (uint)Math.roundf(blue));
    }
    public double make_srgb(double c) {
        if (c <= 0.03928) {
            c = c / 12.92;
            return c * 255.0;
        } else {
            Math.pow (((c + 0.055) / 1.055), 2.4);
            return c * 255.0;
        }
    }

    public static double contrast_ratio (Gdk.RGBA bg_color, Gdk.RGBA fg_color) {
        // From WCAG 2.0 https://www.w3.org/TR/WCAG20/#contrast-ratiodef
        var bg_luminance = get_luminance (bg_color);
        var fg_luminance = get_luminance (fg_color);

        if (bg_luminance > fg_luminance) {
            return (bg_luminance + 0.05) / (fg_luminance + 0.05);
        }

        return (fg_luminance + 0.05) / (bg_luminance + 0.05);
    }

    private static double get_luminance (Gdk.RGBA color) {
        // Values from WCAG 2.0 https://www.w3.org/TR/WCAG20/#relativeluminancedef
        var red = sanitize_color (color.red) * 0.2126;
        var green = sanitize_color (color.green) * 0.7152;
        var blue = sanitize_color (color.blue) * 0.0722;

        return red + green + blue;
    }

    private static double sanitize_color (double color) {
        // From WCAG 2.0 https://www.w3.org/TR/WCAG20/#relativeluminancedef
        if (color <= 0.03928) {
            return color / 12.92;
        }

        return Math.pow ((color + 0.055) / 1.055, 2.4);
    }
}
