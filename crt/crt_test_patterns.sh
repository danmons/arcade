#!/bin/bash

## Quick script to generate CRT test images.
## Everything is calculated in 8 bit per channel linear RGB out to PNG files
##
## Useful for folks wanting to test/calibrate
## CRT displays with a Raspberry Pi or similar device.
##
## blame elvis@stickfreaks.com
## I make no apologies for rampant use of the correct
## English spelling of "colour" or "grey"

## Set variable "I" to point to ImageMagick's "convert" binary
## Set variable "M" to point to ImageMagick's "montage" binary
## Alternatively, GraphicsMagick's "gm convert" and "gm montage" may work too, but I haven't tested it
I="/usr/bin/convert"
M="/usr/bin/montage"

## Set variable "RES" to your desired resolution for the output images
## Common resolutions you might want:
## NTSC 240p - 320x240
## PAL  288p - 384x288
## NTSC 480i, 480p, VGA - 640x480
## PAL  576i, 576p - 768x576
XRES=320
YRES=240
RES="${XRES}x${YRES}"

## Useful functions
function build_chunks_colour {
    $I -size ${CRES} xc:"rgb(255,0,0)"     ${ODIR}/chunk_red.png     ; RED=${ODIR}/chunk_red.png
    $I -size ${CRES} xc:"rgb(0,255,0)"     ${ODIR}/chunk_green.png   ; GREEN=${ODIR}/chunk_green.png
    $I -size ${CRES} xc:"rgb(0,0,255)"     ${ODIR}/chunk_blue.png    ; BLUE=${ODIR}/chunk_blue.png
    $I -size ${CRES} xc:"rgb(255,255,0)"   ${ODIR}/chunk_yellow.png  ; YELLOW=${ODIR}/chunk_yellow.png
    $I -size ${CRES} xc:"rgb(255,0,255)"   ${ODIR}/chunk_magenta.png ; MAGENTA=${ODIR}/chunk_magenta.png
    $I -size ${CRES} xc:"rgb(0,255,255)"   ${ODIR}/chunk_cyan.png    ; CYAN=${ODIR}/chunk_cyan.png
    $I -size ${CRES} xc:"rgb(0,0,0)"       ${ODIR}/chunk_black.png   ; BLACK=${ODIR}/chunk_black.png
    $I -size ${CRES} xc:"rgb(255,255,255)" ${ODIR}/chunk_white.png   ; WHITE=${ODIR}/chunk_white.png
}

## Single-colour images
## Primaries - red, green, blue
## Secondaries - yellow, magenta, cyan
## Tertiaries - greyscale black to white in 10% jumps
ODIR=${RES}/pure_colours
mkdir -p ${ODIR}

$I -size $RES xc:"rgb(255,0,0)" ${ODIR}/red_100.png
$I -size $RES xc:"rgb(127,0,0)" ${ODIR}/red_050.png

$I -size $RES xc:"rgb(0,255,0)" ${ODIR}/green_100.png
$I -size $RES xc:"rgb(0,127,0)" ${ODIR}/green_050.png

$I -size $RES xc:"rgb(,0,255)" ${ODIR}/blue_100.png
$I -size $RES xc:"rgb(,0,127)" ${ODIR}/blue_050.png

$I -size $RES xc:"rgb(255,255,0)" ${ODIR}/yellow_100.png
$I -size $RES xc:"rgb(127,127,0)" ${ODIR}/yellow_050.png

$I -size $RES xc:"rgb(255,0,255)" ${ODIR}/magenta_100.png
$I -size $RES xc:"rgb(127,0,127)" ${ODIR}/magenta_050.png

$I -size $RES xc:"rgb(0,255,255)" ${ODIR}/cyan_100.png
$I -size $RES xc:"rgb(0,127,127)" ${ODIR}/cyan_050.png

