var body = document.body;
var slide_div = document.getElementById('slide_div');
var img = document.getElementById('img');
var audio = document.getElementById('audio');
var play_button = document.getElementById('play_button');
var rewind_button = document.getElementById('rewind_button');
var fastforward_button = document.getElementById('fastforward_button');
var description_button = document.getElementById("collapsible");
var play_button_small = document.getElementById('play_button_small');
var pause_button_small = document.getElementById('pause_button_small');
var text1 = document.getElementById('tt1');
var text2 = document.getElementById('tt2');
var textI = document.getElementById('ttI');
var slider = document.getElementById('timeslider');
var audio_bar = document.getElementById('audio_bar');
var description_bar = document.getElementById('description_bar');
var annotationDiv = document.getElementById('annotation');
var slide_miniature_container = document.getElementById('slide_miniature_container');
var all_controls = [ play_button, rewind_button, fastforward_button ];
var opt_button = document.getElementById('options_button');
var opt_menu = document.getElementById('options_menu');
var fullscreen_button = document.getElementById('fullscreen_button');
var miniature_button = document.getElementById('miniature_button');

const little_jump = 5; // second
const big_jump = 30; // second

// Change playback rate constants
const PLAYBACK_RATE_INCREMENT = 0.2;
const PLAYBACK_RATE_MAX = 3;
const PLAYBACK_RATE_MIN = 0.6;

function debugText(text) {
	description_button.innerHTML += text + ' ';
}

function update_audio_bar_size() {
	if (audio_bar.offsetWidth <= 400) {
		text2.className = "no-disp";
		textI.className = "no-disp";
	} else {
		text2.className = "time-text-2";
		textI.className = "time-text-sep";
	}
}

body.onload = function() {
	var loc = window.location.toString();
	if (loc.includes('?')) {
		audio.currentTime = loc.split("?")[1];
	}
	update_audio_bar_size();
}

audio.ondurationchange = function() {
	text2.innerHTML = timePrint(audio.duration);
	var new_time = audio.currentTime / audio.duration;
	if (new_time < audio.duration) {
		slider.value = new_time;
	} else {
		slider.value = audio.duration;
	}
}

slider.oninput = function() {
	audio.currentTime = slider.value * audio.duration;
}
slider.onchange = function() {
	document.activeElement.blur();
}

document.onkeydown = function (e) {
	e = e || window.event;
	if (e.key == 32) { // Space bar
		toggle_play_audio();
	} else if (e.key == 'ArrowLeft'  || e.key == 'j' || e.key == 'h') { // Jump backward
		if (e.ctrlKey) {
			var slideIndex = getIndexFromTimestamp(slideTimestamp, audio.currentTime);
			audio.currentTime = slideTimestamp[Math.max(0, slideIndex - 1)];
		} else if (e.shiftKey) { audio.currentTime -= big_jump;
		} else { audio.currentTime -= little_jump; }
	} else if (e.key == ' '					 || e.key == 'k') { // K
		toggle_play_audio();
	} else if (e.key == 'ArrowRight' || e.key == 'l') { // Jump forward
		if (e.ctrlKey) {
			var slideIndex = getIndexFromTimestamp(slideTimestamp, audio.currentTime);
			audio.currentTime = slideTimestamp[Math.min(slideTimestamp.length - 1, slideIndex + 1)];
		} else if (e.shiftKey) { audio.currentTime += big_jump;
		} else { audio.currentTime += little_jump; }
	} else if (e.key == '<') {
		decreasePlaybackRate();
	} else if (e.key == '>') {
		increasePlaybackRate();
	};
}

function getIndexFromTimestamp(array, ts) {
	var i = array.findIndex(start_ts => start_ts > ts);
	if (i === -1) { // Every start_ts are inferior to ts
		return array.length - 1;
	}
	return array.findIndex(start_ts => start_ts > ts) - 1;
}

function getStem(path) {
	return path.substring(path.lastIndexOf('/') + 1, path.lastIndexOf('.'));
}

function timePrint(time) {
	var hours = Math.floor(time / 3600);
	var time2 = time % 3600;
	var min = Math.floor(time2 / 60);
	var sec = Math.floor(time2 % 60);

	return hours.toString() + ":" + min.toString().padStart(2, '0') + ':' + sec.toString().padStart(2, '0');
}

