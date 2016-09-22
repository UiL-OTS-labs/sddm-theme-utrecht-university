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

import SddmComponents 2.0

import './components'

Rectangle {
  id: container
  /*
  * geometry of the whole screen.
  */
  readonly property rect geometry: screenModel.geometry(-1)
  width: geometry.width
  height: geometry.height



  readonly property string generalFontFamily: 'Oxygen'

  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.ArrowCursor
  }

  /*
  * Some lanuages are read left to right, for this we enable layout mirroring.
  */
  LayoutMirroring.enabled: Qt.locale().textDirection == Qt.RightToLeft
  LayoutMirroring.childrenInherit: true

  /*
  * Provided by SDDM; textConstants for the GUI labels
  */
  TextConstants { id: textConstants }

  /*
  * Resets most of the crucial states of the login screen.
  */
  function reset()
  {
    userMessage.state = 'welcome'

    name.text = ''
    password.text = ''

    name.forceActiveFocus()

    textFields.enabled = true
    majorButtons.enabled = true
    loginButton.enabled = true // above does not seem to want to reset this =/

    sessionOptionsSwitch.checked = false
    moreInfoOptionsSwitch.checked = false
  }

  /*
  * Locks the GUI part responsible for login.
  */

  function lockLogin()
  {
    textFields.enabled = false
    loginButton.enabled = false
  }

  /*
  * Resets most of the crucial states of the login screen.
  */
  function attemptLogin()
  {
    lockLogin()
    messageReset.stop()
    sddm.login(name.text, password.text, session.index)
  }

  Connections {
    target: sddm

    onLoginSucceeded: {
      userMessage.state = 'message'
      userMessage.color = "steelblue"
      userMessage.text = textConstants.loginSucceeded

      userMessageReset.start()
    }

    onLoginFailed: {
      userMessage.state = 'message'
      userMessage.color = "darkred"
      userMessage.text = textConstants.loginFailed
      messageReset.start()

      textFields.enabled = true

      majorButtons.enabled = true
      loginButton.enabled = true // above does not seem to want to reset this =/

      password.selectAll()
      password.forceActiveFocus()

    }
  }

  /*
  * Timer to reset the welcome state after showing messages
  */
  Timer {
    id: messageReset
    interval: config.retryTimeout

    onTriggered: {
      reset()
    }
  }

  Image {
    id: background
    asynchronous: true

    anchors.fill: container
    horizontalAlignment: Image.AlignLeft; verticalAlignment: Image.AlignTop
    //fillMode: Image.PreserveAspectCrop

    source: config.backgroundImage
    onStatusChanged: {
      if (status == Image.Error && source != config.defaultBackground) {
        source = config.defaultBackground
      }
    }
  }

  Image {
    id: background_overlay
    asynchronous: true

    anchors.fill: container
    horizontalAlignment: Image.AlignLeft; verticalAlignment: Image.AlignTop
    fillMode: Image.PreserveAspectCrop

    source: config.foregroundImage
    onStatusChanged: {
      if (status == Image.Error && source != config.defaultBackground) {
        source = config.defaultBackground
      }
    }
  }

  Rectangle {
    id: extraOptionsButtons
    color: 'transparent'

    height: extraColumn.implicitHeight;width: extraColumn.implicitWidth

    anchors {
      left: parent.left
      bottom: parent.bottom
      margins: 20
    }

    Column {
      id: extraColumn
      spacing: 10
      opacity: 0.7
      anchors.fill: parent

      Row {
        spacing: 10
        Switch { id: moreInfoOptionsSwitch; checked: false }

        Text { text: 'More Information'; font.family: generalFontFamily }
      }

      Row {
        spacing: 10
        Switch { id: sessionOptionsSwitch; checked: false}
        Text {text: 'Session Options'; font.family: generalFontFamily }
      }
    }

  }

  Rectangle
  {
    anchors.top: sessionOptions.top
    anchors.horizontalCenter: sessionOptions.horizontalCenter
    height: sessionOptions.height+10
    width: sessionOptions.width+10

    color: 'white'
    opacity: Math.min(sessionOptions.opacity, 0.5)
  }

  GroupBox {
    id: sessionOptions

    title: 'Session Options'
    anchors {
      top: mainBox.bottom
      horizontalCenter: container.horizontalCenter
    }
    width: mainBox.width

    opacity: sessionOptionsSwitch.checked ? 1 : 0

    Behavior on opacity {
      NumberAnimation { duration: 50 }
    }

    Row {
      spacing: 4
      anchors {
        left: parent.left
        right: parent.right
      }

      Column {
        spacing : 10
        width: parent.width/2
        Text {
          id: lblSession
          text: textConstants.session
          wrapMode: TextEdit.WordWrap
          font.bold: true
          font.pixelSize: 12
          font.family: generalFontFamily
        }

        ComboBox {
          id: session
          width: parent.width
          height: 30

          arrowIcon: "images/arrow-orange.png"

          model: sessionModel
          index: sessionModel.lastIndex
        }
      }

      Column {
        width: parent.width/2
        spacing : 10
        anchors.bottom: parent.bottom

        Text {
          id: lblLayout
          text: textConstants.layout
          wrapMode: TextEdit.WordWrap
          font.bold: true
          font.pixelSize: 12
          font.family: generalFontFamily
        }

        LayoutBox {
          id: layoutBox
          width: parent.width
          height: 30
          arrowIcon: "images/arrow-orange.png"
        }
      }
    }
  }

  Rectangle
  {
    anchors.top: information.top
    anchors.horizontalCenter: information.horizontalCenter
    height: information.height+10
    width: information.width+10

    color: 'white'
    opacity: Math.min(information.opacity,0.5)
  }

  GroupBox {
    id: information
    title: 'Host: ' + sddm.hostName
    anchors.bottom: mainBox.top
    anchors.horizontalCenter: container.horizontalCenter
    width: mainBox.width

    opacity: moreInfoOptionsSwitch.checked ? 1 : 0

    Behavior on opacity {
      NumberAnimation { duration: 150 }
    }

    Text {
      id: informationText
      anchors.fill: parent
      text: config.infoText
      height: text.implicitHeight
      color: 'black'
      font.pixelSize: 14
      font.family: generalFontFamily
      wrapMode: TextEdit.WordWrap
    }
  }



