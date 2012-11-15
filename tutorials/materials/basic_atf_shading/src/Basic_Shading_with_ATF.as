/*

Shadind example in Away3d

Demonstrates:

How to create multiple lightsources in a scene with ATF Textures.
How to apply specular maps, normals maps and diffuse texture maps to a material.

Code by Rob Bateman & Simo Santavirta
rob@infiniteturtles.co.uk
http://www.infiniteturtles.co.uk

This code is distributed under the MIT License

Copyright (c)  

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the ‚ÄúSoftware‚Äù), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED ‚ÄúAS IS‚Äù, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

*/

package {
	import away3d.cameras.*;
	import away3d.containers.*;
	import away3d.controllers.*;
	import away3d.debug.*;
	import away3d.entities.*;
	import away3d.lights.*;
	import away3d.materials.*;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.primitives.*;
	import away3d.textures.ATFCubeTexture;
	import away3d.textures.ATFTexture;

	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.ui.Keyboard;
	import flash.utils.*;
	
	[SWF(backgroundColor="#000000", frameRate="60", quality="LOW")]
	public class Basic_Shading_with_ATF extends Sprite
	{
		//signature swf
    	[Embed(source="/../asset/signature.swf", symbol="Signature")]
    	private var SignatureSwf:Class;
    	
		//cube textures
		[Embed(source="/../asset/cube/trinket_diffuse.atf", mimeType="application/octet-stream")]
    	public static var TrinketDiffuse:Class;
		[Embed(source="/../asset/cube/trinket_specular.atf", mimeType="application/octet-stream")]
		public static var TrinketSpecular:Class;
		[Embed(source="/../asset/cube/trinket_normal.atf", mimeType="application/octet-stream")]
		public static var TrinketNormals:Class;
		
    	//sphere textures
		[Embed(source="/../asset/ball/beachball_diffuse.atf", mimeType="application/octet-stream")]
    	public static var BeachBallDiffuse:Class;
		[Embed(source="/../asset/ball/beachball_specular.atf", mimeType="application/octet-stream")]
		public static var BeachBallSpecular:Class;
		
    	//torus textures
		[Embed(source="/../asset/torus/weave_diffuse.atf", mimeType="application/octet-stream")]
		public static var WeaveDiffuse:Class;
		[Embed(source="/../asset/torus/weave_normal.atf", mimeType="application/octet-stream")]
		public static var WeaveNormals:Class;
		
		//plane textures
		[Embed(source="/../asset/floor/floor_diffuse.atf", mimeType="application/octet-stream")]
		public static var FloorDiffuse:Class;
		[Embed(source="/../asset/floor/floor_specular.atf", mimeType="application/octet-stream")]
		public static var FloorSpecular:Class;
		[Embed(source="/../asset/floor/floor_normal.atf", mimeType="application/octet-stream")]
		public static var FloorNormals:Class;
    	
		//engine variables
    	private var scene:Scene3D;
		private var camera:Camera3D;
		private var view:View3D;
		private var cameraController:HoverController;
		
		//skymap
		private var _skyMap:ATFCubeTexture;
		[Embed(source="/../asset/sky/hourglass_cubemap2.atf", mimeType="application/octet-stream")]
		public static var SkyMapCubeTexture : Class;
		
		//signature variables
		private var Signature:Sprite;
		private var SignatureBitmap:Bitmap;
		
		//material objects
		private var planeMaterial:TextureMaterial;
		private var sphereMaterial:TextureMaterial;
		private var cubeMaterial:TextureMaterial;
		private var torusMaterial:TextureMaterial;
		
		//light objects
		private var light1:DirectionalLight;
		private var light2:DirectionalLight;
		private var lightPicker:StaticLightPicker;
		
		//scene objects
		private var plane:Mesh;
		private var sphere:Mesh;
		private var cube:Mesh;
		private var torus:Mesh;
		
		//navigation variables
		private var move:Boolean = false;
		private var lastPanAngle:Number;
		private var lastTiltAngle:Number;
		private var lastMouseX:Number;
		private var lastMouseY:Number;
		
		/**
		 * Constructor
		 */
		public function Basic_Shading_with_ATF()
		{
			init();
		}
		
		/**
		 * Global initialise function
		 */
		private function init():void
		{
			//Debug.active = true;
			initEngine();
			initLights();
			initMaterials();
			initObjects();
			initListeners();
		}
		
		/**
		 * Initialise the engine
		 */
		private function initEngine():void
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			scene = new Scene3D();
			
			camera = new Camera3D();
			
			view = new View3D();
			view.antiAlias = 4;
			view.scene = scene;
			view.camera = camera;
			
			//setup controller to be used on the camera
			cameraController = new HoverController(camera);
			cameraController.distance = 1000;
			cameraController.minTiltAngle = 0;
			cameraController.maxTiltAngle = 90;
			cameraController.panAngle = 45;
			cameraController.tiltAngle = 20;
			
			//view.addSourceURL("srcview/index.html");
			addChild(view);
			
			//add signature
			Signature = Sprite(new SignatureSwf());
			SignatureBitmap = new Bitmap(new BitmapData(Signature.width, Signature.height, true, 0));
			stage.quality = StageQuality.HIGH;
			SignatureBitmap.bitmapData.draw(Signature);
			stage.quality = StageQuality.LOW;
			addChild(SignatureBitmap);
			
			addChild(new AwayStats(view));
			
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUp);
		}
		
		private function keyUp(event:KeyboardEvent):void
		{
			switch (event.keyCode) {
				case Keyboard.F:
					stage.displayState = StageDisplayState.FULL_SCREEN;
			}
		}
		
		/**
		 * Initialise the materials
		 */
		 
		private function initMaterials():void
		{
			planeMaterial = new TextureMaterial(new ATFTexture(new FloorDiffuse()));
			planeMaterial.specularMap = new ATFTexture(new FloorSpecular());
			planeMaterial.normalMap = new ATFTexture(new FloorNormals());
			planeMaterial.lightPicker = lightPicker;
			planeMaterial.repeat = true;
			planeMaterial.mipmap = false;
			
			sphereMaterial = new TextureMaterial(new ATFTexture(new BeachBallDiffuse()));
			sphereMaterial.specularMap = new ATFTexture(new BeachBallSpecular());
			sphereMaterial.lightPicker = lightPicker;
			
			cubeMaterial = new TextureMaterial(new ATFTexture(new TrinketDiffuse()));
			cubeMaterial.specularMap = new ATFTexture(new TrinketSpecular());
			cubeMaterial.normalMap = new ATFTexture(new TrinketNormals());
			cubeMaterial.lightPicker = lightPicker;
			cubeMaterial.mipmap = false;
			
			var torusTexture:ATFTexture = new ATFTexture(new WeaveDiffuse());
			torusMaterial = new TextureMaterial(torusTexture);
			torusMaterial.specularMap = torusTexture;
			torusMaterial.normalMap = new ATFTexture(new WeaveNormals());
			torusMaterial.lightPicker = lightPicker;
			torusMaterial.repeat = true;
		}
		
		/**
		 * Initialise the lights
		 */
		private function initLights():void
		{
			light1 = new DirectionalLight();
			light1.direction = new Vector3D(0, -1, 0);
			light1.ambient = 0.1;
			light1.diffuse = 0.7;
			
			scene.addChild(light1);
			
			light2 = new DirectionalLight();
			light2.direction = new Vector3D(0, -1, 0);
			light2.color = 0xd7b940;
			light2.ambient = 0.1;
			light2.diffuse = 0.7;
			
			scene.addChild(light2);
			
			lightPicker = new StaticLightPicker([light1, light2]);
		}
		
		/**
		 * Initialise the scene objects
		 */
		private function initObjects():void
		{
			plane = new Mesh(new PlaneGeometry(1000, 1000), planeMaterial);
			plane.geometry.scaleUV(2, 2);
			plane.y = -20;
			
			scene.addChild(plane);
			
	        sphere = new Mesh(new SphereGeometry(150, 40, 20), sphereMaterial);
	        sphere.x = 300;
	        sphere.y = 160;
	        sphere.z = 300;
	        
			scene.addChild(sphere);
			
	        cube = new Mesh(new CubeGeometry(200, 200, 200, 1, 1, 1, false), cubeMaterial);
	        cube.x = 300;
	        cube.y = 160;
	        cube.z = -250;
	        
			scene.addChild(cube);
			
	        torus = new Mesh(new TorusGeometry(150, 60, 40, 20), torusMaterial);
			torus.geometry.scaleUV(10, 5);
	        torus.x = -250;
	        torus.y = 160;
	        torus.z = -250;
			
			scene.addChild(torus);
			
			
			_skyMap = new ATFCubeTexture(new SkyMapCubeTexture());
			scene.addChild(new SkyBox(_skyMap));
		}
		
		/**
		 * Initialise the listeners
		 */
		private function initListeners():void
		{
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			stage.addEventListener(Event.RESIZE, onResize);
			onResize();
		}
		
		/**
		 * Navigation and render loop
		 */
		private function onEnterFrame(event:Event):void
		{
			if (move) {
				cameraController.panAngle = 0.3*(stage.mouseX - lastMouseX) + lastPanAngle;
				cameraController.tiltAngle = 0.3*(stage.mouseY - lastMouseY) + lastTiltAngle;
			}
			
			light1.direction = new Vector3D(Math.sin(getTimer()/10000)*150000, 1000, Math.cos(getTimer()/10000)*150000);
			
			view.render();
		}
		
		/**
		 * Mouse down listener for navigation
		 */
		private function onMouseDown(event:MouseEvent):void
		{
			lastPanAngle = cameraController.panAngle;
			lastTiltAngle = cameraController.tiltAngle;
			lastMouseX = stage.mouseX;
			lastMouseY = stage.mouseY;
			move = true;
			stage.addEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
		}
		
		/**
		 * Mouse up listener for navigation
		 */
		private function onMouseUp(event:MouseEvent):void
		{
			move = false;
			stage.removeEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
		}
		
		/**
		 * Mouse stage leave listener for navigation
		 */
		private function onStageMouseLeave(event:Event):void
		{
			move = false;
			stage.removeEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
		}
		
		/**
		 * stage listener for resize events
		 */
		private function onResize(event:Event = null):void
		{
			view.width = stage.stageWidth;
			view.height = stage.stageHeight;
			SignatureBitmap.y = stage.stageHeight - Signature.height;
		}
	}
}