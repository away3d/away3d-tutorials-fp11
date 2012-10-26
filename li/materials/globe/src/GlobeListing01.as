package li.materials.globe.src
{

	import away3d.entities.Mesh;
	import away3d.lights.PointLight;
	import away3d.materials.ColorMaterial;
	import away3d.materials.TextureMaterial;
	import away3d.primitives.SphereGeometry;
	import away3d.utils.Cast;

	import li.base.ListingBase;

	public class GlobeListing01 extends ListingBase
	{
		// Diffuse map for globe.
		[Embed(source="../../../../embeds/globe/land_ocean_ice_2048_match.jpg")]
		public static var EarthDiffuse:Class;

		private var _earth:Mesh;

		public function GlobeListing01() {
			super();
		}

		override protected function onSetup():void {

			// View settings.
			_view.camera.lens.far = 12000;

			createSun();
			createEarth();
			createStarField();
		}

		private function createStarField():void {
			// Define geometry and material to be shared by all stars.
			var starGeometry:SphereGeometry = new SphereGeometry( 5, 4, 3 );
			var starMaterial:ColorMaterial = new ColorMaterial( 0xFFFFFF );
			for( var i:uint = 0; i < 500; i++ ) {
				// Define unique star mesh that uses shared stuff.
				var starMesh:Mesh = new Mesh( starGeometry, starMaterial );
				_view.scene.addChild( starMesh );
				// Randomly position in spherical coordinates.
				var radius:Number = rand( 500, 10000 );
				var elevation:Number = rand( -Math.PI, Math.PI );
				var azimuth:Number = rand( -Math.PI, Math.PI );
				// Spherical to cartesian.
				starMesh.x = radius * Math.cos( elevation ) * Math.sin( azimuth );
				starMesh.y = radius * Math.sin( elevation );
				starMesh.z = radius * Math.cos( elevation ) * Math.cos( azimuth );
			}
		}

		private function createSun():void {

			// Light object.
			var light:PointLight = new PointLight();
			light.x = 10000;
			_lightPicker.lights = [ light ];

			// Geometry.
			var sun:Mesh = new Mesh( new SphereGeometry( 500 ), new ColorMaterial( 0xFFFFFF ) );
			sun.x = 10000;
			_view.scene.addChild( sun );
		}

		private function createEarth():void {

			// Material.
			var earthMaterial:TextureMaterial = new TextureMaterial( Cast.bitmapTexture( EarthDiffuse ) );
			earthMaterial.lightPicker = _lightPicker;

			// Geometry.
			_earth = new Mesh( new SphereGeometry( 100, 200, 100 ), earthMaterial );
			_earth.rotationY = rand( 0, 360 );
			_view.scene.addChild( _earth );
		}

		override protected function onUpdate():void {
			super.onUpdate();
			_earth.rotationY += 0.1;
		}

		private function rand( min:Number, max:Number ):Number {
			return (max - min)*Math.random() + min;
		}
	}
}
