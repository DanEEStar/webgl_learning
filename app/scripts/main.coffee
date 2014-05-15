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
    @initTextures(@gl, @prg)

    @tx = 0.0
    @ty = 0.0
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
    prg.a_Position = gl.getAttribLocation(prg, 'a_Position')
    prg.a_TexCoord = gl.getAttribLocation(prg, 'a_TexCoord')

    prg.u_Sampler1 = gl.getUniformLocation(prg, 'u_Sampler1')
    prg.u_Sampler2 = gl.getUniformLocation(prg, 'u_Sampler2')
    return prg

  initBuffers: (gl, prg) ->
    vertices = new Float32Array([
      -0.5, 0.5, 0.0, 1.0,
      -0.5, -0.5, 0.0, 0.0,
      0.5, 0.5, 1.0, 1.0,
      0.5, -0.5, 1.0, 0.0
    ])

    vertexBuffer = gl.createBuffer()
    gl.bindBuffer(gl.ARRAY_BUFFER, vertexBuffer)
    gl.bufferData(gl.ARRAY_BUFFER, vertices, gl.STATIC_DRAW)

    gl.vertexAttribPointer(prg.a_Position, 2, gl.FLOAT, false, 4*4, 0)
    gl.enableVertexAttribArray(prg.a_Position)

    gl.vertexAttribPointer(prg.a_TexCoord, 2, gl.FLOAT, false, 4*4, 8)
    gl.enableVertexAttribArray(prg.a_TexCoord)

    return 4

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

    mat4.identity(@modelView)
    mat4.translate(@modelView, @modelView, [@tx, @ty, 0])
    mat4.rotateZ(@modelView, @modelView, @radianAngle)

    @gl.uniformMatrix4fv(@prg.uMatrix, false, @modelView)

    @gl.clearColor(0.0, 0.0, 0.0, 1.0)
    @gl.clear(@gl.COLOR_BUFFER_BIT)

    @gl.drawArrays(@gl.TRIANGLE_STRIP, 0, @numVertices)

  handleClick: (evt) ->
    _.noop()

loader = new AssetLoader()
loader.addImage('tex1', '/images/sky.jpg')
loader.addImage('tex2', '/images/circle.gif')
loader.start(() ->
  hl = new HelloWorld(loader)
  renderLoop = () ->
    utils.requestAnimFrame(renderLoop)
    hl.drawScene()
  renderLoop()
)

