package com.controls.advancedDataGridClasses
{

  public class MergeAdvancedDataGridColumn extends AdvancedDataGridColumn
  {
    public function MergeAdvancedDataGridColumn(columnName:String=null)
    {
      super(columnName);
    }

    private var _verticalMerge:Boolean = false;

    [Inspectable(enumeration="true,false", defaultValue="false")]
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