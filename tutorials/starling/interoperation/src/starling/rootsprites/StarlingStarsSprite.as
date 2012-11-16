/* 
Framework Integration Example

Starling scene used in the framework integration examples.

Code by Greg Caldwell
greg@geepers.co.uk
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
package starling.rootsprites{
	import starling.core.Starling;
	import starling.extensions.PDParticleSystem;
	import starling.extensions.ParticleSystem;
	import starling.textures.Texture;
	import starling.display.Sprite;

	public class StarlingStarsSprite extends Sprite
	{
		// Starling Particle assets
		[Embed(source="../../../embeds/stars.pex", mimeType="application/octet-stream")]
		private static const StarsConfig:Class;
		
		[Embed(source = "../../../embeds/stars.png")]
		private static const StarsParticle:Class;
		
		private static var _instance:StarlingStarsSprite;
		
		private var mParticleSystem:ParticleSystem;
		
		public static function getInstance():StarlingStarsSprite
		{
			return _instance;
		}

		public function StarlingStarsSprite()
		{
			_instance = this;
			
			var psConfig:XML = XML(new StarsConfig());
			var psTexture:Texture = Texture.fromBitmap(new StarsParticle());

			mParticleSystem = new PDParticleSystem(psConfig, psTexture);
			mParticleSystem.emitterX = 400;
			mParticleSystem.emitterY = 300;
			mParticleSystem.maxCapacity = 100;
			mParticleSystem.emissionRate = 50;
			this.addChild(mParticleSystem);

			Starling.juggler.add(mParticleSystem);
			
			mParticleSystem.start();
		}
	}
}
