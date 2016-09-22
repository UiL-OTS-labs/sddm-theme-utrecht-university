/***************************************************************************
* Copyright (c) 2016 Chris van Run <labman.gw.@uu.nl>
*
* Permission is hereby granted, free of charge, to any person
* obtaining a copy of this software and associated documentation
* files (the "Software"), to deal in the Software without restriction,
* including without limitation the rights to use, copy, modify, merge,
* publish, distribute, sublicense, and/or sell copies of the Software,
* and to permit persons to whom the Software is furnished to do so,
* subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included
* in all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
* OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
* OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
* ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE
* OR OTHER DEALINGS IN THE SOFTWARE.
*
***************************************************************************/

import QtQuick 2.0
import QtGraphicalEffects 1.0

FocusScope {
	id: container
  width: 200; height: 40

  property color buttonColor: 'grey'
  property string buttonTextText: 'ButtonTextText'
  property string buttonFontFamily: 'Oxygen'
  property int buttonFontPixelSize: 14
  property color buttonFontColor: 'white'

  property real buttonHoverOffsetFactor: 1.0
  property real buttonPressedFacter: 0.2

  property real buttonRadius: 6
  property real buttonOffset: 2.0

  signal released()
  signal pressed()
  signal clicked()

  property bool enabled: true

  property bool returnPressed: false
  readonly property bool isFocused: activeFocus || area.containsMouse
  readonly property bool isPressed: returnPressed || area.pressed || !enabled

  function getTransformedVariabled(normalValue)
  {
    var x = normalValue
    if( isPressed )
      return x * buttonPressedFacter
    if( isFocused)
      return x * buttonHoverOffsetFactor
    return x	
  }

  Rectangle {
   id: top
   color: buttonColor
   radius: buttonRadius

   border.width: isFocused ? 4 : 0
   border.color: Qt.lighter(color, 1.5)

   antialiasing: true;
   clip: true
   smooth: true

   z: 101
   x: -1 * getTransformedVariabled(buttonOffset)
   y: x
   width: parent.width-buttonOffset; height: parent.height-buttonOffset

    	// Highlighting from above
    	LinearGradient {
       source: parent
       opacity: (area.isFocused || isPressed) ? 0.2 : 0.1
       anchors.fill: parent
       start: Qt.point(0, 0)
       end: Qt.point(parent.width/3.3, parent.height)
       gradient: Gradient {
        GradientStop { position: 0.0; color: 'white' }
        GradientStop { position: 1.0; color: 'transparent' }
      }
    }
  }

  Rectangle {
   id: side
   z: 100
   x: buttonOffset
   y: x
   clip: true
   smooth: true
   width: top.width; height: top.height
   color: Qt.darker(buttonColor, 1.5)
   radius: buttonRadius
 }

 DropShadow {
   id: shadow
   anchors.fill: side
   horizontalOffset: getTransformedVariabled(2)
   verticalOffset: horizontalOffset
   radius: 1
   samples: 20
   color: "#80000000"
   source: side
 }

 Text {
  id: buttonText
  z: 103
  text: buttonTextText
  anchors.fill: top
  anchors.margins: 5
  verticalAlignment: Text.AlignVCenter
  horizontalAlignment: Text.AlignHCenter
  height: text.implicitHeight
  font.family: buttonFontFamily
  font.pixelSize: buttonFontPixelSize
  color: buttonFontColor
  elide: Text.ElideRight
}

MouseArea {
 id: area

 anchors.fill: parent

 hoverEnabled: true

 cursorShape: Qt.PointingHandCursor

 acceptedButtons: Qt.LeftButton

 onPressed: {
    if(container.enabled)
    {
      container.forceActiveFocus()
      container.pressed()
    }
  }

  onReleased: {
    if(container.enabled)
    {
      container.forceActiveFocus()
      container.released()
    }
  }

  onClicked: {
    if(container.enabled)
    {
      container.forceActiveFocus()
      container.clicked()
    }
  }
}

Keys.onPressed: {
  if ((event.key == Qt.Key_Space || event.key == Qt.Key_Return ) && container.enabled) {
    container.returnPressed = true;
    container.pressed()
    event.accepted = true
  }
}

Keys.onReleased:
{
  if ((event.key == Qt.Key_Space || event.key == Qt.Key_Return ) && container.enabled) {
    container.returnPressed = false;
    container.released()
    container.clicked()
    event.accepted = true
  }
}

}