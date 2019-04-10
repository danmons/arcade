crt_test_patterns.sh
====================

# About
This generates a bunch of test images you can use to make sure your old CRT looks good.  You can send them to your CRT however you like (Raspberry Pi, ArcadeVGA, various analogue and digital connections to TVs, PC monitors, broadcast monitors, arcade CRTs, etc, etc).

I assume you're generating them in BASH and have a copy of ImageMagick installed.  I've tested it all under Linux, but making it work under MacOS or Windows10+BASH should be fairly easy.

These take heaps of inspiration from various test projects like broadcast test patterns, arcade board test patterns, 240p Test Suite, etc.

A proper colorimeter is always better.  But finding ones that work with CRTs is getting more difficult, and the ones that still exist are expensive. If you do want an economical one, I recommend the open source ColorHug: https://hughski.com/

Everything assumes
* sRGB colour space
* D65 white point
* Gamma 2.2
* Peak luminance of 80 cd/m^2
* Ambient environment light of 5000K at 200 lux
* https://en.wikipedia.org/wiki/SRGB

Colours are
* 3 channels, 8 bit per channel, 0-255
* primaries (red, green, blue)
* secondaries (cyan, magenta, yellow)
* black and white
* broadcast black is back16
* broadcast white is white235
* sRGB gamma 2.2 50% luminance is grey188

# Tests

## checkerboards
Combinations of two colours in a 4x3 grid.  

Can be used for CRT linearity, colour or convergence testing

## ebu_bars
European Broadcasting Union colour bars.

Both 75% and 100% levels.  Provided is a comparison to the EBU colour bars in blue-only that you can test with something like a broadcast monitor's "blue only" mode, or a blue gel filter.

Other comparison versions are supplied that you can test with various colour combinations.

## geom
Geometry tests.  Should demonstrate things like
* Linearity - do circles look like circles?
* Overscan - is some of the picture around the edges cropped?
* Convergence - do the R/G/B guns on your CRT line up?
* Sharpness - is everything in focus?

## levels
Check various levels, like
* gamma - using an sRGB colour space, D65 white point and gamma 2.2 you should see
** on the left is a pixel grid of pure black and white
** on the right is pure grey188
** at gamma 2.2, sitting back from the screen, left and right should match in brightness, intensity, and approximate colour

* black levels ("brightness" on your CRT controls)
** top bar is black0 (left) to black32 (right)
** bottom bar is black32 (right) to black0 (left)
** broadcast black is black16, in the centre of both levels, and should appear the same as pure black at the top and bottom, with black 16-0 all appearing the same

* white levels ("contrast" on your CRT controls)
** top bar is white255 (left) to white215 (right)
** bottom bar is white215 (right) to white255 (left)
** broadcast black is black235, in the centre of both levels, and should appear the same as pure white at the top and bottom, with white 235-255 all appearing the same

* colour levels, similar to Capcom and other arcade board RGB level tests.

## pure_colours
* Pure colours at 50% and 100%
* black0, white255
* grey ramp from 10% to 90% in steps of 10