## Percentage values are rounded down to whole integers
$I -size $RES xc:"rgb(25,25,25)"    ${ODIR}/grey_010.png
$I -size $RES xc:"rgb(51,51,51)"    ${ODIR}/grey_020.png
$I -size $RES xc:"rgb(76,76,76)"    ${ODIR}/grey_030.png
$I -size $RES xc:"rgb(102,102,102)" ${ODIR}/grey_040.png
$I -size $RES xc:"rgb(127,127,127)" ${ODIR}/grey_050.png
$I -size $RES xc:"rgb(153,153,153)" ${ODIR}/grey_060.png
$I -size $RES xc:"rgb(178,178,178)" ${ODIR}/grey_070.png
$I -size $RES xc:"rgb(204,204,204)" ${ODIR}/grey_080.png
$I -size $RES xc:"rgb(229,229,229)" ${ODIR}/grey_090.png

$I -size $RES xc:"rgb(0,0,0)" ${ODIR}/black_pure.png
$I -size $RES xc:"rgb(0,0,0)" ${ODIR}/black_reference.png

$I -size $RES xc:"rgb(255,255,255)" ${ODIR}/white_pure.png
$I -size $RES xc:"rgb(235,235,235)" ${ODIR}/white_reference.png

## Checkerboards 4x3 patterns of squares
CXRES=$(( ${XRES}/4 ))
CYRES=$(( ${YRES}/3 ))
CRES="${CXRES}x${CYRES}"
ODIR=${RES}/checkerboards
mkdir -p ${ODIR}
build_chunks_colour

## Build checkerboards

for C1 in ${RED} ${GREEN} ${BLUE} ${YELLOW} ${MAGENTA} ${CYAN} ${BLACK} ${WHITE}
do
    for C2 in ${RED} ${GREEN} ${BLUE} ${YELLOW} ${MAGENTA} ${CYAN} ${BLACK} ${WHITE}
    do
        P1=$( basename ${C1} ) ; P1=$( echo "${P1%.*}" | cut -d "_" -f 2 )
        P2=$( basename ${C2} ) ; P2=$( echo "${P2%.*}" | cut -d "_" -f 2 )
        # 2 colour
        $M -size ${RES} \
            ${C1} ${C2} ${C1} ${C2} \
            ${C2} ${C1} ${C2} ${C1} \
            ${C1} ${C2} ${C1} ${C2} \
            -geometry +0+0 ${ODIR}/check_${P1}_${P2}.png
    done
done

## Clean up temp images
rm ${ODIR}/chunk_*.png

## Black/white levels
## Reference black is 16, so we build to 2*reference=32
## Reference white = 235, so we build to 255-(255-reference)*2=215
## Test black/white by tuning brightness/contrast until only half the gradient can be seen
CXRES=${XRES}
CYRES=$(( ${YRES}/4 ))
CRES="${CXRES}x${CYRES}"
ODIR=${RES}/levels
mkdir -p ${ODIR}

$I -size ${CRES} xc:"rgb(0,0,0)" ${ODIR}/chunk_black.png
$I -size ${CRES} xc:"rgb(255,255,255)" ${ODIR}/chunk_white.png
$I -size ${CRES} -define gradient:direction=east gradient:"rgb(0,0,0)"-"rgb(32,32,32)" ${ODIR}/chunk_blackscale1.png
$I -size ${CRES} -define gradient:direction=east gradient:"rgb(32,32,32)"-"rgb(0,0,0)" ${ODIR}/chunk_blackscale2.png
$I -size ${CRES} -define gradient:direction=east gradient:"rgb(255,255,255)"-"rgb(215,215,215)" ${ODIR}/chunk_whitescale1.png
$I -size ${CRES} -define gradient:direction=east gradient:"rgb(215,215,215)"-"rgb(255,255,255)" ${ODIR}/chunk_whitescale2.png

