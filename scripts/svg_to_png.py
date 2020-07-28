#!/usr/bin/python
#
# -*- coding: utf-8 -*-
#
# @mainpage  Cpmvert SVG image file format to the  PNG image file format
#
# @section intro_sec Introduction
# This is a command line tool that convert given svg image file format to the 
# png inage file format to the same dimension.
# For exmaple: ./svg_to_png.py -f input.svg -o out.png
#
# @author Andranik Haroyan
# Email: haroyana@vmware.com
#
# @date 28-Jul-2020
#
# @copyright VMware (C) 2020
# version 1.0
#
##############################################################################

import cairo
import rsvg
from xml.dom import minidom


def convert_svg_to_png(svg_file, output_file):
    print "processing '" + svg_file + "' file"
    # Get the svg files content
    with open(svg_file) as f:
        svg_data = f.read()

    # Get the width / height inside of the SVG
    doc = minidom.parse(svg_file)
    width = [path.getAttribute('width') for path
                 in doc.getElementsByTagName('svg')][0]
    height = [path.getAttribute('height') for path
                  in doc.getElementsByTagName('svg')][0]

    # if the svg width defiend in the inch convert to pixel
    if str(width).find("in") != -1:
        width = float(str(width).replace('in', '')) * 96
    width = int(width)

    # if the svg height defiend in the inch convert to pixel
    if str(height).find("in") != -1:
        height = float(str(height).replace('in', '')) * 96
    height = int(height)

    doc.unlink()

    # create the png object
    img = cairo.ImageSurface(cairo.FORMAT_ARGB32, width, height)
    ctx = cairo.Context(img)
    handler = rsvg.Handle(None, str(svg_data))
    handler.render_cairo(ctx)
    # write png file
    img.write_to_png(output_file)

if __name__ == '__main__':
    from argparse import ArgumentParser

    parser = ArgumentParser()

    parser.add_argument("-f", "--file", dest="svg_file",
                        help="SVG input file", metavar="FILE")
    parser.add_argument("-o", "--output", dest="output", default="svg.png",
                        help="PNG output file", metavar="FILE")
    args = parser.parse_args()
    print "Converting '" + args.svg_file + "' to the '" + args.output + "' file"
    convert_svg_to_png(args.svg_file, args.output)
    print "Complete"
