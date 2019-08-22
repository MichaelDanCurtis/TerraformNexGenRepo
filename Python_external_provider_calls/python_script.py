#!/usr/bin/env python

"""Script to test the external data provider in Terraform"""

import sys
import json

def read_in():
    return {x.strip() for x in sys.stdin}

def main():
    lines = read_in()
    for line in lines:
        if line:
            jsondata = json.loads(line)
            jsondata["new-data"] = "Test123"
            sys.stdout.write(json.dumps(jsondata))

if __name__ == '__main__':
    main()