$M -size ${RES} \
    ${ODIR}/chunk_black.png \
    ${ODIR}/chunk_blackscale1.png \
    ${ODIR}/chunk_blackscale2.png \
    ${ODIR}/chunk_black.png \
    -tile 1x4 -geometry +0+0 ${ODIR}/level_black.png

$M -size ${RES} \
    ${ODIR}/chunk_white.png \
    ${ODIR}/chunk_whitescale1.png \
    ${ODIR}/chunk_whitescale2.png \
    ${ODIR}/chunk_white.png \
    -tile 1x4 -geometry +0+0 ${ODIR}/level_white.png

## sRGB at gamma 2.2 says that 50% grey is grey188
## Test gamma by looking at checkerboard/grey188 so that they look the same from a distance
CXRES=$(( ${XRES}/4 ))
CYRES=$(( ${YRES}/4 ))
CRES="${CXRES}x${CYRES}"

$I -size ${CRES} xc:"rgb(0,0,0)" ${ODIR}/chunk_srgb_black.png
$I -size ${CRES} pattern:gray50 ${ODIR}/chunk_srgb_checkerboard.png
$I -size ${CRES} xc:"rgb(188,188,188)" ${ODIR}/chunk_srgb_gamma22.png

$M -size ${RES} \
    ${ODIR}/chunk_srgb_black.png ${ODIR}/chunk_srgb_black.png ${ODIR}/chunk_srgb_black.png ${ODIR}/chunk_srgb_black.png \
    ${ODIR}/chunk_srgb_black.png ${ODIR}/chunk_srgb_checkerboard.png ${ODIR}/chunk_srgb_gamma22.png ${ODIR}/chunk_srgb_black.png \
    ${ODIR}/chunk_srgb_black.png ${ODIR}/chunk_srgb_checkerboard.png ${ODIR}/chunk_srgb_gamma22.png ${ODIR}/chunk_srgb_black.png \
    ${ODIR}/chunk_srgb_black.png ${ODIR}/chunk_srgb_black.png ${ODIR}/chunk_srgb_black.png ${ODIR}/chunk_srgb_black.png \
    -tile 4x4 -geometry +0+0 ${ODIR}/gamma_22_srgb.png

## Colour gradient
CXRES=$((${XRES}/16))
CYRES=$((${YRES}/12))
CRES="${CXRES}x${CYRES}"

for i in $(seq 10 7 99) 99
do
    $I -size ${CRES} xc:"rgb($((255*${i}/100)),0,0)" ${ODIR}/chunk_red_${i}.png
    $I -size ${CRES} xc:"rgb(0,$((255*${i}/100)),0)" ${ODIR}/chunk_green_${i}.png
    $I -size ${CRES} xc:"rgb(0,0,$((255*${i}/100)))" ${ODIR}/chunk_blue_${i}.png
    $I -size ${CRES} xc:"rgb($((255*${i}/100)),0,$((255*${i}/100)))" ${ODIR}/chunk_magenta_${i}.png
    $I -size ${CRES} xc:"rgb($((255*${i}/100)),$((255*${i}/100)),0)" ${ODIR}/chunk_yellow_${i}.png
    $I -size ${CRES} xc:"rgb(0,$((255*${i}/100)),$((255*${i}/100)))" ${ODIR}/chunk_cyan_${i}.png
    $I -size ${CRES} xc:"rgb($((255*${i}/100)),$((255*${i}/100)),$((255*${i}/100)))" ${ODIR}/chunk_grey_${i}.png
done

for i in $(seq -w 1 16)
do
    $I -size ${CRES} xc:"rgb(0.0.0)" ${ODIR}/chunk_black_${i}.png
done

