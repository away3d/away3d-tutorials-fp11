package tut02
{
	import away3d.textures.Texture2DBase;

	import away3d.materials.MaterialBase;

	public class TrivialTextureMaterial extends MaterialBase
	{
		public function TrivialTextureMaterial(texture : Texture2DBase)
		{
			// pick either of these, which shows a different approach in cleaning up render state
//			addPass(new TrivialTexturePass(texture));
			addPass(new TrivialTexturePass_Alternative(texture));
		}
	}
}
