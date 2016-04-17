#!/usr/bin/python

from sys import stdin
import re

def label_visible(l):
#   if node label l should be hidden:
#       return False
    return True

def edge_visible(l, d):
#   if edge label l with style d should be hidden:
#       return False
    return True


def node_color(ls):
#   if some node label should be colored l in ls:
#       return 'color'
    return None

def rebuild(a1):
    a2 = [k+'="'+a1[k]+'"' for k in a1]
    return ', '.join(a2)

def name(line):
    sp = line.find(' ')
    return line[:sp]

def attr(line):
    lb = line.find('[')
    rb = line.rfind(']')
    props = line[lb+1:rb]
    attrs = props.split(', ')
    attrmap = {}
    for a in attrs:
        eq = a.find('=')
        k = a[:eq]
        v = a[eq+1:]
        if v.startswith('"') and v.endswith('"'):
            v = v.strip('"')
        attrmap[k] = v
    return attrmap

def node(line):
    n = name(line)
    a1 = attr(line)
    a2 = {}
    for k in a1:
        v = a1[k]
        if k == 'label':
            ls = v.split('\\n')
            ls = filter(label_visible, ls)
            c = node_color(ls)
            if c is not None:
                a2['color'] = c
                # a2['style'] = 'filled'
            v = '\\n'.join(ls)
        a2[k] = v
    print(n, '[' + rebuild(a2) + '];')

def edge(line):
    n = name(line)
    a1 = attr(line)
    l = a1['label']
    d = 'style' in a1 and a1['style'] == 'dotted'
    if edge_visible(l, d): 
        print(n, '[' + rebuild(a1) + '];')

rules = [
    (re.compile('"\d+"->"\d+"\s\['), edge),
    (re.compile('"\d+"\s\['),        node)
]

for line in stdin:
    t = False
    line = line.strip()
    for (re, fun) in rules:
        if not t and re.match(line):
            fun(line)
            t = True
    if not t:
        print(line)
