#!/bin/bash

## Build options

function def_value () {
	varname="$1"
	defvalue="$2"
	warn="$3"
	if [ -z "${!varname}" ]; then
		eval "$varname"='$defvalue'
		if [ -n "$warn" ]; then
			warn "$warn"
		fi
	fi
}

function error () {
	echo -e "\e[31mError\e[0m: $1"
	exit 1
}

function warn () {
	echo -e "\e[33mWarning:\e[0m $1"
}

output=

while [ "$#" -ge 1 ]; do
	arg="$1"
	shift

	if [ "$arg" = "-h" -o "$arg" = "--help" ]; then
		echo "Usage: $(basename "$0") [OPTIONS]"
		echo
		echo "  -o FILE          set output to FILE (default Makefile)"
		echo "  -h, --help       print this message"
		exit 0
	elif [ "$arg" = "-o" ]; then
		if [ $# -eq 0 ]; then
			error "option \"$arg\" needs an argument."
		fi
		if [ -n "$output" ]; then
			warn "option \"$arg\" used multiple times."
		fi
		output="$1"
		shift
	else
		error "unknown option \"$arg\"."
	fi
done

if [ -z "$output" ]; then
	output=Makefile
fi

source .defconfig

## Input checking

if ! [ "$MINIATURES_QUALITY " -eq "$MINIATURES_QUALITY" ] &> /dev/null; then
	error "MINIATURES_QUALITY should be an integer between 0 and 100"
fi

if ! ((MINIATURES_QUALITY >= 0 && MINIATURES_QUALITY <= 100)) &>/dev/null; then
	error "MINIATURES_QUALITY should be an integer between 0 and 100"
fi

if [ "$BUILD_TYPE" != debug -a "$BUILD_TYPE" != release ]; then
	error "BUILD_TYPE should be \"debug\" or \"release\""
fi

if [ "$BUILD_VERBOSE" != "true" -a "$BUILD_VERBOSE" != "false" ]; then
	error "BUILD_VERBOSE should be \"true\" or \"false\""
fi

if [ "$SOURCE_ARCHIVE" != "true" -a "$SOURCE_ARCHIVE" != "false" ]; then
	error "SOURCE_ARCHIVE should be \"true\" or \"false\""
fi

if [ "$SOURCE_ARCHIVE" = "true" ]; then
	if [ ! -d ".git" ]; then
		error "SOURCE_ARCHIVE is true but this is not a git repository"
	fi
fi

if [ "$HTML_MINIFY" != "true" -a "$HTML_MINIFY" != "false" ]; then
	error "HTML_MINIFY should be \"true\" or \"false\""
fi

if [ "$HTML_MINIFY" = "true" ]; then
	if ! hash htmlmin 2> /dev/null; then
		error "HTML_MINIFY is true but htmlmin seems not installed"
	fi
fi

if [ "$JAVASCRIPT_MINIFY" != "true" -a "$JAVASCRIPT_MINIFY" != "false" ]; then
	error "JAVASCRIPT_MINIFY should be \"true\" or \"false\""
fi

if [ "$JAVASCRIPT_MINIFY" = "true" ]; then
	if ! hash "$TERSER_NAME" 2> /dev/null; then
		error "JAVASCRIPT_MINIFY is true but terser seems not installed"
	fi
fi

## Checking for data repositories

list=$(ls -d data/*/ 2> /dev/null)
if [ -z "$list" ]; then
	error "no data repositories found"
fi

## Writing makefile

if [ "$BUILD_VERBOSE" = "false" ]; then
	delete_output="1>/dev/null 2>/dev/null"
	mkdir="@mkdir"
elif [ "$BUILD_VERBOSE" = "true" ]; then
	delete_output=
	mkdir="mkdir"
fi

if [ "$SOURCE_ARCHIVE" = "false" ]; then
	source_archive=
elif [ "$SOURCE_ARCHIVE" = "true" ]; then
	source_archive='$(SOURCEARCHIVE)'
fi

cat <<EOF > "$output"
##### CONFIGURATION #####
#
# MINIATURES_QUALITY=$MINIATURES_QUALITY
# DATA_DIR=$DATA_DIR
# BUILD_DIR=$BUILD_DIR
# BUILD_TYPE=$BUILD_TYPE
# BUILD_VERBOSE=$BUILD_VERBOSE
# SOURCE_ARCHIVE=$SOURCE_ARCHIVE
# HTML_MINIFY=$HTML_MINIFY
# TERSER_NAME=$TERSER_NAME
# JAVASCRIPT_MINIFY=$JAVASCRIPT_MINIFY
#
#########################

all: build

SRCDIR := src
DATADIR := $DATA_DIR
BUILDDIR := $BUILD_DIR
TMPBUILDDIR := tmp

TERSERNAME := $TERSER_NAME

### Gather sources ###

# Categories source files and dirs

CATFILES := \$(wildcard \$(DATADIR)/*/*.cat)
CATDIRS := \$(dir \$(CATFILES))

# Sub-categories source files and dirs

SCATFILESp = \$(wildcard \$(cat)/*/*.scat)
SCATFILES := \$(foreach cat, \$(CATDIRS), \$(SCATFILESp))
SCATDIRS := \$(dir \$(SCATFILES))

# Presentations source files, dirs and images

PFILESp = \$(wildcard \$(scat)/*/*.p)
PFILES := \$(foreach scat, \$(SCATDIRS), \$(PFILESp))
PDIRS := \$(dir \$(PFILES))

PIMGSp = \$(wildcard \$(p)/slides/*.svg)
PIMGS := \$(foreach p, \$(PDIRS), \$(PIMGSp))

### Targets generation ###

# Categories index and image files

CATBDIRS := \$(CATDIRS:\$(DATADIR)/%=\$(BUILDDIR)/%)

CATBINDEXp = \$(cat)/catindex.html
CATBINDEX := \$(foreach cat, \$(CATBDIRS), \$(CATBINDEXp))

CATBIMGp = \$(scat)/catimg.jpg
CATBIMG := \$(foreach scat, \$(CATBDIRS), \$(CATBIMGp))

# Sub-categories index and image files

SCATBDIRS := \$(SCATDIRS:\$(DATADIR)/%=\$(BUILDDIR)/%)

SCATBINDEXp = \$(scat)/scatindex.html
SCATBINDEX := \$(foreach scat, \$(SCATBDIRS), \$(SCATBINDEXp))

SCATBIMGp = \$(scat)/scatimg.jpg
SCATBIMG := \$(foreach scat, \$(SCATBDIRS), \$(SCATBIMGp))

# Presentations files (index, audio, pimage, images, pdf and timestamps js)

PBDIRS := \$(PDIRS:\$(DATADIR)/%=\$(BUILDDIR)/%)

PBINDEXp = \$(p)/pindex.html
PBINDEX := \$(foreach p, \$(PBDIRS), \$(PBINDEXp))

PBAUDIOp = \$(p)/audio/audio.opus \$(p)/audio/audio.aac
PBAUDIO := \$(foreach p, \$(PBDIRS), \$(PBAUDIOp))

PBIMGp = \$(p)/pimg.jpg
PBIMG := \$(foreach p, \$(PBDIRS), \$(PBIMGp))

PBIMGS := \$(PIMGS:\$(DATADIR)/%=\$(BUILDDIR)/%)
PBMINIATURES := \$(PBIMGS:%.svg=%.jpg)

PBPDFp = \$(p)/diapos.pdf \$(p)/diapos.pdf
PBPDF := \$(foreach p, \$(PBDIRS), \$(PBPDFp))

PBTIMESp = \$(p)/tabs.js
PBTIMES := \$(foreach p, \$(PBDIRS), \$(PBTIMESp))

PBARCHIVEp = \$(p)/archive.zip
PBARCHIVE := \$(foreach p, \$(PBDIRS), \$(PBARCHIVEp))

# Details page

DETAILSIMAGES = \
	\$(BUILDDIR)/details/images/yt_cours_1_360p_small.jpg \
	\$(BUILDDIR)/details/images/yt_cours_1_360p.png \
	\$(BUILDDIR)/details/images/pimoid_cours_1_small.jpg \
	\$(BUILDDIR)/details/images/pimoid_cours_1.png \
	\$(BUILDDIR)/details/images/donate_button.png

SOURCEARCHIVE = \$(BUILDDIR)/details/pimoid-slides.zip

# Common dir targets

COMMONF := \$(BUILDDIR)/details/index.html \$(BUILDDIR)/details/stylesheet.css \
 \$(DETAILSIMAGES) \
 \$(BUILDDIR)/common/common.js \$(BUILDDIR)/common/play_button.svg \
 \$(BUILDDIR)/common/options.svg \$(BUILDDIR)/common/full_screen.svg \
 \$(BUILDDIR)/common/miniature.svg \
 \$(BUILDDIR)/common/play_small.svg \$(BUILDDIR)/common/pause_small.svg \
 \$(BUILDDIR)/common/rewind_icon.svg \$(BUILDDIR)/common/mstylesheet.css \
 \$(BUILDDIR)/common/pstylesheet.css \$(BUILDDIR)/aindex.html

### Rules definitions ###

# Simple copy rules (for images, audio, pdf and timestamp js)

# for categories images
\$(BUILDDIR)/%/catimg.jpg: \$(DATADIR)/%/catimg.jpg
	$mkdir -p \$(dir \$@)
	cp -f \$^ \$@
\$(BUILDDIR)/%/scatimg.jpg: \$(DATADIR)/%/scatimg.jpg
	$mkdir -p \$(dir \$@)
	cp -f \$^ \$@
\$(BUILDDIR)/%/pimg.jpg: \$(DATADIR)/%/pimg.jpg
	$mkdir -p \$(dir \$@)
	cp -f \$^ \$@

\$(BUILDDIR)/details/%.png: \$(SRCDIR)/details/%.png
	$mkdir -p \$(dir \$@)
	cp -f \$^ \$@

\$(BUILDDIR)/details/%.jpg: \$(SRCDIR)/details/%.jpg
	$mkdir -p \$(dir \$@)
	cp -f \$^ \$@

\$(BUILDDIR)/%/audio/audio.aac: \$(DATADIR)/%/audio/audio.aac
	$mkdir -p \$(dir \$@)
	cp -f \$^ \$@

\$(BUILDDIR)/%/audio/audio.opus: \$(DATADIR)/%/audio/audio.opus
	$mkdir -p \$(dir \$@)
	cp -f \$^ \$@

\$(BUILDDIR)/%/diapos.pdf: \$(DATADIR)/%/diapos.pdf
	$mkdir -p \$(dir \$@)
	cp -f \$^ \$@

\$(BUILDDIR)/%.svg: \$(SRCDIR)/%.svg
	$mkdir -p \$(dir \$@)
	cp -f \$^ \$@

\$(BUILDDIR)/%.svg: \$(DATADIR)/%.svg
	$mkdir -p \$(dir \$@)
	cp -f \$^ \$@

\$(BUILDDIR)/%.css: \$(SRCDIR)/%.css
	$mkdir -p \$(dir \$@)
EOF

if [ "$BUILD_TYPE" = release -a "$HTML_MINIFY" = true ]; then
	cat <<EOF >> "$output"
	htmlmin -c -s \$^ > \$@
EOF
else
	cat <<EOF >> "$output"
	cp \$^ \$@
EOF
fi

cat <<EOF >> "$output"

# Miniatures rules

\$(BUILDDIR)/%.jpg: \$(TMPBUILDDIR)/%.png
	$mkdir -p \$(dir \$@)
	convert \$^ -quality $MINIATURES_QUALITY \$@

\$(TMPBUILDDIR)/%.png: \$(DATADIR)/%.svg
	$mkdir -p \$(dir \$@)
	inkscape \$^ -o \$@ -w 140 $delete_output

# Javascript minifying rules

# Don't use toplevel as it would remove all the data in tabs.js
\$(BUILDDIR)/%.js: \$(DATADIR)/%.js
	$mkdir -p \$(dir \$@)
EOF

if [ "$BUILD_TYPE" = release ]; then
	if [ "$JAVASCRIPT_MINIFY" = true ]; then
		cat <<EOF >> "$output"
	\$(TERSERNAME) --compress drop_console=true --mangle -- \$^ > \$@
EOF
	else
		cat <<EOF >> "$output"
	cp \$^ \$@
EOF
	fi
elif [ "$BUILD_TYPE" = debug ]; then
	if [ "$JAVASCRIPT_MINIFY" = true ]; then
		cat <<EOF >> "$output"
	\$(TERSERNAME) -- \$^ > /dev/null
EOF
	fi
	cat <<EOF >> "$output"
	cp \$^ \$@
EOF
fi

cat <<EOF >> "$output"

\$(BUILDDIR)/common/common.js: \$(SRCDIR)/common/common.js
	$mkdir -p \$(dir \$@)
EOF

if [ "$BUILD_TYPE" = release ]; then
	if [ "$JAVASCRIPT_MINIFY" = true ]; then
		cat <<EOF >> "$output"
	\$(TERSERNAME) --compress drop_console=true --mangle --toplevel -- \$^ > \$@
EOF
	else
		cat <<EOF >> "$output"
	cp \$^ \$@
EOF
	fi
elif [ "$BUILD_TYPE" = debug ]; then
	if [ "$JAVASCRIPT_MINIFY" = true ]; then
		cat <<EOF >> "$output"
	\$(TERSERNAME) -- \$^ > /dev/null
EOF
	fi
	cat <<EOF >> "$output"
	cp \$^ \$@
EOF
fi

cat <<EOF >> "$output"
# HTML indexes generation rules

\$(BUILDDIR)/details/index.html: \$(SRCDIR)/details/gendetails.sh
	$mkdir -p \$(dir \$@)
	\$^ $SOURCE_ARCHIVE \$@

\$(TMPBUILDDIR)/aindex.html: \$(SRCDIR)/common/genaindex.sh \$(DATADIR)/*/*.cat
	$mkdir -p \$(dir \$@)
EOF
if [ "$BUILD_VERBOSE" = "true" ]; then
	cat <<EOF >> "$output"
	\$^ \$@
EOF
elif [ "$BUILD_VERBOSE" = "false" ]; then
	cat <<EOF >> "$output"
	@echo \$< \$@
	@\$^ \$@
EOF
fi

cat <<EOF >> "$output"

\$(TMPBUILDDIR)/%/catindex.html: \$(SRCDIR)/common/gencatindex.sh \
 \$(DATADIR)/%/*.cat \$(DATADIR)/%/*/*.scat
	$mkdir -p \$(dir \$@)
EOF
if [ "$BUILD_VERBOSE" = "true" ]; then
	cat <<EOF >> "$output"
	\$^ \$@
EOF
elif [ "$BUILD_VERBOSE" = "false" ]; then
	cat <<EOF >> "$output"
	@echo \$< \$@
	@\$^ \$@
EOF
fi

cat <<EOF >> "$output"

\$(TMPBUILDDIR)/%/scatindex.html: \$(SRCDIR)/common/genscatindex.sh \
 \$(DATADIR)/%/*.scat \$(DATADIR)/%/../*.cat \$(DATADIR)/%/*/*.p
	$mkdir -p \$(dir \$@)
EOF
if [ "$BUILD_VERBOSE" = "true" ]; then
	cat <<EOF >> "$output"
	\$^ \$@
EOF
elif [ "$BUILD_VERBOSE" = "false" ]; then
	cat <<EOF >> "$output"
	@echo \$< \$@
	@\$^ \$@
EOF
fi

cat <<EOF >> "$output"

# false: not a archive
\$(TMPBUILDDIR)/%/pindex.html: \$(SRCDIR)/common/genpindex.sh \$(DATADIR)/%/*.p \
 \$(DATADIR)/%/../*.scat \$(DATADIR)/%/../../*.cat
	$mkdir -p \$(dir \$@)
EOF
if [ "$BUILD_VERBOSE" = "true" ]; then
	cat <<EOF >> "$output"
	\$^ false \$@
EOF
elif [ "$BUILD_VERBOSE" = "false" ]; then
	cat <<EOF >> "$output"
	@echo \$< \$@
	@\$^ false \$@
EOF
fi

cat <<EOF >> "$output"

\$(BUILDDIR)/%.html: \$(TMPBUILDDIR)/%.html
	$mkdir -p \$(dir \$@)
EOF

if [ "$BUILD_TYPE" = release -a "$HTML_MINIFY" = true ]; then
	cat <<EOF >> "$output"
	htmlmin -c -s \$^ > \$@
EOF
else
	cat <<EOF >> "$output"
	cp \$^ \$@
EOF
fi

cat <<EOF >> "$output"

# Offline archive generation

\$(TMPBUILDDIR)/zip/%/index.html: \$(TMPBUILDDIR)/zip/%/index-raw.html
	$mkdir -p \$(dir \$@)
EOF

if [ "$BUILD_TYPE" = release -a "$HTML_MINIFY" = true ]; then
	cat <<EOF >> "$output"
	htmlmin -c -s \$^ > \$@
EOF
else
	cat <<EOF >> "$output"
	cp \$^ \$@
EOF
fi

cat <<EOF >> "$output"

# true: it is an a archive
\$(TMPBUILDDIR)/zip/%/index-raw.html: \$(SRCDIR)/common/genpindex.sh \
 \$(DATADIR)/%/*.p \$(DATADIR)/%/../*.scat \$(DATADIR)/%/../../*.cat
	$mkdir -p \$(dir \$@)
EOF
if [ "$BUILD_VERBOSE" = "true" ]; then
	cat <<EOF >> "$output"
	\$^ true \$@
EOF
elif [ "$BUILD_VERBOSE" = "false" ]; then
	cat <<EOF >> "$output"
	@echo \$< \$@
	@\$^ true \$@
EOF
fi

cat <<EOF >> "$output"

\$(BUILDDIR)/%/archive.zip: \$(SRCDIR)/common/genarchive.sh \
 \$(TMPBUILDDIR)/zip/%/index.html \$(DATADIR)/%/audio/audio.aac \
 \$(BUILDDIR)/%/tabs.js \$(BUILDDIR)/common/common.js \
 \$(BUILDDIR)/common/pstylesheet.css \$(SRCDIR)/common/play_button.svg \
 \$(SRCDIR)/common/play_small.svg \$(SRCDIR)/common/pause_small.svg \
 \$(SRCDIR)/common/options.svg \$(SRCDIR)/common/full_screen.svg \
 \$(SRCDIR)/common/miniature.svg \$(SRCDIR)/common/rewind_icon.svg \
 \$(SRCDIR)/common/rewind_icon.svg \$(DATADIR)/%/slides/*.svg
	$mkdir -p \$(dir \$@)
EOF
if [ "$BUILD_VERBOSE" = "true" ]; then
	cat <<EOF >> "$output"
	\$^ \$@
EOF
elif [ "$BUILD_VERBOSE" = "false" ]; then
	cat <<EOF >> "$output"
	@echo \$< \$@
	@\$^ \$@ $delete_output
EOF
fi

if [ "$SOURCE_ARCHIVE" = "true" ]; then
cat <<EOF >> "$output"

# Source archive generation

\$(SOURCEARCHIVE): \$(shell git ls-tree -r --name-only HEAD)
	$mkdir -p \$(dir \$@)
EOF
if [ "$BUILD_VERBOSE" = "true" ]; then
	cat <<EOF >> "$output"
	zip \$@ \$^
EOF
elif [ "$BUILD_VERBOSE" = "false" ]; then
	cat <<EOF >> "$output"
	@echo zip \$@
	@zip \$@ \$^ $delete_output
EOF
fi

fi

cat <<EOF >> "$output"

### User rules ###

common: \$(COMMONF)

build: \$(CATBINDEX) \$(CATBIMG) \$(SCATBINDEX) \$(SCATBIMG) \$(PBINDEX) \
	\$(PBIMG) \$(PBAUDIO) \$(PBPDF) \$(PBIMGS) \$(PBMINIATURES) \$(PBTIMES) \
	\$(PBARCHIVE) $source_archive common

clean:
	rm -rf \$(BUILDDIR) \$(TMPBUILDDIR)

.PHONY: all build common clean
EOF