audio.addEventListener('timeupdate', function() {
	var ts = audio.currentTime;
	var slideIndex = getIndexFromTimestamp(slideTimestamp, ts);
	var slideName = slideNameFromIndex[slideIndex];

	// Update time text
	text1.innerHTML = timePrint(ts);
	// Update time bar
	slider.value = ts / audio.duration;

	// Displayed image is not what it should be
	// TODO: Display a loading icon or a black shade over the slide so the user
	// know the slide is not in sync
	if (getStem(img.children[img.children.length-1].src) != slideName) {
		for (let child of img.children) {
			// Source tag use 'srcset' and img tag use 'src'
			let propFromTag = {
				"SOURCE": "srcset",
				"IMG"   : "src"   ,
			};
			const childTag = child.tagName;
			const childProp = propFromTag[childTag];
			const src = child[childProp];
			const baseDir = src.substring(0, src.lastIndexOf('/') + 1)
			const extension = src.substring(src.lastIndexOf('.'))
			child[childProp] = baseDir + slideName + extension;
		}
	}
	var i = getIndexFromTimestamp(annotationTimestamps, ts);
	var text = annotationTexts[i];
	if (text != annotationDiv.innerHTML) {
		if (text === "") {
			annotationDiv.style.opacity = 0;
		} else {
			annotationDiv.style.opacity = 1;
			annotationDiv.innerHTML	= text;
		}
	}
});

let lastSlideDivClickTs = 0;

function handle_click_controls(e) {
	var rect = slide_div.getBoundingClientRect();
	var x_ratio = (e.clientX - rect.left) / rect.width; //x position within the element.
	var size_ratio = 0.20;
	if (x_ratio < size_ratio) {
		audio.currentTime -= little_jump;
		hide_controls([fastforward_button, play_button]);
		blink_controls([rewind_button]);
	} else if (x_ratio > 1.0 - size_ratio) {
		audio.currentTime += little_jump;
		hide_controls([rewind_button, play_button]);
		blink_controls([fastforward_button]);
	} else {
		const FULLSCREEN_MAX_DELAY_MS = 400;
		if (new Date().getTime() - lastSlideDivClickTs < FULLSCREEN_MAX_DELAY_MS) {
			toggleFullscreen();
		}
		toggle_play_audio();
		lastSlideDivClickTs = new Date().getTime();
	}
}

/*
 * Fullscreen
 */

fullscreen_button.addEventListener('click', function(e) {
	if (!fullscreen_button.classList.contains("disabled-button")) {
		toggleFullscreen();
	}
} );

let isFullscreen = false;
function toggleFullscreen() {
	if (isFullscreen) {
		if (document.exitFullscreen) {
			document.exitFullscreen();
		}
		exitFullscreenUI();
	} else {
		if (slide_div.requestFullscreen) { // Not an iPhone
			slide_div.requestFullscreen();
		}
		enterFullscreenUI();
	}
}
function enterFullscreenUI() {
	audio_bar.classList.add('no-disp');
	description_bar.classList.add('no-disp');
	isFullscreen = true;
}
function exitFullscreenUI() {
	audio_bar.classList.remove('no-disp');
	description_bar.classList.remove('no-disp');
	isFullscreen = false;
}
// If the user enter/exit its browser fullscreen mode, show/hide the UI
slide_div.addEventListener('fullscreenchange', (event) => {
	if (document.fullscreenElement) {
		enterFullscreenUI();
	} else {
		exitFullscreenUI();
	}
}, false);

/*
 * Player
 */

function toggle_play_audio() {
	if (audio.paused) {
		audio.play();
		play_button_small.className = "no-disp";
		pause_button_small.className = "";
	} else {
		audio.pause();
		pause_button_small.className = "no-disp";
		play_button_small.className = "";
	}
}

document.getElementById("toggle_button").onclick = toggle_play_audio;

function decreasePlaybackRate() {
	audio.playbackRate -= PLAYBACK_RATE_INCREMENT
	audio.playbackRate = Math.max(audio.playbackRate, PLAYBACK_RATE_MIN)
}
function increasePlaybackRate() {
	audio.playbackRate += PLAYBACK_RATE_INCREMENT
	audio.playbackRate = Math.min(audio.playbackRate, PLAYBACK_RATE_MAX)
}

function blink_controls(controls) {
	for (let c of controls) {
		c.className = 'show';
		setTimeout(function(control) {
			control.className = 'quick_fade';
		}, 150, c)
	}
}

