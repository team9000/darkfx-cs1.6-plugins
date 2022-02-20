#define NUM_COLORS 135

#if defined NEED_COLORNAMES
new colornames[NUM_COLORS][] = {
"red",
"gray",
"maroon",
"green",
"lime",
"olive",
"yellow",
"navy",
"blue",
"purple",
"fuchsia",
"teal",
"aqua",
"silver",
"white",
"aliceblue",
"antiquewhite",
"aquamarine",
"azure",
"beige",
"blueviolet",
"brown",
"burlywood",
"cadetblue",
"chartreuse",
"chocolate",
"coral",
"cornflowerblue",
"cornsilk",
"crimson",
"darkblue",
"darkcyan",
"darkgoldenrod",
"darkgray",
"darkgreen",
"darkkhaki",
"darkmagenta",
"darkolivegreen",
"darkorange",
"darkorchid",
"darkred",
"darksalmon",
"darkseagreen",
"darkslateblue",
"darkslategray",
"darkturquoise",
"darkviolet",
"deeppink",
"deepskyblue",
"dimgray",
"dodgerblue",
"firebrick",
"floralwhite",
"forestgreen",
"gainsboro",
"ghostwhite",
"gold",
"goldenrod",
"greenyellow",
"honeydew",
"hotpink",
"indianred",
"indigo",
"ivory",
"khaki",
"lavender",
"lavenderblush",
"lawngreen",
"lemonchiffon",
"lightblue",
"lightcoral",
"lightcyan",
"lightgoldenrodyellow",
"lightgreen",
"lightgrey",
"lightpink",
"lightsalmon",
"lightseagreen",
"lightskyblue",
"lightslategray",
"lightsteelblue",
"lightyellow",
"limegreen",
"linen",
"mediumaquamarine",
"mediumblue",
"mediumorchid",
"mediumpurple",
"mediumseagreen",
"mediumslateblue",
"mediumspringgreen",
"mediumturquoise",
"mediumvioletred",
"midnightblue",
"mintcream",
"mistyrose",
"moccasin",
"navajowhite",
"oldlace",
"olivedrab",
"orange",
"orangered",
"orchid",
"palegoldenrod",
"palegreen",
"paleturquoise",
"palevioletred",
"papayawhip",
"peachpuff",
"peru",
"pink",
"plum",
"powderblue",
"rosybrown",
"royalblue",
"saddlebrown",
"salmon",
"sandybrown",
"seagreen",
"seashell",
"sienna",
"skyblue",
"slateblue",
"slategray",
"snow",
"springgreen",
"steelblue",
"tan",
"thistle",
"tomato",
"turquoise",
"violet",
"wheat",
"whitesmoke",
"yellowgreen"
}
#endif

