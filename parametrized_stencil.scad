// --- Parameters ---
// Overall dimensions of the stencil
page_width = 148; // [mm]
page_height = 210; // [mm]

// Padding from the stencil edges to the line area (margins)
padding_top = 15; // [mm] Space above the title line
padding_bottom = 10; // [mm] Space below the last line
padding_left = 10; // [mm] Left margin
padding_right = 10; // [mm] Right margin

// Line Configuration
num_lines = 25; // Number of regular writing lines (excluding the title line)
line_thickness = 0.75; // [mm] Thickness of the slots (determines drawn line height)
title_line_gap = 10; // [mm] Extra vertical space below the title line slot

// Stencil physical thickness
stencil_thickness = 1; // [mm] Thickness of the stencil material


// --- Advanced Parameters ---
subtraction_overlap = 0.1; // [mm] Small overlap for boolean operations to avoid glitches


// --- Calculations ---
// Calculate the usable width for the line slots
usable_width = page_width - padding_left - padding_right;

// Calculate the total vertical space available for all lines and gaps between them
usable_height = page_height - padding_top - padding_bottom;

// Calculate the Y position for the bottom edge of the title line slot
// Y=0 is at the bottom edge of the stencil
title_line_bottom_y = page_height - padding_top - line_thickness;

// Calculate the Y position for the bottom edge of the first regular line slot
first_regular_line_bottom_y = title_line_bottom_y - title_line_gap - line_thickness;

// Calculate the remaining vertical height available for the regular lines and the gaps between them
// This area starts from the bottom of the first regular line and ends at the top of the bottom padding
regular_lines_area_height = first_regular_line_bottom_y - padding_bottom;

// Calculate the vertical spacing between the bottom edge of one regular line slot
// and the bottom edge of the next regular line slot.
// This distributes the lines evenly within the regular lines area.
// If num_lines is 1, spacing is irrelevant but calculated anyway to avoid division by zero issues later.
line_spacing = (num_lines > 1) ? regular_lines_area_height / (num_lines -1) : regular_lines_area_height;

// Assert calculations validity
assert(usable_width > 0, "Calculated usable_width must be positive. Check paddings.");
assert(usable_height > 0, "Calculated usable_height must be positive. Check paddings.");
assert(regular_lines_area_height >= 0, "Calculated regular_lines_area_height must be non-negative. Check paddings and title_line_gap.");
assert(num_lines >= 0, "Number of lines must be non-negative.");


// --- Module Definition ---
module line_stencil() {
    difference() {
        // Create the base plate of the stencil
        cube([page_width, page_height, stencil_thickness]);

        // Subtract the title line slot
        translate([
            padding_left,
            title_line_bottom_y,
            -subtraction_overlap
        ])
        cube([
            usable_width,
            line_thickness,
            stencil_thickness + 2 * subtraction_overlap
        ]);

        // Subtract the regular line slots
        if (num_lines > 0) {
            for (i = [0 : num_lines - 1]) {
                // Calculate the Y position for the bottom edge of the current regular line
                current_line_bottom_y = first_regular_line_bottom_y - i * line_spacing;

                // Check if the line is within bounds before creating it
                if (current_line_bottom_y >= padding_bottom) {
                    translate([
                        padding_left,
                        current_line_bottom_y,
                        -subtraction_overlap
                    ])
                    cube([
                        usable_width,
                        line_thickness,
                        stencil_thickness + 2 * subtraction_overlap
                    ]);
                }
            }
        }
    }
}

// --- Run ---
line_stencil();