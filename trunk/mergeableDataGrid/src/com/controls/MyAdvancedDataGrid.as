package com.controls
{
  import com.controls.advancedDataGridClasses.AdvancedDataGrid;
  import com.controls.advancedDataGridClasses.AdvancedDataGridColumnGroup;
  import com.controls.advancedDataGridClasses.AdvancedDataGridItemRendererEx;
  import mx.styles.ISimpleStyleClient;
  import mx.styles.StyleManager;

  import flash.display.DisplayObject;
  import flash.display.Graphics;
  import flash.display.Shape;
  import flash.display.Sprite;
  import flash.events.Event;
  import flash.events.MouseEvent;
  import flash.geom.Point;

  import mx.collections.ArrayCollection;
  import mx.controls.listClasses.IListItemRenderer;
  import mx.core.FlexShape;
  import mx.core.FlexSprite;
  import mx.core.IFlexDisplayObject;
  import mx.core.UIComponent;


  public class MyAdvancedDataGrid extends AdvancedDataGrid
  {

    protected var rowMergeMap:Array;
    protected var colorIndexList:Array;

    /**
     *  @private
     */
    private var displayWidth:Number;

    public function MyAdvancedDataGrid()
    {
      super();

      rowMergeMap = [];

      //super.itemRenderer = new ContextualClassFactory(AdvancedDataGridItemRenderer, moduleFactory);
      setRowMergeMap();
    }

    override protected function drawHighlightIndicator(indicator:Sprite, x:Number, y:Number, width:Number, height:Number, color:uint, itemRenderer:IListItemRenderer):void
    {
      baseDrawIndicator(indicator , x , y , width , height , color , itemRenderer);
    }

    override protected function drawSelectionIndicator(indicator:Sprite, x:Number, y:Number, width:Number, height:Number, color:uint, itemRenderer:IListItemRenderer):void
    {
      baseDrawIndicator(indicator , x , y , width , height , color , itemRenderer);
    }

    private function getRowMergeMapItem(visibleRow:int , visibleCol:int):RowMergeMapItem
    {
      return rowMergeMap[visibleCol][visibleRow];
    }

    private function drawSelectionIndicatorEx(indicator:Sprite, x:Number, y:Number, width:Number, height:Number, color:uint, itemRenderer:IListItemRenderer):void
    {
      if(isRowSelectionMode())
              width = unscaledWidth - viewMetrics.left - viewMetrics.right;

            var g:Graphics = indicator.graphics;
          g.beginFill(color);
          g.drawRect(x , y , width , height);
          g.endFill();

          indicator.x = 0;
          indicator.y = 0;
    }

    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void{
      super.updateDisplayList(unscaledWidth,unscaledHeight);
      if (displayWidth != unscaledWidth - viewMetrics.right - viewMetrics.left)
        {
            displayWidth = unscaledWidth - viewMetrics.right - viewMetrics.left;
        }
      setRowMergeMap();
      verticalItemMerge();
    }


    private function getLockedContent():Sprite
    {
        var locked:Sprite = Sprite(listContent.getChildByName("lockedContent"));
        if (!locked)
        {
            locked = new UIComponent();
            locked.name = "lockedContent";
            locked.cacheAsBitmap = true;
            locked.mouseEnabled = false;
            listContent.addChild(locked);
        }
        listContent.setChildIndex(locked, listContent.numChildren - 1);

        return locked;
    }


    override protected function drawHorizontalSeparators():void
    {
      super.drawHorizontalSeparators();
       // draw horizontalGridlines if needed.
        var lineCol:uint = getStyle("horizontalGridLineColor");

        var lockedContent:Sprite = getLockedContent();

        // draw vertical lines in the locked column area
        var lockedLinesBody:Sprite = Sprite(lockedContent.getChildByName("lockedHorizontalLines"));

        if (lockedLinesBody)
        {
            lockedLinesBody.graphics.clear();

            while (lockedLinesBody.numChildren)
            {
                lockedLinesBody.removeChildAt(0);
            }
        }

        //In case of horizontal lines we don't need to care
        //about column locking a line from 0-displayWidth will do
        if (getStyle("horizontalGridLines")
            || lockedRowCount > 0 && lockedRowCount < listItems.length)
        {
            if (!lockedLinesBody)
            {
                lockedLinesBody = new UIComponent();
                lockedLinesBody.name = "lockedHorizontalLines";
                lockedContent.addChild(lockedLinesBody);
            }

            if (getStyle("horizontalGridLines"))
            {
                for (var i:int = 0; i < listItems.length; i++)
                {
                    drawHorizontalSeparator(lockedLinesBody, i, lineCol, rowInfo[i].y + rowInfo[i].height);
                }
            }
            else
                drawHorizontalSeparator(lockedLinesBody, lockedRowCount - 1 , lineCol, rowInfo[lockedRowCount - 1].y + rowInfo[lockedRowCount - 1].height);
        }
    }

    private function drawHorizontalSeparator(s:Sprite, rowIndex:int, color:uint, y:Number):void
    {
        var useLockedSeparator:Boolean = false;

        if (lockedRowCount > 0 && rowIndex == lockedRowCount - 1)
        {
            useLockedSeparator = true;
        }

        var hSepSkinName:String = "hSeparator" + rowIndex;
        var hLockedSepSkinName:String = "hLockedSeparator" + rowIndex;
        var createThisSkinName:String = useLockedSeparator ? hLockedSepSkinName : hSepSkinName;
        var createThisStyleName:String = useLockedSeparator ? "horizontalLockedSeparatorSkin" : "horizontalSeparatorSkin";

        var sepSkin:IFlexDisplayObject;
        var lockedSepSkin:IFlexDisplayObject;
        var deleteThisSkin:IFlexDisplayObject;
        var createThisSkin:IFlexDisplayObject;

        // Look for separator by name
        sepSkin = IFlexDisplayObject(s.getChildByName(hSepSkinName));
        lockedSepSkin = IFlexDisplayObject(s.getChildByName(hLockedSepSkinName));

        createThisSkin = useLockedSeparator ? lockedSepSkin : sepSkin;
        deleteThisSkin = useLockedSeparator ? sepSkin : lockedSepSkin;

        if (deleteThisSkin)
        {
            s.removeChild(DisplayObject(deleteThisSkin));
            //delete deleteThisSkin;
        }

        if (!createThisSkin)
        {
            var sepSkinClass:Class = Class(getStyle(createThisStyleName));

            if (sepSkinClass)
            {
                createThisSkin = IFlexDisplayObject(new sepSkinClass());
                createThisSkin.name = createThisSkinName;

                var styleableSkin:ISimpleStyleClient = createThisSkin as ISimpleStyleClient;
                if (styleableSkin)
                    styleableSkin.styleName = this;

                s.addChild(DisplayObject(createThisSkin));
            }
        }

        if (createThisSkin)
        {
            var mHeight:Number = !isNaN(createThisSkin.measuredHeight) ? createThisSkin.measuredHeight : 1;
            createThisSkin.setActualSize(displayWidth, mHeight);
            createThisSkin.move(0, y);
        }
        else // If we still don't have a sepSkin, then we have no skin style defined. Use the default function instead
        {
            for each(var item:IListItemRenderer in listItems[rowIndex])
               {
                  MydrawHorizontalLine(s, rowIndex, color, rowInfo[rowIndex].y, item);
               }

            /* for(var index:int=0; index<listItems.length; i++){
                MydrawHorizontalLine(s, rowIndex, color, rowInfo[rowIndex].y, listItems[index]);
            } */
        }
    }


    private function MydrawHorizontalLine(s:Sprite, rowIndex:int, color:uint, y:Number, item:IListItemRenderer = null):void{
      //super.drawHorizontalLine(s,rowIndex,color,y);

      var g:Graphics = s.graphics;

      if(item && y > 0)
      {
        if(rowIndex>0)
        {
          if(item is AdvancedDataGridItemRendererEx)
          {
                if(AdvancedDataGridItemRendererEx(item).text ==
                              AdvancedDataGridItemRendererEx(listItems[rowIndex-1][0]).data[Object(item).listData.dataField.toString()] ){

                }else{
                   g.lineStyle(1, color);
                   g.moveTo(item.x, y);
                   g.lineTo(item.x + item.width,y);
                }
          }
          else
          {
              g.lineStyle(1, color);
              g.moveTo(item.x, y);
              g.lineTo(item.x + item.width,y);

          }
        }
      }
      else
      {
         /* g.lineStyle(1, color);
         g.moveTo(0, y);
         g.lineTo(displayWidth, y); */
      }


    }


    override protected function drawRowBackgrounds():void
    {
      super.drawRowBackgrounds();

       setRowMergeMap();
       verticalItemMerge();
    }

    override public function validateDisplayList():void
    {
      super.validateDisplayList();

      setRowMergeMap();
      verticalItemMerge();
    }

    override protected function scrollHandler(event:Event):void
    {
      super.scrollHandler(event);

      verticalItemMerge();
    }

    override protected function mouseWheelHandler(event:MouseEvent):void
    {
      super.mouseWheelHandler(event);
      verticalItemMerge();
    }

    private function setRowMergeMap():void
    {
      var column:Object;
      var _rowMergeMap:Array = [];

      for(var i:Number = 0 ; i < this.columns.length ; i++)
      {
        column = this.columns[i];

        if(column.hasOwnProperty("verticalMerge"))
          if(column.verticalMerge == false)
            continue;

        _rowMergeMap.push( new Object() );
      }

      rowMergeMap = _rowMergeMap;
    }

    private function verticalItemMerge():void
    {
      if(this.dataProvider == null || this.dataProvider.length == 0) return;

      rowMergeMap = getRowMergeList();
      colorIndexList = getColorIndexList();

      drawRowBackgroundsEx();
    }



    private function getColumnX(columnIndex:int):Number
    {
      var retn:Number = 0;
      var length:int = columns.length;

      if(columnIndex != 0)
      {
        for(var i:int = 0 ; i < length ; i++)
        {
          retn += columns[i].width;
          if(columnIndex - 1 == i) break;
        }
      }

      drawLinesAndColumnBackgrounds()

      return retn;

    }



    /**
     *  Draws lines between columns, and column backgrounds.
     *  This implementation calls the <code>drawHorizontalLine()</code>,
     *  <code>drawVerticalLine()</code>,
     *  and <code>drawColumnBackground()</code> methods as needed.
     *  It creates a
     *  Sprite that contains all of these graphics and adds it as a
     *  child of the <code>listContent</code> at the front of the z-order.
     */
    /* override protected function drawLinesAndColumnBackgrounds():void
    {
        var lines:Sprite = getLines();
        lines.graphics.clear();

        var len:uint = getNumColumns();
        len = (len != -1)? len : visibleColumns.length;
        // defend against degenerate case when width == 0
        var optimumColumns:Array = getOptimumColumns();
        if (len > optimumColumns.length)
            len = optimumColumns.length;

        // draw horizontal lines
        drawHorizontalSeparators();

        // draw vertical lines
        drawVerticalSeparators();

        // draw column backgrounds
        if (headerInfos && hasHeaderItemsCreated(0) && hasHeaderItemsCreated(len-1))
        {
            var colBGs:Sprite = Sprite(listContent.getChildByName("colBGs"));
            // traverse the columns, set the sizes, draw the column backgrounds
            var lastChild:int = -1;
            for (var i:int = 0; i < len; i++)
            {
                var col:AdvancedDataGridColumn = optimumColumns[i];
                var bgCol:Object;
                if (enabled)
                    bgCol = col.getStyle("backgroundColor");
                else
                    bgCol = col.getStyle("backgroundDisabledColor");

                if (bgCol !== null && !isNaN(Number(bgCol)))
                {
                    if (!colBGs)
                    {
                        colBGs = new FlexSprite();
                        colBGs.mouseEnabled = false;
                        colBGs.name = "colBGs";
                        listContent.addChildAt(colBGs, listContent.getChildIndex(listContent.getChildByName("rowBGs")) + 1);
                    }
                    drawColumnBackground(colBGs, i, Number(bgCol), col);
                    lastChild = i;
                }
                else if (colBGs)
                {
                    var background:Shape = Shape(colBGs.getChildByName(i.toString()));
                    if (background)
                    {
                        var g:Graphics = background.graphics;
                        g.clear();
                        colBGs.removeChild(background);
                    }
                }
            }
            if (colBGs && colBGs.numChildren)
            {
                while (colBGs.numChildren)
                {
                    var bg:DisplayObject = colBGs.getChildAt(colBGs.numChildren - 1);
                    if (parseInt(bg.name) > lastChild)
                        colBGs.removeChild(bg);
                    else
                        break;
                }
            }
        }
    } */


    private function drawRowBackgroundsEx():void
    {
      var colors:Array;
          colors = getStyle("depthColors");

          var rowBGs:Sprite = Sprite(listContent.getChildByName("rowBGs"));
          if (!rowBGs)
          {
              rowBGs = new FlexSprite();
              rowBGs.mouseEnabled = false;
              rowBGs.name = "rowBGs";
              listContent.addChildAt(rowBGs, 0);
          }

          var color:Object;
          var depthColors:Boolean = false;

          if (colors)
          {
              depthColors = true;
          }
          else
          {
              colors = getStyle("alternatingItemColors");
          }

          color = getStyle("backgroundColor");
          if (!colors || colors.length == 0)
              return;

          StyleManager.getColorNames(colors);

          var i:int = 0;
          var j:int = 0;
          var rowcolor:int;

          var actualRow:int;
          var data:Object;
          var listItem:Object;
          var rowMap:RowMergeMapItem;
          var count:int = 0;
          var rowIndex:int;
          var prevColor:int;

      while(rowBGs.numChildren > 0)
        rowBGs.removeChildAt(0);

          for(i = 0 ; i < this.columns.length ; i++)
      {
        actualRow = verticalScrollPosition;
        rowIndex = 0;

        for(j = 0 ; j < this.listItems.length ; j++)
        {

          rowMap = rowMergeMap[i][j];

          if(colorIndexList[i][actualRow] == null)
          {
            //FIXME
            //rowcolor = colors[(colorIndexList[i][actualRow - 1].colorIndex + 1) % colors.length];
          }
          else
          {
            rowcolor = colors[colorIndexList[i][actualRow].colorIndex];
          }

          if(rowMap == null)
          {
            rowcolor = colors[actualRow % colors.length];
          }

          prevColor = rowcolor;
          actualRow++;

          if(rowMap == null)
          {
            drawRowBackgroundEx(rowBGs , getColumnX(i) , rowInfo[j].y , columns[i].width , rowInfo[j].height , rowcolor);
            count++;
            continue;
          }

          if(rowMap.parentIndex != -1) continue;

          drawRowBackgroundEx(rowBGs , getColumnX(rowMap.columnIndex) , rowInfo[rowMap.rowIndex].y ,
            columns[rowMap.columnIndex].width , rowInfo[rowMap.rowIndex].height * (rowMap.rowCount + 1) , rowcolor);

          count++;
        }
      }

      while (rowBGs.numChildren > count + columns.length)
          {
              rowBGs.removeChildAt(rowBGs.numChildren - 1);
          }
    }

    private function drawRowBackgroundEx(s:Sprite , x:Number , y:Number , width:Number , height:Number , color:int):void
    {
      var background:Shape;

          background = new FlexShape();
            background.name = "background";
            s.addChild(background);

          var g:Graphics = background.graphics;
          g.clear();
          g.beginFill(color, getStyle("backgroundAlpha"));
          g.drawRect(x , y , width , height);
          g.endFill();
    }

    private function getColorIndexList():Array
    {
      var colors:Array;

      var prevColor:int;
      var retn:Array = [];
      var buf:String;
      var index:int;

      var dp:ArrayCollection = this.dataProvider as ArrayCollection;

      colors = getStyle("alternatingItemColors");

      for(var i:int = 0 ; i < this.columns.length ; i++)
      {
        retn.push( [] );

        for(var j:int = 0 ; j < dp.length ; j++)
        {
          var item:Object = dp[j];
          var value:String = getColumnItemText(groupedColumns , item , columns[i].dataField);

          var colorIndexItem:ColorIndexItem = new ColorIndexItem();

          if(buf != value)
          {
            colorIndexItem.colorIndex = index % colors.length;
            buf = value;
            index++;
            prevColor = colorIndexItem.colorIndex;
          }
          else
          {
            colorIndexItem.colorIndex = prevColor;
          }

          retn[i].push( colorIndexItem );
        }
      }

      return retn;
    }


    private function getRowMergeList():Array
    {
      var retn:Array = [];

      var index:int;
      var item:Object;
      var dataBuf:String;
      var column:Object;

      var itemRenderer:IListItemRenderer;

      var prevLabel:String;
      var mergeRowIndex:int;

      for(var i:Number = 0 ; i < this.columns.length ; i++)
      {
        for(var j:Number = 0 ; j < this.listItems.length ; j++)
        {
          if(j == 0) retn.push( [] );

          if(columns[i].hasOwnProperty("verticalMerge"))
            if(columns[i].verticalMerge == false)
              continue;

          var mergeMap:RowMergeMapItem = new RowMergeMapItem();

          mergeMap.rowIndex = j;
          mergeMap.columnIndex = i;
          mergeMap.itemRenderer = itemRenderer = this.listItems[j][i];

          if(itemRenderer == null) continue;

          if(prevLabel == itemRenderer["text"])
          {
            if(retn[i][mergeRowIndex]){
              retn[i][mergeRowIndex].rowCount++;
              mergeMap.parentIndex = mergeRowIndex;
              itemRenderer.visible = false;
            }
          }
          else
          {
            mergeRowIndex = j;
            itemRenderer.visible = true;
          }

          prevLabel = itemRenderer["text"];

          retn[i].push(mergeMap);
        }
      }

      return retn;
    }

    private function getColorIndexItem(columnIndex:int , rowIndex:int):int
    {
      var item:ColorIndexItem = colorIndexList[columnIndex][rowIndex] as ColorIndexItem;

      return item.colorIndex;
    }

    private function getColumnItemText(columns:Array , data:Object , columnName:String):String
    {
      var retn:String;

      for(var i:int = 0 ; i < columns.length ; i++)
      {
        if(columns[i] is AdvancedDataGridColumnGroup)
        {
          if(data.hasOwnProperty(columns[i].dataField))
            retn = getColumnItemText(columns[i].children , data[ columns[i].dataField ] , columnName);
          else
            return null;

          if(retn != null) return retn;
        }

        if(columns[i].dataField == columnName)
          return data[columnName].toString();
      }
      return null;
    }

    private function baseDrawIndicator(indicator:Sprite, x:Number, y:Number, width:Number, height:Number, color:uint, itemRenderer:IListItemRenderer):void
    {
      super.drawSelectionIndicator(indicator , x , y , width , height , color , itemRenderer);


      //complexDrawIndicator(indicator , x , y , width , height , color , itemRenderer);
    }

    private function complexDrawIndicator(indicator:Sprite, x:Number, y:Number, width:Number, height:Number, color:uint, itemRenderer:IListItemRenderer):void
    {
      var retn:Array = [];
      var length:int = columns.length;

      var px:Point = itemRendererToIndices(itemRenderer);


      trace(px);
      /*
      for(var i:Number = 0 ; i < this.columns.length ; i++)
      {
        var p:DrawIndicatorParam = new DrawIndicatorParam();

        p.indicator = indicator;
        p.x = getColumnX(i);
        p.y = 44;
        p.width = columns[i].width;
        p.height = 44;
        p.color = color;

        p.itemRenderer = itemRenderer;

        retn[i] = p;
      }
      */

    }

  }
}

import mx.controls.listClasses.IListItemRenderer;
import flash.display.Sprite;

class RowMergeMapItem
{
  public var rowIndex:int;
  public var parentIndex:int = -1;
  public var columnIndex:int;
  public var rowCount:Number = 0;
  public var itemRenderer:IListItemRenderer;
}

class ColorIndexItem
{
  public var colorIndex:int;
}

class DrawIndicatorParam
{
  public var indicator:Sprite;
  public var x:Number;
  public var y:Number;
  public var width:Number;
  public var height:Number;
  public var color:uint;
  public var itemRenderer:IListItemRenderer;
}
