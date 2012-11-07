/*

Simple texturing example in Away3d

Demonstrates:

How to texture a sphere from the Basic Shading demo

Code by Greg Caldwell
greg.caldwell@geepers.co.uk
http://www.geepers.co.uk

This code is distributed under the MIT License

Copyright (c)  

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the “Software”), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

*/

package
{
	import flash.text.TextFormat;
	import flash.text.TextField;
	import away3d.materials.utils.DefaultMaterialManager;
	import away3d.cameras.*;
	import away3d.containers.*;
	import away3d.debug.*;
	import away3d.entities.*;
	import away3d.lights.*;
	import away3d.materials.*;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.primitives.*;
	import away3d.utils.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.utils.*;
	
	[SWF(backgroundColor="#000000", frameRate="60", quality="LOW")]
	public class Basic_Shading_Ex1 extends Sprite
	{
		//signature swf
    	[Embed(source="/../embeds/signature.swf", symbol="Signature")]
    	private var SignatureSwf:Class;
    			
    	//sphere textures
		[Embed(source="/../embeds/beachball_diffuse.jpg")]
    	public static var BeachBallDiffuse:Class;
		[Embed(source="/../embeds/beachball_specular.jpg")]
		public static var BeachBallSpecular:Class;
		    	
    	//engine variables
    	private var scene:Scene3D;
		private var camera:Camera3D;
		private var view:View3D;
		
		//signature variables
		private var Signature:Sprite;
		private var SignatureBitmap:Bitmap;
		
		// Info variables
		private var info : TextField;
		
		//material objects
		private var sphereMaterial:TextureMaterial;
		
		//light objects
		private var light1:DirectionalLight;
		private var lightPicker:StaticLightPicker;
		
		//scene objects
		private var plane:WireframePlane;
		private var sphere:Mesh;
		private var textureMode : Number = -1;
		
		/**
		 * Constructor
		 */
		public function Basic_Shading_Ex1()
		{
			init();
		}
		
		/**
		 * Global initialise function
		 */
		private function init():void
		{
			initEngine();
			initText();
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
			camera.y = 300;
			camera.z = -450;
			camera.lookAt(new Vector3D(0.1, 160, 0));
			
			view = new View3D();
			view.antiAlias = 4;
			view.scene = scene;
			view.camera = camera;

			addChild(view);
			
			//add signature
			Signature = Sprite(new SignatureSwf());
			SignatureBitmap = new Bitmap(new BitmapData(Signature.width, Signature.height, true, 0));
			stage.quality = StageQuality.HIGH;
			SignatureBitmap.bitmapData.draw(Signature);
			stage.quality = StageQuality.LOW;
			addChild(SignatureBitmap);
			
			addChild(new AwayStats(view));
		}
		
		/**
		 * Initialise the info text field
		 */
		private function initText() : void {
			info = new TextField();
			info.x = 150;
			info.y = 20;
			info.width = 500;
			info.defaultTextFormat = new TextFormat("_sans", 14, 0xFFFF00, true);
			
			addChild(info);
		}
		
		/**
		 * Initialise the materials
		 */
		private function initMaterials():void
		{
			sphereMaterial = new TextureMaterial(Cast.bitmapTexture(BeachBallDiffuse));
			sphereMaterial.specularMap = Cast.bitmapTexture(BeachBallSpecular);
			sphereMaterial.lightPicker = lightPicker;
		}
		
		/**
		 * Initialise the lights
		 */
		private function initLights():void
		{
			light1 = new DirectionalLight();
			light1.direction = new Vector3D(0, -1, 0);
			light1.color = 0xFFFFFF;
			light1.ambient = 0.1;
			light1.diffuse = 0.7;
			
			scene.addChild(light1);
			
			lightPicker = new StaticLightPicker([light1]);
		}
		
		/**
		 * Initialise the scene objects
		 */
		private function initObjects():void
		{
			plane = new WireframePlane(1000, 1000, 20, 20, 0x0080A0, 1.5, WireframePlane.ORIENTATION_XZ);
			plane.y = -20;
			
			scene.addChild(plane);
			
	        sphere = new Mesh(new SphereGeometry(150, 40, 20), sphereMaterial);
	        sphere.y = 160;
	        
			scene.addChild(sphere);
			
			onChangeMaterial(null);
		}
		
		/**
		 * Initialise the listeners
		 */
		private function initListeners():void
		{
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			addEventListener(MouseEvent.CLICK, onChangeMaterial);
			stage.addEventListener(Event.RESIZE, onResize);
			onResize();
		}

		/**
		 * Navigation and render loop
		 */
		private function onEnterFrame(event:Event):void
		{
			sphere.rotationY -= 0.2;
						
			light1.direction = new Vector3D(Math.sin(getTimer()/2000)*150000, 1000, Math.cos(getTimer()/2000)*150000);
			
			view.render();
		}

		/**
		 * Toggle material on the mesh
		 */
		private function onChangeMaterial(event : MouseEvent) : void {
			textureMode++;
			if (textureMode>2) textureMode = 0;
			
			switch (textureMode) {
				 case 0: 
				 	sphere.material = DefaultMaterialManager.getDefaultMaterial(sphere);
					info.text = "Material : NONE";
					break;
				 case 1: 
					info.text = "Material : Diffuse bitmap only";
					sphere.material = sphereMaterial;
				 	sphereMaterial.texture = Cast.bitmapTexture(BeachBallDiffuse);
				 	sphereMaterial.specularMap = null;
					break;
				 case 2: 
					info.text = "Material : Diffuse bitmap and Specular map";
					sphereMaterial.specularMap = Cast.bitmapTexture(BeachBallSpecular);
					break;
			}
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