$M -size ${RES} \
    ${ODIR}/chunk_black_*.png \
    \
    ${ODIR}/chunk_black_01.png  ${ODIR}/chunk_red_*.png  ${ODIR}/chunk_black_16.png \
    \
    ${ODIR}/chunk_black_01.png  ${ODIR}/chunk_green_*.png  ${ODIR}/chunk_black_16.png \
    \
    ${ODIR}/chunk_black_01.png  ${ODIR}/chunk_blue_*.png  ${ODIR}/chunk_black_16.png \
    \
    ${ODIR}/chunk_black_*.png \
    \
    ${ODIR}/chunk_black_01.png  ${ODIR}/chunk_red_*.png  ${ODIR}/chunk_black_16.png \
    \
    ${ODIR}/chunk_black_*.png \
    \
    ${ODIR}/chunk_black_01.png  ${ODIR}/chunk_green_*.png  ${ODIR}/chunk_black_16.png \
    \
    ${ODIR}/chunk_black_*.png \
    \
    ${ODIR}/chunk_black_01.png  ${ODIR}/chunk_blue_*.png  ${ODIR}/chunk_black_16.png \
    \
    ${ODIR}/chunk_black_*.png \
    -tile 16x12 -geometry +0+0 ${ODIR}/level_rgb.png

$M -size ${RES} \
    ${ODIR}/chunk_black_*.png \
    \
    ${ODIR}/chunk_black_01.png  ${ODIR}/chunk_cyan_*.png  ${ODIR}/chunk_black_16.png \
    \
    ${ODIR}/chunk_black_01.png  ${ODIR}/chunk_magenta_*.png  ${ODIR}/chunk_black_16.png \
    \
    ${ODIR}/chunk_black_01.png  ${ODIR}/chunk_yellow_*.png  ${ODIR}/chunk_black_16.png \
    \
    ${ODIR}/chunk_black_*.png \
    \
    ${ODIR}/chunk_black_01.png  ${ODIR}/chunk_cyan_*.png  ${ODIR}/chunk_black_16.png \
    \
    ${ODIR}/chunk_black_*.png \
    \
    ${ODIR}/chunk_black_01.png  ${ODIR}/chunk_magenta_*.png  ${ODIR}/chunk_black_16.png \
    \
    ${ODIR}/chunk_black_*.png \
    \
    ${ODIR}/chunk_black_01.png  ${ODIR}/chunk_yellow_*.png  ${ODIR}/chunk_black_16.png \
    \
    ${ODIR}/chunk_black_*.png \
    -tile 16x12 -geometry +0+0 ${ODIR}/level_cmy.png

$M -size ${RES} \
    ${ODIR}/chunk_black_*.png \
    \
    ${ODIR}/chunk_black_01.png  ${ODIR}/chunk_red_*.png  ${ODIR}/chunk_black_16.png \
    \
    ${ODIR}/chunk_black_01.png  ${ODIR}/chunk_green_*.png  ${ODIR}/chunk_black_16.png \
    \
    ${ODIR}/chunk_black_01.png  ${ODIR}/chunk_blue_*.png  ${ODIR}/chunk_black_16.png \
    \
    ${ODIR}/chunk_black_*.png \
    \
    ${ODIR}/chunk_black_01.png  ${ODIR}/chunk_grey_*.png  ${ODIR}/chunk_black_16.png \
    \
    ${ODIR}/chunk_black_*.png \
    \
    ${ODIR}/chunk_black_01.png  ${ODIR}/chunk_cyan_*.png  ${ODIR}/chunk_black_16.png \
    \
    ${ODIR}/chunk_black_01.png  ${ODIR}/chunk_magenta_*.png  ${ODIR}/chunk_black_16.png \
    \
    ${ODIR}/chunk_black_01.png  ${ODIR}/chunk_yellow_*.png  ${ODIR}/chunk_black_16.png \
    \
    ${ODIR}/chunk_black_*.png \
    -tile 16x12 -geometry +0+0 ${ODIR}/level_rgbwcmy.png

rm ${ODIR}/chunk_*.png