/*
* Main box that limits the size of the main column
*/
  Rectangle {
    id: mainBox
    anchors.centerIn: parent
    width: 320; height: 320
    color: 'transparent'

    /*
    * Main column that holds all crucial parts of the login screen.
    */
    Column {
      id: mainColumn
      spacing: 30
      anchors.fill: parent
      anchors.topMargin: spacing
      anchors.bottomMargin: spacing

      Label {
        id: userMessage
        state: 'welcome'
        width: text.implicitWidth
        anchors.left: parent.left

        states: [
          State {
            name: 'welcome'
            PropertyChanges {
              target: userMessage;
              font.bold: false;
              font.family: generalFontFamily
              text: config.welcomeText
              color: 'white'
              font.pixelSize: 20
            }
          },
          State {
            name: 'message'
            PropertyChanges {
              target: userMessage;
              font.family: generalFontFamily
              font.bold: true;
              font.pixelSize: 20;
            }
          }
        ]
      }

      // Artsy vertical divider
      CustomVerticalLine {
        anchors{
          left: parent.left
          right: parent.right
        }
        height: 2
        color: 'white'
      }

      /*
      * Container for the custom textfields for username and password.
      */
      Column
      {
        id: textFields

        property bool enabled: true
        onEnabledChanged: {
          name.isEnabled = textFields.enabled
          password.isEnabled = textFields.enabled
        }

        spacing: 10

        anchors {
          left: parent.left
          right: parent.right
        }

        // Username
        Item
        {
          anchors.left: parent.left
          anchors.right: parent.right
          height: 30

          // ICON
          Image {
            id: nameIcon
            source: 'images/nameicon.svg'
            anchors.verticalCenter: parent.verticalCenter

            mipmap: true
            sourceSize.width:  parent.height

            fillMode: Image.PreserveAspectFit
          }

          // FIELD
          CustomTextField {
            id: name
            height: parent.height
            anchors.left: nameIcon.right
            anchors.leftMargin: 10

            unfocusWidth: parent.width - nameIcon.width - anchors.leftMargin
            placeholderText: config.namePlaceHolder

            Keys.onBacktabPressed: rebootButton.forceActiveFocus()
            Keys.onTabPressed: password.forceActiveFocus()

            Keys.onEnterPressed: password.forceActiveFocus()
            Keys.onReturnPressed:
            {
              password.forceActiveFocus()
              password.selectAll()
            }

            Keys.onEscapePressed: container.reset()
          }
        }

        // Password
        Item
        {
          anchors {
            left: parent.left
            right: parent.right
          }
          height: 30

          // ICON
          Image {
            id: passwordIcon
            anchors.verticalCenter: parent.verticalCenter
            mipmap: true
            sourceSize.width:  parent.height

            source: 'images/passwordicon.svg'
            fillMode: Image.PreserveAspectFit
          }

          // FIELD
          CustomTextField {
            id: password
            height: parent.height
            anchors {
              left: passwordIcon.right
              leftMargin: 10
            }

            unfocusWidth: parent.width - passwordIcon.width - anchors.leftMargin
            placeholderText: config.passwordPlaceHolder
            showCapsLockWarning: true
            echoMode: TextInput.Password

            Keys.onBacktabPressed: name.forceActiveFocus()
            Keys.onTabPressed: loginButton.forceActiveFocus()

            Keys.onEnterPressed: attemptLogin()
            Keys.onReturnPressed: attemptLogin()

            Keys.onEscapePressed: container.reset()
          }
        }
      }

      // Artsy vertical divider
      CustomVerticalLine {
        anchors{
          left: parent.left
          right: parent.right
        }
        height: 2
        color: 'white'
      }

      /*
      * Row for the functional buttons (e.g. login)
      */
      Row {
        id: majorButtons
        height: 60
        spacing: 10

        property bool enabled: true

        onEnabledChanged: {
          loginButton.enabled = majorButtons.enabled
          shutdownButton.enabled = majorButtons.enabled
          rebootButton.enabled = majorButtons.enabled
        }

        anchors{
          left: parent.left
          right: parent.right
        }

        // LOGIN
        CustomButton {
          id: loginButton
          width: (parent.width-(parent.spacing*2))*(1/3)
          height: parent.height
          buttonTextText: 'Login'
          buttonFontColor: 'white'
          buttonColor: enabled ? '#339933' : 'grey'

          Keys.onBacktabPressed: password.forceActiveFocus()
          Keys.onTabPressed: shutdownButton.forceActiveFocus()
          Keys.onEscapePressed: container.reset()

          onClicked: attemptLogin()
        }

        // SHUTDOWN or POWEROFF
        CustomButton {
          id: shutdownButton
          width: (parent.width-(parent.spacing*2))*(1/3)
          height: parent.height
          buttonTextText: 'Shutdown'
          buttonFontColor: 'white'
          buttonColor: enabled ? '#ff704d' : 'grey'

          Keys.onBacktabPressed: loginButton.forceActiveFocus()
          Keys.onTabPressed: rebootButton.forceActiveFocus()
          Keys.onEscapePressed: container.reset()

          onClicked: {
            majorButtons.enabled = false
            textFields.enabled = false
            sddm.powerOff()
          }
        }

        // REBOOT
        CustomButton {
          id: rebootButton
          width: (parent.width-(parent.spacing*2))*(1/3)
          height: parent.height
          buttonTextText: 'Reboot'
          buttonFontColor: 'white'
          buttonColor: enabled ? '#ffa64d' : 'grey'

          Keys.onBacktabPressed: shutdownButton.forceActiveFocus()
          Keys.onTabPressed: name.forceActiveFocus()
          Keys.onEscapePressed: container.reset()

          onClicked: {
            majorButtons.enabled = false
            textFields.enabled = false
            sddm.reboot()
          }
        }
      }
    }
  }

  //focus works in qmlscene
  //but this seems to be needed when loaded from SDDM
  //I don't understand why, but we have seen this before in the old lock screen
  Timer {
      id: resetDelayHack
      interval: 200
      onTriggered: reset()
  }
  //end hack

  /*
  * After loading call reset to setup first use.
  */
  Component.onCompleted: {
    resetDelayHack.start()
  }
}
