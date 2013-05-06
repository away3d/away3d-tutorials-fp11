package
{
	import away3d.containers.View3D;
	import away3d.entities.Mesh;
	import away3d.materials.MaterialBase;
	import away3d.primitives.SphereGeometry;

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;

	import tut01.TrivialColorMaterial;

	import utils.FlightController;

	[SWF(width="800", height="600", frameRate="60")]
	public class CustomMaterials01 extends Sprite
	{
		private var view : View3D;
		private var controller : FlightController;

		public function CustomMaterials01()
		{
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
			var material : MaterialBase = new TrivialColorMaterial();
			view.scene.addChild(new Mesh(sphereGeom, material));
		}

		private function onEnterFrame(event : Event) : void
		{
			view.render();
		}
	}
}
