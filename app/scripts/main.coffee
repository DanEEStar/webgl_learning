class AssetLoader
  constructor: () ->
    @cache = {}
    @filesToLoad = []

  addImage: (key, src) ->
    @filesToLoad.push({
      key: key,
      src: src
    })

  getImage: (key) ->
    @cache[key]

  loadImage: (imageInfo, callback) ->
    image = new Image()
    image.onload = () ->
      callback(imageInfo.key, image)
    image.src = imageInfo.src

  start: (callback) ->
    numImagesToLoad = @filesToLoad.length
    numImagesLoaded = 0

    imageLoadComplete = (key, image) =>
      console.log("image loaded #{key}")
      @cache[key] = image
      numImagesLoaded += 1
      if numImagesLoaded >= numImagesToLoad
        @filesToLoad = []
        callback()
      else
        imageInfo = @filesToLoad[numImagesLoaded]
        @loadImage(imageInfo, imageLoadComplete)

    imageInfo = @filesToLoad[numImagesLoaded]
    @loadImage(imageInfo, imageLoadComplete)


class HelloWorld
  constructor: (@loader) ->
    console.log('hello world')
    @gl = @createWebGLContext()
    @prg = @initShaders(@gl)
    @numVertices = @initBuffers(@gl, @prg)
    #@initTextures(@gl, @prg)

    @tx = 0.0
    @ty = 0.0
    @radianAngle = 0
    @eyeX = 0.2

    @mvMatrix = mat4.create()

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

    prg.u_mvMatrix = gl.getUniformLocation(prg, 'u_mvMatrix')
    prg.a_Position = gl.getAttribLocation(prg, 'a_Position')
    prg.a_Color = gl.getAttribLocation(prg, 'a_Color')

    return prg

  initBuffers: (gl, prg) ->
    vertices = new Float32Array([
      0.0,  0.5,  -0.4,  0.4,  1.0,  0.4,
      -0.5, -0.5,  -0.4,  0.4,  1.0,  0.4,
      0.5, -0.5,  -0.4,  1.0,  0.4,  0.4,

      0.5,  0.4,  -0.2,  1.0,  0.4,  0.4,
      -0.5,  0.4,  -0.2,  1.0,  1.0,  0.4,
      0.0, -0.6,  -0.2,  1.0,  1.0,  0.4,

      0.0,  0.5,   0.0,  0.4,  0.4,  1.0,
      -0.5, -0.5,   0.0,  0.4,  0.4,  1.0,
      0.5, -0.5,   0.0,  1.0,  0.4,  0.4,
    ])

    vertexBuffer = gl.createBuffer()
    gl.bindBuffer(gl.ARRAY_BUFFER, vertexBuffer)
    gl.bufferData(gl.ARRAY_BUFFER, vertices, gl.STATIC_DRAW)

    gl.vertexAttribPointer(prg.a_Position, 3, gl.FLOAT, false, 4*6, 0)
    gl.enableVertexAttribArray(prg.a_Position)

    gl.vertexAttribPointer(prg.a_Color, 3, gl.FLOAT, false, 4*6, 4*3)
    gl.enableVertexAttribArray(prg.a_Color)

    return 9

  initTextures: (gl, prg) ->
    texture = gl.createTexture()
    gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, 1)
    gl.activeTexture(gl.TEXTURE0)
    gl.bindTexture(gl.TEXTURE_2D, texture)
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR)
    gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGB, gl.RGB, gl.UNSIGNED_BYTE, @loader.getImage('tex2'));
    gl.uniform1i(prg.u_Sampler1, 0)

    texture1 = gl.createTexture()
    gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, 1)
    gl.activeTexture(gl.TEXTURE1)
    gl.bindTexture(gl.TEXTURE_2D, texture1)
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR)
    gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGB, gl.RGB, gl.UNSIGNED_BYTE, @loader.getImage('tex1'));
    gl.uniform1i(prg.u_Sampler2, 1)

  createWebGLContext: () ->
    return utils.getGLContext('canvas')

  drawScene: () ->
    #@tx += 0.001
    #@ty += 0.002
    @radianAngle += 0.005

    mat4.identity(@mvMatrix)
    mat4.lookAt(@mvMatrix, [@eyeX, 0.25, 0.25], [0, 0, 0], [0, 1, 0])
    mat4.translate(@mvMatrix, @mvMatrix, [@tx, @ty, 0])
    mat4.rotateZ(@mvMatrix, @mvMatrix, @radianAngle)

    @gl.uniformMatrix4fv(@prg.u_mvMatrix, false, @mvMatrix)

    @gl.clearColor(0.0, 0.0, 0.0, 1.0)
    @gl.clear(@gl.COLOR_BUFFER_BIT)

    @gl.drawArrays(@gl.TRIANGLES, 0, 9)

  handleClick: (evt) ->
    _.noop()

  handleKeyDown: (evt) =>
    if evt.keyCode == 39
      @eyeX += 0.05
    else if evt.keyCode == 37
      @eyeX -= 0.05


loader = new AssetLoader()
loader.addImage('tex1', '/images/sky.jpg')
loader.addImage('tex2', '/images/circle.gif')
loader.start(() ->
  hl = new HelloWorld(loader)

  $(document).on('keydown', hl.handleKeyDown)

  renderLoop = () ->
    utils.requestAnimFrame(renderLoop)
    hl.drawScene()
  renderLoop()
)

