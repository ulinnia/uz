#!/bin/sh

case "$1" in
    *.tar*) tar tf "$1";;
    *.7z|*.zip|*.rar) 7z l "$1";;
    *.pdf) pdftotext "$1" -;;
    *) highlight -O ansi "$1";;
esac
