package li.materials.globe.src
{

	import away3d.entities.Mesh;
	import away3d.lights.PointLight;
	import away3d.materials.ColorMaterial;
	import away3d.materials.TextureMaterial;
	import away3d.materials.methods.FresnelSpecularMethod;
	import away3d.materials.methods.SpecularShadingModel;
	import away3d.primitives.SkyBox;
	import away3d.primitives.SphereGeometry;
	import away3d.textures.BitmapCubeTexture;
	import away3d.utils.Cast;

	import flash.display.BitmapData;
	import flash.geom.ColorTransform;

	import li.base.ListingBase;

	public class GlobeListing03 extends ListingBase
	{
		// Diffuse map for globe.
		[Embed(source="../../../../embeds/globe/land_ocean_ice_2048_match.jpg")]
		public static var EarthDiffuse:Class;

		// Normal map for globe.
		[Embed(source="../../../../embeds/globe/EarthNormal.png")]
		public static var EarthNormals:Class;

		// Specular map for globe.
		[Embed(source="../../../../embeds/globe/earth_specular_2048.jpg")]
		public static var EarthSpecular:Class;

		// Night diffuse map for globe.
		[Embed(source="../../../../embeds/globe/land_lights_16384.jpg")]
    	public static var EarthNight:Class;

		// Skybox textures.
		[Embed(source="../../../../embeds/skybox/space_posX.jpg")]
		private var PosX:Class;
		[Embed(source="../../../../embeds/skybox/space_negX.jpg")]
		private var NegX:Class;
		[Embed(source="../../../../embeds/skybox/space_posY.jpg")]
		private var PosY:Class;
		[Embed(source="../../../../embeds/skybox/space_negY.jpg")]
		private var NegY:Class;
		[Embed(source="../../../../embeds/skybox/space_posZ.jpg")]
		private var PosZ:Class;
		[Embed(source="../../../../embeds/skybox/space_negZ.jpg")]
		private var NegZ:Class;

		private var _earth:Mesh;

		public function GlobeListing03() {
			super();
		}

		override protected function onSetup():void {

			// View settings.
			_view.camera.lens.far = 12000;

			createSun();
			createEarth();
			createSpace();
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
			light.diffuse = 2;
			light.ambient = 1;
			_lightPicker.lights = [ light ];

			// Geometry.
			var sun:Mesh = new Mesh( new SphereGeometry( 500 ), new ColorMaterial( 0xFFFFFF ) );
			sun.x = 10000;
			_view.scene.addChild( sun );
		}

		private function createEarth():void {

			// Fresnel specular method for earth.
			var earthFresnelSpecular:FresnelSpecularMethod = new FresnelSpecularMethod(true);
			earthFresnelSpecular.fresnelPower = 1;
			earthFresnelSpecular.normalReflectance = 0.1;
			earthFresnelSpecular.shadingModel = SpecularShadingModel.PHONG;

			// Material.
			var earthMaterial:TextureMaterial = new TextureMaterial( Cast.bitmapTexture( EarthDiffuse ) );
			earthMaterial.specularMethod = earthFresnelSpecular;
			earthMaterial.normalMap = Cast.bitmapTexture( EarthNormals );
			earthMaterial.specularMap = Cast.bitmapTexture( EarthSpecular );
			earthMaterial.ambientTexture = Cast.bitmapTexture( EarthNight );
			earthMaterial.gloss = 5;
			earthMaterial.specular = 1;
			earthMaterial.ambientColor = 0xFFFFFF;
			earthMaterial.ambient = 1;
			earthMaterial.lightPicker = _lightPicker;

			// Geometry.
			_earth = new Mesh( new SphereGeometry( 100, 200, 100 ), earthMaterial );
			_earth.rotationY = rand( 0, 360 );
			_view.scene.addChild( _earth );
		}

		private function createSpace():void {

			// Cube texture.
			var cubeTexture:BitmapCubeTexture = new BitmapCubeTexture(
					Cast.bitmapData( PosX ), Cast.bitmapData( NegX ),
					Cast.bitmapData( PosY ), Cast.bitmapData( NegY ),
					Cast.bitmapData( PosZ ), Cast.bitmapData( NegZ ) );

			// Skybox geometry.
			var skyBox:SkyBox = new SkyBox( cubeTexture );
			_view.scene.addChild( skyBox );
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
