Please note that this is just a mirror of the ZIP file available at [pimoid.fr](https://pimoid.fr/)

I did not develop this software.

# Pimoid-slides

This software enables one to build a website to display presentations with high
quality, full-screen vectorial slides, and clear audio with very low bandwidth
requirement.

Instead of filming a presentation with a camera, it uses directly the source
slides to have the best quality. It also use high compression format such as
opus for audio.
On Jancovici courses, it used 10 time less data than the video equivalent on
Youtbe, and with a higher quality.

See src/details/index.html for more details.

# Building the website

## Adding presentations

First, you need to add some presentations to the data/ folder, otherwise your
website will be empty.

Each presenter will have its own folder in data/. Each presenter folder will
contain group of presentations. And each group will contain actual presentations.
Each presentation will contain slides, audio, a timestamps file to synchronise the last
two, a thumbnail, and metadata.

For example, here is a data/ folder with 2 presenters: a demo presenter and
Jancovici, an actual presenter.

```
data/
├── example_presenter
│   ├── example_topic_1
│   │   ├── course_1
│   │   └── course_2
│   └── example_topic_2
│       └── presentation_1
└── jancovici
    └── mines_2019
        ├── cours_1
        ├── cours_2
        └── cours_3
```

You can take example from the presentations of Jancovici.
Run:
```
$ cd data/
$ git clone https://git.pimoid.fr/pimoid-slides-jancovici.git
```

## Requirements

Requirements:

- make
- zip
- inkscape
- imagemagick

Optional:

- git (source code archive generation)
- terser
- htmlmin

If you are running Debian, you can install these requirements with apt:
$ sudo apt install make uglifyjs.terser zip inkscape imagemagick htmlmin

## Build

First, generate the Makefile with the configure.sh script:
```
$ ./configure.sh
```

You can give arguments to modify the build configuration with environment
variables to this script. All arguments have default values and are explained
in ".defconfig" file. Example (build configuration with better
miniatures quality and custom output directory):
```
$ MINIATURES_QUALITY=80 BUILD_DIR=/tmp/build ./configure.sh
```

Then, use make to build the website:
```
$ make
```

The build time may be quite long (mainly because slides rasterisation and
archive generation), so you can enable parallel jobs to reduce it:
```
$ make -j$(nproc)
```

# HTTP configuration

Requirements:

- an HTTP server

The content of the build directory should be delivered by the HTTP server.
The webserver must be configured to send these files as directory indexes:
index.html, aindex.html, catindex.html, scatindex.html and pindex.html.
For exemple, with Apache, this correspond to the following configuration:
> `DirectoryIndex index.html aindex.html catindex.html scatindex.html pindex.html`

It is also advised to enable SVG compression on the server. With Apache, you
first need to enable the deflate compression module:
> `$ a2enmod deflate`
Then, enable SVG compression with this line:
> `AddOutputFilterByType DEFLATE image/svg+xml`

# Questions - help

You can send us a message to ask questions, or if you need help to use it, or
whatever else related to this project :
> slides@pimoid.fr
We will try to answer quickly !
