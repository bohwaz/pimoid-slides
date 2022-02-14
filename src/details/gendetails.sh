#!/bin/bash

set -e

archive=$1
outputfile=${@: -1}

echo > "$outputfile"

if [ "$archive" == "true" ]; then
	archivetext="<li> Archive ZIP&nbsp;: <a href="pimoid-slides.zip">Télécharger</a> </li>"
else
	archivetext=
fi

cat <<EOF >> "$outputfile"
<!DOCTYPE html>
<html lang="fr">
	<head>
		<meta charset="utf-8">
		<meta name="viewport" content="width=device-width,user-scalable=no">
		<title>Lecteur Pimoid</title>
		<link rel="stylesheet" href="stylesheet.css">
	</head>
	<body bgcolor=#000>
		<div class="content">
			<div class="title">
				<span class="title-path"><a href="..">Accueil</a> / </span>
				<h1 class="title-main">Visionneur de présentation Pimoid</h1>
			</div>
			<h2>
				Fonctionnement
			</h2>
			<p>
				Ce visionneur de présentation a été conçu dans le but de minimiser la
				quantité de données transmises, et donc de minimiser la consommation
				energétique associée, tout en offrant un bon confort de visionnage.
				Au lieu de diffuser une vidéo de la présentation, comme par exemple
				sur YouTube, ce lecteur affiche les diapos, sous forme d'images
				vectorielles compressées, en jouant la piste son du présentateur,
				compressée elle aussi. Il assure en permanance la synchronisation entre
				la diapo à afficher et la piste son.
			</p>
			<h2>
				Avantages
			</h2>
			<p>
				Par rapport à une vidéo, ce fonctionnement permet plusieurs avantages :
			</p>
			<ul>
				<li>
					Tout d'abord, comme expliqué ci-dessus, cela permet de transférer
					moins de données : environ 10 fois moins&nbsp;! La consomation énergétique
					engendrée est donc plus faible. De plus, cela rend possible le
					visionnage d'une présentation dans de bonnes conditions même avec une
					connexion à faible débit.
				</li>
				<li>
					La lisibilité des diapos : dans une vidéo, plusieurs facteurs
					peuvent la rendre mauvaise : la caméra peut ne pas être en face de
					l'écran de projection, elle peut bouger, être trop loin, etc. Et même
					si toutes ces conditions sont réunies, la vidéo devra avoir une
					définition assez élevée, ce qui implique une taille conséquente. Ici,
					les diapos sont sous formes d'images statiques vectorielles, directement
					extraites du fichier projeté par le présentateur : elle sont nettes, quelque
					soit la taille de l'écran de l'utilisateur, suffisament définies, elles
					prennent tout l'écran et ne bougent pas.
				</li>
				<li>
					L'interface utilisateur : il est possible de se déplacer
					temporellement dans la présentation avec des raccourcis clavier. La
					durée des sauts peut être fixe (Flèche ou Shift + Flèche) ou non :
					comme les changements de diapos sont connus du visualisateur, il est
					possible de sauter directement à la diapo suivante ou de retourner à
					la précédente (Ctrl + Flèche).
				</li>
			</ul>
			<h2>
				Comparaison avec Youtube
			</h2>
			<p>Cette comparaison a été faite sur la
			<a href="../jancovici/mines_2019/cours_1/">première
			présentation du cours des Mines de Jean-Marc Jancovici</a>. La
			<a href="https://www.youtube.com/watch?v=xgy0rW0oaFI">vidéo Youtube</a>
			correspondante est en qualité 360p.</p>
			<h3>Qualité d'image</h3>
			<p>Voici deux captures d'écran montrant la différence de qualité entre
			Youtube et le lecteur Pimoid sur cette présenatation.</p>
			<p>Cliquez sur une capture d'écran pour l'ouvrir en plein écran.</p>
				<div class="row">
					<div class="column">
						<a target="_blank" href="images/yt_cours_1_360p.png">
							<img src="images/yt_cours_1_360p_small.jpg" alt="Youtube screenshot" class="comp_img">
						</a>
						<div class="comp_img_desc">
							Sur Youtube, la diapo est floue. La légende est à peine visible.
						</div>
					</div>
					<div class="column">
						<a target="_blank" href="images/pimoid_cours_1.png">
							<img src="images/pimoid_cours_1_small.jpg" alt="Pimoid screenshot" class="comp_img">
						</a>
						<div class="comp_img_desc">
							Sur Pimoid, la diapo est bien nette, et occupe tout l'écran.
						</div>
					</div>
				</div>
			<h3>Utilisation de données</h3>
			<p>Pimoid utilise environ 10 fois moins de données que Youtube (en qualité 360p) !
			<!-- From https://www.w3schools.com/howto/howto_css_skill_bar.asp -->
			<div class="comp_data_graph">
				<div class="comp_data_section">
					<div><p class="comp_data_desc">Youtube</p></div><div class="comp_data_bar comp_yt"> 300 Mo</div>
				</div>

				<div class="comp_data_section">
				<div><p class="comp_data_desc">SlideShare + SoundCloud</p></div><div class="comp_data_bar comp_sssc">143 Mo</div>
				</div>

				<div class="comp_data_section">
					<div><p class="comp_data_desc">Pimoid</p></div>
					<span class="comp_data_bar comp_pimoid">&nbsp;</span><span class="size">30 Mo</span>
				</div>
			</div>
			<h2>
				Formats utilisés
			</h2>
				<p>
					Ce visualisateur utilise les formats libres suivants&nbsp;:
				</p>
				<ul>
					<li>
						Le format <a href="https://fr.wikipedia.org/wiki/Scalable_Vector_Graphics">SVG</a> pour
						les diapos. C'est un format d'images vectorielles, ce qui permet d'avoir
						une très bonne qualité d'affichage quelque soit la taille de la définition
						de l'écran. Les objets graphiques (comme des cercles, de flèches ou du texte)
						sont décrits tels quels, contrairement à un format d'image classique
						qui décrit simplement une matrice de pixels. Si la diapo utilise des
						images matricielles, elles sont encodées au format JPG dans le fichier
						SVG, avec une qualité réglée à 50 / 100. Ce format étant basé sur XML,
						c'est un format texte, il est donc envoyé compressé au format Gzip (deflate)
						si le navigateur le supporte.
					</li>
					<li>
						Le format
						<a href="https://fr.wikipedia.org/wiki/Opus_Interactive_Audio_Codec">Opus</a>
						pour le son. Il est encodé à un débit assez faible, 10 kb/s, ce qui
						est toutefois suffisant pour fournir une écoute claire et confortable
						de la voix du présentateur.
					</li>
				</ul>
				<p>
					SVG est supporté par tous les navigateurs, sauf de très vieilles versions
					d'Internet Explorer, tout comme les images JPG, cela ne pose donc pas
					de problèmes de compatibilité. Opus est supporté par la majorité des
					navigateurs, seuls Internet Explorer et Safari ne le supportent pas.
					Pour que le visionnage soit quand même possible, en cas
					d'incompatibilité, l'audio est fourni avec un autre format compatible,
					<a href="https://fr.wikipedia.org/wiki/Advanced_Audio_Coding">AAC</a>,
					qui est toutefois moins performant qu'Opus, la qualité peut donc être
					légèrement dégradée, et la quantité de données transférées plus élevée.
				</p>
			<h2>
				Code source
			</h2>
				<p>
					Le code source de ce site est accessible librement :
				</p>
				<ul>
					<li>
						Git&nbsp;: https://git.pimoid.fr/pimoid-slides.git
					</li>
					$archivetext
				</ul>
			<h2>
				Contact
			</h2>
				<p>
					Vous pouvez nous contacter à cette adresse mail&nbsp;:&nbsp;<a href="mailto:slides@pimoid.fr?subject=Contact">slides@pimoid.fr</a>.
				</p>
			<h2>
				Contribuer
			</h2>
				<p>
					Ce site est developpé bénévolement, dans le but de diffuser gratuitement des présentations de qualité de manière minimaliste.
				</p>
				<p>
					Comme il n'y a pas de pub, nous ne recevons aucune rémunération pour notre travail (et même&nbsp;: chaque fois qu'une personne regarde une présentation, cela nous coute une toute petite fraction de centime !).
				</p>
				<p>
					Si le coeur vous en dit, pour nous aider à continuer à développer le site, vous pouvez nous donner un ou deux euros via le lien "faire un don" ci-dessous. Merci à vous !
				</p>
				<br>
				<form action="https://www.paypal.com/donate" method="post" target="_top">
					<input type="hidden" name="hosted_button_id" value="WDD2T9JWZ74C4" />
					<input class="donate_button" type="image" src="images/donate_button.png" border="0" name="submit" title="PayPal - The safer, easier way to pay online!" alt="Donate with PayPal button" />
				</form>
				<p class="crypto">
					Bitcoin : 1PimoidjSAumU1sJexHfn1WBcRAYoS7BSt<br>
					Litecoin : LPimoidWo4s3DPrUFF4ssBoBWqznzj4tgF
				</p>
		</div>
	</body>
</html>
EOF
