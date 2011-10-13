package a3dparticle.animators.actions 
{
	import away3d.core.base.IRenderable;
	import away3d.core.managers.Stage3DProxy;
	import away3d.materials.passes.MaterialPassBase;
	import away3d.materials.utils.ShaderRegisterElement;
	import flash.display3D.Context3DVertexBufferFormat;
	
	import away3d.arcane;
	use namespace arcane;
	
	/**
	 * ...
	 * @author ...
	 */
	public class TimeAction extends PerParticleAction
	{
		private var _startTimeFun:Function;
		private var _endTimeFun:Function;
		
		private var _tempStartTime:Number;
		private var _tempEndTime:Number;
		
		
		private var timeAtt:ShaderRegisterElement;
		
		private var hasEndTime:Boolean;
		
		private var _loop:Boolean;
		
		public function TimeAction() 
		{
			priority = 0;
			dataLenght = 2;
		}
		
		public function set startTimeFun(fun:Function):void
		{
			_startTimeFun = fun;
		}
		
		public function set endTimeFun(fun:Function):void
		{
			_endTimeFun = fun;
			hasEndTime = true;
		}
		
		public function set loop(value:Boolean):void
		{
			_loop = value;
			if (value)
			{
				hasEndTime = true;
			}
		}
		
		override public function genOne(index:uint):void
		{
			_tempStartTime = 0;
			if (_startTimeFun != null)
			{
				_tempStartTime = _startTimeFun(index);
			}
			_tempEndTime = 1000;
			if (_endTimeFun != null)
			{
				_tempEndTime = _endTimeFun(index);
			}
		}
		
		override public function distributeOne(index:int, verticeIndex:uint):void
		{
			_vertices.push(_tempStartTime);
			_vertices.push(_tempEndTime);
		}
		
		override public function getAGALVertexCode(pass : MaterialPassBase) : String
		{
			timeAtt = shaderRegisterCache.getFreeVertexAttribute();//timeAtt.x is start，timeAtt.y is during time
			
			var code:String = "";
			code += "sub " + _animation.vertexTime.toString() + "," + _animation.timeConst.toString() + ".x," + timeAtt.toString() + ".x\n";
			code += "max " + _animation.vertexTime.toString() + "," + _animation.zeroConst.toString() + "," +  _animation.vertexTime.toString() + "\n";
			if (hasEndTime)
			{
				if (_loop)
				{
					var div:ShaderRegisterElement = shaderRegisterCache.getFreeVertexVectorTemp();
					code += "div " + div.toString() + ".xyz," + _animation.vertexTime.toString() + "," + timeAtt.toString() + ".y\n";
					code += "frc " + div.toString() + ".xyz," + div.toString() + ".xyz\n";
					code += "mul " + _animation.vertexTime.toString() + "," +div.toString() + ".xyz," + timeAtt.toString() + ".y\n";
				}
				else
				{
					var sge:ShaderRegisterElement = shaderRegisterCache.getFreeVertexVectorTemp();
					code += "sge " + sge.toString() + ".x," +  timeAtt.toString() + ".y," + _animation.vertexTime.toString() + "\n";
					code += "mul " + _animation.vertexTime.toString() + "," +sge.toString() + ".x," + _animation.vertexTime.toString() + "\n";
				}
			}
			code += "div " + _animation.vertexLife.toString() + "," + _animation.vertexTime.toString() + "," + timeAtt.toString() + ".y\n";
			code += "mov " + _animation.fragmentTime.toString() + "," + _animation.vertexTime.toString() +"\n";
			code += "mov " + _animation.fragmentLife.toString() + "," + _animation.vertexLife.toString() +"\n";
			return code;
		}
		
		override public function setRenderState(stage3DProxy : Stage3DProxy, pass : MaterialPassBase, renderable : IRenderable) : void
		{
			stage3DProxy.setSimpleVertexBuffer(timeAtt.index, getVertexBuffer(stage3DProxy), Context3DVertexBufferFormat.FLOAT_2);
		}
		
	}

}