/*
 * Copyright (c) 2011.
 * @author - Seyran Sitshayev <seyrancom@gmail.com>
 */

/**
 * Created by IntelliJ IDEA.
 * User: Seyran
 * Date: 2/22/11
 * Time: 2:06 AM
 * To change this template use File | Settings | File Templates.
 */
package com.seyran.ui.layouts
{
    import flash.geom.Point;

    import mx.core.ILayoutElement;
    import mx.core.IVisualElement;

    import spark.components.supportClasses.GroupBase;
    import spark.layouts.VerticalAlign;
    import spark.layouts.supportClasses.LayoutBase;

    public class FlowLayout extends LayoutBase
    {
        //--------------------------------------------------------------------------
        //
        //  Variables
        //
        //--------------------------------------------------------------------------

        private var columnWidths:Array;

        private var lastWidth:Number = -1;

        private var lastHeight:Number = -1;

        private var updateCount:Number = 0;

        private var columnMaxNum:Number = -1;

        //--------------------------------------------------------------------------
        //
        //  Properties
        //
        //--------------------------------------------------------------------------

        //----------------------------------
        //
        //----------------------------------

        private var _variableColumnWidth:Boolean = true;

        /**
         * -1 for unlimited columns
         */
        protected function get variableColumnWidth():Boolean
        {
            return _variableColumnWidth;
        }

        protected function set variableColumnWidth(value:Boolean):void
        {
            if (value == _variableColumnWidth)
            {
                return;
            }

            _variableColumnWidth = value;
            invalidateTargetSizeAndDisplayList();
        }

        //----------------------------------
        //
        //----------------------------------

        private var _columnMinWidth:Number = -1;

        /**
         * -1 for unlimited width
         */
        public function get columnMinWidth():Number
        {
            return _columnMinWidth;
        }

        public function set columnMinWidth(value:Number):void
        {
            if (value == _columnMinWidth)
            {
                return;
            }

            _columnMinWidth = value;
            invalidateTargetSizeAndDisplayList();
        }

        //----------------------------------
        //
        //----------------------------------

        private var _columnMaxWidth:Number = -1;

        /**
         * -1 for unlimited columns
         */
        public function get columnMaxWidth():Number
        {
            return _columnMaxWidth;
        }

        public function set columnMaxWidth(value:Number):void
        {
            if (value == _columnMaxWidth)
            {
                return;
            }

            _columnMaxWidth = value;
            variableColumnWidth = _columnMaxWidth == -1;
            invalidateTargetSizeAndDisplayList();
        }

        //----------------------------------
        //  requestedColumnCount
        //----------------------------------

        private var _requestedColumnCount:Number = -1;

        /**
         * -1 for unlimited columns
         */
        public function get requestedColumnCount():Number
        {
            return _requestedColumnCount;
        }

        public function set requestedColumnCount(value:Number):void
        {
            if (value == _requestedColumnCount)
            {
                return;
            }

            _requestedColumnCount = value;
            invalidateTargetSizeAndDisplayList();
        }

        //----------------------------------
        //  horizontalGap
        //----------------------------------

        private var _horizontalGap:Number = 6;

        public function get horizontalGap():Number
        {
            return _horizontalGap;
        }

        public function set horizontalGap(value:Number):void
        {
            if (value == _horizontalGap)
                return;

            _horizontalGap = value;
            invalidateTargetSizeAndDisplayList();
        }

        //----------------------------------
        //  verticalGap
        //----------------------------------

        private var _verticalGap:Number = 6;

        public function get verticalGap():Number
        {
            return _verticalGap;
        }

        public function set verticalGap(value:Number):void
        {
            if (value == _verticalGap)
                return;

            _verticalGap = value;
            invalidateTargetSizeAndDisplayList();
        }

        //----------------------------------
        //  verticalAlign
        //----------------------------------

        private var _verticalAlign:String = VerticalAlign.TOP;

        [Inspectable("General", enumeration="top,bottom,middle", defaultValue="top")]
        public function get verticalAlign():String
        {
            return _verticalAlign;
        }

        public function set verticalAlign(value:String):void
        {
            if (_verticalAlign == value)
                return;

            _verticalAlign = value;
            invalidateTargetSizeAndDisplayList();
        }

        //----------------------------------
        //  paddingLeft
        //----------------------------------

        private var _paddingLeft:Number = 0;

        public function get paddingLeft():Number
        {
            return _paddingLeft;
        }

        public function set paddingLeft(value:Number):void
        {
            if (_paddingLeft == value)
                return;

            _paddingLeft = value;
            invalidateTargetSizeAndDisplayList();
        }

        //----------------------------------
        //  paddingRight
        //----------------------------------

        private var _paddingRight:Number = 0;

        public function get paddingRight():Number
        {
            return _paddingRight;
        }

        public function set paddingRight(value:Number):void
        {
            if (_paddingRight == value)
                return;

            _paddingRight = value;
            invalidateTargetSizeAndDisplayList();
        }

        //----------------------------------
        //  paddingTop
        //----------------------------------

        private var _paddingTop:Number = 0;

        public function get paddingTop():Number
        {
            return _paddingTop;
        }

        public function set paddingTop(value:Number):void
        {
            if (_paddingTop == value)
                return;

            _paddingTop = value;
            invalidateTargetSizeAndDisplayList();
        }

        //----------------------------------
        //  paddingBottom
        //----------------------------------

        private var _paddingBottom:Number = 0;

        public function get paddingBottom():Number
        {
            return _paddingBottom;
        }

        public function set paddingBottom(value:Number):void
        {
            if (_paddingBottom == value)
                return;

            _paddingBottom = value;
            invalidateTargetSizeAndDisplayList();
        }

        public function getIncludedElementAt(index:int):IVisualElement
        {
            //var element:IVisualElement = useVirtualLayout ? target.getVirtualElementAt(index) : target.getElementAt(index);
            var element:IVisualElement = target.getElementAt(index);
            element = (!element || !element.includeInLayout) ? null : element;
            return element;
        }

        protected function getOptimalColumnSize(columnIndex:int, preferredWidth:Number):Number
        {
            columnIndex = columnMaxNum <= columnIndex ? 0 : columnIndex;
            return !variableColumnWidth && columnWidths && columnWidths[columnIndex] ? columnWidths[columnIndex] : preferredWidth;
        }

        protected function getOptimalColumnSizes(columnWidths:Array, rowWidth:Number):Array
        {
            var suitableColumnsSizes:Array = [];
            var elementColumnIndex:int = 0;
            var measuredWidth:Number = 0;
            var maxColumnWidths:Array;
            var newRowWidth:Number;

            // init sizes, for one column, it's size equal to row width
            suitableColumnsSizes[0] = rowWidth;

            for (var columnCount:int = 2, length:Number = requestedColumnCount == -1 ? columnWidths.length : requestedColumnCount; columnCount <= length; columnCount++)
            {
                maxColumnWidths = [];
                newRowWidth = 0;
                for (var i:int = 0; i < length; i++)
                {
                    measuredWidth = columnWidths[i];
                    elementColumnIndex = i % columnCount;
                    if (columnMaxWidth != -1 && columnMaxWidth < measuredWidth)
                    {
                        measuredWidth = columnMaxWidth;
                    }
                    else if (columnMinWidth != -1 && columnMinWidth > measuredWidth)
                    {
                        measuredWidth = columnMinWidth;
                    }
                    maxColumnWidths[elementColumnIndex] = !maxColumnWidths[elementColumnIndex] || measuredWidth > maxColumnWidths[elementColumnIndex] ? measuredWidth : maxColumnWidths[elementColumnIndex];
                }
                for (i = maxColumnWidths.length - 1; i >= 0; i--)
                {
                    newRowWidth += maxColumnWidths[i] + horizontalGap;
                }

                if (newRowWidth > rowWidth)
                {
                    break;
                }

                suitableColumnsSizes = maxColumnWidths;
                // fit last column to remaining width
                suitableColumnsSizes[suitableColumnsSizes.length - 1] = rowWidth - (newRowWidth - suitableColumnsSizes[suitableColumnsSizes.length - 1]);
            }

            return suitableColumnsSizes;
        }

        protected function calculateColumnSizes(rowWidth:Number):void
        {
            var n:int = target ? target.numElements : 0;
            var element:ILayoutElement;
            var realWidth:Number = rowWidth - (paddingLeft + paddingRight);
            columnWidths = [];
            columnMaxNum = -1;
            if (!variableColumnWidth)
            {
                for (var i:int = 0; i < n; i++)
                {
                    element = getIncludedElementAt(i);
                    if (!element || !element.includeInLayout)
                        continue;

                    columnWidths.push(Math.ceil(element.getPreferredBoundsWidth()));
                }

                columnWidths = getOptimalColumnSizes(columnWidths, realWidth);
                columnMaxNum = columnWidths ? columnWidths.length : 0;
                /*
                 var measuredWidth:Number = 0;
                 var maxWidth:Number = 0;
                 var minWidth:Number = Number.MAX_VALUE;
                 for (var i:int = 0; i < n; i++)
                 {
                 element = getIncludedElementAt(i);
                 if (!element || !element.includeInLayout)
                 continue;

                 measuredWidth = Math.ceil(element.getPreferredBoundsWidth());
                 maxWidth = measuredWidth > maxWidth ? measuredWidth : maxWidth;
                 minWidth = measuredWidth < minWidth ? measuredWidth : minWidth;
                 }

                 maxWidth = Math.min(columnMaxWidth, maxWidth);
                 if (columnMinWidth > 0 && columnMinWidth > maxWidth)
                 {
                 maxWidth = columnMinWidth;
                 }
                 columnMaxNum = requestedColumnCount == -1 && realWidth > 0 ? Math.floor(realWidth / (maxWidth + horizontalGap)) : requestedColumnCount;
                 columnWidth = columnMaxNum > 1 ? Math.floor((realWidth - horizontalGap * (columnMaxNum - 1)) / columnMaxNum) : -1;
                 */
            }
        }

        //--------------------------------------------------------------------------
        //
        //  Overriden methods
        //
        //--------------------------------------------------------------------------

        override public function measure():void
        {
            if (lastWidth == -1)
                return;

            var measuredWidth:Number = 0;
            var measuredMinWidth:Number = 0;
            var measuredHeight:Number = 0;
            var measuredMinHeight:Number = 0;

            var layoutTarget:GroupBase = target;
            var n:int = layoutTarget.numElements;
            var element:ILayoutElement;
            var i:int;
            var width:Number = layoutTarget.explicitWidth;

            if (isNaN(width) && lastWidth != -1)
                width = lastWidth;

            if (isNaN(width)) // width is not defined by parent or user
            {
                // do not specify measuredWidth and measuredHeight to real
                // values because in fact we can layout at any width or height
                for (i = 0; i < n; i++)
                {
                    element = getIncludedElementAt(i);
                    if (!element || !element.includeInLayout)
                        continue;

                    measuredWidth = Math.ceil(element.getPreferredBoundsWidth());
                    measuredHeight = Math.ceil(element.getPreferredBoundsHeight());
                    break;
                }
                measuredMinWidth = measuredWidth;
                measuredMinHeight = measuredHeight;
            }
            else
            {
                // calculate lines based on width
                var currentLineWidth:Number = 0;
                var currentLineHeight:Number = 0;
                var lineNum:int = 1;
                var columnIndex:int = 0;

                calculateColumnSizes(width);
                for (i = 0; i < n; i++)
                {
                    element = getIncludedElementAt(i);
                    if (!element || !element.includeInLayout)
                        continue;

                    var widthWithoutPaddings:Number = width - paddingLeft - paddingRight;
                    var elementWidth:Number = getOptimalColumnSize(columnIndex, Math.ceil(element.getPreferredBoundsWidth()));

                    if (((requestedColumnCount == -1 && variableColumnWidth) || columnMaxNum > columnIndex)
                            && (currentLineWidth == 0 || currentLineWidth + horizontalGap + elementWidth <= widthWithoutPaddings))
                    {
                        currentLineWidth += elementWidth + (currentLineWidth == 0 ? 0 : horizontalGap);
                        currentLineHeight = Math.max(currentLineHeight, Math.ceil(element.getPreferredBoundsHeight()));
                        columnIndex++;
                    }
                    else
                    {
                        measuredHeight += currentLineHeight;
                        columnIndex = 1;
                        lineNum++;
                        currentLineWidth = elementWidth;
                        currentLineHeight = Math.ceil(element.getPreferredBoundsHeight());
                    }
                }

                measuredHeight += currentLineHeight;

                if (lineNum > 1)
                    measuredHeight += verticalGap * (lineNum - 1);

                // do not set measuredWidth to real value because really we can
                // layout at any width
                for (i = 0; i < n; i++)
                {
                    element = getIncludedElementAt(i);
                    if (!element || !element.includeInLayout)
                        continue;

                    measuredWidth = measuredMinWidth = width;
                    //measuredWidth = measuredMinWidth = getOptimalColumnSize(columnIndex, Math.ceil(element.getPreferredBoundsWidth()));
                    break;
                }
                measuredMinHeight = measuredHeight;
            }

            layoutTarget.measuredWidth = measuredWidth + paddingLeft + paddingRight;
            layoutTarget.measuredMinWidth = measuredMinWidth + paddingLeft + paddingRight;
            layoutTarget.measuredHeight = measuredHeight + _paddingTop + _paddingBottom;
            layoutTarget.measuredMinHeight = measuredMinHeight + _paddingTop + _paddingBottom;
        }

        override public function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
        {
            super.updateDisplayList(unscaledWidth, unscaledHeight)
            // after second updating need skip other requests
            /*
             if (lastHeight == unscaledHeight && lastWidth == unscaledWidth && updateCount > 2)
             {
             updateCount = 0;
             return;
             }
             else if (lastHeight == unscaledHeight && lastWidth == unscaledWidth)
             {
             updateCount++;
             }
             */

            var layoutTarget:GroupBase = target;
            var n:int = layoutTarget.numElements;
            var element:ILayoutElement;
            var i:int;
            // calculate lines based on width
            var x:Number = paddingLeft;
            var y:Number = _paddingTop;
            var maxLineHeight:Number = 0;
            var contentHeight:Number = 0;
            var contentWidth:Number = 0;
            var elementCounter:int = 0;
            var columnIndex:int = 0;
            var positions:Vector.<Point> = new Vector.<Point>(n);

            calculateColumnSizes(unscaledWidth);

            for (i = 0; i < n; i++)
            {
                element = getIncludedElementAt(i);
                if (!element || !element.includeInLayout)
                    continue;

                var elementWidth:Number = getOptimalColumnSize(columnIndex, Math.ceil(element.getPreferredBoundsWidth()));

                if (((requestedColumnCount == -1 && variableColumnWidth) || columnMaxNum > columnIndex)
                        && (x == paddingLeft || x + horizontalGap + elementWidth <= unscaledWidth - paddingRight))
                {
                    if (elementCounter > 0)
                        x += horizontalGap;
                    positions[i] = new Point(x, y);

                    elementWidth = getOptimalColumnSize(columnIndex, (unscaledWidth - paddingRight) - (x + horizontalGap));

                    element.setLayoutBoundsSize(elementWidth, NaN);

                    maxLineHeight = Math.max(maxLineHeight, Math.ceil(element.getPreferredBoundsHeight()));
                    columnIndex++;
                }
                else
                {
                    x = paddingLeft;
                    y += verticalGap + maxLineHeight;
                    positions[i] = new Point(x, y);

                    elementWidth = getOptimalColumnSize(0, (unscaledWidth - paddingRight) - x);
                    element.setLayoutBoundsSize(elementWidth, NaN);

                    maxLineHeight = Math.ceil(element.getPreferredBoundsHeight());
                    columnIndex = 1;
                }

                x += elementWidth;
                elementCounter++;

                contentWidth = Math.max(x, contentWidth);
                if (i == n - 1)
                {
                    contentHeight = Math.max(y + maxLineHeight, contentHeight);
                }
            }

            // verticalAlign and setLayoutBoundsPosition() for elements
            var yAdd:Number = 0;
            var yDifference:Number = contentHeight - (y + maxLineHeight + _paddingBottom);
            if (_verticalAlign == VerticalAlign.MIDDLE)
                yAdd = Math.round(yDifference / 2);
            else if (_verticalAlign == VerticalAlign.BOTTOM)
                yAdd = Math.round(yDifference);
            for (i = 0; i < n; i++)
            {
                element = getIncludedElementAt(i);
                if (!element || !element.includeInLayout)
                    continue;
                var point:Point = positions[i];
                point.y += yAdd;
                element.setLayoutBoundsPosition(point.x, point.y);
            }

            if (layoutTarget.numElements == 0)
            {
                layoutTarget.setContentSize(Math.ceil(paddingLeft + paddingRight),
                        Math.ceil(paddingTop + paddingBottom));
            }
            else
            {
                layoutTarget.setContentSize(contentWidth, contentHeight);
            }

            if (lastHeight == -1 || lastHeight != unscaledWidth)
            {
                lastHeight = unscaledHeight;
            }
            // if width changed then height will change too - remeasure
            if (lastWidth == -1 || lastWidth != unscaledWidth)
            {
                lastWidth = unscaledWidth;
                invalidateTargetSizeAndDisplayList();
            }
        }

        //--------------------------------------------------------------------------
        //
        //  Methods
        //
        //--------------------------------------------------------------------------

        private function invalidateTargetSizeAndDisplayList():void
        {
            var g:GroupBase = target;
            if (!g)
                return;

            g.invalidateSize();
            g.invalidateDisplayList();
        }

    }
}