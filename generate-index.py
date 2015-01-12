#!/usr/bin/python

import json
import os
import sys

base_dir = os.path.dirname(os.path.realpath(__file__))
content_dir = os.path.join(base_dir, 'content/')
json_file = os.path.join(base_dir, 'index.json')

def prep_json(file_path):
    js = load_json(file_path)
    js.pop('dashboardSections', None)
    js.pop('alerts', None)
    js.pop('queries', None)
    js.pop('eventTypes', None)
    js.pop('extractedFields', None)
    js['fileName'] = prep_path(file_path)
    return js


def load_json(file_path):
    f = open(file_path)
    text = f.read()
    f.close()
    try:
        json_text = json.loads(text);
    except ValueError as e:
        print "JSON Syntax error found in", file_path
        print "ValueError:", e
        sys.exit(0);
    return json_text


def prep_path(file_path):
    return file_path.split(content_dir)[1]


def hex_name(framework):
    return "#" +  str(hex(framework))[2:]


frameworks = {} # frameworks [ framework ] [ namespace ] = path
paths = []
for root, subs, names in os.walk(content_dir):
    for name in names:
        if name.endswith('.vlcp'):
            path = os.path.join(root, name)
            js = load_json(path)
            framework = int(js['framework'][1:], 16)
            namespace = js['namespace']

            if framework not in frameworks:
                frameworks[framework] = {}
            if namespace in frameworks[framework]:
                print "The following two files contain the same namespace and framemwork:"
                print "\t" + prep_path(path)
                print "\t" + prep_path(frameworks[framework][namespace])
                print "Remove the older version and rerun this script to continue"
                sys.exit()
            frameworks[framework][namespace] = path
            paths.append(path)

index_json = []
for path in paths:
    js = prep_json(path)
    index_json.append(js)
g = open(json_file, 'w')
g.write(json.dumps(index_json, indent=2, separators=(',', ': ')))
g.close()
