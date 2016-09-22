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

import QtQuick 2.4

import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2

FocusScope {
	id: container
	height: 30
	
	state: txtMain.activeFocus ? "focused" : "notfocused"

	property bool showCapsLockWarning: false
	property alias echoMode: txtMain.echoMode
	property string passwordCharacter: '\u25CF'
	property alias placeholderText: txtMain.placeholderText
	property alias text: txtMain.text

	property int focusWidth: unfocusWidth*1.10
	property int unfocusWidth: 200

	property bool isEnabled: true

	function selectAll() {
        txtMain.selectAll()
	}

	TextField {
        id: txtMain
        readOnly: !isEnabled
        width: parent.width; height: parent.height
        font.pixelSize: 14

        focus: true

         Behavior on width {
        	SpringAnimation { spring: 0.5; damping: 0.1; mass: 0.7 }
        }

        style: TextFieldStyle {
				selectionColor: 'grey'
				font.family: 'Oxygen'
				textColor: container.isEnabled ? 'black' : 'grey'
				passwordCharacter: container.passwordCharacter
        }

        Keys.forwardTo: [container]
	}

	Image {
        id: capsLockWarning
        visible: keyboard.capsLock && showCapsLockWarning && txtMain.activeFocus
        
        anchors {
        	right: txtMain.right
        	verticalCenter: parent.verticalCenter
        }

        fillMode: Image.PreserveAspectFit
        height: parent.height - 10

        source: "../images/warning.svg"

        sourceSize.height: height

        anchors.rightMargin: 20
	}

	states: [
            State {
                name: "focused"
                PropertyChanges { 
                	target: container; 
                	width: focusWidth;
                }
            },
            State {
                name: "notfocused"
                PropertyChanges { 
                	target: container; 
                	width: unfocusWidth; 
                }
            }
        ]
}	