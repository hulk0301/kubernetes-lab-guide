#!/bin/sh

#apt-get install libffi-dev

pip install markdown2pdf
md2pdf lab/lab-1.md --theme=github
