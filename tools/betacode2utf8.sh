#!/bin/sh
# See LICENSE file for copyright and license details.

usage="Usage: $0

Wrapper around tlgu to suppress error messages and remove any
betacode not converted."

test "$1" = "-h" && echo "$usage" && exit 1

tlgu $@ 2>/dev/null | sed -e 's/[*0\.,:;_\(\)\/=\\|&@-]//g' -e "s/'/’/g" -e '/^$/d' -e '/^ $/d' -e '/^’/d'
