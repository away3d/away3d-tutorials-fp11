package
{
	import away3d.containers.View3D;
	import away3d.debug.Debug;
	import away3d.entities.Mesh;
	import away3d.lights.DirectionalLight;
	import away3d.materials.MaterialBase;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.primitives.SphereGeometry;
	import away3d.textures.BitmapTexture;
	import away3d.utils.Cast;

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Vector3D;

	import tut03.SingleLightTextureMaterial;

	import utils.FlightController;

	[SWF(width="800", height="600", frameRate="60")]
	public class CustomMaterials03 extends Sprite
	{
		[Embed(source="../assets/floor_diffuse.jpg")]
		private var TextureAsset : Class;

		private var view : View3D;
		private var controller : FlightController;
		private var light : DirectionalLight;
		private var angle : Number = 0;

		public function CustomMaterials03()
		{
			Debug.active = true;
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;

			initView();
			initController();
			initScene();

			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}

		private function initView() : void
		{
			view = new View3D();
			view.camera.z = -150;
			addChild(view);
		}

		private function initController() : void
		{
			// we init controller already since it'll be useful to test materials
			controller = new FlightController(view.camera, stage);
			controller.start();
		}

		private function initScene() : void
		{
			var sphereGeom : SphereGeometry = new SphereGeometry();
			var texture : BitmapTexture = Cast.bitmapTexture(TextureAsset);
			var material : MaterialBase = new SingleLightTextureMaterial(texture);

			light = new DirectionalLight(-1, -1, 1);
			view.scene.addChild(light);

			material.lightPicker = new StaticLightPicker([light]);

			var mesh : Mesh = new Mesh(sphereGeom, material);
			view.scene.addChild(mesh);
		}

		private function onEnterFrame(event : Event) : void
		{
			// just rotate the light over time
			light.direction = new Vector3D(-Math.cos(angle), -1, -Math.sin(angle));
			angle += .01;
			view.render();
		}
	}
}