function hide_controls(controls) {
	for (let c of controls) {
		c.className = 'disapear';
	}
}

function show_controls_and_fade(controls) {
	for (let c of controls) {
		c.className = 'show';
		setTimeout(function(control) {
			control.className = 'slow_fade';
		}, 1000, c)
	}
}

audio.addEventListener('pause', function() {
	show_controls_and_fade(all_controls);
});

audio.addEventListener('play', function() {
	hide_controls([rewind_button, fastforward_button]);
	blink_controls([play_button]);
});

// To be compatible with mobile browser
function unify(e) { return e.changedTouches ? e.changedTouches[0] : e };

let touchStartX = null, touchStartY = null, touchStartMs = null;
let touchStartAudioTime = null;

function onPointerClickStart(e) {
	// So mobile browsers don't fire mousedown/mouseup after touchstart/touchend
	e.preventDefault();
	if ("button" in e && e.button !== 0) {
		return; // Ignore any click other than left click
	}
	touchStartX = unify(e).clientX;
	touchStartY = unify(e).clientY;
	touchStartMs = new Date().getTime();
	touchStartAudioTime = audio.currentTime;
};

function onPointerMove(e) {
	if (touchStartX === null)
		return;
	let dx = unify(e).clientX - touchStartX;
	let dy = unify(e).clientY - touchStartY;
	if (Math.abs(dx) > Math.abs(dy)) { // Horizontal swipe
		audio.currentTime = touchStartAudioTime + dx;
	} else { // Vertical swipe
		/*if (Math.abs(dy) > 10) {
			if (dy > 0)
				close_description();
			else
				open_description();
		}*/
	}
};

function onPointerClickEnd(e) {
	const elapsedTimeMs = new Date().getTime() - touchStartMs;
	let dx = unify(e).clientX - touchStartX;
	if (elapsedTimeMs < 200 && Math.abs(dx) < 10)
		handle_click_controls(unify(e));

	touchStartX = null, touchStartY = null;
}


slide_div.addEventListener('mousedown', onPointerClickStart, false);
slide_div.addEventListener('mousemove', onPointerMove, false);
slide_div.addEventListener('mouseup'  , onPointerClickEnd, false);
slide_div.addEventListener('pointerleave'  , onPointerClickEnd, false);

slide_div.addEventListener('touchstart', onPointerClickStart, false);
slide_div.addEventListener('touchmove' , onPointerMove, false);
slide_div.addEventListener('touchend'  , onPointerClickEnd, false);

/*
 * Miniature
 */

let miniature_has_paused = false;

function showPlayerHideMiniatures() {
	slide_div.classList.remove('no-disp');
	slide_miniature_container.classList.add('no-disp');
	opt_button.classList.remove('disabled-button');
	fullscreen_button.classList.remove('disabled-button');
	if (miniature_has_paused) {
		if (audio.paused) {
			toggle_play_audio();
		}
		miniature_has_paused = false;
	}
}

function hidePlayerShowMiniatures() {
	slide_div.classList.add('no-disp');

	// Show Miniatures and center to current miniature
	slide_miniature_container.classList.remove('no-disp');
	const currentSlideIndex = getIndexFromTimestamp(slideTimestamp, audio.currentTime);
	const currentMiniature = document.getElementById("miniature-" + currentSlideIndex);
	currentMiniature.scrollIntoView({block: "center"});
	for (let miniatureLink of Array.from(slide_miniature_container.children)) {
		children = miniatureLink.children[0];
		if (children) {
			children.classList.remove('current_miniature');
		}
	}
	currentMiniature.classList.add('current_miniature');

	opt_button.classList.add('disabled-button');
	fullscreen_button.classList.add('disabled-button');
	if (!audio.paused) {
		toggle_play_audio();
		miniature_has_paused = true;
	}
}

miniature_button.addEventListener('click', function(e) {
	if (slide_div.classList.contains('no-disp')) {
		showPlayerHideMiniatures();
	} else {
		hidePlayerShowMiniatures();
	}
} );

