class HelloWorld
  constructor: () ->
    console.log('hello world')
    @createWebGLContext()
    window.onkeydown = _.bind(@checkKey, this)

  createWebGLContext: () ->
    canvas = document.getElementById("canvas")
    unless canvas
      console.log('there is no canvas on this page')
      return

    names = ['webgl', 'experimental-webgl', 'webkit-3d', 'moz-webgl']

    for name in names
      try
        gl = canvas.getContext(name)
      catch e
      if gl
        break

    unless gl
      console.log("WebGL is not available")
    else
      @gl = gl
      console.log("Hooray! You got a WebGL context")

  checkKey: (evt) ->
    switch evt.keyCode
      when 49 then @clear(1.0, 0, 0, 1.0)
      when 50 then @clear(0, 1.0, 0, 1.0)

  clear: (r, g, b, a) ->
    @gl.clearColor(r, g, b, a)
    @gl.clear(@gl.COLOR_BUFFER_BIT)
    @gl.viewport(0, 0, 800, 600)


hl = new HelloWorld()
