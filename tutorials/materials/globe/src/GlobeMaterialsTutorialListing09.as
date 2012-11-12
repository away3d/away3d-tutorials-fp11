package tutorials.materials.globe.src
{

	import away3d.arcane;
	import away3d.containers.ObjectContainer3D;
	import away3d.entities.Mesh;
	import away3d.entities.Sprite3D;
	import away3d.filters.BloomFilter3D;
	import away3d.lights.PointLight;
	import away3d.materials.ColorMaterial;
	import away3d.materials.TextureMaterial;
	import away3d.materials.methods.CompositeDiffuseMethod;
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
	import flash.geom.Vector3D;

	use namespace arcane;

	public class GlobeMaterialsTutorialListing09 extends GlobeMaterialsTutorialListingBase
	{
		// Diffuse map for the Earth's surface.
		[Embed(source="../../../../embeds/solar/earth_diffuse.jpg")]
		public static var EarthSurfaceDiffuse:Class;

		// Diffuse map for the Moon's surface.
		[Embed(source="../../../../embeds/solar/moon.jpg")]
		public static var MoonSurfaceDiffuse:Class;

		// Normal map for globe.
		[Embed(source="../../../../embeds/solar/earth_normals.png")]
		public static var EarthSurfaceNormals:Class;

		// Specular map for globe.
		[Embed(source="../../../../embeds/solar/earth_specular.jpg")]
		public static var EarthSurfaceSpecular:Class;

		// Night diffuse map for globe.
		[Embed(source="../../../../embeds/solar/earth_ambient.jpg")]
		public static var EarthSurfaceNight:Class;

		// Diffuse map for clouds.
		[Embed(source="../../../../embeds/solar/earth_clouds.jpg")]
		public static var EarthSkyDiffuse:Class;

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

		// Star texture.
		[Embed(source="../../../../embeds/solar/star.jpg")]
		private var StarTexture:Class;

		// Sun texture.
		[Embed(source="../../../../embeds/solar/sun.jpg")]
		private var SunTexture:Class;

		// Lens flare.
		[Embed(source="../../../../embeds/lensflare/flare0.jpg")]
		private var Flare0:Class;
		[Embed(source="../../../../embeds/lensflare/flare1.jpg")]
		private var Flare1:Class;
		[Embed(source="../../../../embeds/lensflare/flare2.jpg")]
		private var Flare2:Class;
		[Embed(source="../../../../embeds/lensflare/flare3.jpg")]
		private var Flare3:Class;
		[Embed(source="../../../../embeds/lensflare/flare4.jpg")]
		private var Flare4:Class;
		[Embed(source="../../../../embeds/lensflare/flare5.jpg")]
		private var Flare5:Class;
		[Embed(source="../../../../embeds/lensflare/flare6.jpg")]
		private var Flare6:Class;
		[Embed(source="../../../../embeds/lensflare/flare7.jpg")]
		private var Flare7:Class;
		[Embed(source="../../../../embeds/lensflare/flare8.jpg")]
		private var Flare8:Class;
		[Embed(source="../../../../embeds/lensflare/flare9.jpg")]
		private var Flare9:Class;
		[Embed(source="../../../../embeds/lensflare/flare10.jpg")]
		private var Flare10:Class;
		[Embed(source="../../../../embeds/lensflare/flare11.jpg")]
		private var Flare11:Class;
		[Embed(source="../../../../embeds/lensflare/flare12.jpg")]
		private var Flare12:Class;

		private var _earth:ObjectContainer3D;
		private var _earthClouds:Mesh;
		private var _moon:ObjectContainer3D;
		private var _sun:Sprite3D;
		private var _atmosphereDiffuseMethod:CompositeDiffuseMethod;
		private var _bloomFilter:BloomFilter3D;
		private var _flares:Vector.<FlareObject> = new Vector.<FlareObject>();
		private var _flareVisible:Boolean;

		public function GlobeMaterialsTutorialListing09() {
			super();
		}

		override protected function onSetup():void {
			createSun();
			createEarth();
			createMoon();
			createDeepSpace();
			createStarField();
		}

		private function createSun():void {
			// Light object.
			var light:PointLight = new PointLight();
			light.diffuse = 2;
			_lightPicker.lights = [ light ];
			// Material.
			var bitmapData:BitmapData = blackToTransparent( Cast.bitmapData( SunTexture ) );
			var sunMaterial:TextureMaterial = new TextureMaterial( new BitmapTexture( bitmapData ) );
			sunMaterial.alphaBlending = true;
			// Geometry.
			_sun = new Sprite3D( sunMaterial, 5000, 5000 );
			_sun.x = light.x = 10000;
			_view.scene.addChild( _sun );
			// Bloom effect.
			_bloomFilter = new BloomFilter3D( 2, 2, 0.5, 0, 4 );
			_view.filters3d = [ _bloomFilter ];
			// Initialize flares.
			_flares.push( new FlareObject( new Flare10(), 3.2, -0.01, 147.9 ) );
			_flares.push( new FlareObject( new Flare11(), 6, 0, 30.6 ) );
			_flares.push( new FlareObject( new Flare7(), 2, 0, 25.5 ) );
			_flares.push( new FlareObject( new Flare7(), 4, 0, 17.85 ) );
			_flares.push( new FlareObject( new Flare12(), 0.4, 0.32, 22.95 ) );
			_flares.push( new FlareObject( new Flare6(), 1, 0.68, 20.4 ) );
			_flares.push( new FlareObject( new Flare2(), 1.25, 1.1, 48.45 ) );
			_flares.push( new FlareObject( new Flare3(), 1.75, 1.37, 7.65 ) );
			_flares.push( new FlareObject( new Flare4(), 2.75, 1.85, 12.75 ) );
			_flares.push( new FlareObject( new Flare8(), 0.5, 2.21, 33.15 ) );
			_flares.push( new FlareObject( new Flare6(), 4, 2.5, 10.4 ) );
			_flares.push( new FlareObject( new Flare7(), 10, 2.66, 50 ) );
		}

		private function createEarth():void {
			// Fresnel specular method for earth surface.
			var earthFresnelSpecularMethod:FresnelSpecularMethod = new FresnelSpecularMethod( true );
			earthFresnelSpecularMethod.fresnelPower = 1;
			earthFresnelSpecularMethod.normalReflectance = 0.1;
			earthFresnelSpecularMethod.shadingModel = SpecularShadingModel.PHONG;
			// Material for earth surface.
			var earthSurfaceMaterial:TextureMaterial = new TextureMaterial( Cast.bitmapTexture( EarthSurfaceDiffuse ) );
			earthSurfaceMaterial.specularMethod = earthFresnelSpecularMethod;
			earthSurfaceMaterial.normalMap = Cast.bitmapTexture( EarthSurfaceNormals );
			earthSurfaceMaterial.specularMap = Cast.bitmapTexture( EarthSurfaceSpecular );
			earthSurfaceMaterial.ambientTexture = Cast.bitmapTexture( EarthSurfaceNight );
			earthSurfaceMaterial.gloss = 5;
			earthSurfaceMaterial.lightPicker = _lightPicker;
			// Material for sky.
			var bitmapData:BitmapData = blackToTransparent( Cast.bitmapData( EarthSkyDiffuse ) );
			var earthCloudMaterial:TextureMaterial = new TextureMaterial( new BitmapTexture( bitmapData ) );
			earthCloudMaterial.alphaBlending = true;
			earthCloudMaterial.lightPicker = _lightPicker;
			earthCloudMaterial.specular = 0;
			// Material for atmosphere.
			_atmosphereDiffuseMethod =  new CompositeDiffuseMethod( modulateDiffuseMethod );
			var atmosphereMaterial:ColorMaterial = new ColorMaterial( 0x1671cc );
			atmosphereMaterial.diffuseMethod = _atmosphereDiffuseMethod;
			atmosphereMaterial.blendMode = BlendMode.ADD;
			atmosphereMaterial.lightPicker = _lightPicker;
			atmosphereMaterial.gloss = 5;
			atmosphereMaterial.specular = 0;
			// Container.
			_earth = new ObjectContainer3D();
			_earth.rotationY = rand( 0, 360 );
			_view.scene.addChild( _earth );
			// Earth surface geometry.
			var earthSurface:Mesh = new Mesh( new SphereGeometry( 100, 200, 100 ), earthSurfaceMaterial );
			_earth.addChild( earthSurface );
			// Earth cloud geometry.
			_earthClouds = new Mesh( new SphereGeometry( 101, 200, 100 ), earthCloudMaterial );
			_earth.addChild( _earthClouds );
			// Earth atmosphere geometry.
			var earthAtmosphere:Mesh = new Mesh( new SphereGeometry( 115, 200, 100 ), atmosphereMaterial );
			earthAtmosphere.scaleX = -1;
			_earth.addChild( earthAtmosphere );
		}

		private function modulateDiffuseMethod( vo:MethodVO, t:ShaderRegisterElement, regCache:ShaderRegisterCache ):String {
			var viewDirFragmentReg:ShaderRegisterElement = _atmosphereDiffuseMethod.viewDirFragmentReg;
			var normalFragmentReg:ShaderRegisterElement = _atmosphereDiffuseMethod.normalFragmentReg;
			var temp:ShaderRegisterElement = regCache.getFreeFragmentSingleTemp();
			regCache.addFragmentTempUsages( temp, 1 );
			var code:String = "dp3 " + temp + ", " + viewDirFragmentReg + ".xyz, " + normalFragmentReg + ".xyz\n" +
					"mul " + temp + ", " + temp + ", " + temp + "\n" +
					"mul " + t + ".w, " + t + ".w, " + temp + "\n";
			regCache.removeFragmentTempUsage( temp );
			return code;
		}

		private function createMoon():void {
			// Fresnel specular method for moon.
			var moonFresnelSpecularMethod:FresnelSpecularMethod = new FresnelSpecularMethod( true );
			moonFresnelSpecularMethod.fresnelPower = 1;
			moonFresnelSpecularMethod.normalReflectance = 0.1;
			moonFresnelSpecularMethod.shadingModel = SpecularShadingModel.PHONG;
			// Material.
			var moonMaterial:TextureMaterial = new TextureMaterial( Cast.bitmapTexture( MoonSurfaceDiffuse ) );
			moonMaterial.specularMethod = moonFresnelSpecularMethod;
			moonMaterial.gloss = 5;
			moonMaterial.ambient = 0.25;
			moonMaterial.specular = 0.5;
			moonMaterial.lightPicker = _lightPicker;
			// Container.
			_moon = new ObjectContainer3D();
			_moon.rotationY = rand( 0, 360 );
			_view.scene.addChild( _moon );
			// Surface geometry.
			var moonSurface:Mesh = new Mesh( new SphereGeometry( 50, 200, 100 ), moonMaterial );
			moonSurface.x = 1000;
			_moon.addChild( moonSurface );
		}

		private function createStarField():void {
			// Define material to be shared by all stars.
			var bitmapData:BitmapData = blackToTransparent( Cast.bitmapData( StarTexture ) );
			var starMaterial:TextureMaterial = new TextureMaterial( new BitmapTexture( bitmapData ) );
			starMaterial.alphaBlending = true;
			for( var i:uint = 0; i < 500; i++ ) {
				// Define unique star.
				var star:Sprite3D = new Sprite3D( starMaterial, 150, 150 );
				_view.scene.addChild( star );
				// Randomly position in spherical coordinates.
				var radius:Number = rand( 2000, 15000 );
				var elevation:Number = rand( -Math.PI, Math.PI );
				var azimuth:Number = rand( -Math.PI, Math.PI );
				// Spherical to cartesian.
				star.x = radius * Math.cos( elevation ) * Math.sin( azimuth );
				star.y = radius * Math.sin( elevation );
				star.z = radius * Math.cos( elevation ) * Math.cos( azimuth );
			}
		}

		private function createDeepSpace():void {
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
			updateBloom();
			updateFlares();
			_earth.rotationY += 0.05;
			_earthClouds.rotationY += 0.01;
			_moon.rotationY -= 0.005;
		}

		private function updateBloom():void {
			// Evaluate alignment with the sun.
			var pos:Vector3D = _view.camera.position.clone();
			pos.normalize();
			var proj:Number = -pos.dotProduct( Vector3D.X_AXIS );
			if( proj < 0 ) proj = 0;
			proj = Math.pow( proj, 12 );
			// Use value to update bloom strength and sun size.
			_bloomFilter.exposure = 10 * proj;
			_sun.scaleX = _sun.scaleY = _sun.scaleZ = 1 + proj;
		}

		private function updateFlares():void {
			// Evaluate flare visibility.
			var sunScreenPosition:Vector3D = _view.project( _sun.scenePosition );
			var xOffset:Number = sunScreenPosition.x - _view.width / 2;
			var yOffset:Number = sunScreenPosition.y - _view.height / 2;
			var earthScreenPosition:Vector3D = _view.project( _earth.scenePosition );
			var earthRadius:Number = 80 * _view.height / earthScreenPosition.z;
			var flareVisibleOld:Boolean = _flareVisible;
			var sunInView:Boolean = sunScreenPosition.x > 0 && sunScreenPosition.x < _view.width && sunScreenPosition.y > 0 && sunScreenPosition.y < _view.height && sunScreenPosition.z > 0;
			var sunOccludedByEarth:Boolean = Math.sqrt( xOffset * xOffset + yOffset * yOffset ) < earthRadius;
			_flareVisible = sunInView && !sunOccludedByEarth;
			// Update flare visibility.
			var flareObject:FlareObject;
			if( _flareVisible != flareVisibleOld ) {
				for each ( flareObject in _flares ) {
					if( _flareVisible )
						addChild( flareObject.sprite );
					else
						removeChild( flareObject.sprite );
				}
			}
			// Update flare position.
			if( _flareVisible ) {
				var flareDirection:Point = new Point( xOffset, yOffset );
				for each ( flareObject in _flares ) {
					flareObject.sprite.x = sunScreenPosition.x - flareDirection.x * flareObject.position - flareObject.sprite.width / 2;
					flareObject.sprite.y = sunScreenPosition.y - flareDirection.y * flareObject.position - flareObject.sprite.height / 2;
				}
			}
		}

		private function rand( min:Number, max:Number ):Number {
		    return (max - min)*Math.random() + min;
		}

		private function blackToTransparent( original:BitmapData ):BitmapData {
			var bmd:BitmapData = new BitmapData( original.width, original.height, true, 0xFFFFFFFF );
			bmd.copyChannel( original, bmd.rect, new Point(), BitmapDataChannel.RED, BitmapDataChannel.ALPHA );
			return bmd;
		}
	}
}

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.BitmapDataChannel;
import flash.geom.Point;

class FlareObject
{
	public var sprite:Bitmap;
	public var size:Number;
	public var position:Number;
	public var opacity:Number;

	private const FLARE_SIZE:Number = 144;

	public function FlareObject( sprite:Bitmap, size:Number, position:Number, opacity:Number ) {
		this.sprite = new Bitmap( new BitmapData( sprite.bitmapData.width, sprite.bitmapData.height, true, 0xFFFFFFFF ) );
		this.sprite.bitmapData.copyChannel( sprite.bitmapData, sprite.bitmapData.rect, new Point(), BitmapDataChannel.RED, BitmapDataChannel.ALPHA );
		this.sprite.alpha = opacity / 100;
		this.sprite.smoothing = true;
		this.sprite.scaleX = this.sprite.scaleY = size * FLARE_SIZE / sprite.width;
		this.size = size;
		this.position = position;
		this.opacity = opacity;
	}
}