#if defined NEED_COLORRGBS
new colorrgbs[NUM_COLORS][3] = {
{255, 0, 0},	// red
{128, 128, 128},	// gray
{128, 0, 0},	// maroon
{0, 128, 0},	// green
{0, 255, 0},	// lime
{128, 128, 0},	// olive
{255, 255, 0},	// yellow
{0, 0, 128},	// navy
{0, 0, 255},	// blue
{128, 0, 128},	// purple
{255, 0, 255},	// fuchsia
{0, 128, 128},	// teal
{0, 255, 255},	// aqua
{192, 192, 192},	// silver
{255, 255, 255},	// white
{240, 248, 255},	// aliceblue
{250, 235, 215},	// antiquewhite
{127, 255, 212},	// aquamarine
{240, 255, 255},	// azure
{245, 245, 220},	// beige
{138, 43, 226},	// blueviolet
{165, 42, 42},	// brown
{222, 184, 135},	// burlywood
{95, 158, 160},	// cadetblue
{127, 255, 0},	// chartreuse
{210, 105, 30},	// chocolate
{255, 127, 80},	// coral
{100, 149, 237},	// cornflowerblue
{255, 248, 220},	// cornsilk
{220, 20, 60},	// crimson
{0, 0, 139},	// darkblue
{0, 139, 139},	// darkcyan
{184, 134, 11},	// darkgoldenrod
{169, 169, 169},	// darkgray
{0, 100, 0},	// darkgreen
{189, 183, 107},	// darkkhaki
{139, 0, 139},	// darkmagenta
{85, 107, 47},	// darkolivegreen
{255, 140, 0},	// darkorange
{153, 50, 204},	// darkorchid
{139, 0, 0},	// darkred
{233, 150, 122},	// darksalmon
{143, 188, 143},	// darkseagreen
{72, 61, 139},	// darkslateblue
{47, 79, 79},	// darkslategray
{0, 206, 209},	// darkturquoise
{148, 0, 211},	// darkviolet
{255, 20, 147},	// deeppink
{0, 191, 255},	// deepskyblue
{105, 105, 105},	// dimgray
{30, 144, 255},	// dodgerblue
{178, 34, 34},	// firebrick
{255, 250, 240},	// floralwhite
{34, 139, 34},	// forestgreen
{220, 220, 220},	// gainsboro
{248, 248, 255},	// ghostwhite
{255, 215, 0},	// gold
{218, 165, 32},	// goldenrod
{173, 255, 47},	// greenyellow
{240, 255, 240},	// honeydew
{255, 105, 180},	// hotpink
{205, 92, 92},	// indianred
{75, 0, 130},	// indigo
{255, 255, 240},	// ivory
{240, 230, 140},	// khaki
{230, 230, 250},	// lavender
{255, 240, 245},	// lavenderblush
{124, 252, 0},	// lawngreen
{255, 250, 205},	// lemonchiffon
{173, 216, 230},	// lightblue
{240, 128, 128},	// lightcoral
{224, 255, 255},	// lightcyan
{250, 250, 210},	// lightgoldenrodyellow
{144, 238, 144},	// lightgreen
{211, 211, 211},	// lightgrey
{255, 182, 193},	// lightpink
{255, 160, 122},	// lightsalmon
{32, 178, 170},	// lightseagreen
{135, 206, 250},	// lightskyblue
{119, 136, 153},	// lightslategray
{176, 196, 222},	// lightsteelblue
{255, 255, 224},	// lightyellow
{50, 205, 50},	// limegreen
{250, 240, 230},	// linen
{102, 205, 170},	// mediumaquamarine
{0, 0, 205},	// mediumblue
{186, 85, 211},	// mediumorchid
{147, 112, 219},	// mediumpurple
{60, 179, 113},	// mediumseagreen
{123, 104, 238},	// mediumslateblue
{0, 250, 154},	// mediumspringgreen
{72, 209, 204},	// mediumturquoise
{199, 21, 133},	// mediumvioletred
{25, 25, 112},	// midnightblue
{245, 255, 250},	// mintcream
{255, 228, 225},	// mistyrose
{255, 228, 181},	// moccasin
{255, 222, 173},	// navajowhite
{253, 245, 230},	// oldlace
{107, 142, 35},	// olivedrab
{255, 165, 0},	// orange
{255, 69, 0},	// orangered
{218, 112, 214},	// orchid
{238, 232, 170},	// palegoldenrod
{152, 251, 152},	// palegreen
{175, 238, 238},	// paleturquoise
{219, 112, 147},	// palevioletred
{255, 239, 213},	// papayawhip
{255, 218, 185},	// peachpuff
{205, 133, 63},	// peru
{255, 192, 203},	// pink
{221, 160, 221},	// plum
{176, 224, 230},	// powderblue
{188, 143, 143},	// rosybrown
{65, 105, 225},	// royalblue
{139, 69, 19},	// saddlebrown
{250, 128, 114},	// salmon
{244, 164, 96},	// sandybrown
{46, 139, 87},	// seagreen
{255, 245, 238},	// seashell
{160, 82, 45},	// sienna
{135, 206, 235},	// skyblue
{106, 90, 205},	// slateblue
{112, 128, 144},	// slategray
{255, 250, 250},	// snow
{0, 255, 127},	// springgreen
{70, 130, 180},	// steelblue
{210, 180, 140},	// tan
{216, 191, 216},	// thistle
{255, 99, 71},	// tomato
{64, 224, 208},	// turquoise
{238, 130, 238},	// violet
{245, 222, 179},	// wheat
{245, 245, 245},	// whitesmoke
{154, 205, 50}	// yellowgreen
}
#endif