## Geometry tests
## Let's draw a bunch of circles
CXRES=$(( ${XRES}/2 ))
CYRES=$(( ${YRES}/2 ))
CXTL=$(( ${XRES}/8 ))
CYTL=$(( ${YRES}/8 ))
CXTR=$(( ${XRES}-${CXTL} ))
CYTR=${CYTL}
CXBL=${CXTL}
CYBL=$(( ${YRES}-${CYTL} ))
CXBR=${CXTR}
CYBR=${CYBL}
ODIR=${RES}/geom
mkdir -p ${ODIR}

$I -size ${RES} +antialias xc:"rgb(255,255,255)" \
    -fill "rgb(255,255,255)" -strokewidth 2 -stroke "rgb(0,0,0)" -draw "translate ${CXRES},${CYRES} circle 0,0 $((${CYRES}-2)),0" \
    -fill "rgb(255,255,255)" -strokewidth 2 -stroke "rgb(0,0,0)" -draw "translate ${CXTL},${CYTL} circle 0,0 $((${CYTL}-2)),0" \
    -fill "rgb(255,255,255)" -strokewidth 2 -stroke "rgb(0,0,0)" -draw "translate ${CXBL},${CYBL} circle 0,0 $((${CYTL}-2)),0" \
    -fill "rgb(255,255,255)" -strokewidth 2 -stroke "rgb(0,0,0)" -draw "translate ${CXTR},${CYTR} circle 0,0 $((${CYTL}-2)),0" \
    -fill "rgb(255,255,255)" -strokewidth 2 -stroke "rgb(0,0,0)" -draw "translate ${CXBR},${CYBR} circle 0,0 $((${CYTL}-2)),0" \
    +antialias ${ODIR}/circle_white.png

$I -size ${RES} +antialias xc:"rgb(255,255,255)" \
    -fill "rgb(255,255,255)" -strokewidth 2 -stroke "rgb(0,0,0)" -draw "translate ${CXRES},${CYRES} circle 0,0 $((${CYRES}-2)),0" \
    -fill "rgb(255,255,255)" -strokewidth 2 -stroke "rgb(0,0,0)" -draw "translate ${CXTL},${CYTL} circle 0,0 $((${CYTL}-2)),0" \
    -fill "rgb(255,255,255)" -strokewidth 2 -stroke "rgb(0,0,0)" -draw "translate ${CXBL},${CYBL} circle 0,0 $((${CYTL}-2)),0" \
    -fill "rgb(255,255,255)" -strokewidth 2 -stroke "rgb(0,0,0)" -draw "translate ${CXTR},${CYTR} circle 0,0 $((${CYTL}-2)),0" \
    -fill "rgb(255,255,255)" -strokewidth 2 -stroke "rgb(0,0,0)" -draw "translate ${CXBR},${CYBR} circle 0,0 $((${CYTL}-2)),0" \
    -fill "rgb(255,255,255)" -strokewidth 2 -stroke "rgb(0,0,0)" -draw "line 0,${CYTL} ${XRES},${CYTL}" \
    -fill "rgb(255,255,255)" -strokewidth 2 -stroke "rgb(0,0,0)" -draw "line 0,${CYBL} ${XRES},${CYBL}" \
    -fill "rgb(255,255,255)" -strokewidth 2 -stroke "rgb(0,0,0)" -draw "line ${CXTL},0 ${CXTL},${YRES}" \
    -fill "rgb(255,255,255)" -strokewidth 2 -stroke "rgb(0,0,0)" -draw "line ${CXTR},0 ${CXTR},${YRES}" \
    -fill "rgb(255,255,255)" -strokewidth 2 -stroke "rgb(0,0,0)" -draw "line 0,$((${YRES}/2)) ${XRES},$((${YRES}/2))" \
    -fill "rgb(255,255,255)" -strokewidth 2 -stroke "rgb(0,0,0)" -draw "line $((${XRES}/2)),0 $((${XRES}/2)),${YRES}" \
    +antialias ${ODIR}/circle_lines_white.png

