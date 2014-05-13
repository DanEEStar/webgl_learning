class HelloWorld
  constructor: () ->
    console.log('hello world')
    @gl = @createWebGLContext()
    @prg = @initShaders(@gl)
    @numVertices = @initBuffers(@gl, @prg)

    @canvas = document.getElementById('canvas')
    @canvas.onmousedown = (evt) =>
      @handleClick(evt)

  initShaders: (gl) ->
    fgShader = utils.getShader(gl, 'shader-fs');
    vxShader = utils.getShader(gl, 'shader-vs');

    prg = gl.createProgram();
    gl.attachShader(prg, vxShader);
    gl.attachShader(prg, fgShader);
    gl.linkProgram(prg);
    gl.useProgram(prg);

    prg.a_Position = gl.getAttribLocation(prg, 'a_Position')
    return prg

  initBuffers: (gl, prg) ->
    vertices = new Float32Array([
      0.0, 0.5, -0.5, -0.5, 0.5, -0.5
    ])

    vertexBuffer = gl.createBuffer()
    gl.bindBuffer(gl.ARRAY_BUFFER, vertexBuffer)
    gl.bufferData(gl.ARRAY_BUFFER, vertices, gl.STATIC_DRAW)

    gl.vertexAttribPointer(prg.a_Position, 2, gl.FLOAT, false, 0, 0)
    gl.enableVertexAttribArray(prg.a_Position)

    return 3

  createWebGLContext: () ->
    return utils.getGLContext('canvas')

  drawScene: () ->
    @gl.clearColor(0.0, 0.0, 0.0, 1.0)
    @gl.clear(@gl.COLOR_BUFFER_BIT)

    @gl.drawArrays(@gl.TRIANGLES, 0, @numVertices)

  handleClick: (evt) ->
    _.noop()


hl = new HelloWorld()
renderLoop = () ->
  utils.requestAnimFrame(renderLoop)
  hl.drawScene()

hl.drawScene()

renderLoop()
