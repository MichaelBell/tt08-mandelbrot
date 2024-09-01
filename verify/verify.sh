#!/bin/bash

set -e

sby -d sby/square -f square.sby
sby -d sby/multiply -f multiply.sby

echo OK