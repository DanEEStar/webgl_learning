class HelloWorld
  constructor: () ->
    console.log('hello world')
    @createWebGLContext()
    @initShaders()
    @initLights()

    @model = null
    @loadBuffers('scripts/cone.json')

    @pMatrix = mat4.create()
    @mvMatrix = mat4.create()
    @nMatrix = mat4.create()

  initShaders: () ->
    fgShader = utils.getShader(@gl, 'shader-fs');
    vxShader = utils.getShader(@gl, 'shader-vs');

    @prg = @gl.createProgram();
    @gl.attachShader(@prg, vxShader);
    @gl.attachShader(@prg, fgShader);
    @gl.linkProgram(@prg);

    @gl.useProgram(@prg);

    @prg.uPMatrix = @gl.getUniformLocation(@prg, 'uPMatrix')
    @prg.uMVMatrix = @gl.getUniformLocation(@prg, 'uMVMatrix')
    @prg.uNMatrix = @gl.getUniformLocation(@prg, 'uNMatrix')

    @prg.aVertexPosition  = @gl.getAttribLocation(@prg, "aVertexPosition")
    @prg.aVertexNormal  = @gl.getAttribLocation(@prg, "aVertexNormal")

    @prg.uMaterialDiffuse  = @gl.getUniformLocation(@prg, "uMaterialDiffuse");
    @prg.uLightDiffuse     = @gl.getUniformLocation(@prg, "uLightDiffuse");
    @prg.uLightDirection   = @gl.getUniformLocation(@prg, "uLightDirection");

  initLights: () ->
    @gl.uniform3fv(@prg.uLightDirection,    [0.0, -1.0, -1.0]);
    @gl.uniform4fv(@prg.uLightDiffuse,      [1.0,1.0,1.0,1.0]);
    @gl.uniform4fv(@prg.uMaterialDiffuse,   [0.5,0.8,0.1,1.0]);

  createWebGLContext: () ->
    @gl = utils.getGLContext('canvas')

  loadBuffers: (path) ->
    $.get(path, (model) =>
      console.log(model)
      @createBuffers(model))

  createBuffers: (model) ->
    @model = model
    @model.normals = utils.calculateNormals(@model.vertices, @model.indices)

    @modelVertexBuffer = @gl.createBuffer()
    @gl.bindBuffer(@gl.ARRAY_BUFFER, @modelVertexBuffer)
    @gl.bufferData(@gl.ARRAY_BUFFER, new Float32Array(@model.vertices), @gl.STATIC_DRAW)

    @modelNormalBuffer = @gl.createBuffer()
    @gl.bindBuffer(@gl.ARRAY_BUFFER, @modelNormalBuffer)
    @gl.bufferData(@gl.ARRAY_BUFFER, new Float32Array(@model.normals), @gl.STATIC_DRAW)
    @gl.bindBuffer(@gl.ARRAY_BUFFER, null)

    @modelIndexBuffer = @gl.createBuffer()
    @gl.bindBuffer(@gl.ELEMENT_ARRAY_BUFFER, @modelIndexBuffer)
    @gl.bufferData(@gl.ELEMENT_ARRAY_BUFFER, new Uint16Array(@model.indices), @gl.STATIC_DRAW)
    @gl.bindBuffer(@gl.ELEMENT_ARRAY_BUFFER, null)

  drawScene: () ->
    @gl.clearColor(0.0, 0.0, 0.0, 1.0);
    @gl.clearDepth(100.0)
    @gl.depthFunc(@gl.LEQUAL)
    @gl.enable(@gl.DEPTH_TEST)
    @gl.clear(@gl.COLOR_BUFFER_BIT | @gl.DEPTH_BUFFER_BIT)
    @gl.viewport(0,0,c_width, c_height)

    mat4.perspective(@pMatrix, 45, c_width / c_height, 0.1, 10000.0)
    mat4.identity(@mvMatrix)
    mat4.translate(@mvMatrix, @mvMatrix, [0.0, 0.0, -5.0])
    @gl.uniformMatrix4fv(@prg.uPMatrix, false, @pMatrix)
    @gl.uniformMatrix4fv(@prg.uMVMatrix, false, @mvMatrix)

    mat4.copy(@nMatrix, @mvMatrix)
    mat4.invert(@nMatrix, @nMatrix)
    mat4.transpose(@nMatrix, @nMatrix)
    @gl.uniformMatrix4fv(@prg.uNMatrix, false, @nMatrix)

    @gl.enableVertexAttribArray(@prg.aVertexPosition)
    @gl.enableVertexAttribArray(@prg.aVertexNormal)

    if @model
      @gl.bindBuffer(@gl.ARRAY_BUFFER, @modelVertexBuffer);
      @gl.vertexAttribPointer(@prg.aVertexPosition, 3, @gl.FLOAT, false, 0, 0);

      @gl.bindBuffer(@gl.ARRAY_BUFFER, @modelNormalBuffer);
      @gl.vertexAttribPointer(@prg.aVertexNormal, 3, @gl.FLOAT, false, 0, 0);

      @gl.bindBuffer(@gl.ELEMENT_ARRAY_BUFFER, @modelIndexBuffer);
      @gl.drawElements(@gl.TRIANGLES, @model.indices.length, @gl.UNSIGNED_SHORT,0);

  checkKey: (evt) ->
    switch evt.keyCode
      when 49 then @clear(1.0, 0, 0, 1.0)
      when 50 then @clear(0, 1.0, 0, 1.0)


hl = new HelloWorld()
renderLoop = () ->
  utils.requestAnimFrame(renderLoop)
  hl.drawScene()

hl.drawScene()

renderLoop()
