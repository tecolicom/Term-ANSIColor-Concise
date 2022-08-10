
# NAME

Text::ANSI::Concise - Produce ANSI terminal sequence with concise notation

# SYNOPSIS

    use Text::ANSI::Concise qw(colorize);
    $text = colorize(SPEC, TEXT);
    $text = colorize(SPEC_1, TEXT_1, SPEC_2, TEXT_2, ...);

    $ perl -MGetopt::EX::Colormap=colortable -e colortable

# DESCRIPTION

It may be useful to give a simple uniform way to specify complicated
colors.

## 256 or 24bit COLORS

By default, this library produces ANSI 256 color sequence.  That is
eight standard colors, eight high intensity colors, 6x6x6 216 colors,
and grayscales from black to white in 24 steps.

Color can be described by 12bit/24bit RGB values but they are
converted to 6x6x6 216 colors, or 24 greyscales if all RGB values are
same.  To produce 24bit RGB color sequence, set `$RGB24` module
variable or use appropiate environment.

# FUNCTION

- **colorize**(_color\_spec_, _text_)
- **colorize24**(_color\_spec_, _text_)

    Return colorized version of given text.

    **colorize** produces 256 or 24bit colors depending on the setting,
    while **colorize24** always produces 24bit color sequence for
    24bit/12bit color spec.  See [ENVIRONMENT](https://metacpan.org/pod/ENVIRONMENT).

- **ansi\_code**(_color\_spec_)

    Produces introducer sequence for given spec.  Reset code can be taken
    by **ansi\_code("Z")**.

- **ansi\_pair**(_color\_spec_)

    Produces introducer and recover sequences for given spec. Recover
    sequence includes _Erase Line_ related control with simple SGR reset
    code.

- **csi\_code**(_name_, _params_)

    Produce CSI (Control Sequence Introducer) sequence by name with
    numeric parameters.  Parameter _name_ is one of standard (CUU, CUD,
    CUF, CUB, CNL, CPL, CHA, CUP, ED, EL, SU, SD, HVP, SGR, SCP, RCP) or
    non-standard (RIS, DECSC, DECRC).

- **colortable**(\[_width_\])

    Print visual 256 color matrix table on the screen.  Default _width_
    is 144.  Use like this:

        perl -MGetopt::EX::Colormap=colortable -e colortable

# COLOR SPEC

Color specification is a combination of single uppercase character
representing 8 colors, and alternative (usually brighter) colors in
lowercase :

    R  r  Red
    G  g  Green
    B  b  Blue
    C  c  Cyan
    M  m  Magenta
    Y  y  Yellow
    K  k  Black
    W  w  White

or RGB values and 24 grey levels if using ANSI 256 or full color
terminal :

    (255,255,255)      : 24bit decimal RGB colors
    #000000 .. #FFFFFF : 24bit hex RGB colors
    #000    .. #FFF    : 12bit hex RGB 4096 colors
    000 .. 555         : 6x6x6 RGB 216 colors
    L00 .. L25         : Black (L00), 24 grey levels, White (L25)

> Beginning `#` can be omitted in 24bit hex RGB notation.  So 6
> consecutive digits means 24bit color, and 3 digits means 6x6x6 color.

or color names enclosed by angle bracket :

    <red> <blue> <green> <cyan> <magenta> <yellow>
    <aliceblue> <honeydue> <hotpink> <mooccasin>
    <medium_aqua_marine>

with other special effects :

    N    None
    Z  0 Zero (reset)
    D  1 Double strike (boldface)
    P  2 Pale (dark)
    I  3 Italic
    U  4 Underline
    F  5 Flash (blink: slow)
    Q  6 Quick (blink: rapid)
    S  7 Stand out (reverse video)
    H  8 Hide (conceal)
    X  9 Cross out

    E    Erase Line

    ;    No effect
    /    Toggle foreground/background
    ^    Reset to foreground
    ~    Cancel following effect

At first the color is considered as foreground, and slash (`/`)
switches foreground and background.  If multiple colors are given in
the same spec, all indicators are produced in the order of their
presence.  Consequently, the last one takes effect.

If the character is preceded by tilde (`~`), it means negation of
following effect; `~S` reset the effect of `S`.  There is a
discussion about negation of `D` (Track Wikipedia link in SEE ALSO),
and Apple\_Terminal (v2.10 433) does not reset at least.

Effect characters are case insensitive, and can be found anywhere and
in any order in color spec string.  Character `;` does nothing and
can be used just for readability, like `SD;K/544`.

Samples:

    RGB  6x6x6    12bit      24bit           color name
    ===  =======  =========  =============  ==================
    B    005      #00F       (0,0,255)      <blue>
     /M     /505      /#F0F   /(255,0,255)  /<magenta>
    K/W  000/555  #000/#FFF  000000/FFFFFF  <black>/<white>
    R/G  500/050  #F00/#0F0  FF0000/00FF00  <red>/<green>
    W/w  L03/L20  #333/#ccc  303030/c6c6c6  <dimgrey>/<lightgrey>

Character "E" is an abbreviation for "{EL}", and it clears the line
from cursor to the end of the line.  At this time, background color is
set to the area.  When this code is found in the start sequence, it is
copied to just before ending reset sequence, with preceding sequence
if necessary, to keep the effect even when the text is wrapped to
multiple lines.

Other ANSI CSI sequences are also available in the form of `{NAME}`.

    CUU n   Cursor up
    CUD n   Cursor Down
    CUF n   Cursor Forward
    CUB n   Cursor Back
    CNL n   Cursor Next Line
    CPL n   Cursor Previous line
    CHA n   Cursor Horizontal Absolute
    CUP n,m Cursor Position
    ED  n   Erase in Display (0 after, 1 before, 2 entire, 3 w/buffer)
    EL  n   Erase in Line (0 after, 1 before, 2 entire)
    SU  n   Scroll Up
    SD  n   Scroll Down
    HVP n,m Horizontal Vertical Position
    SGR n*  Select Graphic Rendition
    SCP     Save Cursor Position
    RCP     Restore Cursor Position

These name accept following optional numerical parameters, using comma
(',') or semicolon (';') to separate multiple ones, with optional
braces.  For example, color spec `DK/544` can be described as
`{SGR1;30;48;5;224}` or more readable `{SGR(1,30,48,5,224)}`.

Some other escape sequences are supported in the form of `{NAME}`.
These sequences do not start with CSI, and take no parameters.

    RIS     Reset to Initial State
    DECSC   DEC Save Cursor
    DECRC   DEC Restore Cursor

# COLOR NAMES

Color names listed in [Graphics::ColorNames::X](https://metacpan.org/pod/Graphics%3A%3AColorNames%3A%3AX) module can be used.
See [https://en.wikipedia.org/wiki/X11\_color\_names](https://en.wikipedia.org/wiki/X11_color_names).

    gray gray0 .. gray100
    grey grey0 .. grey100

    aliceblue antiquewhite antiquewhite1 antiquewhite2 antiquewhite3
    antiquewhite4 aqua aquamarine aquamarine1 aquamarine2 aquamarine3
    aquamarine4 azure azure1 azure2 azure3 azure4 beige bisque bisque1
    bisque2 bisque3 bisque4 black blanchedalmond blue blue1 blue2 blue3
    blue4 blueviolet brown brown1 brown2 brown3 brown4 burlywood
    burlywood1 burlywood2 burlywood3 burlywood4 cadetblue cadetblue1
    cadetblue2 cadetblue3 cadetblue4 chartreuse chartreuse1 chartreuse2
    chartreuse3 chartreuse4 chocolate chocolate1 chocolate2 chocolate3
    chocolate4 coral coral1 coral2 coral3 coral4 cornflowerblue cornsilk
    cornsilk1 cornsilk2 cornsilk3 cornsilk4 crimson cyan cyan1 cyan2 cyan3
    cyan4 darkblue darkcyan darkgoldenrod darkgoldenrod1 darkgoldenrod2
    darkgoldenrod3 darkgoldenrod4 darkgray darkgreen darkgrey darkkhaki
    darkmagenta darkolivegreen darkolivegreen1 darkolivegreen2
    darkolivegreen3 darkolivegreen4 darkorange darkorange1 darkorange2
    darkorange3 darkorange4 darkorchid darkorchid1 darkorchid2 darkorchid3
    darkorchid4 darkred darksalmon darkseagreen darkseagreen1
    darkseagreen2 darkseagreen3 darkseagreen4 darkslateblue darkslategray
    darkslategray1 darkslategray2 darkslategray3 darkslategray4
    darkslategrey darkturquoise darkviolet deeppink deeppink1 deeppink2
    deeppink3 deeppink4 deepskyblue deepskyblue1 deepskyblue2 deepskyblue3
    deepskyblue4 dimgray dimgrey dodgerblue dodgerblue1 dodgerblue2
    dodgerblue3 dodgerblue4 firebrick firebrick1 firebrick2 firebrick3
    firebrick4 floralwhite forestgreen fuchsia gainsboro ghostwhite gold
    gold1 gold2 gold3 gold4 goldenrod goldenrod1 goldenrod2 goldenrod3
    goldenrod4 honeydew honeydew1 honeydew2 honeydew3 honeydew4 hotpink
    hotpink1 hotpink2 hotpink3 hotpink4 indianred indianred1 indianred2
    indianred3 indianred4 indigo ivory ivory1 ivory2 ivory3 ivory4 khaki
    khaki1 khaki2 khaki3 khaki4 lavender lavenderblush lavenderblush1
    lavenderblush2 lavenderblush3 lavenderblush4 lawngreen lemonchiffon
    lemonchiffon1 lemonchiffon2 lemonchiffon3 lemonchiffon4 lightblue
    lightblue1 lightblue2 lightblue3 lightblue4 lightcoral lightcyan
    lightcyan1 lightcyan2 lightcyan3 lightcyan4 lightgoldenrod
    lightgoldenrod1 lightgoldenrod2 lightgoldenrod3 lightgoldenrod4
    lightgoldenrodyellow lightgray lightgreen lightgrey lightpink
    lightpink1 lightpink2 lightpink3 lightpink4 lightsalmon lightsalmon1
    lightsalmon2 lightsalmon3 lightsalmon4 lightseagreen lightskyblue
    lightskyblue1 lightskyblue2 lightskyblue3 lightskyblue4 lightslateblue
    lightslategray lightslategrey lightsteelblue lightsteelblue1
    lightsteelblue2 lightsteelblue3 lightsteelblue4 lightyellow
    lightyellow1 lightyellow2 lightyellow3 lightyellow4 lime limegreen
    linen magenta magenta1 magenta2 magenta3 magenta4 maroon maroon1
    maroon2 maroon3 maroon4 mediumaquamarine mediumblue mediumorchid
    mediumorchid1 mediumorchid2 mediumorchid3 mediumorchid4 mediumpurple
    mediumpurple1 mediumpurple2 mediumpurple3 mediumpurple4 mediumseagreen
    mediumslateblue mediumspringgreen mediumturquoise mediumvioletred
    midnightblue mintcream mistyrose mistyrose1 mistyrose2 mistyrose3
    mistyrose4 moccasin navajowhite navajowhite1 navajowhite2 navajowhite3
    navajowhite4 navy navyblue oldlace olive olivedrab olivedrab1
    olivedrab2 olivedrab3 olivedrab4 orange orange1 orange2 orange3
    orange4 orangered orangered1 orangered2 orangered3 orangered4 orchid
    orchid1 orchid2 orchid3 orchid4 palegoldenrod palegreen palegreen1
    palegreen2 palegreen3 palegreen4 paleturquoise paleturquoise1
    paleturquoise2 paleturquoise3 paleturquoise4 palevioletred
    palevioletred1 palevioletred2 palevioletred3 palevioletred4 papayawhip
    peachpuff peachpuff1 peachpuff2 peachpuff3 peachpuff4 peru pink pink1
    pink2 pink3 pink4 plum plum1 plum2 plum3 plum4 powderblue purple
    purple1 purple2 purple3 purple4 rebeccapurple red red1 red2 red3 red4
    rosybrown rosybrown1 rosybrown2 rosybrown3 rosybrown4 royalblue
    royalblue1 royalblue2 royalblue3 royalblue4 saddlebrown salmon salmon1
    salmon2 salmon3 salmon4 sandybrown seagreen seagreen1 seagreen2
    seagreen3 seagreen4 seashell seashell1 seashell2 seashell3 seashell4
    sienna sienna1 sienna2 sienna3 sienna4 silver skyblue skyblue1
    skyblue2 skyblue3 skyblue4 slateblue slateblue1 slateblue2 slateblue3
    slateblue4 slategray slategray1 slategray2 slategray3 slategray4
    slategrey snow snow1 snow2 snow3 snow4 springgreen springgreen1
    springgreen2 springgreen3 springgreen4 steelblue steelblue1 steelblue2
    steelblue3 steelblue4 tan tan1 tan2 tan3 tan4 teal thistle thistle1
    thistle2 thistle3 thistle4 tomato tomato1 tomato2 tomato3 tomato4
    turquoise turquoise1 turquoise2 turquoise3 turquoise4 violet violetred
    violetred1 violetred2 violetred3 violetred4 webgray webgreen webgrey
    webmaroon webpurple wheat wheat1 wheat2 wheat3 wheat4 white whitesmoke
    x11gray x11green x11grey x11maroon x11purple yellow yellow1 yellow2
    yellow3 yellow4 yellowgreen

Enclose them by angle bracket to use, like:

    <deeppink>/<lightyellow>

Although these colors are defined in 24bit value, they are mapped to
6x6x6 216 colors by default.  Set `$RGB24` module variable to use
24bit color mode.

# FUNCTION SPEC

Color spec can be CODEREF or object.  If it is a CODEREF, that code is
called with text as an argument, and return the result.

If it is an object which has method `call`, it is called with the
variable `$_` set as target text.

# EXAMPLE

If you want to use this module instead of [Term::ANSIColor](https://metacpan.org/pod/Term%3A%3AANSIColor), this
example code

    use Term::ANSIColor;
    print color 'bold blue';
    print "This text is bold blue.\n";
    print color 'reset';
    print "This text is normal.\n";
    print colored("Yellow on magenta.", 'yellow on_magenta'), "\n";
    print "This text is normal.\n";
    print colored ['yellow on_magenta'], 'Yellow on magenta.', "\n";
    print colored ['red on_bright_yellow'], 'Red on bright yellow.', "\n";
    print colored ['bright_red on_black'], 'Bright red on black.', "\n";
    print "\n";

can be written with [Getopt::EX::Colormap](https://metacpan.org/pod/Getopt%3A%3AEX%3A%3AColormap) like:

    use Text::ANSI::Concise qw(colorize ansi_code);
    print ansi_code 'DB';
    print "This text is bold blue.\n";
    print ansi_code 'Z';
    print "This text is normal.\n";
    print colorize('Y/M', "Yellow on magenta."), "\n";
    print "This text is normal.\n";
    print colorize('Y/M', 'Yellow on magenta.'), "\n";
    print colorize('R/y', 'Red on bright yellow.'), "\n";
    print colorize('r/K', 'Bright red on black.'), "\n";
    print "\n";

# RESET SEQUENCE

This module produces _RESET_ and _Erase Line_ sequence to recover
from colored text.  This is preferable to clear background color set
by scrolling in the middle of colored text at the bottom line of the
terminal.

However, on some terminal, including Apple\_Terminal, _Erase Line_
sequence clear the text on the cursor position when it is at the
rightmost column of the screen.  In other words, rightmost character
sometimes mysteriously disappear when it is the last character in the
colored region.  If you do not like this behavior, set module variable
`$NO_RESET_EL` or `GETOPTEX_NO_RESET_EL` environment.

# ENVIRONMENT

If the environment variable `NO_COLOR` is set, regardless of its
value, colorizing interface in this module never produce color
sequence.  Primitive function such as `ansi_code` is not the case.
See [https://no-color.org/](https://no-color.org/).

If the module variable `$NO_NO_COLOR` or `GETOPTEX_NO_NO_COLOR`
environment is true, `NO_COLOR` value is ignored.

**color** method and **colorize** function produces 256 or 24bit colors
depending on the value of `$RGB24` module variable.  Also 24bit mode
is enabled when environment `GETOPTEX_RGB24` is set or `COLORTERM`
is `truecolor`.

If the module variable `$NO_RESET_EL` set, or `GETOPTEX_NO_RESET_EL`
environment, _Erace Line_ sequence is not produced after RESET code.
See ["RESET SEQUENCE"](#reset-sequence).

# SEE ALSO

[https://en.wikipedia.org/wiki/ANSI\_escape\_code](https://en.wikipedia.org/wiki/ANSI_escape_code)

[Graphics::ColorNames::X](https://metacpan.org/pod/Graphics%3A%3AColorNames%3A%3AX)

[https://en.wikipedia.org/wiki/X11\_color\_names](https://en.wikipedia.org/wiki/X11_color_names)

[https://no-color.org/](https://no-color.org/)

# AUTHOR

Kazumasa Utashiro

# COPYRIGHT

The following copyright notice applies to all the files provided in
this distribution, including binary files, unless explicitly noted
otherwise.

Copyright 2015-2022 Kazumasa Utashiro

# LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
