class HelloWorld
  constructor: () ->
    console.log('hello world')
    @createWebGLContext()
    @initShaders()

    @points = []

    @canvas = document.getElementById('canvas')
    @canvas.onmousedown = (evt) =>
      @handleClick(evt)

  initShaders: () ->
    fgShader = utils.getShader(@gl, 'shader-fs');
    vxShader = utils.getShader(@gl, 'shader-vs');

    @prg = @gl.createProgram();
    @gl.attachShader(@prg, vxShader);
    @gl.attachShader(@prg, fgShader);
    @gl.linkProgram(@prg);
    @gl.useProgram(@prg);

    @prg.a_Position = @gl.getAttribLocation(@prg, 'a_Position')
    @prg.a_PointSize = @gl.getAttribLocation(@prg, 'a_PointSize')
    @prg.u_FragColor = @gl.getUniformLocation(@prg, 'u_FragColor')

  createWebGLContext: () ->
    @gl = utils.getGLContext('canvas')

  drawScene: () ->
    @gl.clearColor(0.0, 0.0, 0.0, 1.0)
    @gl.clear(@gl.COLOR_BUFFER_BIT)

    for point in @points
      @gl.vertexAttrib3f(@prg.a_Position, point[0], point[1], 0.0)
      @gl.vertexAttrib1f(@prg.a_PointSize, 10)
      @gl.uniform4fv(@prg.u_FragColor, point[2])
      @gl.drawArrays(@gl.POINTS, 0, 1)

  handleClick: (evt) ->
    x = evt.clientX;
    y = evt.clientY;
    rect = evt.target.getBoundingClientRect()

    x = ((x - rect.left) - @canvas.width/2) / (@canvas.width/2)
    y = (@canvas.height/2 - (y - rect.top)) / (@canvas.height/2)

    console.log(x, y)
    @points.push([x, y, [_.random(0.5, 1.0), _.random(0.5, 1.0), _.random(0.5, 1.0), 1.0]])


hl = new HelloWorld()
renderLoop = () ->
  utils.requestAnimFrame(renderLoop)
  hl.drawScene()

hl.drawScene()

renderLoop()
