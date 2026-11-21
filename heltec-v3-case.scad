// WY6Y Pop Repeater case: Heltec WiFi LoRa 32 V3 over a 3000 mAh 103665 LiPo,
// stock antenna on the SMA pigtail, standing straight up out of the lid.
//
// Three prints, no supports: base, tray, lid. Print in PETG or ASA (a south
// window will soften PLA). Lid holds on with 4 x M3 x 8 self-tapping screws.
//
// Stack, bottom up: battery in the base -> tray on the wall ledges -> board
// on the tray rails, OLED up -> lid. USB-C exits one end wall; the SMA jack
// sits in the lid over the empty end of the box.
//
// Board numbers from Heltec's V3 dimension drawing (2026-11-21): OLED and
// buttons on top (5 mm), USB-C on the UNDERSIDE (10.2 total - 5 - 1.6 = ~3.5),
// glass 27.28 long starting ~17.8 mm from the USB end, module 18.56 wide,
// u.FL on top at the far end. Things still marked [check] are inferred.
//
// Export: openscad -D 'part="base"' -o base.stl heltec-v3-case.scad  (and tray, lid)

part = "all";          // all | base | tray | lid | preview

/* ---- parts we hold ---- */
bat_l = 65;   bat_w = 36;   bat_t = 10;       // 103665, from the listing
pcb_l = 50.2; pcb_w = 25.5; pcb_t = 1.6;      // Heltec spec (pcb_t [check])
top_h = 5.2;          // OLED module, from the drawing (5) + 0.2
under_h = 5;          // under the PCB: USB-C body ~3.5 + battery plug [check]

/* ---- features on the board, measured from the USB-C end of the PCB ---- */
usb_w = 9.0;  usb_h = 3.5;                    // USB-C body, hangs under the PCB, centred
oled_x = 19.5; oled_w = 24; oled_d = 13;     // window over the lit area (glass 17.8..45.1 from USB end)
oled_y = 0;           // offset from the board centreline (lit area may sit ~1 mm off) [check]

/* ---- the SMA pigtail jack ---- */
sma_d = 6.6;          // 1/4-36 thread = 6.35 mm, plus clearance
sma_flat = 6.0;       // D-flat on the jack thread (0 = round hole) [check]

/* ---- shell ---- */
wall = 2;  floor_t = 2;  lid_t = 2.4;
clr = 0.6;            // fit clearance around battery and board
tray_t = 2;  rail_w = 2.5;
screw_d = 2.6;  screw_head_d = 6;  post_d = 7;

in_l = bat_l + 2 * clr + 2;                   // interior length
in_w = max(bat_w, pcb_w) + 2 * clr;           // interior width
// Corner posts start above the battery (45 degree cone underneath, so no
// supports) so the battery can use the full floor, corners included.
post_tip_z = floor_t + bat_t + 1;             // cone tip, 1 mm over the battery
tray_z = post_tip_z + post_d / 2;             // tray bottom = full post diameter
board_z = tray_z + tray_t + under_h;          // PCB bottom
in_top = board_z + pcb_t + top_h + 0.6;       // underside of the lid
out_l = in_l + 2 * wall;  out_w = in_w + 2 * wall;
base_h = in_top;                              // base walls run to the lid

board_x0 = wall + 0.4;                        // USB end of the PCB, tight to the wall
board_y0 = wall + (in_w - pcb_w) / 2;
free_x0 = board_x0 + pcb_l + 1;               // empty end of the box
sma_x = (free_x0 + wall + in_l) / 2;
sma_y = out_w / 2;
post_inset = wall + post_d / 2 - 1.5;
posts = [[post_inset, post_inset], [out_l - post_inset, post_inset],
         [post_inset, out_w - post_inset], [out_l - post_inset, out_w - post_inset]];

$fn = 48;

module rounded_box(l, w, h, r = 3) {
    hull() for (x = [r, l - r], y = [r, w - r]) translate([x, y, 0]) cylinder(r = r, h = h);
}

