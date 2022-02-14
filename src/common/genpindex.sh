#!/bin/bash

set -e

inputfile=$1
parentscatfile=$2
parentcatfile=$3
is_archive=$4
outputfile=$5

ptitle=$(cat "$inputfile" | grep "^TITLE" | cut -d"|" -f2)
pscattitle=$(cat "$parentscatfile" | grep "^TITLE" | cut -d"|" -f2)
pscatpdesc=$(cat "$parentscatfile" | grep "^PRES_DESCRIPTION" | cut -d"|" -f2)
pcattitle=$(cat "$parentcatfile" | grep "^TITLE" | cut -d"|" -f2)
pcatpdesc=$(cat "$parentcatfile" | grep "^PRES_DESCRIPTION" | cut -d"|" -f2)

if [ -n "$pscatpdesc" ]; then pscatpdesc="$pscatpdesc<br>"; fi
if [ -n "$pcatpdesc" ]; then pcatpdesc="$pcatpdesc<br>"; fi

if [ "$is_archive" == "true" ]; then
	common_path="common"
	title_hierarchy=$(cat << EOM
	<span class="title-path">Accueil / $pcattitle / $pscattitle / </span>
EOM
)
	menu_buttons=$(cat << EOM
	<div id="get_ts_link_button" class="option option-last option-first">
		Copier un lien horodaté
	</div>
EOM
)
	is_archive_val="true"
else
	common_path="../../../common"
	title_hierarchy=$(cat << EOM
	<span class="title-path"><a href="../../..">Accueil</a> / <a href="../..">$pcattitle</a> / <a href="..">$pscattitle</a> / </span>
EOM
)
	menu_buttons=$(cat << EOM
	<div id="dl-slides" class="option option-first">
		Télécharger les diapos
	</div>
	<div id="dl-audio" class="option">
		Télécharger l'audio
	</div>
	<div id="dl-archive" class="option">
		Télécharger l'archive hors-ligne
	</div>
	<div id="get_ts_link_button" class="option option-last">
		Copier un lien horodaté
	</div>
EOM
)
	details="Pour plus de détails, <a href=\"../../../details/\"><b>cliquez&nbsp;ici</b></a>."
	is_archive_val="false"
fi

echo > "$outputfile"

cat <<EOF1 >> "$outputfile"
<!DOCTYPE html>
<html lang="fr">
	<head>
		<meta charset="utf-8">
		<meta name="viewport" content="width=device-width,user-scalable=no">
		<title>$ptitle</title>
		<link rel="stylesheet" href="$common_path/pstylesheet.css">
	</head>
	<body bgcolor=#000000>
		<div class="flex">
			<div id="slide_div" class="diapo">
				<div id="slide_controls">
					<img id="play_button" class="show" src="$common_path/play_button.svg" alt="play button">
					<img id="rewind_button" class="show" src="$common_path/rewind_icon.svg" alt="rewind button">
					<img id="fastforward_button" class="show" src="$common_path/rewind_icon.svg" alt="fast-forward button">
				</div>
				<picture class="diapo-img" id="img">
					<source  class="diapo-img" srcset="slides/slide-0.svg" type="image/svg+xml">
					<img class="diapo-img" src="slides/slide-0.jpg" alt="diapo" type="image/jpeg">
				</picture>
				<div id="options_menu" class="options-menu no-disp">
					$menu_buttons
				</div>
			</div>
			<div id="slide_miniature_container" class="slide_miniature_container no-disp">
			</div>
			<div id="audio_bar" class="audio">
				<div id="toggle_button" class="first_bar_button">
					<img id="play_button_small" src="$common_path/play_small.svg" type="image/svg+xml" alt="play">
					<img id="pause_button_small" class="no-disp" src="$common_path/pause_small.svg" type="image/svg+xml" alt="pause">
				</div>
				<input type="range" min="0" max="1" value="0" step="any" class="slider" id="timeslider">
				<span id="tt1" class="time-text-1">0:00:00</span> <span id="ttI" class="time-text-sep">/</span> <span id="tt2" class="time-text-2">0:00:00</span>
				<div id="options_button" class="first_bar_button">
					<img class="option-img" src="$common_path/options.svg" type="image/svg+xml" alt="options">
				</div>
				<div id="miniature_button" class="other_bar_buttons">
					<img class="option-img" src="$common_path/miniature.svg" type="image/svg+xml" alt="options">
				</div>
				<div id="fullscreen_button" class="other_bar_buttons">
					<img class="option-img" src="$common_path/full_screen.svg" type="image/svg+xml" alt="options">
				</div>
				<audio id="audio">
					<source src="audio/audio.opus" type="audio/ogg">
					<source src="audio/audio.aac">
					Not supported
				</audio>
			</div>
			<button id="description_bar" type="button" class="collapsible">
				<div class="button-left" id="collapsible">
					En savoir plus
				</div>
				<div class="button-right" id="annotation"></div>
			</button>
			<div class="description bounce">
				<div class="description-text">
					$title_hierarchy
					<h1>$ptitle</h1>
					<p>
						$pdesc
						$pscatpdesc
						$pcatpdesc
					</p>
					<br>
					<div class="description-pimoid">
						<h1>
							À propos du visionneur de présentation Pimoid
						</h1>
						<p>
							Ce visionneur de présentation a été conçu dans le but de minimiser la quantité de données transmises, et donc la consommation énergétique associée, tout en offrant un bon confort de visionnage. Il consomme environ 10x moins de donnés que le même cours au format vidéo.
							$details
						</p>
						<br>
						<h2>
							Raccourcis
						</h2>
						<table>
							<tr><td class="shortcut">Double-clic sur la diapo&nbsp;:</td><td>passer en plein écran</td></tr>
							<tr><td class="shortcut"><samp><kbd>&#8592;</kbd>/<kbd>&#8594;</kbd>&nbsp;</samp>:</td><td>reculer/avancer de 5&nbsp;secondes</td></tr>
							<tr><td class="shortcut"><samp><kbd>Shift</kbd>&nbsp;+&nbsp;<kbd>&#8592;</kbd>/<kbd>&#8594;</kbd>&nbsp;</samp>:</td><td>reculer/avancer de 30&nbsp;secondes</td></tr>
							<tr><td class="shortcut"><samp><kbd>Ctrl</kbd>&nbsp;+&nbsp;<kbd>&#8592;</kbd>/<kbd>&#8594;</kbd>&nbsp;</samp>:</td><td>aller à la diapo précédente/suivante</td></tr>
							<tr><td class="shortcut">Cliquer-glisser&nbsp;:</td><td>se déplacer finement dans la conférence</td></tr>
							<tr><td class="shortcut"><samp><kbd><</kbd>/<kbd>></kbd>&nbsp;</samp>:</td><td>ralentir/accélérer la vitesse de lecture</td></tr>
						</table>
						<br>
						Des problèmes ? Des incohérences ? Des idées d'amélioration ?
						<a href="mailto:slides@pimoid.fr?subject=Retours">Envoyez-nous vos retours par un e&#8209;mail&nbsp;!</a>&nbsp;:-)
						<br>
					</div>
				</div>
			</div>
		</div>
	</body>
	<script>
		var is_archive = $is_archive_val;
	</script>
	<script src="tabs.js" type="text/javascript"></script>
	<script src="$common_path/common.js">
	</script>
</html>
EOF1