$I -size ${RES} +antialias xc:"rgb(127,127,127)" \
    -fill "rgb(127,127,127)" -strokewidth 2 -stroke "rgb(0,0,0)" -draw "translate ${CXRES},${CYRES} circle 0,0 $((${CYRES}-2)),0" \
    -fill "rgb(127,127,127)" -strokewidth 2 -stroke "rgb(0,0,0)" -draw "translate ${CXTL},${CYTL} circle 0,0 $((${CYTL}-2)),0" \
    -fill "rgb(127,127,127)" -strokewidth 2 -stroke "rgb(0,0,0)" -draw "translate ${CXBL},${CYBL} circle 0,0 $((${CYTL}-2)),0" \
    -fill "rgb(127,127,127)" -strokewidth 2 -stroke "rgb(0,0,0)" -draw "translate ${CXTR},${CYTR} circle 0,0 $((${CYTL}-2)),0" \
    -fill "rgb(127,127,127)" -strokewidth 2 -stroke "rgb(0,0,0)" -draw "translate ${CXBR},${CYBR} circle 0,0 $((${CYTL}-2)),0" \
    +antialias ${ODIR}/circle_grey.png

$I -size ${RES} +antialias xc:"rgb(127,127,127)" \
    -fill "rgb(127,127,127)" -strokewidth 2 -stroke "rgb(0,0,0)" -draw "translate ${CXRES},${CYRES} circle 0,0 $((${CYRES}-2)),0" \
    -fill "rgb(127,127,127)" -strokewidth 2 -stroke "rgb(0,0,0)" -draw "translate ${CXTL},${CYTL} circle 0,0 $((${CYTL}-2)),0" \
    -fill "rgb(127,127,127)" -strokewidth 2 -stroke "rgb(0,0,0)" -draw "translate ${CXBL},${CYBL} circle 0,0 $((${CYTL}-2)),0" \
    -fill "rgb(127,127,127)" -strokewidth 2 -stroke "rgb(0,0,0)" -draw "translate ${CXTR},${CYTR} circle 0,0 $((${CYTL}-2)),0" \
    -fill "rgb(127,127,127)" -strokewidth 2 -stroke "rgb(0,0,0)" -draw "translate ${CXBR},${CYBR} circle 0,0 $((${CYTL}-2)),0" \
    -fill "rgb(127,127,127)" -strokewidth 2 -stroke "rgb(0,0,0)" -draw "line 0,${CYTL} ${XRES},${CYTL}" \
    -fill "rgb(127,127,127)" -strokewidth 2 -stroke "rgb(0,0,0)" -draw "line 0,${CYBL} ${XRES},${CYBL}" \
    -fill "rgb(127,127,127)" -strokewidth 2 -stroke "rgb(0,0,0)" -draw "line ${CXTL},0 ${CXTL},${YRES}" \
    -fill "rgb(127,127,127)" -strokewidth 2 -stroke "rgb(0,0,0)" -draw "line ${CXTR},0 ${CXTR},${YRES}" \
    -fill "rgb(127,127,127)" -strokewidth 2 -stroke "rgb(0,0,0)" -draw "line 0,$((${YRES}/2)) ${XRES},$((${YRES}/2))" \
    -fill "rgb(127,127,127)" -strokewidth 2 -stroke "rgb(0,0,0)" -draw "line $((${XRES}/2)),0 $((${XRES}/2)),${YRES}" \
    +antialias ${ODIR}/circle_lines_grey.png

#SW=$((${YRES}/240))
SW=1

