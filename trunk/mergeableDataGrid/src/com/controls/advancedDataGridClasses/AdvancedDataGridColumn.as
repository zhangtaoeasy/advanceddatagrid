package com.controls.advancedDataGridClasses
{
	import mx.controls.advancedDataGridClasses.AdvancedDataGridColumn;

	public class AdvancedDataGridColumn extends mx.controls.advancedDataGridClasses.AdvancedDataGridColumn
	{
		public function AdvancedDataGridColumn(columnName:String=null)
		{
			super(columnName);
		}
		
		public var _verticalMerge:Boolean = false;
		
		public function set verticalMerge(value:Boolean):void
		{
			_verticalMerge = value;
		}
		
		public function get verticalMerge():Boolean
		{
			return _verticalMerge;
		}		
	}
}