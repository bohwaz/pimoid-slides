#!/bin/bash

set -e

catinputfiles=${@:1:$(($#-1))}
outputfile=${@: -1}

echo > "$outputfile"

cat <<EOF1 >> "$outputfile"
<!DOCTYPE html>
<html lang="fr">
 	<head>
		<meta charset="utf-8">
		<meta name="viewport" content="width=device-width,user-scalable=no">
		<link rel="stylesheet" href="common/mstylesheet.css" />
		<title>Accueil</title>
	</head>
	<body bgcolor=#000>
		<div class="content">
			<div class="redifs-pan">
				<div class="redifs-title">
					<span class="title-path"><br></span>
					<h1 class="title-main">Accueil</h1>
				</div>
				<div class="description">
					<p>
						Pimoid Slides est un visionneur de présentation : il permet
						d'écouter une présentation ou un cours tout en voyant les diapos du
						présentateur.
						Il a été conçu avec l'objectif d'être sobre en données transférées,
						tout en améliorant le confort de visionnage par rapport à une vidéo.
					</p>
					<p>
						Pour plus de détails, <a href="details/"><b>cliquez&nbsp;ici</b></a>.
					</p>
				</div>
				<div class="redifs-box">
EOF1

sortedfiles=$(for file in $catinputfiles; do echo "$file"; done | sort -h)

for file in $sortedfiles; do
	cattitle=$(cat "$file" | grep TITLE | cut -d"|" -f2)
	linkpath="$(basename $(dirname $file))"
	imgpath="$linkpath/catimg.jpg"
cat <<EOF1 >> "$outputfile"
					<a class="redif-box-link" href="$linkpath/">
						<div class="redif-box" style="background-image: url('$imgpath')">
							<div class="redif-box-text">
								<h2>$cattitle</h2>
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
