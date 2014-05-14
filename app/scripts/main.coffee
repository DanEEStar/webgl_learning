class HelloWorld
  constructor: () ->
    console.log('hello world')
    @gl = @createWebGLContext()
    @prg = @initShaders(@gl)
    @numVertices = @initBuffers(@gl, @prg)

    @tx = 0.3
    @ty = 0.4
    @radianAngle = 0

    @modelView = mat4.create()

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

    prg.uMatrix = gl.getUniformLocation(prg, 'uMatrix')
    return prg

  initBuffers: (gl, prg) ->
    vertices = new Float32Array([
      -0.5, -0.5,
      -0.5, 0.5,
      0.0, 0.5
      0.0, -0.5
      0.5, 0.5
      0.5, -0.5
    ])

    vertexBuffer = gl.createBuffer()
    gl.bindBuffer(gl.ARRAY_BUFFER, vertexBuffer)
    gl.bufferData(gl.ARRAY_BUFFER, vertices, gl.STATIC_DRAW)

    gl.vertexAttribPointer(prg.a_Position, 2, gl.FLOAT, false, 0, 0)
    gl.enableVertexAttribArray(prg.a_Position)

    return 6

  createWebGLContext: () ->
    return utils.getGLContext('canvas')

  drawScene: () ->
    #@tx += 0.001
    #@ty += 0.002
    @radianAngle += 0.005

    mat4.identity(@modelView)
    mat4.translate(@modelView, @modelView, [@tx, @ty, 0])
    mat4.rotateZ(@modelView, @modelView, @radianAngle)
    mat4.scale(@modelView, @modelView, [0.4, 1.4, 1])

    @gl.uniformMatrix4fv(@prg.uMatrix, false, @modelView)

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
