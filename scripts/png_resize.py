#!/usr/bin/python
#
# -*- coding: utf-8 -*-
#
# @mainpage  Resize PNG image file
#
# @section intro_sec Introduction
# This is a command line tool that resize given png inage to the coresponding size.
# By default it is 144x144 px.
# For exmaple: ./png_resize.py -f in.png -o out.png -x 144 -y 144
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

from PIL import Image
import argparse


def resize_file(in_file, out_file, new_size):
	im = Image.open(in_file)
	
	larger_im = im.resize(new_size)
	larger_im.save(out_file)



if __name__ == '__main__':
	parser = argparse.ArgumentParser(description='Resize PNG and add a frame for printing.')
	parser.add_argument('-f', nargs='?', dest='input', 
	                    help='imput png file name')
	parser.add_argument('-o', nargs='?', dest='output',
	                    help='output png file name')
	# choose smaller of two:
	parser.add_argument('-x', '--width', type=int, default=144, dest='widht',
	                    help='target width (including margins, default size is 144px)')
	parser.add_argument('-y', '--height', type=int, default=144, dest='height',
	                    help='target height (including margins, default size is 144pz)')
	options = vars(parser.parse_args())

	print ""
	print "The '" + options['input'] + "' file will be resized to the " + str(options['widht']) + "x" + str(options['height']) + " px"
	print ""
	size = (options['widht'], options['height'])
	resize_file(options['input'], options['output'], size)
	print "The resized image file is '" + options['output'] + "'"


