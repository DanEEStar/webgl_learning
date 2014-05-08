class HelloWorld
  constructor: () ->
    console.log('hello world')
    @createWebGLContext()
    @initShaders()
    @createBuffers()

  initShaders: () ->
    fgShader = utils.getShader(@gl, "shader-fs");
    vxShader = utils.getShader(@gl, "shader-vs");

    @prg = @gl.createProgram();
    @gl.attachShader(@prg, vxShader);
    @gl.attachShader(@prg, fgShader);
    @gl.linkProgram(@prg);

    if !@gl.getProgramParameter(@prg, @gl.LINK_STATUS)
      console.log("Could not initialise shaders");

    @gl.useProgram(@prg);

    # The following lines allow us obtaining a reference to the uniforms and attributes defined in the shaders.
    # This is a necessary step as the shaders are NOT written in JavaScript but in a
    # specialized language called GLSL. More about this on chapter 3.
    @prg.vertexPosition = @gl.getAttribLocation(@prg, "aVertexPosition");

  createWebGLContext: () ->
    @gl = utils.getGLContext('canvas')

  createBuffers: () ->
    @vertices =  [
      -0.5,0.5,0.0,
      -0.5,-0.5,0.0,
      0.5,-0.5,0.0,
      0.5,0.5,0.0
    ]
    @indices = [3,2,1,3,1,0]

    @coneVBO = @gl.createBuffer()
    @gl.bindBuffer(@gl.ARRAY_BUFFER, @coneVBO)
    @gl.bufferData(@gl.ARRAY_BUFFER, new Float32Array(@vertices), @gl.STATIC_DRAW)
    @gl.bindBuffer(@gl.ARRAY_BUFFER, null)

    @coneIBO = @gl.createBuffer()
    @gl.bindBuffer(@gl.ELEMENT_ARRAY_BUFFER, @coneIBO)
    @gl.bufferData(@gl.ELEMENT_ARRAY_BUFFER, new Uint16Array(@indices), @gl.STATIC_DRAW)
    @gl.bindBuffer(@gl.ELEMENT_ARRAY_BUFFER, null)

  drawScene: () ->
    @gl.clearColor(0, 0, 0, 1)
    @gl.enable(@gl.DEPTH_TEST)

    @gl.clear(@gl.COLOR_BUFFER_BIT | @gl.DEPTH_BUFFER_BIT);
    @gl.viewport(0,0,c_width, c_height);

    @gl.bindBuffer(@gl.ARRAY_BUFFER, @coneVBO);
    @gl.vertexAttribPointer(@prg.aVertexPosition, 3, @gl.FLOAT, false, 0, 0);
    @gl.enableVertexAttribArray(@prg.vertexPosition);

    @gl.bindBuffer(@gl.ELEMENT_ARRAY_BUFFER, @coneIBO);
    @gl.drawElements(@gl.TRIANGLES, @indices.length, @gl.UNSIGNED_SHORT,0);

  checkKey: (evt) ->
    switch evt.keyCode
      when 49 then @clear(1.0, 0, 0, 1.0)
      when 50 then @clear(0, 1.0, 0, 1.0)

  clear: (r, g, b, a) ->
    @gl.clearColor(r, g, b, a)
    @gl.clear(@gl.COLOR_BUFFER_BIT)
    @gl.viewport(0, 0, 800, 600)


hl = new HelloWorld()
renderLoop = () ->
  utils.requestAnimFrame(renderLoop)
  hl.drawScene()

renderLoop()
