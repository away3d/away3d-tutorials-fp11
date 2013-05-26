package tut03
{
	import away3d.arcane;
	import away3d.cameras.Camera3D;
	import away3d.core.base.IRenderable;
	import away3d.core.managers.Stage3DProxy;
	import away3d.lights.DirectionalLight;
	import away3d.materials.passes.MaterialPassBase;
	import away3d.textures.Texture2DBase;

	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;

	use namespace arcane;

	/**
	 * SingleLightTexturePass is a pass rendering a texture material using a single directional light
	 */
	public class SingleLightTexturePass extends MaterialPassBase
	{
		private var _matrix : Matrix3D = new Matrix3D();
		private var _fragmentData : Vector.<Number> = new <Number>[0, 0, 0, 0];

		private var _texture : Texture2DBase;

		public function SingleLightTexturePass(texture : Texture2DBase)
		{
			super();
			_texture = texture;

			// tell the material how many resources are used so it will know which to clear when switching passes.
			_numUsedStreams = 3;	// vertex position, uv coords and normals
			_numUsedTextures = 1;	// a single texture
		}


		public function get texture() : Texture2DBase
		{
			return _texture;
		}

		public function set texture(value : Texture2DBase) : void
		{
			_texture = value;
		}

		/**
		 * Get the vertex shader code for this shader
		 */
		override arcane function getVertexCode() : String
		{
			return  "m44 op, va0, vc0\n" +	// transform to view space
					"mov v0, va1\n" +		// pass on uv coords
					"mov v1, va2"			// pass on normals
		}

		/**
		 * Get the fragment shader code for this shader
		 * @param fragmentAnimatorCode Any additional fragment animation code imposed by the framework, used by some animators. Ignore this for now, since we're not using them.
		 */
		override arcane function getFragmentCode(fragmentAnimatorCode : String) : String
		{
			return 	"tex ft0, v0, fs0 <2d, clamp, linear, miplinear>\n" +
					"nrm ft1.xyz, v1\n" + 				// renormalize interpolated normal
					"dp3 ft2.x, fc0.xyz, ft1.xyz\n" +	// standard dot3 lambert shading: d = max(0, dot3(light, normal))
					"max ft2.x, ft2.x, fc0.w\n" +		// fc0.w contains 0
					"mul oc, ft0, ft2.x";
		}

		/**
		 * Sets the render state which is constant for this pass
		 * @param stage3DProxy The stage3DProxy used for the current render pass
		 * @param camera The camera currently used for rendering
		 */
		override arcane function activate(stage3DProxy : Stage3DProxy, camera : Camera3D) : void
		{
			super.activate(stage3DProxy, camera);

			// retrieve the actual texture object, and assign it to slot 0 (fs0)
			// we set this in activate, not in render, because the texture is constant for this pass
			stage3DProxy._context3D.setTextureAt(0, _texture.getTextureForStage3D(stage3DProxy));
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

			// expect a directional light to be assigned
			var light : DirectionalLight = _lightPicker.directionalLights[0];

			// the light direction relative to the renderable object (model space)
			var objectSpaceDir : Vector3D = renderable.inverseSceneTransform.transformVector(light.sceneDirection);
			objectSpaceDir.normalize();

			// passing on inverse light direction to simplify shader code (it expects the direction _to_ the light)
			_fragmentData[0] = -objectSpaceDir.x;
			_fragmentData[1] = -objectSpaceDir.y;
			_fragmentData[2] = -objectSpaceDir.z;
			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, _fragmentData, 1);

			// upload the world-view-projection matrix
			_matrix.copyFrom(renderable.sceneTransform);
			_matrix.append(viewProjection);
			context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, _matrix, true);

			renderable.activateVertexBuffer(0, stage3DProxy);
			renderable.activateUVBuffer(1, stage3DProxy);
			renderable.activateVertexNormalBuffer(2, stage3DProxy);

			context.drawTriangles(renderable.getIndexBuffer(stage3DProxy), 0, renderable.numTriangles);
		}
	}
}