function populateMiniatureContainer() {
	var paddingElement = document.createElement("div");
	paddingElement.classList.add("padding_slide_miniature");
	slide_miniature_container.appendChild(paddingElement);

	slideTimestamp.forEach(function(ts, index) {
		slideStem = slideNameFromIndex[index];
		slide_miniature_container.appendChild(createMiniature(ts, index, slideStem));
	});

	// Adding dummy elements for last line
	for (var i = 0; i < 50; i++) {
		var dummyElement = document.createElement("div");
		dummyElement.classList.add("dummy_slide_miniature");
		slide_miniature_container.appendChild(dummyElement);
	}
	var lastDummyElement = document.createElement("div");
	lastDummyElement.classList.add("last_dummy_slide_miniature");
	slide_miniature_container.appendChild(lastDummyElement);
}
populateMiniatureContainer();


/* Generate an html element for a miniature
 * <a class="slide_miniature_link">
 *	 <div class="slide_miniature" style="background-image: url('slides/slide-0.svg')">
 *	 </div>
 * </a>
 */
function createMiniature(ts, index, slideStem) {
	var div = document.createElement("div");
	div.id = "miniature-" + index;
	div.classList.add("slide_miniature");
	if (is_archive) {
		div.style = "background-image: url('slides/" + slideStem + ".svg')";
	} else {
		div.style = "background-image: url('slides/" + slideStem + ".jpg')";
	}

	var link = document.createElement("a");
	link.classList.add("slide_miniature_link");
	link.onclick = function() {
		audio.currentTime = ts;
		showPlayerHideMiniatures();
	}
	link.appendChild(div);

	return link;
}

/*
 * Annotation
 */

function getTransitionEndEventName() {
  var transitions = {
      "transition"      : "transitionend",
      "OTransition"     : "oTransitionEnd",
      "MozTransition"   : "transitionend",
      "WebkitTransition": "webkitTransitionEnd"
  }
  let bodyStyle = body.style;
  for (let transition in transitions) {
      if (bodyStyle[transition] != undefined) {
          return transitions[transition];
      }
  }
}

// remove annotation text when opacity reach 0
annotationDiv.addEventListener(getTransitionEndEventName(), (event) => {
	if (annotationDiv.style.opacity == 0) {
		//annotationDiv.style.display = "none";
		annotationDiv.innerHTML	= "";
	}
});

/*
 * Description
 */

description_button.addEventListener("click", function() {
	this.classList.toggle("active");
	var content = this.parentNode.nextElementSibling;
	if (content.style.maxHeight) {
		content.style.maxHeight = null;
	} else {
		content.style.maxHeight = content.scrollHeight + "px";
	}
}, false);

window.onresize = function() {
	var content = description_button.parentNode.nextElementSibling;
	if (content.style.maxHeight) {
		content.style.maxHeight = content.scrollHeight + "px";
	}
	update_audio_bar_size();
}

function getUrlWithoutQuery() {
	return window.location.href.split('?')[0]
}

opt_button.addEventListener('click', function(e) {
	if (opt_menu.className == "options-menu") {
		opt_menu.className = "options-menu no-disp";
	} else {
		opt_menu.className = "options-menu";
	}
	e.stopPropagation();
}, false);
document.addEventListener('click', function() {
	opt_menu.className = "options-menu no-disp";
}, false);

document.getElementById("dl-slides").addEventListener('click', function(e) {
	window.open('diapos.pdf');
	opt_menu.className = "options-menu no-disp";
	e.stopPropagation();
}, false);
document.getElementById("dl-audio").addEventListener('click', function(e) {
	window.open('audio/audio.opus');
	opt_menu.className = "options-menu no-disp";
	e.stopPropagation();
}, false);
document.getElementById("dl-archive").addEventListener('click', function(e) {
	window.open('archive.zip');
	opt_menu.className = "options-menu no-disp";
	e.stopPropagation();
}, false);
document.getElementById("get_ts_link_button").addEventListener('click', function(e) {
	navigator.clipboard.writeText(getUrlWithoutQuery() + "?" + Math.round(audio.currentTime));
	opt_menu.className = "options-menu no-disp";
	e.stopPropagation();
}, false);

// A click on the menu shouldn't trigger any action on the slide_div controls underneath
opt_menu.addEventListener('mouseup', function(e) { e.stopPropagation(); }, false);
opt_menu.addEventListener('mousedown', function(e) { e.stopPropagation(); }, false);
opt_menu.addEventListener('touchstart', function(e) { e.stopPropagation(); }, false);
opt_menu.addEventListener('touchend', function(e) { e.stopPropagation(); }, false);
