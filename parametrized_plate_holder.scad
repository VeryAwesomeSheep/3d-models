// --- Parameters ---
// Number of plates
num_plates = 6;
// Slot size for the plates [mm]
plate_thickness = 15; 
// Thickness of the poles/fingers [mm]
finger_thickness = 8;
// Overall width [mm]
holder_width = 120;
// Thickness of the side rails [mm]
rail_thickness = 10;
// Height of the solid base underneath the poles/fingers [mm]
base_height = 15;
// Height of the slanted poles/fingers [mm]
wave_height = 60;
// Angle of the poles/fingers (max ~40 for no support printing) [deg]
wave_angle = 15;
// Radius for smoothing out the poles/fingers
corner_radius = 2.5;
// Middle support
middle_support = false;
// Curve smoothness
$fn = 48;

// --- Module Definition ---
module plate_holder() {
    // Calculate layout distances
    pitch = plate_thickness + finger_thickness;
    total_length = num_plates * pitch + finger_thickness;
    shift_x = wave_height * tan(wave_angle);

    // 2D profile of the poles side wall
    module wave_profile() {
        // Zigzag points for the poles
        top_points = [
            for (i = [num_plates : -1 : 0])
                for (j = [0 : 3])
                    let (
                        p = [
                            [i*pitch + finger_thickness, base_height],
                            [i*pitch + finger_thickness + shift_x, base_height + wave_height],
                            [i*pitch + shift_x, base_height + wave_height],
                            [i*pitch, base_height]
                        ]
                    ) p[j]
        ];

        // Combine with the bottom corners
        all_points = concat([[0, 0], [total_length, 0]], top_points);

        // Smooth the profile
        intersection() {
            offset(r = corner_radius)
                offset(r = -corner_radius * 2)
                    offset(r = corner_radius)
                        polygon(all_points);

            // Cut off the bottom rounding
            translate([-abs(shift_x) - corner_radius*4, 0])
                square([total_length + abs(shift_x)*2 + corner_radius*8, base_height + wave_height + corner_radius*2]);
        }
    }

    union() {
        // Left side wall
        translate([0, rail_thickness, 0])
            rotate([90, 0, 0])
            linear_extrude(height = rail_thickness)
            wave_profile();

        // Right side wall
        translate([0, holder_width, 0])
            rotate([90, 0, 0])
            linear_extrude(height = rail_thickness)
            wave_profile();

        // Front crossbeam (at start)
        cube([finger_thickness, holder_width, base_height]);

        // Rear crossbeam (at end)
        translate([total_length - finger_thickness, 0, 0])
            cube([finger_thickness, holder_width, base_height]);

        // Automatically add a middle support beam if holding 5 or more plates
        if (middle_support) {
            mid_index = floor(num_plates / 2);
            translate([mid_index * pitch, 0, 0])
                cube([finger_thickness, holder_width, base_height]);
        }
    }
}

// --- Run ---
plate_holder();
