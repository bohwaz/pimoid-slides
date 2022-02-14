# BUG FIX
 - julien.pimoid.fr/:1 Uncaught (in promise) DOMException: The play() request was interrupted by a call to pause().
 - Sur iPhone, la barre audio execute le onClick to slide_div et fais play/pause

# IDEES
## Backend
 - recherche dichotomique des slides dans le javascript
 - au lieu de rechercher la diapo actuelle à chaque fois, juste vérifier qu'on est dans le bon encadrement
 - Réécrire le JS en Haskell puis convertir avec GhcJs

## Lecteur
 - Afficher un curseur ou une ellipse pour remplacer le curseur du présentateur
 - support pour media controls: https://stackoverflow.com/questions/59828493/how-to-customize-global-media-controls-in-google-chrome-question-and-answer
 - Picture in picture ?
 - Ctrl+Flèche Gauche retourne au début de la slide actuel, ou à la slide précédent si on est à moins de 2sec du début de la slide actuelle
 - Swipe vers le haut ouvre "En savoir plus"
 - Swipe vers le bas affiche toutes les miniatures
 - Mettre un "5s" au centre des boutons avance/recule
 - Mettre une barre de progression pour savoir quand la slide va changer
 - Raccourci clavier affiche icon brievement
 - Afficher un icone de chargement lorsque la slide prend du temps à se télécharger et ne correspond pas aux timestamps théoriques, ou que l'audio bufferise
 - Afficher une petite vidéo dans un coin pour voir le présentateur
### Miniatures
 - Utiliser toute la largeur de l'écran en ajustant la largeur des miniatures
 - Mettre en évidence la diapo actuelle
 - Centrer la liste des miniatures sur la diapo actuelle
### Sous-titres
 - Afficher des sous-titres
 - Options pour changer la langues des sous-titres
 - Recherche textuelle dans les sous-titres, puis aller au timestamp correspondant
### Annotations
 - lien animation slide-in: http://jsfiddle.net/qP5fW/87/
 - recenser toutes les liens annotations temporaires et les écrire en dur dans la description, avec un lien "Aller à cet endroit" qui ammène au moment où Janco en parle. En Javascript au chargement de la page ou en python au moment du make ?

## Autres
 - Lorsqu'on clique sur le lien git, afficher une page qui explique comment clone un projet git, et afficher le README
 - Traduire le site en anglais
 - Ajouter un mode clair/sombre
 - compteur de vues
 - Ajouter une favicon
 - Icon pour swipe
 - Dans les retours par mail, intégrer l'url de la page actuelle
 - Mettre une barre de progression dans le menu qui affiche ou l'utilisateur en est dans la vidéo
 - Dans les menus afficher la durée du cours sur la miniature
 - Dans les menus afficher les émissions de CO2 émis pour le visionnage du cours
 - Reprendre la vidéo où l'utilisateur en était
 - Rediriger les utilisateurs de Safari sur Macintosh vers un autre navigateur. Sur iPhone, tous les navigateur moteur Webkit.
### Téléchargements
 - Dans les archives, mettre uniquement les slides qui vont être affichées
 - Télécharger les images utilisés pendant la présentation plutôt que les pdf du cours des mines

# DONE
 - Changer le playback_rate
 - Rendre le code Open-Source
 - compresser css et html en enlevant commentaire, newline
 - Télécharger un pack HTML/CSS/JS slides/audio pour visionnage offline
 - Capturer les swipes pour se déplacer finement dans l'audio sur mobile et PC
 - minify Javascript
 - Quand on clique sur coté de la slide, le button d'avance/recule s'affiche brievement
 - Quand on clique sur le coté de la slide, ça avance/recule
 - liens arborescent de la hierarchie du site
 - Petites icons des touches Ctrl, shift, pour les raccourcis
 - un menu vers les autres vidéos
 - Mettre des images dans le menu
 - refaire les images avec density 300
 - liens vers le cours suivant
 - lien vers site Janco/ vidéo YT
 - petit encart de texte qui dit que ça consomme moins de donnée que vidéo Youtube
 - lien en cours de vidéo vers vidéo/article en rapport
 - centrer slides
 - Faire des liens vers les scripts Blender pour que quand on en modifie un, ça le modifie pour tous
 - diapo suivante, précédente
 - play/pause avec espace, gauche droite pour seek
 - blender create javascript file
 - preview n frame in the future/past
 - replace frames by VideoCapture::get(CV_CAP_PROP_POS_FRAMES)
 - blender ask for roi then launch auto-detect
 - ajout comparaison Yt/Pimoid avec graph et screenshots
 - Utiliser des slides vectorielles
 - Créer un bouton de téléchargement déroulant pour choisir quoi télécharger
 - focus la diapo et pas l'audio pour avoir des shortcuts unifié (problème résolue avec la barre audio custom)
 - Sur PC, si on sort le curseur de la zone de slide pendant un swipe, puis qu'on relache la souris, le swipe continue à être actif lorsqu'on revient sur la zone de slide
 - Click droit ne devrait pas lancer de swipe
 - Créer un mode plein-écran pour les téléphones
 - Créer un menu avec les miniatures des slides