module base() {
    difference() {
        union() {
            difference() {
                rounded_box(out_l, out_w, base_h);
                translate([wall, wall, floor_t]) cube([in_l, in_w, base_h]);
            }
            // corner screw posts
            for (p = posts) translate([p[0], p[1], post_tip_z]) {
                cylinder(d1 = 0, d2 = post_d, h = post_d / 2);
                translate([0, 0, post_d / 2]) cylinder(d = post_d, h = base_h - tray_z);
            }
            // tray ledges on the long walls, 45 degree underside so no supports
            for (y = [wall, out_w - wall]) {
                mirror_y = y > out_w / 2;
                translate([wall + post_d - 1, y, tray_z])
                    rotate([0, 90, 0])
                    linear_extrude(in_l - 2 * post_d + 2)
                    polygon(mirror_y ? [[0, 0], [2, 0], [0, -2]] : [[0, 0], [2, 0], [0, 2]]);
            }
        }
        // screw pilots
        for (p = posts) translate([p[0], p[1], tray_z - 1]) cylinder(d = screw_d, h = base_h);
        // USB-C opening, generous so the plug collar fits
        translate([-1, board_y0 + pcb_w / 2 - (usb_w + 3) / 2, board_z - usb_h - 1.5])
            cube([wall + 2, usb_w + 3, usb_h + 3]);
        // vent slots, both long walls, low and high
        for (y = [-1, out_w - wall - 1]) for (i = [0:5]) for (z = [floor_t + 3, in_top - 5])
            translate([12 + i * 9, y, z]) cube([4, wall + 2, 2.5]);
    }
}

module tray() {
    tl = in_l - 2 * post_d + 1.6;             // clears the corner posts
    tw = in_w - 0.6;
    tx = wall + post_d - 0.8;
    ry1 = board_y0 - wall - 0.3;              // rails, in tray coordinates
    ry2 = ry1 + pcb_w - rail_w;
    rx_end = board_x0 + pcb_l - 2 - tx;
    translate([tx, wall + 0.3, tray_z]) difference() {
        union() {
            cube([tl, tw, tray_t]);
            // rails under the long edges of the PCB, on solid plate
            for (y = [ry1, ry2]) cube([rx_end, rail_w, tray_t + under_h]);
        }
        // cut between the rails: battery wires and air
        translate([4, ry1 + rail_w + 1, -1]) cube([rx_end - 8, ry2 - ry1 - rail_w - 2, tray_t + 2]);
        // open far end for the pigtail
        translate([rx_end + 2, 4, -1]) cube([tl - rx_end - 6, tw - 8, tray_t + 2]);
    }
}

module lid() {
    difference() {
        union() {
            rounded_box(out_l, out_w, lid_t);
            // locating lip inside the walls
            translate([wall + 0.3, wall + 0.3, -1.6])
                difference() {
                    cube([in_l - 0.6, in_w - 0.6, 1.6]);
                    translate([1.2, 1.2, -1]) cube([in_l - 3, in_w - 3, 4]);
                }
            // two clamp ribs pressing the PCB edges onto the rails
            for (y = [board_y0 + 0.2, board_y0 + pcb_w - 1.4])
                // start past the RST/PRG buttons (2.6..6.8 mm from the USB end)
                translate([board_x0 + 9, y, -(in_top - board_z - pcb_t)])
                    cube([pcb_l - 13, 1.2, in_top - board_z - pcb_t]);
        }
        for (p = posts) {
            translate([p[0], p[1], -5]) cylinder(d = 3.4, h = 20);
            translate([p[0], p[1], lid_t - 1.2]) cylinder(d = screw_head_d, h = 5);
            // the lip must clear the posts
            translate([p[0], p[1], -3]) cylinder(d = post_d + 0.8, h = 3);
        }
        // OLED window, chamfered
        translate([board_x0 + oled_x, board_y0 + pcb_w / 2 + oled_y - oled_d / 2, -1])
            hull() {
                cube([oled_w, oled_d, 0.1]);
                translate([-1, -1, lid_t + 1]) cube([oled_w + 2, oled_d + 2, 0.1]);
            }
        // SMA jack, D-flat so it can't spin when the antenna is screwed on
        translate([sma_x, sma_y, -5]) intersection() {
            cylinder(d = sma_d, h = 20);
            if (sma_flat > 0) translate([-sma_d / 2, -sma_d / 2, 0]) cube([sma_d, sma_flat, 20]);
        }
        // pin holes for RST/PRG are left out on purpose: lift the lid to reach them
    }
}

if (part == "base") base();
else if (part == "tray") tray();
else if (part == "lid") translate([0, out_w, lid_t]) rotate([180, 0, 0]) lid();   // printed top-down
else if (part == "preview") {
    color("#5a8") base();
    color("#ca6") tray();
    color("#468", 0.6) translate([0, 0, in_top + 8]) lid();
    color("#c33", 0.5) translate([wall + clr, (out_w - bat_w) / 2, floor_t]) cube([bat_l, bat_w, bat_t]);
    color("#246", 0.8) translate([board_x0, board_y0, board_z]) cube([pcb_l, pcb_w, pcb_t]);
}
else {
    base();
    translate([0, out_w + 8, 0]) tray();
    translate([0, 2 * (out_w + 8), 0]) translate([0, out_w, lid_t]) rotate([180, 0, 0]) lid();
}

echo(str("Outside: ", out_l, " x ", out_w, " x ", base_h + lid_t, " mm"));