$I -size ${RES} +antialias xc:"rgb(0,0,0)" \
    -fill "rgb(255,255,255)" -strokewidth ${SW} -stroke "rgb(255,255,255)" -draw "line $((${XRES}/20*2)),0 $((${XRES}/20*2)),${YRES}" \
    -fill "rgb(255,255,255)" -strokewidth ${SW} -stroke "rgb(255,255,255)" -draw "line $((${XRES}/20*3)),0 $((${XRES}/20*3)),${YRES}" \
    -fill "rgb(255,255,255)" -strokewidth ${SW} -stroke "rgb(255,255,255)" -draw "line $((${XRES}/20*4)),0 $((${XRES}/20*4)),${YRES}" \
    -fill "rgb(255,255,255)" -strokewidth ${SW} -stroke "rgb(255,255,255)" -draw "line $((${XRES}/20*5)),0 $((${XRES}/20*5)),${YRES}" \
    -fill "rgb(255,255,255)" -strokewidth ${SW} -stroke "rgb(255,255,255)" -draw "line $((${XRES}/20*6)),0 $((${XRES}/20*6)),${YRES}" \
    -fill "rgb(255,255,255)" -strokewidth ${SW} -stroke "rgb(255,255,255)" -draw "line $((${XRES}/20*7)),0 $((${XRES}/20*7)),${YRES}" \
    -fill "rgb(255,255,255)" -strokewidth ${SW} -stroke "rgb(255,255,255)" -draw "line $((${XRES}/20*8)),0 $((${XRES}/20*8)),${YRES}" \
    -fill "rgb(255,255,255)" -strokewidth ${SW} -stroke "rgb(255,255,255)" -draw "line $((${XRES}/20*9)),0 $((${XRES}/20*9)),${YRES}" \
    -fill "rgb(255,255,255)" -strokewidth ${SW} -stroke "rgb(255,255,255)" -draw "line $((${XRES}/20*10)),0 $((${XRES}/20*10)),${YRES}" \
    -fill "rgb(255,255,255)" -strokewidth ${SW} -stroke "rgb(255,255,255)" -draw "line $((${XRES}/20*11)),0 $((${XRES}/20*11)),${YRES}" \
    -fill "rgb(255,255,255)" -strokewidth ${SW} -stroke "rgb(255,255,255)" -draw "line $((${XRES}/20*12)),0 $((${XRES}/20*12)),${YRES}" \
    -fill "rgb(255,255,255)" -strokewidth ${SW} -stroke "rgb(255,255,255)" -draw "line $((${XRES}/20*13)),0 $((${XRES}/20*13)),${YRES}" \
    -fill "rgb(255,255,255)" -strokewidth ${SW} -stroke "rgb(255,255,255)" -draw "line $((${XRES}/20*14)),0 $((${XRES}/20*14)),${YRES}" \
    -fill "rgb(255,255,255)" -strokewidth ${SW} -stroke "rgb(255,255,255)" -draw "line $((${XRES}/20*15)),0 $((${XRES}/20*15)),${YRES}" \
    -fill "rgb(255,255,255)" -strokewidth ${SW} -stroke "rgb(255,255,255)" -draw "line $((${XRES}/20*16)),0 $((${XRES}/20*16)),${YRES}" \
    -fill "rgb(255,255,255)" -strokewidth ${SW} -stroke "rgb(255,255,255)" -draw "line $((${XRES}/20*17)),0 $((${XRES}/20*17)),${YRES}" \
    -fill "rgb(255,255,255)" -strokewidth ${SW} -stroke "rgb(255,255,255)" -draw "line $((${XRES}/20*18)),0 $((${XRES}/20*18)),${YRES}" \
    \
    -fill "rgb(255,255,255)" -strokewidth ${SW} -stroke "rgb(255,255,255)" -draw "line 0,$((${YRES}/15*2)) ${XRES},$((${YRES}/15*2))" \
    -fill "rgb(255,255,255)" -strokewidth ${SW} -stroke "rgb(255,255,255)" -draw "line 0,$((${YRES}/15*3)) ${XRES},$((${YRES}/15*3))" \
    -fill "rgb(255,255,255)" -strokewidth ${SW} -stroke "rgb(255,255,255)" -draw "line 0,$((${YRES}/15*4)) ${XRES},$((${YRES}/15*4))" \
    -fill "rgb(255,255,255)" -strokewidth ${SW} -stroke "rgb(255,255,255)" -draw "line 0,$((${YRES}/15*5)) ${XRES},$((${YRES}/15*5))" \
    -fill "rgb(255,255,255)" -strokewidth ${SW} -stroke "rgb(255,255,255)" -draw "line 0,$((${YRES}/15*6)) ${XRES},$((${YRES}/15*6))" \
    -fill "rgb(255,255,255)" -strokewidth ${SW} -stroke "rgb(255,255,255)" -draw "line 0,$((${YRES}/15*7)) ${XRES},$((${YRES}/15*7))" \
    -fill "rgb(255,255,255)" -strokewidth ${SW} -stroke "rgb(255,255,255)" -draw "line 0,$((${YRES}/15*8)) ${XRES},$((${YRES}/15*8))" \
    -fill "rgb(255,255,255)" -strokewidth ${SW} -stroke "rgb(255,255,255)" -draw "line 0,$((${YRES}/15*9)) ${XRES},$((${YRES}/15*9))" \
    -fill "rgb(255,255,255)" -strokewidth ${SW} -stroke "rgb(255,255,255)" -draw "line 0,$((${YRES}/15*10)) ${XRES},$((${YRES}/15*10))" \
    -fill "rgb(255,255,255)" -strokewidth ${SW} -stroke "rgb(255,255,255)" -draw "line 0,$((${YRES}/15*11)) ${XRES},$((${YRES}/15*11))" \
    -fill "rgb(255,255,255)" -strokewidth ${SW} -stroke "rgb(255,255,255)" -draw "line 0,$((${YRES}/15*12)) ${XRES},$((${YRES}/15*12))" \
    -fill "rgb(255,255,255)" -strokewidth ${SW} -stroke "rgb(255,255,255)" -draw "line 0,$((${YRES}/15*13)) ${XRES},$((${YRES}/15*13))" \
    \
    -fill "rgb(255,0,0)" -strokewidth ${SW} -stroke "rgb(255,0,0)" -draw "line $((${XRES}/20*0)),0 $((${XRES}/20*0)),${YRES}" \
    -fill "rgb(255,0,0)" -strokewidth ${SW} -stroke "rgb(255,0,0)" -draw "line $((${XRES}/20*1)),0 $((${XRES}/20*1)),${YRES}" \
    -fill "rgb(255,0,0)" -strokewidth ${SW} -stroke "rgb(255,0,0)" -draw "line $((${XRES}/20*19)),0 $((${XRES}/20*19)),${YRES}" \
    -fill "rgb(255,0,0)" -strokewidth ${SW} -stroke "rgb(255,0,0)" -draw "line $((${XRES}/20*20-1)),0 $((${XRES}/20*20-1)),${YRES}" \
    \
    -fill "rgb(255,0,0)" -strokewidth ${SW} -stroke "rgb(255,0,0)" -draw "line 0,$((${YRES}/15*0)) ${XRES},$((${YRES}/15*0))" \
    -fill "rgb(255,0,0)" -strokewidth ${SW} -stroke "rgb(255,0,0)" -draw "line 0,$((${YRES}/15*1)) ${XRES},$((${YRES}/15*1))" \
    -fill "rgb(255,0,0)" -strokewidth ${SW} -stroke "rgb(255,0,0)" -draw "line 0,$((${YRES}/15*14)) ${XRES},$((${YRES}/15*14))" \
    -fill "rgb(255,0,0)" -strokewidth ${SW} -stroke "rgb(255,0,0)" -draw "line 0,$((${YRES}/15*15-1)) ${XRES},$((${YRES}/15*15-1))" \
    \
    +antialias ${ODIR}/grid_overscan.png
