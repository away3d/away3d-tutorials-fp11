package li.materials.globe.src
{

	import away3d.arcane;
	import away3d.containers.ObjectContainer3D;
	import away3d.entities.Mesh;
	import away3d.lights.PointLight;
	import away3d.materials.ColorMaterial;
	import away3d.materials.TextureMaterial;
	import away3d.materials.methods.CompositeDiffuseMethod;
	import away3d.materials.methods.CompositeSpecularMethod;
	import away3d.materials.methods.FresnelSpecularMethod;
	import away3d.materials.methods.MethodVO;
	import away3d.materials.methods.SpecularShadingModel;
	import away3d.materials.utils.ShaderRegisterCache;
	import away3d.materials.utils.ShaderRegisterElement;
	import away3d.primitives.SkyBox;
	import away3d.primitives.SphereGeometry;
	import away3d.textures.BitmapCubeTexture;
	import away3d.textures.BitmapTexture;
	import away3d.utils.Cast;

	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.display.BlendMode;
	import flash.geom.Point;

	import li.base.ListingBase;

	use namespace arcane;

	public class GlobeListing05 extends ListingBase
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

		// Diffuse map for sky.
		[Embed(source="../../../../embeds/globe/cloud_combined_2048.jpg")]
		public static var SkyDiffuse:Class;

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

		private var _earth:ObjectContainer3D;
		private var _atmosphereDiffuseMethod:CompositeDiffuseMethod;
		private var _atmosphereSpecularMethod:CompositeSpecularMethod;

		public function GlobeListing05() {
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

			_earth = new ObjectContainer3D();
			_earth.rotationY = rand( 0, 360 );
			_view.scene.addChild( _earth );

			// Fresnel specular method for earth.
			var groundFresnelSpecular:FresnelSpecularMethod = new FresnelSpecularMethod( true );
			groundFresnelSpecular.fresnelPower = 1;
			groundFresnelSpecular.normalReflectance = 0.1;
			groundFresnelSpecular.shadingModel = SpecularShadingModel.PHONG;

			// Earth material.
			var groundMaterial:TextureMaterial = new TextureMaterial( Cast.bitmapTexture( EarthDiffuse ) );
			groundMaterial.specularMethod = groundFresnelSpecular;
			groundMaterial.normalMap = Cast.bitmapTexture( EarthNormals );
			groundMaterial.specularMap = Cast.bitmapTexture( EarthSpecular );
			groundMaterial.ambientTexture = Cast.bitmapTexture( EarthNight );
			groundMaterial.gloss = 5;
			groundMaterial.specular = 1;
			groundMaterial.ambientColor = 0xFFFFFF;
			groundMaterial.ambient = 1;
			groundMaterial.lightPicker = _lightPicker;

			// Earth geometry.
			var ground:Mesh = new Mesh( new SphereGeometry( 100, 200, 100 ), groundMaterial );
			_earth.addChild( ground );

			// Clouds material.
			var skyBitmap:BitmapData = new BitmapData( 2048, 1024, true, 0xFFFFFFFF );
			skyBitmap.copyChannel( Cast.bitmapData( SkyDiffuse ), skyBitmap.rect, new Point(), BitmapDataChannel.RED, BitmapDataChannel.ALPHA );
			var cloudsMaterial:TextureMaterial = new TextureMaterial( new BitmapTexture( skyBitmap ) );
			cloudsMaterial.alphaBlending = true;
			cloudsMaterial.lightPicker = _lightPicker;
			cloudsMaterial.specular = 0;
			cloudsMaterial.ambientColor = 0x1b2048;
			cloudsMaterial.ambient = 1;

			// Clouds geometry.
			var clouds:Mesh = new Mesh( new SphereGeometry( 102, 200, 100 ), cloudsMaterial );
			_earth.addChild( clouds );

			// Atmosphere material.
			_atmosphereDiffuseMethod = new CompositeDiffuseMethod( modulateDiffuseMethod );
			_atmosphereSpecularMethod = new CompositeSpecularMethod( modulateSpecularMethod );
			_atmosphereSpecularMethod.shadingModel = SpecularShadingModel.PHONG;
			var atmosphereMaterial:ColorMaterial = new ColorMaterial( 0x1671cc );
			atmosphereMaterial.diffuseMethod = _atmosphereDiffuseMethod;
			atmosphereMaterial.specularMethod = _atmosphereSpecularMethod;
			atmosphereMaterial.blendMode = BlendMode.ADD;
			atmosphereMaterial.lightPicker = _lightPicker;
			atmosphereMaterial.specular = 0.5;
			atmosphereMaterial.gloss = 5;
			atmosphereMaterial.ambientColor = 0x0;
			atmosphereMaterial.ambient = 1;

			// Atmosphere geometry.
			var atmosphere:Mesh = new Mesh( new SphereGeometry( 110, 200, 100 ), atmosphereMaterial );
			atmosphere.scaleX = -1;
			_view.scene.addChild( atmosphere );

		}

		private function modulateDiffuseMethod( vo:MethodVO, t:ShaderRegisterElement, regCache:ShaderRegisterCache ):String {
			var viewDirFragmentReg:ShaderRegisterElement = _atmosphereDiffuseMethod.viewDirFragmentReg;
			var normalFragmentReg:ShaderRegisterElement = _atmosphereSpecularMethod.normalFragmentReg;
			var code:String = "dp3 " + t + ".w, " + viewDirFragmentReg + ".xyz, " + normalFragmentReg + ".xyz\n" +
					"mul " + t + ".w, " + t + ".w, " + t + ".w\n";
			return code;
		}

		private function modulateSpecularMethod( vo:MethodVO, t:ShaderRegisterElement, regCache:ShaderRegisterCache ):String {
			var viewDirFragmentReg:ShaderRegisterElement = _atmosphereDiffuseMethod.viewDirFragmentReg;
			var normalFragmentReg:ShaderRegisterElement = _atmosphereDiffuseMethod.normalFragmentReg;
			var temp:ShaderRegisterElement = regCache.getFreeFragmentSingleTemp();
			regCache.addFragmentTempUsages( temp, 1 );
			var code:String = "dp3 " + temp + ", " + viewDirFragmentReg + ".xyz, " + normalFragmentReg + ".xyz\n" +
					"neg" + temp + ", " + temp + "\n" +
					"mul " + t + ".w, " + t + ".w, " + temp + "\n";
			regCache.removeFragmentTempUsage( temp );
			return code;
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
			return (max - min) * Math.random() + min;
		}
	}
}
