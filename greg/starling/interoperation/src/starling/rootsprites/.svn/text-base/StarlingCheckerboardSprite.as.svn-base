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
package
starling.rootsprites{
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.textures.Texture;

	public class StarlingCheckerboardSprite extends Sprite
	{		
		private static var _instance : StarlingCheckerboardSprite;
		
		private var container : Sprite;
		
		public static function getInstance():StarlingCheckerboardSprite
		{
			return _instance;
		}

		public function StarlingCheckerboardSprite()
		{
			_instance = this;
			
			// Draw the checkerboard pattern to a bitmap data - using a flash Sprite gradien
			var m:Matrix = new Matrix();
			m.createGradientBox(512, 512, 0, 0, 0);
			
			// Create gradient background
			var fS:flash.display.Sprite = new flash.display.Sprite();
			fS.graphics.beginGradientFill(GradientType.RADIAL, [ 0xaa0000, 0x00bb00 ], [ 1, 1 ], [ 0, 255 ], m);
			fS.graphics.drawRect(0, 0, 512, 512);
			fS.graphics.endFill();
			
			// Draw the gradient to the bitmap data
			var checkers:BitmapData = new BitmapData(512, 512, true, 0x0);
			checkers.draw(fS);
			
			// Create the holes in the board (bitmap data)
			for (var yP:int = 0; yP < 16; yP++) {
				for (var xP:int = 0; xP < 16; xP++) {
					if ((yP + xP) % 2 == 0) {
						checkers.fillRect(new Rectangle(xP * 32, yP * 32, 32, 32), 0x0);
					}
				}
			}
			
			// Create the Starling texture from the bitmapdata
			var checkerTx:Texture = Texture.fromBitmapData(checkers);
			
			// Create a sprite and add an image using the checker texture
			// Assign the pivot point in the centre of the sprite
			container = new Sprite();
			container.pivotX = container.pivotY = 256;
			container.x = 400;
			container.y = 300;
			container.scaleX = container.scaleY = 2;
			
			
			container.addChild(new Image(checkerTx));			
			// Add the container sprite to the Starling stage
			addChild(container);
		}
		
		public function update() : void 
		{
			container.rotation += 0.005;
		}
	}
}
