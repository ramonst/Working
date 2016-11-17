﻿<%@ Page Title="Contact" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Contact.aspx.cs" Inherits="WebApplication2.Contact" %>

<asp:Content runat="server" ID="BodyContent" ContentPlaceHolderID="MainContent">
    	<meta name="viewport" content="width=device-width, user-scalable=no, minimum-scale=1.0, maximum-scale=1.0">
    <asp:Panel ID="Panel1" runat="server">
        <div id="container"></div>
	<div id="info">
		<a href="http://threejs.org" target="_blank">three.js</a> -
		marching cubes -
		[based on greggman's <a href="http://webglsamples.googlecode.com/hg/blob/blob.html">blob</a>, original code by Henrik Rydgård]
	</div>

	<script src="Scripts/threeJS/three.js"></script>

	<script src="Scripts/threeJS/OrbitControls.js"></script>

	<script src="Scripts/threeJS/Shaders/CopyShader.js"></script>
	<script src="Scripts/threeJS/Shaders/FXAAShader.js"></script>
	<script src="Scripts/threeJS/Shaders/HorizontalTiltShiftShader.js"></script>
	<script src="Scripts/threeJS/Shaders/VerticalTiltShiftShader.js"></script>

	<script src="Scripts/threeJS/postprocessing/EffectComposer.js"></script>
	<script src="Scripts/threeJS/postprocessing/RenderPass.js"></script>
	<script src="Scripts/threeJS/postprocessing/BloomPass.js"></script>
	<script src="Scripts/threeJS/postprocessing/ShaderPass.js"></script>
	<script src="Scripts/threeJS/postprocessing/MaskPass.js"></script>
	<script src="Scripts/threeJS/postprocessing/SavePass.js"></script>

	<script src="Scripts/threeJS/MarchingCubes.js"></script>
	<script src="Scripts/threeJS/ShaderToon.js"></script>

	<script src="Scripts/threeJS/Detector.js"></script>
	<script src="Scripts/threeJS/stats.min.js"></script>
	<script src="Scripts/threeJS/dat.gui.min.js"></script>


	<script>
	    if (!Detector.webgl) Detector.addGetWebGLMessage();

	    var MARGIN = 0;

	    var SCREEN_WIDTH = window.innerWidth;
	    var SCREEN_HEIGHT = window.innerHeight - 2 * MARGIN;

	    var container, stats;

	    var camera, scene, renderer;

	    var mesh, texture, geometry, materials, material, current_material;

	    var light, pointLight, ambientLight;

	    var effect, resolution, numBlobs;

	    var composer, effectFXAA, hblur, vblur;

	    var effectController;

	    var time = 0;
	    var clock = new THREE.Clock();

	    init();
	    animate();

	    function init() {

	        container = document.getElementById('container');

	        // CAMERA

	        camera = new THREE.PerspectiveCamera(45, SCREEN_WIDTH / SCREEN_HEIGHT, 1, 10000);
	        camera.position.set(-500, 500, 1500);

	        // SCENE

	        scene = new THREE.Scene();

	        // LIGHTS

	        light = new THREE.DirectionalLight(0xffffff);
	        light.position.set(0.5, 0.5, 1);
	        scene.add(light);

	        pointLight = new THREE.PointLight(0xff3300);
	        pointLight.position.set(0, 0, 100);
	        scene.add(pointLight);

	        ambientLight = new THREE.AmbientLight(0x080808);
	        scene.add(ambientLight);

	        // MATERIALS

	        materials = generateMaterials();
	        current_material = "shiny";

	        // MARCHING CUBES

	        resolution = 28;
	        numBlobs = 10;

	        effect = new THREE.MarchingCubes(resolution, materials[current_material].m, true, true);
	        effect.position.set(0, 0, 0);
	        effect.scale.set(700, 700, 700);

	        effect.enableUvs = false;
	        effect.enableColors = false;

	        scene.add(effect);

	        // RENDERER

	        renderer = new THREE.WebGLRenderer();
	        renderer.setClearColor(0x050505);
	        renderer.setPixelRatio(window.devicePixelRatio);
	        renderer.setSize(SCREEN_WIDTH, SCREEN_HEIGHT);

	        renderer.domElement.style.position = "absolute";
	        renderer.domElement.style.top = MARGIN + "px";
	        renderer.domElement.style.left = "0px";

	        container.appendChild(renderer.domElement);

	        //

	        renderer.gammaInput = true;
	        renderer.gammaOutput = true;

	        // CONTROLS

	        controls = new THREE.OrbitControls(camera, renderer.domElement);

	        // STATS

	        stats = new Stats();
	        container.appendChild(stats.dom);

	        // COMPOSER

	        renderer.autoClear = false;

	        var renderTargetParameters = { minFilter: THREE.LinearFilter, magFilter: THREE.LinearFilter, format: THREE.RGBFormat, stencilBuffer: false };
	        renderTarget = new THREE.WebGLRenderTarget(SCREEN_WIDTH, SCREEN_HEIGHT, renderTargetParameters);

	        effectFXAA = new THREE.ShaderPass(THREE.FXAAShader);

	        hblur = new THREE.ShaderPass(THREE.HorizontalTiltShiftShader);
	        vblur = new THREE.ShaderPass(THREE.VerticalTiltShiftShader);

	        var bluriness = 8;

	        hblur.uniforms['h'].value = bluriness / SCREEN_WIDTH;
	        vblur.uniforms['v'].value = bluriness / SCREEN_HEIGHT;

	        hblur.uniforms['r'].value = vblur.uniforms['r'].value = 0.5;

	        effectFXAA.uniforms['resolution'].value.set(1 / SCREEN_WIDTH, 1 / SCREEN_HEIGHT);

	        composer = new THREE.EffectComposer(renderer, renderTarget);

	        var renderModel = new THREE.RenderPass(scene, camera);

	        vblur.renderToScreen = true;
	        //effectFXAA.renderToScreen = true;

	        composer = new THREE.EffectComposer(renderer, renderTarget);

	        composer.addPass(renderModel);

	        composer.addPass(effectFXAA);

	        composer.addPass(hblur);
	        composer.addPass(vblur);

	        // GUI

	        setupGui();

	        // EVENTS

	        window.addEventListener('resize', onWindowResize, false);

	    }

	    //

	    function onWindowResize(event) {

	        SCREEN_WIDTH = window.innerWidth;
	        SCREEN_HEIGHT = window.innerHeight - 2 * MARGIN;

	        camera.aspect = SCREEN_WIDTH / SCREEN_HEIGHT;
	        camera.updateProjectionMatrix();

	        renderer.setSize(SCREEN_WIDTH, SCREEN_HEIGHT);
	        composer.setSize(SCREEN_WIDTH, SCREEN_HEIGHT);

	        hblur.uniforms['h'].value = 4 / SCREEN_WIDTH;
	        vblur.uniforms['v'].value = 4 / SCREEN_HEIGHT;

	        effectFXAA.uniforms['resolution'].value.set(1 / SCREEN_WIDTH, 1 / SCREEN_HEIGHT);

	    }

	    function generateMaterials() {

	        // environment map

	        var path = "textures/cube/SwedishRoyalCastle/";
	        var format = '.jpg';
	        var urls = [
				path + 'px' + format, path + 'nx' + format,
				path + 'py' + format, path + 'ny' + format,
				path + 'pz' + format, path + 'nz' + format
	        ];

	        var cubeTextureLoader = new THREE.CubeTextureLoader();

	        var reflectionCube = cubeTextureLoader.load(urls);
	        reflectionCube.format = THREE.RGBFormat;

	        var refractionCube = cubeTextureLoader.load(urls);
	        reflectionCube.format = THREE.RGBFormat;
	        refractionCube.mapping = THREE.CubeRefractionMapping;

	        // toons

	        var toonMaterial1 = createShaderMaterial("toon1", light, ambientLight),
			toonMaterial2 = createShaderMaterial("toon2", light, ambientLight),
			hatchingMaterial = createShaderMaterial("hatching", light, ambientLight),
			hatchingMaterial2 = createShaderMaterial("hatching", light, ambientLight),
			dottedMaterial = createShaderMaterial("dotted", light, ambientLight),
			dottedMaterial2 = createShaderMaterial("dotted", light, ambientLight);

	        hatchingMaterial2.uniforms.uBaseColor.value.setRGB(0, 0, 0);
	        hatchingMaterial2.uniforms.uLineColor1.value.setHSL(0, 0.8, 0.5);
	        hatchingMaterial2.uniforms.uLineColor2.value.setHSL(0, 0.8, 0.5);
	        hatchingMaterial2.uniforms.uLineColor3.value.setHSL(0, 0.8, 0.5);
	        hatchingMaterial2.uniforms.uLineColor4.value.setHSL(0.1, 0.8, 0.5);

	        dottedMaterial2.uniforms.uBaseColor.value.setRGB(0, 0, 0);
	        dottedMaterial2.uniforms.uLineColor1.value.setHSL(0.05, 1.0, 0.5);

	        var texture = new THREE.TextureLoader().load("textures/UV_Grid_Sm.jpg");
	        texture.wrapS = texture.wrapT = THREE.RepeatWrapping;

	        var materials = {

	            "chrome":
                {
                    m: new THREE.MeshLambertMaterial({ color: 0xffffff, envMap: reflectionCube }),
                    h: 0, s: 0, l: 1
                },

	            "liquid":
                {
                    m: new THREE.MeshLambertMaterial({ color: 0xffffff, envMap: refractionCube, refractionRatio: 0.85 }),
                    h: 0, s: 0, l: 1
                },

	            "shiny":
                {
                    m: new THREE.MeshStandardMaterial({ color: 0x550000, envMap: reflectionCube, roughness: 0.1, metalness: 1.0 }),
                    h: 0, s: 0.8, l: 0.2
                },

	            "matte":
                {
                    m: new THREE.MeshPhongMaterial({ color: 0x000000, specular: 0x111111, shininess: 1 }),
                    h: 0, s: 0, l: 1
                },

	            "flat":
                {
                    m: new THREE.MeshPhongMaterial({ color: 0x000000, specular: 0x111111, shininess: 1, shading: THREE.FlatShading }),
                    h: 0, s: 0, l: 1
                },

	            "textured":
                {
                    m: new THREE.MeshPhongMaterial({ color: 0xffffff, specular: 0x111111, shininess: 1, map: texture }),
                    h: 0, s: 0, l: 1
                },

	            "colors":
                {
                    m: new THREE.MeshPhongMaterial({ color: 0xffffff, specular: 0xffffff, shininess: 2, vertexColors: THREE.VertexColors }),
                    h: 0, s: 0, l: 1
                },

	            "plastic":
                {
                    m: new THREE.MeshPhongMaterial({ color: 0x000000, specular: 0x888888, shininess: 250 }),
                    h: 0.6, s: 0.8, l: 0.1
                },

	            "toon1":
                {
                    m: toonMaterial1,
                    h: 0.2, s: 1, l: 0.75
                },

	            "toon2":
                {
                    m: toonMaterial2,
                    h: 0.4, s: 1, l: 0.75
                },

	            "hatching":
                {
                    m: hatchingMaterial,
                    h: 0.2, s: 1, l: 0.9
                },

	            "hatching2":
                {
                    m: hatchingMaterial2,
                    h: 0.0, s: 0.8, l: 0.5
                },

	            "dotted":
                {
                    m: dottedMaterial,
                    h: 0.2, s: 1, l: 0.9
                },

	            "dotted2":
                {
                    m: dottedMaterial2,
                    h: 0.1, s: 1, l: 0.5
                }

	        };

	        return materials;

	    }

	    function createShaderMaterial(id, light, ambientLight) {

	        var shader = THREE.ShaderToon[id];

	        var u = THREE.UniformsUtils.clone(shader.uniforms);

	        var vs = shader.vertexShader;
	        var fs = shader.fragmentShader;

	        var material = new THREE.ShaderMaterial({ uniforms: u, vertexShader: vs, fragmentShader: fs });

	        material.uniforms.uDirLightPos.value = light.position;
	        material.uniforms.uDirLightColor.value = light.color;

	        material.uniforms.uAmbientLightColor.value = ambientLight.color;

	        return material;

	    }

	    //

	    function setupGui() {

	        var createHandler = function (id) {

	            return function () {

	                var mat_old = materials[current_material];
	                mat_old.h = m_h.getValue();
	                mat_old.s = m_s.getValue();
	                mat_old.l = m_l.getValue();

	                current_material = id;

	                var mat = materials[id];
	                effect.material = mat.m;

	                m_h.setValue(mat.h);
	                m_s.setValue(mat.s);
	                m_l.setValue(mat.l);

	                if (current_material === "textured") {

	                    effect.enableUvs = true;

	                } else {

	                    effect.enableUvs = false;

	                }

	                if (current_material === "colors") {

	                    effect.enableColors = true;

	                } else {

	                    effect.enableColors = false;

	                }

	            };

	        };

	        effectController = {

	            material: "shiny",

	            speed: 1.0,
	            numBlobs: 10,
	            resolution: 28,
	            isolation: 80,

	            floor: true,
	            wallx: false,
	            wallz: false,

	            hue: 0.0,
	            saturation: 0.8,
	            lightness: 0.1,

	            lhue: 0.04,
	            lsaturation: 1.0,
	            llightness: 0.5,

	            lx: 0.5,
	            ly: 0.5,
	            lz: 1.0,

	            postprocessing: false,

	            dummy: function () {
	            }

	        };

	        var h, m_h, m_s, m_l;

	        var gui = new dat.GUI();

	        // material (type)

	        h = gui.addFolder("Materials");

	        for (var m in materials) {

	            effectController[m] = createHandler(m);
	            h.add(effectController, m).name(m);

	        }

	        // material (color)

	        h = gui.addFolder("Material color");

	        m_h = h.add(effectController, "hue", 0.0, 1.0, 0.025);
	        m_s = h.add(effectController, "saturation", 0.0, 1.0, 0.025);
	        m_l = h.add(effectController, "lightness", 0.0, 1.0, 0.025);

	        // light (point)

	        h = gui.addFolder("Point light color");

	        h.add(effectController, "lhue", 0.0, 1.0, 0.025).name("hue");
	        h.add(effectController, "lsaturation", 0.0, 1.0, 0.025).name("saturation");
	        h.add(effectController, "llightness", 0.0, 1.0, 0.025).name("lightness");

	        // light (directional)

	        h = gui.addFolder("Directional light orientation");

	        h.add(effectController, "lx", -1.0, 1.0, 0.025).name("x");
	        h.add(effectController, "ly", -1.0, 1.0, 0.025).name("y");
	        h.add(effectController, "lz", -1.0, 1.0, 0.025).name("z");

	        // simulation

	        h = gui.addFolder("Simulation");

	        h.add(effectController, "speed", 0.1, 8.0, 0.05);
	        h.add(effectController, "numBlobs", 1, 50, 1);
	        h.add(effectController, "resolution", 14, 100, 1);
	        h.add(effectController, "isolation", 10, 300, 1);

	        h.add(effectController, "floor");
	        h.add(effectController, "wallx");
	        h.add(effectController, "wallz");

	        // rendering

	        h = gui.addFolder("Rendering");
	        h.add(effectController, "postprocessing");

	    }

	    // this controls content of marching cubes voxel field

	    function updateCubes(object, time, numblobs, floor, wallx, wallz) {

	        object.reset();

	        // fill the field with some metaballs

	        var i, ballx, bally, ballz, subtract, strength;

	        subtract = 12;
	        strength = 1.2 / ((Math.sqrt(numblobs) - 1) / 4 + 1);

	        for (i = 0; i < numblobs; i++) {

	            ballx = Math.sin(i + 1.26 * time * (1.03 + 0.5 * Math.cos(0.21 * i))) * 0.27 + 0.5;
	            bally = Math.abs(Math.cos(i + 1.12 * time * Math.cos(1.22 + 0.1424 * i))) * 0.77; // dip into the floor
	            ballz = Math.cos(i + 1.32 * time * 0.1 * Math.sin((0.92 + 0.53 * i))) * 0.27 + 0.5;

	            object.addBall(ballx, bally, ballz, strength, subtract);

	        }

	        if (floor) object.addPlaneY(2, 12);
	        if (wallz) object.addPlaneZ(2, 12);
	        if (wallx) object.addPlaneX(2, 12);

	    }

	    //


	    function animate() {

	        requestAnimationFrame(animate);

	        render();
	        stats.update();

	    }

	    function render() {

	        var delta = clock.getDelta();

	        time += delta * effectController.speed * 0.5;

	        controls.update(delta);

	        // marching cubes

	        if (effectController.resolution !== resolution) {

	            resolution = effectController.resolution;
	            effect.init(Math.floor(resolution));

	        }

	        if (effectController.isolation !== effect.isolation) {

	            effect.isolation = effectController.isolation;

	        }

	        updateCubes(effect, time, effectController.numBlobs, effectController.floor, effectController.wallx, effectController.wallz);

	        // materials

	        if (effect.material instanceof THREE.ShaderMaterial) {

	            if (current_material === "dotted2") {

	                effect.material.uniforms.uLineColor1.value.setHSL(effectController.hue, effectController.saturation, effectController.lightness);

	            } else if (current_material === "hatching2") {

	                u = effect.material.uniforms;

	                u.uLineColor1.value.setHSL(effectController.hue, effectController.saturation, effectController.lightness);
	                u.uLineColor2.value.setHSL(effectController.hue, effectController.saturation, effectController.lightness);
	                u.uLineColor3.value.setHSL(effectController.hue, effectController.saturation, effectController.lightness);
	                u.uLineColor4.value.setHSL((effectController.hue + 0.2 % 1.0), effectController.saturation, effectController.lightness);

	            } else {

	                effect.material.uniforms.uBaseColor.value.setHSL(effectController.hue, effectController.saturation, effectController.lightness);

	            }

	        } else {

	            effect.material.color.setHSL(effectController.hue, effectController.saturation, effectController.lightness);

	        }

	        // lights

	        light.position.set(effectController.lx, effectController.ly, effectController.lz);
	        light.position.normalize();

	        pointLight.color.setHSL(effectController.lhue, effectController.lsaturation, effectController.llightness);

	        // render

	        if (effectController.postprocessing) {

	            composer.render(delta);

	        } else {

	            renderer.clear();
	            renderer.render(scene, camera);

	        }

	    }

</script>

    </asp:Panel>
</asp:Content>