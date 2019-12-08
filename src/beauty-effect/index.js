'use strict';

var videoElement = document.querySelector('#video');

getUserMedia();


function getUserMedia() {
  const constraints = {
    video: true,
	  audio: true
  };
  return navigator.mediaDevices.getUserMedia(constraints).
    then(gotStream).catch(handleError);
}

function gotStream(stream) {
  window.stream = videoElement.srcObject = stream;
  glUtil.renderWithWebGL(canvas, video, stream, true);
}

function handleError(error) {
	debugger;
  console.error('Error: ', error);
}