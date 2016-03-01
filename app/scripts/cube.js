(function() {
    "use strict";

    var canvas = document.getElementById('canvas');
    var width = canvas.width;
    var height = canvas.height;

    var cubeColor = {
        r: 0.0,
        g: 0.0,
        b: 1.0
    };

    var gl = initWebGL(document.getElementById('canvas'));
    var prg = initShaders(gl);
    var numVertices = initBuffers(gl, prg);

    var mMatrix = mat4.create();
    var pMatrix = mat4.create();
    var vMatrix = mat4.create();
    var mvpMatrix = mat4.create();
    var normalMatrix = mat4.create();
    mat4.perspective(pMatrix, 3.14159/3, width/height, 1, 100);

    var lightDirection = vec3.create();
    vec3.normalize(lightDirection, [0.5, 3.0, 4.0]);

    var radianAngle = 0;

    renderLoop();


    function renderLoop() {
        window.requestAnimationFrame(renderLoop);
        update();
        drawScene();
    }

    function update() {
        radianAngle += 0.005;
    }

    function drawScene() {
        gl.enable(gl.DEPTH_TEST);
        gl.clearColor(0.0, 0.0, 0.0, 1.0);
        gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);

        gl.uniform3fv(prg.u_LightDirection, lightDirection);
        gl.uniform3fv(prg.u_LightColor, [1.0, 1.0, 1.0]);
        gl.uniform3fv(prg.u_AmbientLight, [0.2, 0.2, 0.2]);
        gl.uniform4fv(prg.u_Color, [cubeColor.r, cubeColor.g, cubeColor.b, 1.0]);

        mat4.lookAt(vMatrix, [0, 0, 5], [0, 0, 0], [0, 1, 0]);

        drawTriangleGroup(0, 0, 0);
    }

    function drawTriangleGroup(x, y, z) {
        mat4.identity(mMatrix);
        mat4.translate(mMatrix, mMatrix, [x, y, z]);
        mat4.rotate(mMatrix, mMatrix, radianAngle, [1, 1, 0]);

        mat4.identity(normalMatrix);
        mat4.invert(normalMatrix, mMatrix);
        mat4.transpose(normalMatrix, normalMatrix);
        gl.uniformMatrix4fv(prg.u_normalMatrix, false, normalMatrix);

        mat4.identity(mvpMatrix);
        mat4.multiply(mvpMatrix, mvpMatrix, pMatrix);
        mat4.multiply(mvpMatrix, mvpMatrix, vMatrix);
        mat4.multiply(mvpMatrix, mvpMatrix, mMatrix);

        gl.uniformMatrix4fv(prg.u_mvpMatrix, false, mvpMatrix);
        gl.drawArrays(gl.TRIANGLES, 0, numVertices);
        gl.drawElements(gl.TRIANGLES, numVertices, gl.UNSIGNED_BYTE, 0);
    }

    function initBuffers(gl, prg) {
        // buffers for a cube
        var vertices = new Float32Array([
            1.0, 1.0, 1.0, -1.0, 1.0, 1.0, -1.0, -1.0, 1.0, 1.0, -1.0, 1.0,
            1.0, 1.0, 1.0, 1.0, -1.0, 1.0, 1.0, -1.0, -1.0, 1.0, 1.0, -1.0,
            1.0, 1.0, 1.0, 1.0, 1.0, -1.0, -1.0, 1.0, -1.0, -1.0, 1.0, 1.0,
            -1.0, 1.0, 1.0, -1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, 1.0,
            -1.0, -1.0, -1.0, 1.0, -1.0, -1.0, 1.0, -1.0, 1.0, -1.0, -1.0, 1.0,
            1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, 1.0, -1.0, 1.0, 1.0, -1.0
        ]);

        var normals = new Float32Array([
            0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0,
            1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0,
            0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0,
            -1.0, 0.0, 0.0, -1.0, 0.0, 0.0, -1.0, 0.0, 0.0, -1.0, 0.0, 0.0,
            0.0, -1.0, 0.0, 0.0, -1.0, 0.0, 0.0, -1.0, 0.0, 0.0, -1.0, 0.0,
            0.0, 0.0, -1.0, 0.0, 0.0, -1.0, 0.0, 0.0, -1.0, 0.0, 0.0, -1.0
        ]);

        var indices = new Uint8Array([
            0, 1, 2, 0, 2, 3,
            4, 5, 6, 4, 6, 7,
            8, 9, 10, 8, 10, 11,
            12, 13, 14, 12, 14, 15,
            16, 17, 18, 16, 18, 19,
            20, 21, 22, 20, 22, 23
        ]);

        initArrayBuffer(gl, vertices, prg.a_Position, 3, gl.FLOAT);
        initArrayBuffer(gl, normals, prg.a_Normal, 3, gl.FLOAT);

        var indexBuffer = gl.createBuffer();
        gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, indexBuffer);
        gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, indices, gl.STATIC_DRAW);

        return indices.length;
    }

    function initArrayBuffer(gl, data, attribute, num, type) {
        var buffer = gl.createBuffer();
        gl.bindBuffer(gl.ARRAY_BUFFER, buffer);
        gl.bufferData(gl.ARRAY_BUFFER, data, gl.STATIC_DRAW);
        gl.vertexAttribPointer(attribute, num, type, false, 0, 0);
        gl.enableVertexAttribArray(attribute);
    }

    function initShaders(gl) {
        var fgShader = getShader(gl, 'shader-fs');
        var vxShader = getShader(gl, 'shader-vs');

        var prg = gl.createProgram();
        gl.attachShader(prg, vxShader);
        gl.attachShader(prg, fgShader);
        gl.linkProgram(prg);
        gl.useProgram(prg);

        // load all the shader variables from the shaders, look at the shader source code in the html file
        prg.u_mvpMatrix = gl.getUniformLocation(prg, 'u_mvpMatrix');
        prg.u_normalMatrix = gl.getUniformLocation(prg, 'u_normalMatrix');
        prg.u_LightColor = gl.getUniformLocation(prg, 'u_LightColor');
        prg.u_LightDirection = gl.getUniformLocation(prg, 'u_LightDirection');
        prg.u_LightColor = gl.getUniformLocation(prg, 'u_LightColor');
        prg.u_AmbientLight = gl.getUniformLocation(prg, 'u_AmbientLight');

        prg.u_Color = gl.getUniformLocation(prg, 'u_Color');

        prg.a_Position = gl.getAttribLocation(prg, 'a_Position');
        prg.a_Color = gl.getAttribLocation(prg, 'a_Color');
        prg.a_Normal = gl.getAttribLocation(prg, 'a_Normal');

        return prg;
    }

    // create the WebGL context
    function initWebGL(canvasId) {
        var gl;

        try {
            gl = canvasId.getContext("webgl");
        }
        catch(e) {}

        if (!gl) {
            console.log("Unable to initialize WebGL. Your browser may not support it.");
            gl = null;
        }

        return gl;
    }

    /*
     * load and compile shader from the html file
     */
    function getShader(gl, id) {
        var script = document.getElementById(id);

        var shader;
        if (script.type === "x-shader/x-fragment") {
            shader = gl.createShader(gl.FRAGMENT_SHADER);
        } else if (script.type === "x-shader/x-vertex") {
            shader = gl.createShader(gl.VERTEX_SHADER);
        } else {
            shader = null;
        }

        gl.shaderSource(shader, script.text);
        gl.compileShader(shader);

        if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
            console.log(gl.getShaderInfoLog(shader));
            return null;
        }
        return shader;
    }

    function hexToRgb(hex) {
        var result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
        return result ? {
            r: parseInt(result[1], 16),
            g: parseInt(result[2], 16),
            b: parseInt(result[3], 16)
        } : null;
    }

    document.querySelector("#color").addEventListener('change', function(evt) {
        var hexColor = evt.srcElement.value;
        var rgbColor = (hexToRgb(hexColor));
        cubeColor.r = rgbColor.r / 255;
        cubeColor.g = rgbColor.g / 255;
        cubeColor.b = rgbColor.b / 255;
    });

}());


