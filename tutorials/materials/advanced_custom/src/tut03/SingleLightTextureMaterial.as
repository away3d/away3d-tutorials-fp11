package tut03
{
	import away3d.textures.Texture2DBase;

	import away3d.materials.MaterialBase;

	public class SingleLightTextureMaterial extends MaterialBase
	{
		public function SingleLightTextureMaterial(texture : Texture2DBase)
		{
			addPass(new SingleLightTexturePass(texture));
		}
	}
}
