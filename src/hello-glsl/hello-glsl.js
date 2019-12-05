;(function() {
  "use strict"
  window.addEventListener("load", setupWebGL, false)
  var gl, program

  function setupWebGL(evt) {
    window.removeEventListener(evt.type, setupWebGL, false)
    if (!(gl = getRenderingContext())) return

    // create vertext shader
    var source = document.querySelector("#vertex-shader").innerHTML
    var vertexShader = gl.createShader(gl.VERTEX_SHADER)
    gl.shaderSource(vertexShader, source)
    gl.compileShader(vertexShader)

    // create fragment shader
    source = document.querySelector("#fragment-shader").innerHTML
    var fragmentShader = gl.createShader(gl.FRAGMENT_SHADER)
    gl.shaderSource(fragmentShader, source)
    gl.compileShader(fragmentShader)

    // create webgl program
    program = gl.createProgram()
    // attach shader
    gl.attachShader(program, vertexShader)
    gl.attachShader(program, fragmentShader)
    // link program
    gl.linkProgram(program)
    // detach and delete shader
    gl.detachShader(program, vertexShader)
    gl.detachShader(program, fragmentShader)
    gl.deleteShader(vertexShader)
    gl.deleteShader(fragmentShader)
    if (!gl.getProgramParameter(program, gl.LINK_STATUS)) {
      var linkErrLog = gl.getProgramInfoLog(program)
      cleanup()
      document.querySelector("p").innerHTML =
        "Shader program did not link successfully. " +
        "Error log: " +
        linkErrLog
      return
    }

    initializeAttributes()

    gl.useProgram(program)
    gl.drawArrays(gl.POINTS, 0, 1)

    cleanup()
  }

  var buffer
  function initializeAttributes() {
    gl.enableVertexAttribArray(0)
    buffer = gl.createBuffer()
    gl.bindBuffer(gl.ARRAY_BUFFER, buffer)
    gl.vertexAttribPointer(0, 1, gl.FLOAT, false, 0, 0)
  }

  function cleanup() {
    gl.useProgram(null)
    if (buffer) gl.deleteBuffer(buffer)
    if (program) gl.deleteProgram(program)
  }

  function getRenderingContext() {
    var canvas = document.querySelector("canvas")
    canvas.width = canvas.clientWidth
    canvas.height = canvas.clientHeight
    var gl =
      canvas.getContext("webgl") || canvas.getContext("experimental-webgl")
    if (!gl) {
      var paragraph = document.querySelector("p")
      paragraph.innerHTML =
        "Failed to get WebGL context." +
        "Your browser or device may not support WebGL."
      return null
    }
    gl.viewport(0, 0, gl.drawingBufferWidth, gl.drawingBufferHeight)
    gl.clearColor(0.0, 0.0, 0.0, 1.0)
    gl.clear(gl.COLOR_BUFFER_BIT)
    return gl
  }
})()
