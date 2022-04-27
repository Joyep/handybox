#!/usr/bin/python3
# coding=utf-8

import sys
import os

def main():


    arglen = len(sys.argv)
    if arglen > 1:
        print("hello %s" % (sys.argv[1]))
    else:
        print("hello!")

main()
