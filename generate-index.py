#!/usr/bin/python

import json
import os
import sys

base_dir = os.path.dirname(os.path.realpath(__file__))
content_dir = os.path.join(base_dir, 'content/')
json_file = os.path.join(base_dir, 'index.json')
maintenance_list_file = os.path.join(base_dir, 'maintenance-list.json')
support_modes = {'maintenance': "maintenance", 'supported': "supported"}

def prep_json(file_path, support_mode):
    js = load_json(file_path)
    js.pop('dashboardSections', None)
    js.pop('alerts', None)
    js.pop('queries', None)
    js.pop('eventTypes', None)
    js.pop('agentClasses', None)
    js.pop('extractedFields', None)
    js.pop('aliasFields', None)
    js.pop('aliasRules', None)
    js.pop('instructions', None)
    js['fileName'] = prep_path(file_path)
    js['supportMode'] = support_mode
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

def prep_support_list(file_path):
    #file should exist and be valid
    maintenance_cp_list = []
    if os.path.isfile(file_path):
        maintenance_cp_list_js = load_json(file_path)
        for namespace in tuple(maintenance_cp_list_js):
            ns = namespace.get('namespace')
            if ns is not None:
                maintenance_cp_list.append(ns)
        if len(maintenance_cp_list) is 0:
            print "INFO: The 'maintenance-list' does not contains any 'namespace' list."
    return maintenance_cp_list

frameworks = {} # frameworks [ framework ] [ namespace ] = path
maintenance_cp_list = prep_support_list(maintenance_list_file)
cps_info = []

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
            cp_info = {}
            cp_info.update({'path': path})
            if namespace in maintenance_cp_list:
                cp_info.update({'mode': support_modes['maintenance']})
            else:
                cp_info.update({'mode': support_modes['supported']})
            cps_info.append(cp_info)

index_json = []
for info in cps_info:
    js = prep_json(info['path'], info['mode'])
    index_json.append(js)

g = open(json_file, 'w')
g.write(json.dumps(index_json, indent=2, separators=(',', ': ')))
g.close()
