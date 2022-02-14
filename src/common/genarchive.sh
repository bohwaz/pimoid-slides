#!/bin/bash

set -e

tmppath="/tmp/$(uuidgen)"

add_files () {
	path=$1
	files=${@:2:$(($#-1))}
	mkdir -p "$tmppath/$path"
	basenames=
	for file in $files; do
		ln -s $(realpath $file) "$tmppath/$path/"
		basenames+="$path/$(basename $file) "
	done
	cd "$tmppath"
	zip "$outputfile" $basenames
	cd -
}

indexfile=$1
audiofile=$2
tabsfile=$3
commonfile=$4
stylesheetfile=$5
svgfiles="$6 $7 $8 $9 ${10} ${11} ${12}"
imgfiles=${@:13:$(($#-13))}
outputfile=$(realpath ${@: -1})

rm -f "$outputfile"

add_files "." "$indexfile"
add_files "audio" "$audiofile"
add_files "." "$tabsfile"
add_files "common" "$commonfile"
add_files "common" "$stylesheetfile"
add_files "common" $svgfiles
add_files "slides" $imgfiles

rm -rf "$tmppath/"
