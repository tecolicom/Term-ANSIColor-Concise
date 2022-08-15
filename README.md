[![Actions Status](https://github.com/kaz-utashiro/Term-ANSIColor-Concise/actions/workflows/test.yml/badge.svg)](https://github.com/kaz-utashiro/Term-ANSIColor-Concise/actions)
# NAME

Term::ANSIColor::Concise - Produce ANSI terminal sequence by concise notation

# SYNOPSIS

    use v5.14;
    use Term::ANSIColor::Concise qw(ansi_color);

    say ansi_color('R', 'This is Red');

    say ansi_color('SDG', 'This is Reverse Bold Green');

    say ansi_color('FUDI;B/L24E',
                   'Flashing Underlined Bold Italic Blue on Gray24 bar');

# DESCRIPTION

This module provides a simple concise format to describe complicated
colors and effects for ANSI terminals.  They are supposed to be used
in command line option parameters.  Easy interface is provided by
[Getopt::EX::Colormap](https://metacpan.org/pod/Getopt%3A%3AEX%3A%3AColormap) module.

## 256 or 24bit COLORS

By default, this library produces ANSI 256 color sequence.  That is
eight standard colors, eight high intensity colors, 6x6x6 216 colors,
and grayscales from black to white in 24 steps.

Color described by 12bit/24bit RGB values are converted to 6x6x6 216
colors, or 24 grayscales if all RGB values are same.

For a terminal which can display 24bit colors, full-color sequence is
produce.  See ["ENVIRONMENT"](#environment) section.

# FUNCTION

- **ansi\_color**(_spec_, _text_)

    Return colorized version of given text.  Produces 256 or 24bit colors
    depending on the setting.

    In the result, given _text_ is enclosed by appropriate open/close
    sequences, but close sequence can be different according to the open
    sequence.  See ["RESET SEQUENCE"](#reset-sequence) section.

    If the _text_ already includes colored regions, they remain untouched
    and only non-colored parts are colored.

    Actually, _spec_ and _text_ pair can be repeated as many as
    possible.  It is same as calling the function multiple times with
    single pair and join results.

- **ansi\_color**(\[ _spec1_, _spec2_, ... \], _text_)

    If _spec_ parameter is ARRAYREF, multiple _spec_s can be specified
    at once.  This is not useful for color spec because they can be simply
    joined, but may be useful when mixed with ["FUNCTION SPEC"](#function-spec).

- **ansi\_color\_24**(_spec_, _text_)
- **ansi\_color\_24**(\[ _spec1_, _spec2_, ... \], _text_)

    Function **ansi\_color\_24** always produces 24bit color sequence for
    12bit/24bit color spec.

- **ansi\_pair**(_color\_spec_)

    Produces introducer and recover sequences for given spec.

    Additional third value indicates if the introducer includes Erase Line
    sequence.  It gives a hint the sequence is necessary for empty string.
    See ["RESET SEQUENCE"](#reset-sequence).

- **ansi\_code**(_color\_spec_)

    Produces introducer sequence for given spec.  Reset code can be taken
    by **ansi\_code("Z")**.

- **csi\_code**(_name_, _params_)

    Produce CSI (Control Sequence Introducer) sequence by name with
    numeric parameters.  Parameter _name_ is one of standard (CUU, CUD,
    CUF, CUB, CNL, CPL, CHA, CUP, ED, EL, SU, SD, HVP, SGR, SCP, RCP) or
    non-standard (RIS, DECSC, DECRC).

# COLOR SPEC

At first the color is considered as foreground, and slash (`/`)
switches foreground and background.  You can declare any number of
components in arbitrary order, and sequences will be produced in the
order or their presence.  So if they conflicts, the later one
overrides the earlier.

Color specification is a combination of following components:

## BASIC 8+8

Single uppercase character representing 8 colors, and alternative
(usually brighter) colors in lowercase :

    R  r  Red
    G  g  Green
    B  b  Blue
    C  c  Cyan
    M  m  Magenta
    Y  y  Yellow
    K  k  Black
    W  w  White

## EFFECTS and CONTROLS

Single case-insensitive chracter for special effects :

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

    E    Erase Line (fill by background color)

    ;    No effect
    /    Toggle foreground/background
    ^    Reset to foreground
    ~    Cancel following effect

Tilde (`~`) negates following effect; `~S` reset the effect of `S`.
There is a discussion about negation of `D` (Track Wikipedia link in
SEE ALSO), and Apple\_Terminal (v2.10 433) does not reset at least.

Single `E` is an abbreviation for "{EL}" (Erase Line).  This is
different from other attributes, but have an effect of painting the
rest of line by background color.

## 6x6x6 216 COLORS

Combination of 0..5 for 216 RGB values :

    Deep          Light
    <----------------->
    000 111 222 333 444 : Black
    500 511 522 533 544 : Red
    050 151 252 353 454 : Green
    005 115 225 335 445 : Blue
    055 155 255 355 455 : Cyan
    505 515 525 535 545 : Magenta
    550 551 552 553 554 : Yellow
    555 444 333 222 111 : White

## 24 GRAY SCALES + 2

24 gray scales are described by `L01` (dark) to `L24` (bright).
Black and White can be described as `L00` and `L25` but they do not
produce gray scale sequence.

    L00 : Level  0 (Black)
    L01 : Level  1
     :
    L24 : Level 24
    L25 : Level 25 (White)

## RGB

12bit/24bit RGB :

    (255,255,255)      : 24bit decimal RGB colors
    #000000 .. #FFFFFF : 24bit hex RGB colors
    #000    .. #FFF    : 12bit hex RGB 4096 colors

> Beginning `#` can be omitted in 24bit hex RGB notation.  So 6
> consecutive digits means 24bit color, and 3 digits means 6x6x6 color,
> if they do not begin with `#`.

## COLOR NAMES

Color names enclosed by angle bracket :

    <red> <blue> <green> <cyan> <magenta> <yellow>
    <aliceblue> <honeydue> <hotpink> <mooccasin>
    <medium_aqua_marine>

These colors are defined in 24bit RGB.  See ["COLOR NAMES"](#color-names) section
for detail.

## CSI SEQUENCES and OTHERS

Native CSI (Control Sequence Introducer) sequences in the form of
`{NAME}`.

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

These names accept following optional numerical parameters, using
comma (',') or semicolon (';') to separate multiple ones, with
optional braces.  For example, color spec `DK/544` can be described
as `{SGR1;30;48;5;224}` or more readable `{SGR(1,30,48,5,224)}`.

Some other escape sequences are supported in the form of `{NAME}`.
These sequences do not start with CSI, and do not take parameters.

    RIS     Reset to Initial State
    DECSC   DEC Save Cursor
    DECRC   DEC Restore Cursor

## EXAMPLES

    RGB  6x6x6    12bit      24bit            color name
    ===  =======  =========  =============    ==================
    B    005      #00F       (0,0,255)        <blue>
     /M     /505      /#F0F     /(255,0,255)  /<magenta>
    K/W  000/555  #000/#FFF  #000000/#FFFFFF  <black>/<white>
    R/G  500/050  #F00/#0F0  #FF0000/#00FF00  <red>/<green>
    W/w  L03/L20  #333/#ccc  #303030/#c6c6c6  <dimgray>/<lightgray>

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

# FUNCTION SPEC

Color spec can be CODEREF or object.  If it is a CODEREF, that code is
called with text as an argument, and return the result.

If it is an object which has method `call`, it is called with the
variable `$_` set as target text.

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
`$NO_RESET_EL` or `ANSICOLOR_NO_RESET_EL` environment.

# ERASE LINE

Erase line sequence "{EL}" clears the line from cursor to the end of
the line.  At this time, background color is set to the area.  When
this code is explicitly found in the start sequence, it is copied to
just before ending reset sequence, with preceding sequence if
necessary, to keep the effect even when the text is wrapped to
multiple lines.

See ["ENVIRONMENT"](#environment) section.

# ENVIRONMENT

If the environment variable `NO_COLOR` is set, regardless of its
value, colorizing interface in this module never produce color
sequence.  Primitive function such as `ansi_code` is not the case.
See [https://no-color.org/](https://no-color.org/).

If the module variable `$NO_NO_COLOR` or `ANSICOLOR_NO_NO_COLOR`
environment is true, `NO_COLOR` value is ignored.

Function **ansi\_color** produces 256 or 24bit colors depending on the
value of `$RGB24` module variable.  Also 24bit mode is enabled when
environment `ANSICOLOR_RGB24` is set or `COLORTERM` is `truecolor`.

If the module variable `$NO_RESET_EL` set, or
`ANSICOLOR_NO_RESET_EL` environment, _Erase Line_ sequence is not
re-produced after RESET code.  See ["RESET SEQUENCE"](#reset-sequence).

# SEE ALSO

## [Getopt::EX::Colormap](https://metacpan.org/pod/Getopt%3A%3AEX%3A%3AColormap)

This module is originally implemented in [Getopt::EX::Colormap](https://metacpan.org/pod/Getopt%3A%3AEX%3A%3AColormap)
module.  It provides an easy way to maintain labeled and indexed list
for color handling in command line option.

You can take care of user option like this:

    use Getopt::Long;
    my @opt_colormap;
    GetOptions('colormap|cm:s' => @opt_colormap);
    
    require Getopt::EX::Colormap;
    my %label = ( FILE => 'DR', LINE => 'Y', TEXT => '' );
    my @index = qw( /544 /545 /445 /455 /545 /554 );
    my $cm = Getopt::EX::Colormap
        ->new(HASH => \%label, LIST => \@index)
        ->load_params(@opt_colormap);  

And then program can use it in two ways:

    print $cm->color('FILE', $filename);

    print $cm->index_color($index, $pattern);

This interface provides a simple uniform way to handle coloring
options for various tools.

## [App::ansiecho](https://metacpan.org/pod/App%3A%3Aansiecho)

To use this module's function directly from a command line,
[App::ansiecho](https://metacpan.org/pod/App%3A%3Aansiecho) is a good one.  You can apply colors and effects for
echoing argument.

## OTHERS

[https://en.wikipedia.org/wiki/ANSI\_escape\_code](https://en.wikipedia.org/wiki/ANSI_escape_code)

[Graphics::ColorNames::X](https://metacpan.org/pod/Graphics%3A%3AColorNames%3A%3AX)

[https://en.wikipedia.org/wiki/X11\_color\_names](https://en.wikipedia.org/wiki/X11_color_names)

[https://no-color.org/](https://no-color.org/)

https://www.ecma-international.org/wp-content/uploads/ECMA-48\_5th\_edition\_june\_1991.pdf

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
