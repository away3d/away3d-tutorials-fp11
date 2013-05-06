package tut01
{
	import away3d.materials.MaterialBase;

	public class TrivialColorMaterial extends MaterialBase
	{
		public function TrivialColorMaterial()
		{
			addPass(new TrivialColorPass());
		}
	}
}
