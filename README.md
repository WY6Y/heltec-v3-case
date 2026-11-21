# Heltec V3 case (WY6Y Pop Repeater)

A three-part case for a Heltec WiFi LoRa 32 V3 sitting over a 3000 mAh 103665 LiPo
(36 x 10 x 65 mm, JST 1.25), with the stock antenna standing straight up from an
SMA jack in the lid. Built for a MeshCore repeater and observer in a window.

![preview](preview.png)

- Outside: 72.2 x 41.2 x 33.3 mm
- Parts: `base.stl`, `tray.stl`, `lid.stl` (the lid is exported upside down, ready to print)
- No supports. PLA is fine indoors out of direct sun; PETG or ASA for a hot sill.
- Hardware: 4 x M3 x 4 x 5 mm brass heat-set inserts (4.1 mm holes in the posts),
  4 x M3 x 8 machine screws, the V3's u.FL to SMA pigtail.
- Press the inserts in flush with a soldering iron (about 220 C for PLA) before assembly.

Stack, bottom up: battery on the floor, tray on the wall ledges, board on the tray
rails with the OLED up, then the lid. USB-C exits the end wall at board level (it's a mid-mount connector).
The RST and PRG buttons have no holes; lift the lid to reach them.

Board dimensions come from Heltec's V3 drawing (50.2 x 25.5 mm, 10.2 mm thick,
OLED module 5 mm; USB-C on the OLED side). Change anything in the parameters at
the top of `heltec-v3-case.scad`, then export:

```
openscad -D 'part="base"' -o base.stl heltec-v3-case.scad
openscad -D 'part="tray"' -o tray.stl heltec-v3-case.scad
openscad -D 'part="lid"'  -o lid.stl  heltec-v3-case.scad
```

Header pins are left off (a repeater doesn't need them; soldered pins would hit the
rails). Before printing, check the room under the board for the battery plug (5 mm
allowed). The SMA hole is plain 6.6 mm; tighten the pigtail's nut.
