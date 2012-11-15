/*

ATF Texture example in Away3d

Demonstrates:

How to use ATF Textures. Both embedded and loaded.

Simo Santavirta
simo@simppa.fi
http://www.simppa.fi

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
	import away3d.containers.View3D;
	import away3d.debug.AwayStats;
	import away3d.entities.Mesh;
	import away3d.materials.TextureMaterial;
	import away3d.primitives.PlaneGeometry;
	import away3d.primitives.SkyBox;
	import away3d.textures.ATFCubeTexture;
	import away3d.textures.ATFTexture;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.Vector3D;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.ui.Keyboard;
	import flash.utils.getTimer;
	
	[SWF(frameRate="60", backgroundColor = "#0", width="960", height="480")]
	public class Basic_ATF_Texture extends Sprite 
	{
		//signature swf
    	[Embed(source="/../asset/signature.swf", symbol="Signature")]
    	private var SignatureSwf:Class;
    	
		//signature variables
		private var Signature:Sprite;
		private var SignatureBitmap:Bitmap;
		
		// engine variables
		private var _view:View3D;

		// scene objects
		private var _plane:Mesh;
		
		// texture
		private var _texture:ATFTexture;
		[Embed(source="/../asset/floor/floor_diffuse.atf", mimeType="application/octet-stream")]
		private const _bytesAtf:Class;
		
		// sky
		private var _skyMap:ATFCubeTexture;
		[Embed(source="/../asset/sky/hourglass_cubemap2.atf", mimeType="application/octet-stream")]
		public static var SkyMapCubeTexture : Class;
		
		// texture loader
		private var loader:URLLoader;
		
		private var _center:Vector3D = new Vector3D();
		
		public function Basic_ATF_Texture() {
			
			
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(event:Event):void
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;

			var url:String = "../asset/floor/floor_diffuse.atf";
			loader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			loader.addEventListener(Event.COMPLETE, setupFromLoader);
			var urlReq:URLRequest = new URLRequest(url);
 			loader.load(urlReq);
			
		}
		
		private function setupFromLoader(event:Event):void
		{
			_texture = new ATFTexture(loader.data);
			
			loader.removeEventListener(Event.COMPLETE, setupFromLoader);
			loader = null;
			
			setupScene();
		}
		
		/**
		 * Setup the scene
		 */
		private function setupScene():void
		{
			//setup the view
			_view = new View3D();
			addChild(_view);

			//setup the camera
			_view.camera.z = -600;
			_view.camera.y = 500;
			_view.camera.lens.far = 10000;
			_view.camera.lookAt(new Vector3D());
			
			//setup the scene
			if(!_texture) _texture = new ATFTexture(new _bytesAtf());
			var textureMaterial:TextureMaterial = new TextureMaterial(_texture);
			
			//place some planes to screen
			var planes:Vector.<Mesh> = new Vector.<Mesh>();
			var x:int, z:int, c:int = 0, l:int = 8;
			var size:int = 700;
			var split:int = -((l*size) >> 1) + (size >> 1);
			for(x = 0; x < l; x++)
			{
				for(z = 0; z < l; z++)
				{
					_plane = planes[c++] = new Mesh(new PlaneGeometry(size, size), textureMaterial);
					_plane.x = split + size * x;
					_plane.z = split + size * z; 
					_view.scene.addChild(_plane);
				}
			}
			
			// add sky
			_skyMap = new ATFCubeTexture(new SkyMapCubeTexture());
			_view.scene.addChild(new SkyBox(_skyMap));
			
			//add signature
			Signature = Sprite(new SignatureSwf());
			SignatureBitmap = new Bitmap(new BitmapData(Signature.width, Signature.height, true, 0));
			SignatureBitmap.bitmapData.draw(Signature);
			addChild(SignatureBitmap);
			
			addChild(new AwayStats(_view));
			
			//setup the render loop
			addEventListener(Event.ENTER_FRAME, _onEnterFrame);
			stage.addEventListener(Event.RESIZE, onResize);
			onResize();
			
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
		 * render loop
		 */
		private function _onEnterFrame(e:Event):void
		{
			var time:int = getTimer();
			var radius:Number = 1400;
			
			_view.camera.x = radius * Math.sin(time * .0005);
			_view.camera.z = radius * Math.cos(time * .0003);
			
			_view.camera.lookAt(_center);
			
			_view.render();
		}

		/**
		 * stage listener for resize events
		 */
		private function onResize(event:Event = null):void
		{
			_view.width = stage.stageWidth;
			_view.height = stage.stageHeight;
			SignatureBitmap.y = stage.stageHeight - Signature.height;
		}
	}
}
