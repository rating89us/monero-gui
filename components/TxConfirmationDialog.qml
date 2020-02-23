// Copyright (c) 2014-2018, The Monero Project
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification, are
// permitted provided that the following conditions are met:
//
// 1. Redistributions of source code must retain the above copyright notice, this list of
//    conditions and the following disclaimer.
//
// 2. Redistributions in binary form must reproduce the above copyright notice, this list
//    of conditions and the following disclaimer in the documentation and/or other
//    materials provided with the distribution.
//
// 3. Neither the name of the copyright holder nor the names of its contributors may be
//    used to endorse or promote products derived from this software without specific
//    prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
// MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
// THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
// THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import QtQuick 2.9
import QtQuick.Controls 1.4

import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import moneroComponents.Clipboard 1.0

import QtQuick.Window 2.0

import "../components" as MoneroComponents
import "." 1.0
import "effects/" as MoneroEffects
import moneroComponents.Wallet 1.0
import moneroComponents.PendingTransaction 1.0
import moneroComponents.NetworkType 1.0
import moneroComponents.Settings 1.0
import FontAwesome 1.0

import "../js/Utils.js" as Utils
import "../js/Windows.js" as Windows


Rectangle {
    id: root
    color: "transparent"
    visible: false

    Clipboard { id: clipboard }

    property var icon
    property alias dialogTitle: dialogTitle
    property alias errorText: errorText
    property alias confirmButton: confirmButton
    property alias backButton: backButton
    property alias bottomText: bottomText
    property alias buttons: buttons
    property alias bottomTextAnimation: bottomTextAnimation

    state: "default"
    states: [
        State {
            // waiting for user action, show tx details + back and confirm buttons
            name: "default";
            when: errorText.text =="" && bottomText.text ==""
            PropertyChanges { target: errorText; visible: false }
            PropertyChanges { target: txAmountText; visible: appWindow.transactionAmount !== "(all)" }
            PropertyChanges { target: txAmountBusyIndicator; visible: !txAmountText.visible }
            PropertyChanges { target: txFiatAmountText; visible: txAmountText.visible && persistentSettings.fiatPriceEnabled }
            PropertyChanges { target: txDetails; visible: true }
            PropertyChanges { target: bottom; visible: true }
            PropertyChanges { target: bottomMessage; visible: false }
            PropertyChanges { target: buttons; visible: true }
            PropertyChanges { target: backButton; visible: true; secondary: true }
            PropertyChanges { target: confirmButton; visible: true }
            StateChangeScript { script: confirmButton.forceActiveFocus() }
        }, State {
            // error message being displayed, show only back button
            name: "error";
            when: errorText.text !==""
            PropertyChanges { target: dialogTitle; text: "Error" }
            PropertyChanges { target: errorText; visible: true }
            PropertyChanges { target: txAmountText; visible: false }
            PropertyChanges { target: txAmountBusyIndicator; visible: false }
            PropertyChanges { target: txFiatAmountText; visible: false }
            PropertyChanges { target: txDetails; visible: false }
            PropertyChanges { target: bottom; visible: true }
            PropertyChanges { target: bottomMessage; visible: false }
            PropertyChanges { target: buttons; visible: true }
            PropertyChanges { target: backButton; visible: true; secondary: false }
            PropertyChanges { target: confirmButton; visible: false }
            StateChangeScript { script: backButton.forceActiveFocus() }
        }, State {
            // creating or sending transaction, show tx details but don't show any button
            name: "bottomText";
            when: errorText.text =="" && bottomText.text !==""
            PropertyChanges { target: errorText; visible: false }
            PropertyChanges { target: txAmountText; visible: appWindow.transactionAmount !== "(all)" }
            PropertyChanges { target: txAmountBusyIndicator; visible: !txAmountText.visible }
            PropertyChanges { target: txFiatAmountText; visible: txAmountText.visible && persistentSettings.fiatPriceEnabled }
            PropertyChanges { target: txDetails; visible: true }
            PropertyChanges { target: bottom; visible: true }
            PropertyChanges { target: bottomMessage; visible: true }
            PropertyChanges { target: buttons; visible: false }
        }
    ]

    // same signals as Dialog has
    signal accepted()
    signal rejected()
    signal closeCallback();

    // background
    MoneroEffects.GradientBackground {
        anchors.fill: parent
        fallBackColor: MoneroComponents.Style.middlePanelBackgroundColor
        initialStartColor: MoneroComponents.Style.middlePanelBackgroundGradientStart
        initialStopColor: MoneroComponents.Style.middlePanelBackgroundGradientStop
        blackColorStart: MoneroComponents.Style._b_middlePanelBackgroundGradientStart
        blackColorStop: MoneroComponents.Style._b_middlePanelBackgroundGradientStop
        whiteColorStart: MoneroComponents.Style._w_middlePanelBackgroundGradientStart
        whiteColorStop: MoneroComponents.Style._w_middlePanelBackgroundGradientStop
        start: Qt.point(0, 0)
        end: Qt.point(height, width)
    }

    // Make window draggable
    MouseArea {
        anchors.fill: parent
        property point lastMousePos: Qt.point(0, 0)
        onPressed: { lastMousePos = Qt.point(mouseX, mouseY); }
        onMouseXChanged: root.x += (mouseX - lastMousePos.x)
        onMouseYChanged: root.y += (mouseY - lastMousePos.y)
    }

    function open() {
        // Center
        root.x = parent.width/2 - root.width/2
        root.y = 100
        root.z = 11
        root.visible = true;
        
        //clean previous error message
        errorText.text = "";        
    }
    
    function close() {
        root.visible = false;
        closeCallback();
    }

    // TODO: implement without hardcoding sizes
    width: 580
    height: 400

    ColumnLayout {
        id: mainLayout
        spacing: 10
        anchors.fill: parent
        anchors.margins: 25

        RowLayout {
            id: column
            Layout.topMargin: 10
            Layout.fillWidth: true

            MoneroComponents.Label {
                id: dialogTitle
                Layout.fillWidth: true
                fontSize: 18
                fontFamily: "Arial"
                horizontalAlignment: Text.AlignHCenter
                color: MoneroComponents.Style.defaultFontColor
                text: {
                    if (appWindow.viewOnly) {
                        "Create transaction file" + translationManager.emptyString
                    } else if (appWindow.sweepUnmixable) {
                        "Sweep unmixable outputs" + translationManager.emptyString
                    } else {
                        "Confirm send" + translationManager.emptyString                      
                    }
                }
            }
        }
        
        Text {
            id: errorText
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: MoneroComponents.Style.defaultFontColor
            text: ""
            wrapMode: Text.Wrap
            font.pixelSize: 15
        }
        
        ColumnLayout {
            id: upperText
            spacing: 0
            Layout.fillWidth: true
            Layout.preferredHeight: 71
        
            BusyIndicator {
                  id: txAmountBusyIndicator
                  Layout.fillWidth: true
                  Layout.alignment : Qt.AlignTop | Qt.AlignLeft
                  running: appWindow.transactionAmount == "(all)"
                  scale: 1
            }
        
            Text {
                id: txAmountText
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 42
                color: MoneroComponents.Style.defaultFontColor
                text: appWindow.transactionAmount + " XMR " +  translationManager.emptyString
            }
    
            Text {
                id: txFiatAmountText
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 20
                color: MoneroComponents.Style.lightGreyFontColor
                text: showFiatConversion(transactionAmount) + translationManager.emptyString
            }
        }

        GridLayout {
            columns: 2
            id: txDetails
            Layout.fillWidth: true
            columnSpacing: 15
            rowSpacing: 16

            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment : Qt.AlignTop | Qt.AlignLeft

                Text {
                    id: fromLabel
                    Layout.fillWidth: true
                    color: MoneroComponents.Style.lightGreyFontColor
                    text: qsTr("From:") + translationManager.emptyString
                    font.pixelSize: 15
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 16

                Text {
                    id: fromText
                    Layout.fillWidth: true
                    font.pixelSize: 15
                    color: MoneroComponents.Style.defaultFontColor
                    text: {
                        if (currentWallet) {
                            var walletName = appWindow.walletName;
                            var currentSubaddressAccount = currentWallet.currentSubaddressAccount;
                            var currentAccountLabel =  currentWallet.getSubaddressLabel(currentWallet.currentSubaddressAccount, 0);
                            if (currentWallet.isHwBacked() === true && currentWallet.isLedger() === true) {
                                "Ledger" + " (" + walletName + ")<br>Account #" + currentSubaddressAccount + (currentAccountLabel !== "" ? " (" + currentAccountLabel + ")" : "")
                            } else if (currentWallet.isHwBacked() === true && currentWallet.isLedger() === false) {
                                "Trezor" + " (" + walletName + ")<br>Account #" + currentSubaddressAccount + (currentAccountLabel !== "" ? " (" + currentAccountLabel + ")" : "")
                            } else {
                                qsTr("My wallet") + " (" + walletName + ")<br>Account #" + currentSubaddressAccount + (currentAccountLabel !== "" ? " (" + currentAccountLabel + ")" : "") + translationManager.emptyString
                            } 
                        } else {
                            return "";
                        }
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment : Qt.AlignTop | Qt.AlignLeft

                Text {
                    id: toLabel
                    Layout.fillWidth: true
                    font.pixelSize: 15
                    color: MoneroComponents.Style.lightGreyFontColor
                    text: qsTr("To:") + translationManager.emptyString
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 16

                Text {
                    id: toText
                    Layout.fillWidth: true
                    font.pixelSize: 15
                    font.family: MoneroComponents.Style.fontRegular.name
                    textFormat: Text.RichText
                    wrapMode: Text.Wrap
                    color: MoneroComponents.Style.defaultFontColor
                    text: {
                        if (appWindow.transactionAddress) {
                            const addressBookName = currentWallet ? currentWallet.addressBook.getDescription(appWindow.transactionAddress) : null;
                            var fulladdress = appWindow.transactionAddress;
                            var spacedaddress = fulladdress.match(/.{1,4}/g);
                            var spacedaddress = spacedaddress.join(' ');
                            if (!addressBookName) {
                                return qsTr("Monero address") + "<br>" + spacedaddress + translationManager.emptyString; 
                            } else {
                                return FontAwesome.addressBook + " " + addressBookName + "<br>" + spacedaddress;
                            }
                        } else {
                            return "";                        
                        }
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment : Qt.AlignTop | Qt.AlignLeft

                Text {
                    id: feeLabel
                    Layout.fillWidth: true
                    color: MoneroComponents.Style.lightGreyFontColor
                    text: qsTr("Fee:") + translationManager.emptyString
                    font.pixelSize: 15
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 16

                Text {
                    id: feeText
                    Layout.fillWidth: true
                    color: MoneroComponents.Style.defaultFontColor
                    font.pixelSize: 15
                    text: {
                        if (currentWallet) {
                            if (currentWallet.isHwBacked() === true) {
                                return "See on device" +  translationManager.emptyString;
                            } else {
                                if (!appWindow.transactionFee) {
                                    return "Calculating fee..." +  translationManager.emptyString;
                                } else {
                                    return appWindow.transactionFee + " XMR " + (persistentSettings.fiatPriceEnabled ? "(" + showFiatConversion(transactionFee) + ")" : "") +  translationManager.emptyString;
                                }
                            }
                        } else {
                            return "";
                        }
                    }
                }
            }
        }

        ColumnLayout {
            id: bottom
            Layout.alignment: Qt.AlignBottom | Qt.AlignHCenter
            Layout.fillWidth: true
            
            RowLayout {
                id: bottomMessage
                Layout.fillWidth: true
                Layout.preferredHeight: 50
              
                BusyIndicator {
                    id: bottomMessageBusyIndicator
                    visible: bottomTextAnimation.running == false
                    running: !appWindow.transactionFee
                    scale: .5
                }
    
                Text {
                    id: bottomText
                    color: MoneroComponents.Style.defaultFontColor
                    text: ""
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.Wrap
                    font.pixelSize: 17
                    opacity: 1
    
                    SequentialAnimation{
                        id:bottomTextAnimation
                        running: false
                        loops: Animation.Infinite
                        alwaysRunToEnd: true
                        NumberAnimation { target: bottomText; property: "opacity"; to: 0; duration: 500}
                        NumberAnimation { target: bottomText; property: "opacity"; to: 1; duration: 500}
                    }
                }
            }

            RowLayout {
                id: buttons
                spacing: 70
                Layout.fillWidth: true
                Layout.preferredHeight: 50
              
                MoneroComponents.StandardButton {
                    id: backButton
                    text: qsTr("Back") + translationManager.emptyString;
                    width: 200
                    focus: false
                    secondary: true
                    KeyNavigation.tab: confirmButton
                    Keys.enabled: backButton.visible
                    Keys.onReturnPressed: backButton.onClicked
                    Keys.onEnterPressed: backButton.onClicked
                    Keys.onEscapePressed: {
                        root.close()
                        root.rejected()
                    }
                    onClicked: {
                        root.close()
                        root.rejected()
                    }
                }
    
                MoneroComponents.StandardButton {
                    id: confirmButton
                    text: qsTr("Confirm") + translationManager.emptyString;
                    rightIcon: "qrc:///images/rightArrow.png"
                    width: 200
                    focus: true
                    KeyNavigation.tab: backButton
                    Keys.enabled: confirmButton.visible
                    Keys.onReturnPressed: confirmButton.onClicked
                    Keys.onEnterPressed: confirmButton.onClicked
                    Keys.onEscapePressed: {
                        root.close()
                        root.rejected()
                    }
                    onClicked: {
                        root.close()
                        root.accepted()
                    }
                }
            }
        }
    }

    // window borders
    Rectangle{
        width: 1
        color: MoneroComponents.Style.grey
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
    }

    Rectangle{
        width: 1
        color: MoneroComponents.Style.grey
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
    }

    Rectangle{
        height: 1
        color: MoneroComponents.Style.grey
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right
    }

    Rectangle{
        height: 1
        color: MoneroComponents.Style.grey
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.right: parent.right
    }

    function showFiatConversion(valueXMR) {
        return (fiatApiConvertToFiat(valueXMR) === "0.00" ? "<0.01 " + fiatApiCurrencySymbol() : "~" + fiatApiConvertToFiat(valueXMR) + " " + fiatApiCurrencySymbol());
    }
}
