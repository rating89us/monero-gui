// Copyright (c) 2014-2019, The Monero Project
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
import QtQuick.XmlListModel 2.0
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.0
import moneroComponents.NetworkType 1.0

import "../components" as MoneroComponents

Rectangle {
    id: wizardHome
    color: "transparent"
    property alias pageHeight: pageRoot.height
    property string viewName: "wizardHome"

    ColumnLayout {
        id: pageRoot
        Layout.alignment: Qt.AlignHCenter;
        width: parent.width - 100
        Layout.fillWidth: true
        anchors.horizontalCenter: parent.horizontalCenter;

        spacing: 10

        ColumnLayout {
            Layout.fillWidth: true
            Layout.topMargin: wizardController.wizardSubViewTopMargin
            Layout.maximumWidth: wizardController.wizardSubViewWidth
            Layout.alignment: Qt.AlignHCenter
            spacing: 0

            WizardHeader {
                Layout.bottomMargin: 20
                title: qsTr("Welcome to Monero") + translationManager.emptyString
                subtitle: ""
            }

            WizardMenuItem {
                headerText: qsTr("Create a new wallet") + translationManager.emptyString
                bodyText: qsTr("Choose this option if this is your first time using Monero.") + translationManager.emptyString
                imageIcon: "qrc:///images/create-wallet.png"

                onMenuClicked: {
                    wizardController.restart();
                    wizardController.createWallet();
                    wizardStateView.state = "wizardCreateWallet1"
                }
            }

            Rectangle {
                Layout.preferredHeight: 1
                Layout.topMargin: 3
                Layout.bottomMargin: 3
                Layout.fillWidth: true
                color: MoneroComponents.Style.dividerColor
                opacity: MoneroComponents.Style.dividerOpacity
            }

            WizardMenuItem {
                headerText: qsTr("Create a new wallet from hardware") + translationManager.emptyString
                bodyText: qsTr("Connect your hardware wallet to create a new Monero wallet.") + translationManager.emptyString
                imageIcon: "qrc:///images/restore-wallet-from-hardware.png"

                onMenuClicked: {
                    wizardController.restart();
                    wizardStateView.state = "wizardCreateDevice1"
                }
            }

            Rectangle {
                Layout.preferredHeight: 1
                Layout.topMargin: 3
                Layout.bottomMargin: 3
                Layout.fillWidth: true
                color: MoneroComponents.Style.dividerColor
                opacity: MoneroComponents.Style.dividerOpacity
            }

            WizardMenuItem {
                headerText: qsTr("Open a wallet from file") + translationManager.emptyString
                bodyText: qsTr("Import an existing .keys wallet file from your computer.") + translationManager.emptyString
                imageIcon: "qrc:///images/open-wallet-from-file.png"

                onMenuClicked: {
                    wizardStateView.state = "wizardOpenWallet1"
                }
            }

            Rectangle {
                Layout.preferredHeight: 1
                Layout.topMargin: 3
                Layout.bottomMargin: 3
                Layout.fillWidth: true
                color: MoneroComponents.Style.dividerColor
                opacity: MoneroComponents.Style.dividerOpacity
            }

            WizardMenuItem {
                headerText: qsTr("Restore wallet from keys or mnemonic seed") + translationManager.emptyString
                bodyText: qsTr("Enter your private keys or 25-word mnemonic seed to restore your wallet.") + translationManager.emptyString
                imageIcon: "qrc:///images/restore-wallet.png"

                onMenuClicked: {
                    wizardController.restart();
                    wizardStateView.state = "wizardRestoreWallet1"
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 16
                spacing: 20

                MoneroComponents.StandardButton {
                    small: true
                    text: qsTr("Change wallet mode") + translationManager.emptyString

                    onClicked: {
                        wizardController.wizardStackView.backTransition = true;
                        wizardController.wizardState = 'wizardModeSelection';
                    }                    
                }

                ListView {
                    id: flagListView
                    interactive: false
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    model: langModel

                    delegate: Rectangle {
                        id: item
                        visible: locale == persistentSettings.locale
                        color: "transparent"
                        width: 150
                        height: locale == persistentSettings.locale ? 32 : 0

                        Rectangle {
                            id: flagRect
                            height: 24
                            width: 24
                            anchors.left: parent.left
                            anchors.leftMargin: 4
                            anchors.verticalCenter: parent.verticalCenter
                            color: "transparent"

                            Image {
                                anchors.fill: parent
                                source: flag
                            }
                        }

                        MoneroComponents.TextPlain {
                            anchors.left: parent.left
                            anchors.leftMargin: 30
                            font.bold: true
                            font.pixelSize: 14
                            color: MoneroComponents.Style.defaultFontColor
                            text: display_name
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                var locale_spl = locale.split("_");

                                // reload active translations
                                console.log(locale_spl[0]);
                                translationManager.setLanguage(locale_spl[0]);

                                // set wizard language settings
                                wizard.language_locale = locale;
                                wizard.language_wallet = wallet_language;
                                wizard.language_language = display_name;

                                appWindow.toggleLanguageView();
                            }
                            hoverEnabled: true
                            onEntered: parent.opacity = 1
                            onExited: parent.opacity = 0.8
                        }
                    }
                }
            }

            MoneroComponents.CheckBox2 {
                id: showAdvancedCheckbox
                Layout.topMargin: 30
                Layout.fillWidth: true
                fontSize: 15
                checked: false
                text: qsTr("Advanced options") + translationManager.emptyString
                visible: appWindow.walletMode >= 2
            }

            ListModel {
                id: networkTypeModel
                ListElement {column1: "Mainnet"; column2: ""; nettype: "mainnet"}
                ListElement {column1: "Testnet"; column2: ""; nettype: "testnet"}
                ListElement {column1: "Stagenet"; column2: ""; nettype: "stagenet"}
            }

            GridLayout {
                visible: showAdvancedCheckbox.checked && appWindow.walletMode >= 2
                columns: 4
                columnSpacing: 20
                Layout.fillWidth: true

                ColumnLayout {
                    Layout.topMargin: 4

                    MoneroComponents.Label {
                        text: qsTr("Change Network:") + translationManager.emptyString
                        fontSize: 14
                    }

                    MoneroComponents.StandardDropdown {
                        id: networkTypeDropdown
                        currentIndex: persistentSettings.nettype
                        dataModel: networkTypeModel
                        Layout.fillWidth: true
                        Layout.maximumWidth: 180
                        Layout.topMargin: 5

                        onChanged: {
                            var item = dataModel.get(currentIndex).nettype.toLowerCase();
                            if(item === "mainnet") {
                                persistentSettings.nettype = NetworkType.MAINNET
                            } else if(item === "stagenet"){
                                persistentSettings.nettype = NetworkType.STAGENET
                            } else if(item === "testnet"){
                                persistentSettings.nettype = NetworkType.TESTNET
                            }
                            appWindow.disconnectRemoteNode()
                        }
                    }
                }

                MoneroComponents.LineEdit {
                    id: kdfRoundsText
                    Layout.fillWidth: true

                    labelText: qsTr("Number of KDF rounds:") + translationManager.emptyString
                    labelFontSize: 14
                    placeholderFontSize: 16
                    placeholderText: "0"
                    validator: IntValidator { bottom: 1 }
                    text: persistentSettings.kdfRounds ? persistentSettings.kdfRounds : "1"
                    onTextChanged: {
                        kdfRoundsText.text = persistentSettings.kdfRounds = parseInt(kdfRoundsText.text) >= 1 ? parseInt(kdfRoundsText.text) : 1;
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                Item {
                    Layout.fillWidth: true
                }
            }
        }
    }

    Behavior on opacity {
        NumberAnimation {
            duration: 200;
            easing.type: Easing.InCubic;
        }
    }

    //Flags model
    XmlListModel {
        id: langModel
        source: "/lang/languages.xml"
        query: "/languages/language"

        XmlRole { name: "display_name"; query: "@display_name/string()" }
        XmlRole { name: "locale"; query: "@locale/string()" }
        XmlRole { name: "wallet_language"; query: "@wallet_language/string()" }
        XmlRole { name: "flag"; query: "@flag/string()" }
        // TODO: XmlListModel is read only, we should store current language somewhere else
        // and set current language accordingly
        XmlRole { name: "isCurrent"; query: "@enabled/string()" }

        onStatusChanged: {
            if(status === XmlListModel.Ready){
                console.log("languages available: ",count);
            }
        }
    }

    function onPageCompleted(){
        wizardController.walletOptionsIsRecoveringFromDevice = false;
    }
}
