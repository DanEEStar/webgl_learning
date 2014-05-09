class HelloWorld
  constructor: () ->
    console.log('hello world')
    @createWebGLContext()
    @initShaders()

    @model = null
    @loadBuffers('scripts/cone.json')

    @pMatrix = mat4.create()
    @mvMatrix = mat4.create()

  initShaders: () ->
    fgShader = utils.getShader(@gl, 'shader-fs');
    vxShader = utils.getShader(@gl, 'shader-vs');

    @prg = @gl.createProgram();
    @gl.attachShader(@prg, vxShader);
    @gl.attachShader(@prg, fgShader);
    @gl.linkProgram(@prg);

    @gl.useProgram(@prg);

    @prg.vertexPositionAttribute = @gl.getAttribLocation(@prg, 'aVertexPosition');
    @prg.pMatrixUniform = @gl.getUniformLocation(@prg, 'uPMatrix');
    @prg.mvMatrixUniform = @gl.getUniformLocation(@prg, 'uMVMatrix');
    @prg.modelColor = @gl.getUniformLocation(@prg, 'modelColor');

  createWebGLContext: () ->
    @gl = utils.getGLContext('canvas')

  loadBuffers: (path) ->
    $.get(path, (model) =>
      console.log(model)
      @createBuffers(model))

  createBuffers: (model) ->
    @model = model
    @modelVertexBuffer = @gl.createBuffer()
    @gl.bindBuffer(@gl.ARRAY_BUFFER, @modelVertexBuffer)
    @gl.bufferData(@gl.ARRAY_BUFFER, new Float32Array(@model.vertices), @gl.STATIC_DRAW)
    @gl.bindBuffer(@gl.ARRAY_BUFFER, null)

    @modelIndexBuffer = @gl.createBuffer()
    @gl.bindBuffer(@gl.ELEMENT_ARRAY_BUFFER, @modelIndexBuffer)
    @gl.bufferData(@gl.ELEMENT_ARRAY_BUFFER, new Uint16Array(@model.indices), @gl.STATIC_DRAW)
    @gl.bindBuffer(@gl.ELEMENT_ARRAY_BUFFER, null)

    @gl.uniform3f(@prg.modelColor, @model.color[0], @model.color[1], @model.color[2]);

  drawScene: () ->
    @gl.clearColor(0.0, 0.0, 0.0, 1.0);
    @gl.enable(@gl.DEPTH_TEST);

    @gl.clear(@gl.COLOR_BUFFER_BIT | @gl.DEPTH_BUFFER_BIT);
    @gl.viewport(0,0,c_width, c_height);

    mat4.perspective(@pMatrix, 45, c_width / c_height, 0.1, 10000.0);
    mat4.identity(@mvMatrix);
    mat4.translate(@mvMatrix, @mvMatrix, [0.0, 0.0, -5.0]);

    @gl.uniformMatrix4fv(@prg.pMatrixUniform, false, @pMatrix);
    @gl.uniformMatrix4fv(@prg.mvMatrixUniform, false, @mvMatrix);

    @gl.enableVertexAttribArray(@prg.vertexPositionAttribute);

    if @model
      @gl.bindBuffer(@gl.ARRAY_BUFFER, @modelVertexBuffer);
      @gl.vertexAttribPointer(@prg.aVertexPosition, 3, @gl.FLOAT, false, 0, 0);
      @gl.enableVertexAttribArray(@prg.vertexPosition);

      @gl.bindBuffer(@gl.ELEMENT_ARRAY_BUFFER, @modelIndexBuffer);
      @gl.drawElements(@gl.LINE_STRIP, @model.indices.length, @gl.UNSIGNED_SHORT,0);

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
