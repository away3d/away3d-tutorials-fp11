/*

   Basic tutorial for Away3D particle system


   Code by Cheng Liao


   This code is distributed under the MIT License

   Copyright (c) The Away Foundation http://www.theawayfoundation.org

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
	import away3d.animators.data.ParticleProperties;
	import away3d.animators.data.ParticlePropertiesMode;
	import away3d.animators.nodes.ParticlePositionNode;
	import away3d.animators.nodes.ParticleVelocityNode;
	import away3d.animators.ParticleAnimationSet;
	import away3d.animators.ParticleAnimator;
	import away3d.containers.View3D;
	import away3d.controllers.HoverController;
	import away3d.core.base.Geometry;
	import away3d.debug.AwayStats;
	import away3d.entities.Mesh;
	import away3d.lights.PointLight;
	import away3d.materials.ColorMaterial;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.primitives.CubeGeometry;
	import away3d.tools.helpers.ParticleGeometryHelper;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Vector3D;
	import flash.utils.Timer;
	
	[SWF(backgroundColor="#000000",frameRate="60")]
	
	public class TheAdvancedDemo extends Sprite
	{
		[Embed(source="../embeds/text.png")]
		private var TEXT_IMG:Class;
		
		private const SIZE:int = 5;
		private const TIME:int = 10000;
		
		private var _view:View3D;
		
		//navigation variables
		private var _cameraController:HoverController;
		private var _move:Boolean = false;
		private var _lastPanAngle:Number;
		private var _lastTiltAngle:Number;
		private var _lastMouseX:Number;
		private var _lastMouseY:Number;
		private var angle:Number = 0;
		private var state:int;
		
		//data variables
		private var data:Vector.<Vector3D>;
		
		//light variables
		private var greenlight:PointLight;
		private var redlight:PointLight;
		private var lightpicker:StaticLightPicker;
		
		//particle animator
		private var animator:ParticleAnimator;
		
		public function TheAdvancedDemo()
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			_view = new View3D();
			_view.antiAlias = 2;
			addChild(_view);
			
			_cameraController = new HoverController(_view.camera, null, 180, 0, 1000, -90);
			
			addChild(new AwayStats(_view));
			initTextData();
			initLights();
			initParticle();
			
			//add listeners
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			stage.addEventListener(Event.RESIZE, onResize);
			onResize();
			
			var timer:Timer = new Timer(TIME);
			timer.addEventListener(TimerEvent.TIMER, onTimer);
			timer.start();
			onTimer(null);
		}
		
		// change the state by time
		private function onTimer(e:Event):void
		{
			switch (state)
			{
				case 0:
					animator.playbackSpeed = 0;
					animator.resetTime(0);
					break;
				case 1:
					animator.playbackSpeed = 1;
					break;
				case 2:
					animator.playbackSpeed = -1;
					break;
			}
			state++;
			state %= 3;
		}
		
		private function initTextData():void
		{
			var bitmapData:BitmapData = new TEXT_IMG().bitmapData;
			data = new Vector.<Vector3D>;
			var depth:int = 10;
			for (var i:int = 0; i < bitmapData.width; i++)
			{
				for (var j:int = 0; j < bitmapData.height; j++)
				{
					if (bitmapData.getPixel(i, j) == 0)
					{
						for (var k:int = 0; k < depth; k++)
						{
							var point:Vector3D = new Vector3D(i - bitmapData.width / 2, bitmapData.height / 2 - j, k);
							point.scaleBy(SIZE);
							data.push(point);
						}
					}
				}
			}
		}
		
		private function initLights():void
		{
			greenlight = new PointLight();
			greenlight.color = 0x00ff00;
			greenlight.fallOff = 500;
			greenlight.radius = 100;
			greenlight.ambient = 0.5;
			greenlight.specular = 2;
			redlight = new PointLight();
			redlight.color = 0xff0000;
			redlight.fallOff = 500;
			redlight.radius = 100;
			redlight.specular = 2;
			_view.scene.addChild(greenlight);
			_view.scene.addChild(redlight);
			lightpicker = new StaticLightPicker([greenlight, redlight]);
		}
		
		private function initParticle():void
		{
			//generate the particle geometry
			var cube:Geometry = new CubeGeometry(SIZE, SIZE, SIZE);
			var geometrySet:Vector.<Geometry> = new Vector.<Geometry>;
			for (var i:int = 0; i < data.length; i++)
			{
				geometrySet.push(cube);
			}
			
			var particleGeometry:Geometry = ParticleGeometryHelper.generateGeometry(geometrySet);
			
			//create the particle animation set
			var animationSet:ParticleAnimationSet = new ParticleAnimationSet();
			//add behaviors to the animationSet
			animationSet.addAnimation(new ParticleVelocityNode(ParticlePropertiesMode.LOCAL_STATIC));
			animationSet.addAnimation(new ParticlePositionNode(ParticlePropertiesMode.LOCAL_STATIC));
			
			//set the initialiser function
			animationSet.initParticleFunc = initParticleParam;
			
			//create material, mesh and animator
			var material:ColorMaterial = new ColorMaterial(0xffffff);
			material.alphaPremultiplied = true;
			material.lightPicker = lightpicker;
			var particleMesh:Mesh = new Mesh(particleGeometry, material);
			animator = new ParticleAnimator(animationSet);
			particleMesh.animator = animator;
			animator.start();
			_view.scene.addChild(particleMesh);
		}
		
		private function initParticleParam(prop:ParticleProperties):void
		{
			prop.startTime = 0;
			var degree1:Number = Math.random() * Math.PI * 2;
			var degree2:Number = Math.random() * Math.PI * 2;
			var r:Number = 30;
			//set the velocity
			prop[ParticleVelocityNode.VELOCITY_VECTOR3D] = new Vector3D(r * Math.sin(degree1) * Math.cos(degree2), r * Math.cos(degree1) * Math.cos(degree2), r * Math.sin(degree2));
			//set the position according to bitmap data
			prop[ParticlePositionNode.POSITION_VECTOR3D] = data[prop.index];
		}
		
		private function onEnterFrame(event:Event):void
		{
			if (_move)
			{
				_cameraController.panAngle = 0.3 * (stage.mouseX - _lastMouseX) + _lastPanAngle;
				_cameraController.tiltAngle = 0.3 * (stage.mouseY - _lastMouseY) + _lastTiltAngle;
			}
			angle += Math.PI / 180;
			greenlight.x = Math.sin(angle) * 300;
			greenlight.z = Math.cos(angle) * 300;
			redlight.x = Math.sin(angle + Math.PI) * 300;
			redlight.z = Math.cos(angle + Math.PI) * 300;
			_view.render();
		}
		
		private function onMouseDown(event:MouseEvent):void
		{
			_lastPanAngle = _cameraController.panAngle;
			_lastTiltAngle = _cameraController.tiltAngle;
			_lastMouseX = stage.mouseX;
			_lastMouseY = stage.mouseY;
			_move = true;
			stage.addEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
		}
		
		private function onMouseUp(event:MouseEvent):void
		{
			_move = false;
			stage.removeEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
		}
		
		private function onStageMouseLeave(event:Event):void
		{
			_move = false;
			stage.removeEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
		}
		
		private function onResize(event:Event = null):void
		{
			_view.width = stage.stageWidth;
			_view.height = stage.stageHeight;
		}
	}
}
