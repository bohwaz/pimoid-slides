#!/bin/bash

set -e

scatinputfile=${@:1:1}
parentcatfile=${@:2:1}
pinputfiles=${@:3:$(($#-3))}
outputfile=${@: -1}

scattitle=$(cat "$scatinputfile" | grep "^TITLE" | cut -d"|" -f2)
scatdesc=$(cat "$scatinputfile" | grep "^DESCRIPTION" | cut -d"|" -f2)

parentcattitle=$(cat "$parentcatfile" | grep "^TITLE" | cut -d"|" -f2)

echo > "$outputfile"

cat <<EOF1 >> "$outputfile"
<!DOCTYPE html>
<html lang="fr">
 	<head>
		<meta charset="utf-8">
		<meta name="viewport" content="width=device-width,user-scalable=no">
		<link rel="stylesheet" href="../../common/mstylesheet.css" />
		<title>$scattitle</title>
	</head>
	<body bgcolor=#000>
		<div class="content">
			<div class="redifs-pan">
				<div class="redifs-title">
					<span class="title-path"><a href="../..">Accueil</a> / <a href="..">$parentcattitle</a> / </span>
					<h1 class="title-main">$scattitle</h1>
				</div>
				<div class="description">
					$scatdesc
				</div>
				<div class="redifs-box">
EOF1

sortedfiles=$(for file in $pinputfiles; do echo "$file"; done | sort -h)

for file in $sortedfiles; do
	ptitle=$(cat "$file" | grep TITLE | cut -d"|" -f2)
	linkpath="$(basename $(dirname $file))"
	imgpath="$linkpath/pimg.jpg"
cat <<EOF1 >> "$outputfile"
					<a class="redif-box-link" href="$linkpath/">
            <div class="redif-box" style="background-image: url('$imgpath')">
              <div class="redif-box-text">
                <h2>$ptitle</h2>
              </div>
              <div class="redif-box-gradient"></div>
            </div>
          </a>
EOF1
done

cat <<EOF1 >> "$outputfile"
				</div>
			</div>
		</div>
	</body>
</html>
EOF1
