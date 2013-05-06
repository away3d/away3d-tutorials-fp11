package tut01
{
	import away3d.arcane;
	import away3d.cameras.Camera3D;
	import away3d.core.base.IRenderable;
	import away3d.core.managers.Stage3DProxy;
	import away3d.materials.passes.MaterialPassBase;

	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.geom.Matrix3D;

	use namespace arcane;

	/**
	 * TrivialColorPass is a pass rendering a flat unshaded colour
	 */
	public class TrivialColorPass extends MaterialPassBase
	{
		private var _fragmentData : Vector.<Number>;
		private var _matrix : Matrix3D = new Matrix3D();

		private var _color : uint;

		public function TrivialColorPass()
		{
			super();

			_fragmentData = new Vector.<Number>();
			color = 0xffff00ff;	// purple by default
		}


		public function get color() : uint
		{
			return _color;
		}

		public function set color(value : uint) : void
		{
			_color = value;
			_fragmentData[0] = ((value >> 16) & 0xff) / 0xff;	// red
			_fragmentData[1] = ((value >> 8) & 0xff) / 0xff;	// green
			_fragmentData[2] = (value & 0xff) / 0xff;			// blue
			_fragmentData[3] = ((value >> 24) & 0xff) / 0xff;	// alpha
		}

		/**
		 * Get the vertex shader code for this shader
		 */
		override arcane function getVertexCode() : String
		{
			// simply transform to view space
			return "m44 op, va0, vc0";
		}

		/**
		 * Get the fragment shader code for this shader
		 * @param fragmentAnimatorCode Any additional fragment animation code imposed by the framework, used by some animators. Ignore this for now, since we're not using them.
		 */
		override arcane function getFragmentCode(fragmentAnimatorCode : String) : String
		{
			// simply set colour as output value
			return "mov oc, fc0";
		}

		/**
		 * Sets the render state which is constant for this pass
		 * @param stage3DProxy The stage3DProxy used for the current render pass
		 * @param camera The camera currently used for rendering
		 */
		override arcane function activate(stage3DProxy : Stage3DProxy, camera : Camera3D) : void
		{
			super.activate(stage3DProxy, camera);
			stage3DProxy._context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, _fragmentData, 1);
		}

		/**
		 * Set render state for the current renderable and draw the triangles.
		 * @param renderable The renderable that needs to be drawn.
		 * @param stage3DProxy The stage3DProxy used for the current render pass.
		 * @param camera The camera currently used for rendering.
		 * @param viewProjection The matrix that transforms world space to screen space.
		 */
		override arcane function render(renderable : IRenderable, stage3DProxy : Stage3DProxy, camera : Camera3D, viewProjection : Matrix3D) : void
		{
			var context : Context3D = stage3DProxy._context3D;
			_matrix.copyFrom(renderable.sceneTransform);
			_matrix.append(viewProjection);
			renderable.activateVertexBuffer(0, stage3DProxy);
			context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, _matrix, true);
			context.drawTriangles(renderable.getIndexBuffer(stage3DProxy), 0, renderable.numTriangles);
		}

		/**
		 * Clear render state for the next pass.
		 * @param stage3DProxy The stage3DProxy used for the current render pass.
		 */
		override arcane function deactivate(stage3DProxy : Stage3DProxy) : void
		{
			// just go for default behaviour
			super.deactivate(stage3DProxy);
		}
	}
}
