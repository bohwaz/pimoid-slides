#!/bin/bash

set -e

catinputfile=${@:1:1}
scatinputfiles=${@:2:$(($#-2))}
outputfile=${@: -1}

cattitle=$(cat "$catinputfile" | grep "^TITLE" | cut -d"|" -f2)
catdesc=$(cat "$catinputfile" | grep "^DESCRIPTION" | cut -d"|" -f2)

echo > "$outputfile"

cat <<EOF1 >> "$outputfile"
<!DOCTYPE html>
<html lang="fr">
 	<head>
		<meta charset="utf-8">
		<meta name="viewport" content="width=device-width,user-scalable=no">
		<link rel="stylesheet" href="../common/mstylesheet.css" />
		<title>$cattitle</title>
	</head>
	<body bgcolor=#000>
		<div class="content">
			<div class="redifs-pan">
				<div class="redifs-title">
					<span class="title-path"><a href="..">Accueil</a> / </span>
					<h1 class="title-main">$cattitle</h1>
				</div>
				<div class="description">
					$catdesc
				</div>
				<div class="redifs-box">
EOF1

sortedfiles=$(for file in $scatinputfiles; do echo "$file"; done | sort -h)

for file in $sortedfiles; do
	scattitle=$(cat "$file" | grep TITLE | cut -d"|" -f2)
	linkpath="$(basename $(dirname $file))"
	imgpath="$linkpath/scatimg.jpg"
cat <<EOF1 >> "$outputfile"
					<a class="redif-box-link" href="$linkpath/">
            <div class="redif-box" style="background-image: url('$imgpath')">
              <div class="redif-box-text">
                <h2>$scattitle</h2>
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
