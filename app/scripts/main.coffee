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
    @eyeX = 0.0

    @mMatrix = mat4.create()
    @pMatrix = mat4.create()
    @vMatrix = mat4.create()
    @mvpMatrix = mat4.create()
    mat4.perspective(@pMatrix, 3.14/3, 1, 1, 100)

    @lightDirection = vec3.create()
    vec3.normalize(@lightDirection, [0.5, 3.0, 4.0])

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

    prg.u_mvpMatrix = gl.getUniformLocation(prg, 'u_mvpMatrix')
    prg.u_LightColor = gl.getUniformLocation(prg, 'u_LightColor')
    prg.u_LightDirection = gl.getUniformLocation(prg, 'u_LightDirection')
    prg.u_LightColor = gl.getUniformLocation(prg, 'u_LightColor')

    prg.a_Position = gl.getAttribLocation(prg, 'a_Position')
    prg.a_Color = gl.getAttribLocation(prg, 'a_Color')
    prg.a_Normal = gl.getAttribLocation(prg, 'a_Normal')

    return prg

  initBuffers: (gl, prg) ->
    @vertices = new Float32Array([
      1.0, 1.0, 1.0,  -1.0, 1.0, 1.0,  -1.0,-1.0, 1.0,   1.0,-1.0, 1.0,
      1.0, 1.0, 1.0,   1.0,-1.0, 1.0,   1.0,-1.0,-1.0,   1.0, 1.0,-1.0,
      1.0, 1.0, 1.0,   1.0, 1.0,-1.0,  -1.0, 1.0,-1.0,  -1.0, 1.0, 1.0,
      -1.0, 1.0, 1.0,  -1.0, 1.0,-1.0,  -1.0,-1.0,-1.0,  -1.0,-1.0, 1.0,
      -1.0,-1.0,-1.0,   1.0,-1.0,-1.0,   1.0,-1.0, 1.0,  -1.0,-1.0, 1.0,
      1.0,-1.0,-1.0,  -1.0,-1.0,-1.0,  -1.0, 1.0,-1.0,   1.0, 1.0,-1.0
    ]);


    @colors = new Float32Array([
      1, 0, 0,   1, 0, 0,   1, 0, 0,  1, 0, 0,
      1, 0, 0,   1, 0, 0,   1, 0, 0,  1, 0, 0,
      1, 0, 0,   1, 0, 0,   1, 0, 0,  1, 0, 0,
      1, 0, 0,   1, 0, 0,   1, 0, 0,  1, 0, 0,
      1, 0, 0,   1, 0, 0,   1, 0, 0,  1, 0, 0,
      1, 0, 0,   1, 0, 0,   1, 0, 0,  1, 0, 0
    ]);


    @normals = new Float32Array([
      0.0, 0.0, 1.0,   0.0, 0.0, 1.0,   0.0, 0.0, 1.0,   0.0, 0.0, 1.0,
       1.0, 0.0, 0.0,   1.0, 0.0, 0.0,   1.0, 0.0, 0.0,   1.0, 0.0, 0.0,
       0.0, 1.0, 0.0,   0.0, 1.0, 0.0,   0.0, 1.0, 0.0,   0.0, 1.0, 0.0,
       -1.0, 0.0, 0.0,  -1.0, 0.0, 0.0,  -1.0, 0.0, 0.0,  -1.0, 0.0, 0.0,
       0.0,-1.0, 0.0,   0.0,-1.0, 0.0,   0.0,-1.0, 0.0,   0.0,-1.0, 0.0,
       0.0, 0.0,-1.0,   0.0, 0.0,-1.0,   0.0, 0.0,-1.0,   0.0, 0.0,-1.0
    ]);


    @indices = new Uint8Array([
      0, 1, 2,   0, 2, 3,
      4, 5, 6,   4, 6, 7,
      8, 9,10,   8,10,11,
      12,13,14,  12,14,15,
      16,17,18,  16,18,19,
      20,21,22,  20,22,23
    ]);

    @initArrayBuffer(gl, @vertices, prg.a_Position)
    @initArrayBuffer(gl, @colors, prg.a_Color)
    @initArrayBuffer(gl, @normals, prg.a_Normal)

    indexBuffer = gl.createBuffer()
    gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, indexBuffer)
    gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, @indices, gl.STATIC_DRAW)

    return @indices.length

  initArrayBuffer: (gl, data, attribute, num=3, type=gl.FLOAT) ->
    buffer = gl.createBuffer()
    gl.bindBuffer(gl.ARRAY_BUFFER, buffer)
    gl.bufferData(gl.ARRAY_BUFFER, data, gl.STATIC_DRAW)
    gl.vertexAttribPointer(attribute, num, type, false, 0, 0)
    gl.enableVertexAttribArray(attribute)

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
    @gl.enable(@gl.DEPTH_TEST)
    @gl.clearColor(0.0, 0.0, 0.0, 1.0)
    @gl.clear(@gl.COLOR_BUFFER_BIT | @gl.DEPTH_BUFFER_BIT)

    @gl.uniform3fv(@prg.u_LightDirection, @lightDirection)
    @gl.uniform3fv(@prg.u_LightColor, [1.0, 1.0, 1.0])

    @radianAngle += 0.005
    mat4.lookAt(@vMatrix, [@eyeX, 0, 5], [0, 0, 0], [0, 1, 0])

    @drawTriangleGroup(0, 0)
    #@drawTriangleGroup(-0.75)

  drawTriangleGroup: (x=0, y=0, z=0) ->
    mat4.identity(@mMatrix)
    mat4.translate(@mMatrix, @mMatrix, [x, y, z])
    mat4.rotate(@mMatrix, @mMatrix, @radianAngle, [1, 1, 0])

    mat4.identity(@mvpMatrix)
    mat4.multiply(@mvpMatrix, @mvpMatrix, @pMatrix)
    mat4.multiply(@mvpMatrix, @mvpMatrix, @vMatrix)
    mat4.multiply(@mvpMatrix, @mvpMatrix, @mMatrix)

    @gl.uniformMatrix4fv(@prg.u_mvpMatrix, false, @mvpMatrix)
    #@gl.drawArrays(@gl.TRIANGLES, 0, @numVertices)
    @gl.drawElements(@gl.TRIANGLES, @numVertices, @gl.UNSIGNED_BYTE, 0)

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

