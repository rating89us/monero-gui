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
import QtQuick.Controls 2.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import FontAwesome 1.0

import "../components" as MoneroComponents
import "../components/effects/" as MoneroEffects

import moneroComponents.Clipboard 1.0
import moneroComponents.Wallet 1.0
import moneroComponents.WalletManager 1.0
import moneroComponents.TransactionHistory 1.0
import moneroComponents.TransactionHistoryModel 1.0
import moneroComponents.Subaddress 1.0
import moneroComponents.SubaddressModel 1.0
import "../js/TxUtils.js" as TxUtils

Rectangle {
    id: pageReceive
    color: "transparent"
    property var model
    property alias receiveHeight: mainLayout.height
    property var lastCreatedAddressAccount
    property int lastCreatedAddressIndex
    property var lastCreatedAddressLabel
    property var lastCreatedAddress
    property bool lastCreatedAddressDisplayed: false
    property bool createAddressOnPageLoad: true
    property bool askLabelWhenCreatingAddress: false
    
    function renameSubaddressLabel(_index){
        inputDialog.labelText = qsTr("Set the label of the selected address:") + translationManager.emptyString;
        inputDialog.onAcceptedCallback = function() {
            
            var ScrollBarPositionBeforeSettingLabel = scrolll.position;
            console.log("scrolll.position (before set label): " + scrolll.position);
            appWindow.currentWallet.subaddress.setLabel(appWindow.currentWallet.currentSubaddressAccount, _index, inputDialog.inputText);
            if (_index == lastCreatedAddressIndex) {
                console.log("is editing FRESH address")
                pageReceive.lastCreatedAddressLabel = inputDialog.inputText;
            } else {
                console.log("is editing USED address")
                scrolll.position = ScrollBarPositionBeforeSettingLabel;
                console.log("scrolll.position (after set label): " + scrolll.position);
            }
        }
        inputDialog.onRejectedCallback = null;
        inputDialog.open(appWindow.currentWallet.getSubaddressLabel(appWindow.currentWallet.currentSubaddressAccount, _index))
    }

    Clipboard { id: clipboard }

    /* main layout */
    RowLayout {
        id: mainLayout
        anchors.margins: 20
        anchors.topMargin: 40

        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right

        spacing: 20

        ColumnLayout {
            id: leftColumn
            spacing: 0
            Layout.alignment: Qt.AlignTop 

            MoneroComponents.Label {
                id: receivePaymentTitleLabel
                fontSize: 24
                text: qsTr("Receive payment") + translationManager.emptyString
            }            
            
            ColumnLayout {
                id: freshAddressColumn
                visible: pageReceive.lastCreatedAddressIndex != ""
                Layout.topMargin: 10
                               
                MoneroComponents.TextPlain {
                    id: freshAddressLabel
                    text: lastCreatedAddressDisplayed ? qsTr("Fresh address (displayed)") : qsTr("Fresh address") + translationManager.emptyString
                    Layout.fillWidth: true
                    color: MoneroComponents.Style.defaultFontColor
                    font.pixelSize: 15
                    font.family: MoneroComponents.Style.fontRegular.name
                    themeTransition: false
                }
                
                Rectangle {
                    id: tableItem2b
                    height: subaddressListRow.subaddressListItemHeight
                    width: parent.width
                    Layout.fillWidth: true
                    Layout.topMargin: 5
                    color: "transparent"
    
                    Rectangle {
                        anchors.right: parent.right
                        anchors.left: parent.left
                        anchors.top: parent.top
                        height: 1
                        color: MoneroComponents.Style.appWindowBorderColor
  
                        MoneroEffects.ColorTransition {
                            targetObj: parent
                            blackColor: MoneroComponents.Style._b_appWindowBorderColor
                            whiteColor: MoneroComponents.Style._w_appWindowBorderColor
                        }
                    }
  
                    RowLayout {
                        id: itemRowb
                        Layout.topMargin: 5
                        Layout.rightMargin: 5
                        //Layout.rightMargin: 80
  
                        MoneroComponents.Label {
                            id: idLabelb
                            color: appWindow.current_subaddress_table_index === pageReceive.lastCreatedAddressIndex ? MoneroComponents.Style.defaultFontColor : "#757575"
                            Layout.alignment: Qt.AlignVCenter
                            Layout.leftMargin: 6
                            width: 27
                            fontSize: 16
                            text: {
                                var freshAddressIndex = pageReceive.lastCreatedAddressIndex;
                                 "#" + freshAddressIndex  
                            }
                            themeTransition: false
                        }
                        
                        ColumnLayout {
                            id: columnb
                            spacing: 0
                            Layout.leftMargin: 11
                            
                            MoneroComponents.Label {
                                id: nameLabelb
                                Layout.topMargin: 6
                                color: MoneroComponents.Style.dimmedFontColor
                                fontSize: 15
                                text: pageReceive.lastCreatedAddressLabel == "" ? qsTr("(no label)") : pageReceive.lastCreatedAddressLabel + translationManager.emptyString;
                                elide: Text.ElideRight
                                textWidth: 300
                                themeTransition: false
                            }
      
                            MoneroComponents.Label {
                                id: addressLabelb
                                Layout.topMargin: 3
                                color: MoneroComponents.Style.defaultFontColor
                                fontSize: 15
                                fontFamily: MoneroComponents.Style.fontMonoRegular.name;
                                text: TxUtils.addressTruncatePretty(pageReceive.lastCreatedAddress, 2)
                                themeTransition: false
                            }
                        }
                    }
                    
                    RowLayout {
                        id: buttonsRowb
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                        anchors.rightMargin: 6
                        height: 21
                        spacing: 10
  
                        MoneroComponents.IconButton {
                            id: renameButtonb
                            image: "qrc:///images/edit.svg"
                            color: MoneroComponents.Style.defaultFontColor
                            opacity: 0.5
                            Layout.preferredWidth: 23
                            Layout.preferredHeight: 21
                            visible: index !== 0
  
                            onClicked: {
                                console.log("pageReceive.lastCreatedAddressLabel (before): " + pageReceive.lastCreatedAddressLabel);
                                renameSubaddressLabel(pageReceive.lastCreatedAddressIndex);
                            }
                        }
  
                        MoneroComponents.IconButton {
                            id: copyButtonb
                            image: "qrc:///images/copy.svg"
                            color: MoneroComponents.Style.defaultFontColor
                            opacity: 0.5
                            Layout.preferredWidth: 16
                            Layout.preferredHeight: 21
  
                            onClicked: {
                                console.log("Fresh address copied to clipboard");
                                console.log("receivePaymentTitleLabel.width: " + receivePaymentTitleLabel.width);
                                clipboard.setText(pageReceive.lastCreatedAddress);
                                appWindow.showStatusMessage(qsTr("Fresh address copied to clipboard"),3);
                                pageReceive.lastCreatedAddressDisplayed = true;
                            }
                        }
                    }

                    Rectangle {
                        anchors.right: parent.right
                        anchors.left: parent.left
                        anchors.bottom: parent.bottom
                        height: 1
                        color: MoneroComponents.Style.appWindowBorderColor
  
                        MoneroEffects.ColorTransition {
                            targetObj: parent
                            blackColor: MoneroComponents.Style._b_appWindowBorderColor
                            whiteColor: MoneroComponents.Style._w_appWindowBorderColor
                        }
                    }

                    MouseArea {
                        cursorShape: Qt.PointingHandCursor
                        width: tableItem2b.width - buttonsRowb.width - 15 //rightMargin of buttonsRowb
                        Layout.rightMargin: 15
                        height: tableItem2b.height
                        hoverEnabled: true
                        onEntered: tableItem2b.color = MoneroComponents.Style.titleBarButtonHoverColor
                        onExited: tableItem2b.color = "transparent"
                        onClicked: {
                            if (rightColumn.visible && subaddressListView.currentIndex == pageReceive.lastCreatedAddressIndex) {
                                rightColumn.visible = false;                                     
                            } else {
                                subaddressListView.currentIndex = pageReceive.lastCreatedAddressIndex;
                                rightColumn.visible = true;
                                pageReceive.lastCreatedAddressDisplayed = true;                              
                            }
                        }
                    }
                }
            }

            RowLayout {
                Layout.topMargin: 7
                Layout.fillWidth: true
                            
                MoneroComponents.CheckBox2 {
                    id: showUsedAddressesCheckbox
                    text: qsTr("Previous addresses") + translationManager.emptyString
                    checked: false
                }
                
                Rectangle {
                  id: spacerRetangle
                  Layout.fillWidth:true
                  color: "transparent"
                }
                
                MoneroComponents.StandardButton {
                    id: createAddressButton
                    small: true
                    text: qsTr("+ Create address") + translationManager.emptyString
                    fontSize: 13
                    onClicked: {
                        inputDialog.labelText = qsTr("Please add a label to your new address:") + translationManager.emptyString
                        inputDialog.onAcceptedCallback = function() {
                            
                            //creates new address
                            console.log("creating address with button");
                            pageReceive.lastCreatedAddressLabel = inputDialog.inputText;
                            appWindow.currentWallet.subaddress.addRow(appWindow.currentWallet.currentSubaddressAccount, pageReceive.lastCreatedAddressLabel)
                                                      
                            pageReceive.lastCreatedAddressAccount = appWindow.currentWallet.currentSubaddressAccount;
                            pageReceive.lastCreatedAddressIndex = appWindow.currentWallet.numSubaddresses(appWindow.currentWallet.currentSubaddressAccount) - 1
                            pageReceive.lastCreatedAddress = appWindow.currentWallet.address(appWindow.currentWallet.currentSubaddressAccount, pageReceive.lastCreatedAddressIndex);                     

                            current_subaddress_table_index = pageReceive.lastCreatedAddressIndex
                            subaddressListView.currentIndex = current_subaddress_table_index

                            if (subaddressListView.currentIndex == pageReceive.lastCreatedAddressIndex && rightColumn.visible) {
                                pageReceive.lastCreatedAddressDisplayed = true;
                            }
                        }
                        inputDialog.onRejectedCallback = null;
                        inputDialog.open()
                    }
                }
            }

            ColumnLayout {
                id: subaddressListRow
                property int subaddressListItemHeight: 50
                visible: showUsedAddressesCheckbox.checked && subaddressListView.count > 2
                Layout.alignment: Qt.AlignTop
                Layout.topMargin: 6
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                Layout.maximumHeight: subaddressListRow.Layout.preferredHeight
                //Layout.preferredHeight: 380
                Layout.preferredHeight: (subaddressListRow.subaddressListItemHeight * (subaddressListView.count -1)) < 401 ? (subaddressListRow.subaddressListItemHeight * (subaddressListView.count -1)) : 401

                ListView {
                    id: subaddressListView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    //Layout.fillHeight: false
                    //Layout.preferredHeight: 380
                    clip: true
                    boundsBehavior: ListView.StopAtBounds
                    interactive: true
                    verticalLayoutDirection: ListView.BottomToTop
                    ScrollBar.vertical: ScrollBar {
                        id: scrolll
                        onActiveChanged: if (!active && !isMac) active = true
                    }

                    delegate: Rectangle {
                        id: tableItem2
                        height: index == pageReceive.lastCreatedAddressIndex ? 0 : subaddressListRow.subaddressListItemHeight
                        width: parent.width
                        Layout.fillWidth: true
                        color: "transparent"

                        Rectangle {
                            anchors.right: parent.right
                            anchors.left: parent.left
                            anchors.top: parent.top
                            height: 1
                            color: MoneroComponents.Style.appWindowBorderColor

                            MoneroEffects.ColorTransition {
                                targetObj: parent
                                blackColor: MoneroComponents.Style._b_appWindowBorderColor
                                whiteColor: MoneroComponents.Style._w_appWindowBorderColor
                            }
                        }

                        RowLayout {
                            id: itemRow
                            Layout.topMargin: 5
                            Layout.rightMargin: 5
                            visible: index == pageReceive.lastCreatedAddressIndex ? false : true

                            MoneroComponents.Label {
                                id: idLabel
                                color: index === appWindow.current_subaddress_table_index ? MoneroComponents.Style.defaultFontColor : "#757575"
                                Layout.alignment: Qt.AlignVCenter
                                Layout.leftMargin: 6
                                width: 27
                                fontSize: 16
                                text: "#" + index
                                themeTransition: false
                            }

                            ColumnLayout {
                                id: columna
                                spacing: 0
                                Layout.leftMargin: 11

                                MoneroComponents.Label {
                                    id: nameLabel
                                    Layout.topMargin: 6
                                    color: MoneroComponents.Style.dimmedFontColor
                                    fontSize: 15
                                    text: {
                                        if (index == 0) {
                                            qsTr("Primary address")  + translationManager.emptyString
                                        } else {
                                            if (label) {
                                                label
                                            } else {
                                                qsTr("(no label)") + translationManager.emptyString
                                            }
                                        }
                                    }
                                    elide: Text.ElideRight
                                    textWidth: 300
                                    themeTransition: false
                                }  
                                MoneroComponents.Label {
                                    id: addressLabel
                                    Layout.topMargin: 3
                                    color: MoneroComponents.Style.defaultFontColor
                                    fontSize: 15
                                    fontFamily: MoneroComponents.Style.fontMonoRegular.name;
                                    text: TxUtils.addressTruncatePretty(address, 2)
                                    themeTransition: false
                                }
                            }
                        }

                        RowLayout {
                            id: buttonsRow
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                            anchors.rightMargin: 15
                            height: 21
                            spacing: 10
                            visible: index == pageReceive.lastCreatedAddressIndex ? false : true

                            MoneroComponents.IconButton {
                                id: renameButton
                                image: "qrc:///images/edit.svg"
                                color: MoneroComponents.Style.defaultFontColor
                                opacity: 0.5
                                Layout.preferredWidth: 23
                                Layout.preferredHeight: 21
                                visible: index !== 0

                                onClicked: {
                                    renameSubaddressLabel(index);
                                }
                            }

                            MoneroComponents.IconButton {
                                id: copyButton
                                image: "qrc:///images/copy.svg"
                                color: MoneroComponents.Style.defaultFontColor
                                opacity: 0.5
                                Layout.preferredWidth: 16
                                Layout.preferredHeight: 21

                                onClicked: {
                                    console.log("Address copied to clipboard");
                                    console.log("idLabelb.width: " + idLabelb.width);
                                    console.log("idLabel.width: " + idLabel.width);
                                    console.log("subaddressListView.height: " + subaddressListView.height);
                                    console.log("subaddressListRow.Layout.preferredHeight: " + subaddressListRow.Layout.preferredHeight);
                                    console.log("subaddressListRow.subaddressListItemHeight : " + subaddressListRow.subaddressListItemHeight);
                                    console.log("subaddressListView.count : " + subaddressListView.count);                                    
                                    clipboard.setText(address);
                                    appWindow.showStatusMessage(qsTr("Address copied to clipboard"),3);
                                    
                                    if (index == pageReceive.lastCreatedAddressIndex) {
                                        console.log("Selected lastCreatedAddress. Displaying...")
                                        pageReceive.lastCreatedAddressDisplayed = true;
                                    }
                                }
                            }
                        }
                        
                        Rectangle {
                            id: rect123
                            anchors.right: parent.right
                            anchors.left: parent.left
                            //Layout.alignment: Qt.AlignBottom
                            anchors.bottom: parent.bottom
                            height: 1
                            color: MoneroComponents.Style.appWindowBorderColor
                            visible: index == 0

                            MoneroEffects.ColorTransition {
                                targetObj: parent
                                blackColor: MoneroComponents.Style._b_appWindowBorderColor
                                whiteColor: MoneroComponents.Style._w_appWindowBorderColor
                            }
                        }
                        
                        MouseArea {
                            cursorShape: Qt.PointingHandCursor
                            //anchors.fill: tableItem2
                            width: tableItem2.width - buttonsRow.width - 15 //rightMargin of buttonsRow
                            //Layout.fillWidth: true
                            //Layout.fillHeight: true
                            Layout.rightMargin: 15
                            height: tableItem2.height
                            hoverEnabled: true
                            onEntered: tableItem2.color = MoneroComponents.Style.titleBarButtonHoverColor
                            onExited: tableItem2.color = "transparent"
                            onClicked: {
                                if (rightColumn.visible && subaddressListView.currentIndex == index) {
                                    rightColumn.visible = false;                                     
                                } else {
                                    subaddressListView.currentIndex = index;
                                    if (subaddressListView.currentIndex == pageReceive.lastCreatedAddressIndex) {
                                        console.log("Selected lastCreatedAddress. Displaying...")
                                        pageReceive.lastCreatedAddressDisplayed = true;
                                    }
                                    rightColumn.visible = true;  
                                }
                                //TODO: see case used address closed and selected with address different from fresh address
                            }
                        }               
                    }
                    onCurrentItemChanged: {
                        // reset global vars
                        console.log("scrolll.position (itemchanged): " + scrolll.position);
                        
                        appWindow.current_subaddress_table_index = subaddressListView.currentIndex;
                        appWindow.current_address = appWindow.currentWallet.address(
                            appWindow.currentWallet.currentSubaddressAccount,
                            subaddressListView.currentIndex
                        );
                        
                        var selectedAddressLabel = appWindow.currentWallet.getSubaddressLabel(appWindow.currentWallet.currentSubaddressAccount, appWindow.current_subaddress_table_index);
                        if (selectedAddressLabel == "") {
                            addressLabelRightColumn.text = qsTr("(no label)") + translationManager.emptyString
                        } else {
                            addressLabelRightColumn.text = selectedAddressLabel
                        }                        
                    }
                }
            }
        }

        ColumnLayout {
            id: rightColumn
            Layout.alignment: Qt.AlignTop | Qt.AlignHCenter
            Layout.topMargin: 75
            spacing: 11
            property int qrSize: 220
            visible: false

            Rectangle {
                id: qrContainer
                color: MoneroComponents.Style.blackTheme ? "white" : "transparent"
                Layout.fillWidth: true
                Layout.maximumWidth: parent.qrSize
                Layout.preferredHeight: width
                radius: 4

                Image {
                    id: qrCode
                    anchors.fill: parent
                    anchors.margins: 1

                    smooth: false
                    fillMode: Image.PreserveAspectFit
                    source: "image://qrcode/" + TxUtils.makeQRCodeString(appWindow.current_address)

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.RightButton
                        onPressAndHold: qrFileDialog.open()
                    }
                }
            }
            
            MoneroComponents.TextPlain {
                id: addressIndexRightColumn
                Layout.alignment: Qt.AlignHCenter
                //Layout.fillWidth: true
                Layout.maximumWidth: parent.qrSize
                text: qsTr("Address #") + subaddressListView.currentIndex + translationManager.emptyString
                wrapMode: Text.WordWrap
                font.family: MoneroComponents.Style.fontRegular.name
                font.pixelSize: 17
                textFormat: Text.RichText
                color: MoneroComponents.Style.defaultFontColor
                themeTransition: false
            }
            
            MoneroComponents.TextPlain {
                id: addressLabelRightColumn
                Layout.alignment: Qt.AlignHCenter
                Layout.maximumWidth: parent.qrSize
                text: {
                    var selectedAddressLabel = appWindow.currentWallet.getSubaddressLabel(appWindow.currentWallet.currentSubaddressAccount, appWindow.current_subaddress_table_index);
                    if (selectedAddressLabel == "") {
                        "#" + subaddressListView.currentIndex + " " + qsTr("(no label)") + translationManager.emptyString
                    } else {
                        "#" + subaddressListView.currentIndex + " " + selectedAddressLabel
                    }
                }
                wrapMode: Text.WordWrap
                font.family: MoneroComponents.Style.fontRegular.name
                font.pixelSize: 17
                textFormat: Text.RichText
                color: MoneroComponents.Style.dimmedFontColor
                themeTransition: false
            }

            MoneroComponents.TextPlain {
                id: addressRightColumn
                Layout.alignment: Qt.AlignHCenter
                Layout.maximumWidth: parent.qrSize
                text: appWindow.current_address
                horizontalAlignment: TextInput.AlignHCenter
                wrapMode: Text.Wrap
                textFormat: Text.RichText
                color: MoneroComponents.Style.defaultFontColor
                font.pixelSize: 15
                font.family: MoneroComponents.Style.fontRegular.name
                themeTransition: false
                MouseArea {
                    hoverEnabled: true
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onEntered: parent.color = MoneroComponents.Style.orange
                    onExited: parent.color = MoneroComponents.Style.defaultFontColor
                    onClicked: {
                      clipboard.setText(appWindow.current_address);
                      appWindow.showStatusMessage(qsTr("Copied to clipboard") + translationManager.emptyString, 3);    
                    }
                }
            }

            MoneroComponents.StandardButton {
                Layout.preferredWidth: 220
                small: true
                text: qsTr("Save as image") + translationManager.emptyString
                fontSize: 14
                onClicked: qrFileDialog.open()
            }
            
            MoneroComponents.StandardButton {
                Layout.preferredWidth: 220
                small: true
                text: qsTr("Edit label") + translationManager.emptyString
                fontSize: 14
                onClicked: renameSubaddressLabel(appWindow.current_subaddress_table_index);
            }

            MoneroComponents.StandardButton {
                Layout.preferredWidth: 220
                small: true
                text: qsTr("Copy to clipboard") + translationManager.emptyString
                fontSize: 14
                onClicked: {
                    clipboard.setText(appWindow.current_address);
                    appWindow.showStatusMessage(qsTr("Copied to clipboard") + translationManager.emptyString, 3);
                }
            }

            MoneroComponents.StandardButton {
                Layout.preferredWidth: 220
                small: true
                text: qsTr("Show on device") + translationManager.emptyString
                fontSize: 14
                visible: appWindow.currentWallet ? appWindow.currentWallet.isHwBacked() : false
                onClicked: {
                    appWindow.currentWallet.deviceShowAddressAsync(
                        appWindow.currentWallet.currentSubaddressAccount,
                        appWindow.current_subaddress_table_index,
                        '');
                }
            }
        }

        MessageDialog {
            id: receivePageDialog
            standardButtons: StandardButton.Ok
        }

        FileDialog {
            id: qrFileDialog
            title: qsTr("Please choose a name") + translationManager.emptyString
            folder: shortcuts.pictures
            selectExisting: false
            nameFilters: ["Image (*.png)"]
            onAccepted: {
                if(!walletManager.saveQrCode(TxUtils.makeQRCodeString(appWindow.current_address), walletManager.urlToLocalPath(fileUrl))) {
                    console.log("Failed to save QrCode to file " + walletManager.urlToLocalPath(fileUrl) )
                    receivePageDialog.title = qsTr("Save QrCode") + translationManager.emptyString;
                    receivePageDialog.text = qsTr("Failed to save QrCode to ") + walletManager.urlToLocalPath(fileUrl) + translationManager.emptyString;
                    receivePageDialog.icon = StandardIcon.Error
                    receivePageDialog.open()
                }
            }
        }
    }

    function handleCreateAddressOnPageLoad() {
        if (createAddressOnPageLoad) {
            console.log("createAddressOnPageLoad = true");
            console.log("==========BEFORE CREATING ADDRESS==========");
            console.log("appWindow.currentWallet.numSubaddresses(appWindow.currentWallet.currentSubaddressAccount): " + appWindow.currentWallet.numSubaddresses(appWindow.currentWallet.currentSubaddressAccount));
            console.log("current_subaddress_table_index: " + current_subaddress_table_index);                           
            console.log ("subaddressListView.currentIndex: " + subaddressListView.currentIndex);
            console.log("pageReceive.lastCreatedAddressIndex: " + pageReceive.lastCreatedAddressIndex);
            
            if (askLabelWhenCreatingAddress) {
                inputDialog.labelText = qsTr("Add payment purpose or person/company you are giving this address (optional):") + translationManager.emptyString
                inputDialog.onAcceptedCallback = function() {
                    pageReceive.lastCreatedAddressLabel = inputDialog.inputText;
                }
                inputDialog.onRejectedCallback = null;
                inputDialog.open()              
            } else {
                pageReceive.lastCreatedAddressLabel = "";
            }
            //creates new address            
            appWindow.currentWallet.subaddress.addRow(appWindow.currentWallet.currentSubaddressAccount, pageReceive.lastCreatedAddressLabel)
            pageReceive.lastCreatedAddressAccount = appWindow.currentWallet.currentSubaddressAccount;
            pageReceive.lastCreatedAddressIndex = appWindow.currentWallet.numSubaddresses(appWindow.currentWallet.currentSubaddressAccount) - 1
            pageReceive.lastCreatedAddress = appWindow.currentWallet.address(appWindow.currentWallet.currentSubaddressAccount, pageReceive.lastCreatedAddressIndex);                     
            current_subaddress_table_index = pageReceive.lastCreatedAddressIndex
            subaddressListView.currentIndex = current_subaddress_table_index
            pageReceive.lastCreatedAddressDisplayed = false;
  //          appWindow.currentWallet.setLastCreatedAddressDisplayedStatus(pageReceive.lastCreatedAddressAccount, pageReceive.lastCreatedAddressDisplayed)
            
            console.log("==========AFTER CREATING ADDRESS==========");
            console.log("appWindow.currentWallet.numSubaddresses(appWindow.currentWallet.currentSubaddressAccount): " + appWindow.currentWallet.numSubaddresses(appWindow.currentWallet.currentSubaddressAccount));
            console.log("current_subaddress_table_index: " + current_subaddress_table_index);                           
            console.log ("subaddressListView.currentIndex: " + subaddressListView.currentIndex);
            console.log("pageReceive.lastCreatedAddressIndex: " + pageReceive.lastCreatedAddressIndex);
            console.log("========================================================");
            console.log("pageReceive.lastCreatedAddressAccount: " + pageReceive.lastCreatedAddressAccount);
            console.log("pageReceive.lastCreatedAddressLabel: " + pageReceive.lastCreatedAddressLabel);
            console.log("pageReceive.lastCreatedAddress: " + pageReceive.lastCreatedAddress);
                                        
            if (subaddressListView.currentIndex == pageReceive.lastCreatedAddressIndex && rightColumn.visible) {
                console.log("Created address with used adress list opened and rightColumn visible. Mark as displayed...")
                pageReceive.lastCreatedAddressDisplayed = true;
    //            appWindow.currentWallet.setLastCreatedAddressDisplayedStatus(pageReceive.lastCreatedAddressAccount, pageReceive.lastCreatedAddressDisplayed)
            }
        }
    }

    function onPageCompleted() {
        console.log("Receive page loaded");
        console.log("subaddressListView.currentIndex0: " + subaddressListView.currentIndex);
        console.log("pageReceive.lastCreatedAddressIndex: " + pageReceive.lastCreatedAddressIndex);
        console.log("pageReceive.lastCreatedAddressLabel: " + pageReceive.lastCreatedAddressLabel);
        console.log("pageReceive.lastCreatedAddress: " + pageReceive.lastCreatedAddress);
        console.log("pageReceive.lastCreatedAddressAccount: " + pageReceive.lastCreatedAddressAccount);
        console.log("appWindow.currentWallet.currentSubaddressAccount: " + appWindow.currentWallet.currentSubaddressAccount);        

        subaddressListView.model = appWindow.currentWallet.subaddressModel

        if (appWindow.currentWallet) {
            appWindow.current_address = appWindow.currentWallet.address(appWindow.currentWallet.currentSubaddressAccount, 0)
            appWindow.currentWallet.subaddress.refresh(appWindow.currentWallet.currentSubaddressAccount)
        }
                                
        //new code:
        
    //    if (appWindow.currentWallet.getLastCreatedAddressDisplayedStatus(appWindow.currentWallet.currentSubaddressAccount) == true) {
    //        console.log("last created address of this account was displayed. Create a new address")
    //        handleCreateAddressOnPageLoad()
    //    } else {
    //        console.log("last created address of this account was NOT displayed. Don't create a new address")
    //    }
        
        
        //current code:
        
        if (appWindow.currentWallet.numSubaddresses(appWindow.currentWallet.currentSubaddressAccount) == 1) {
            //never use the first address of an account (regardless if it's 4... or 8...)
            console.log("first load of receive page of a primary/secondary account with no subaddress, a fresh subaddress must be created");
            handleCreateAddressOnPageLoad()
        }
        
        if (pageReceive.lastCreatedAddressAccount >= 0 && (appWindow.currentWallet.currentSubaddressAccount != pageReceive.lastCreatedAddressAccount)) {
            console.log("account changed")
            handleCreateAddressOnPageLoad()
        }
        if (pageReceive.lastCreatedAddress && lastCreatedAddressDisplayed) {
            console.log("lastCreatedAddress exists and was displayed. Create a new one")
            handleCreateAddressOnPageLoad()            
        }        
        if (pageReceive.lastCreatedAddress && !lastCreatedAddressDisplayed) {
            console.log("lastCreatedAddress exists but wasn't displayed. Don't create a new one")
        }
        if (!pageReceive.lastCreatedAddress && lastCreatedAddressDisplayed) {
            console.log("lastCreatedAddress doesn't exists but was displayed. Create a new one")
            handleCreateAddressOnPageLoad()
        }
        if (!pageReceive.lastCreatedAddress && !lastCreatedAddressDisplayed) {
            console.log("lastCreatedAddress doesn't exists and wasn't displayed. Wallet was closed and now it reopening")
            handleCreateAddressOnPageLoad()  
        }
    }

    function clearFields() {
        // @TODO: add fields
    }

    function onPageClosed() {
        showUsedAddressesCheckbox.checked = false;
        rightColumn.visible = false;
        
        if (lastCreatedAddressDisplayed) {
            pageReceive.lastCreatedAddressIndex = "";
            pageReceive.lastCreatedAddressLabel = "";
            pageReceive.lastCreatedAddress = "";
        }
        console.log("Receive page closed");
        console.log("subaddressListView.currentIndex0: " + subaddressListView.currentIndex);
        console.log("pageReceive.lastCreatedAddressIndex: " + pageReceive.lastCreatedAddressIndex);
        console.log("pageReceive.lastCreatedAddressLabel: " + pageReceive.lastCreatedAddressLabel);
        console.log("pageReceive.lastCreatedAddress: " + pageReceive.lastCreatedAddress);
        console.log("pageReceive.lastCreatedAddressAccount: " + pageReceive.lastCreatedAddressAccount);
        console.log("appWindow.currentWallet.currentSubaddressAccount: " + appWindow.currentWallet.currentSubaddressAccount);        
    }
}
