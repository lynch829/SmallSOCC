#!/usr/bin/python
# -*- coding: utf-8 -*-
"""
main.py

control frontend for Sparse Orthogonal Collimator SOC
"""

import sys
import os
from os.path import dirname

# We use QWidget to represent the window, QApplication as the non-vis container for the window
from OpenGL import GL
from PyQt5.QtCore import Qt, QUrl, QObject, pyqtProperty
from PyQt5.QtWidgets import QApplication
from PyQt5.QtQml import QQmlApplicationEngine, qmlRegisterType, QQmlComponent, QQmlEngine

from version import VERSION_FULL

# allow ctrl-c kill
import signal
signal.signal(signal.SIGINT, signal.SIG_DFL)

from leaflet import Leaflet


####################################################################################################
# Start GUI
if __name__ == '__main__':
    app = QApplication(sys.argv) # nonGUI control - must be initialized before any QWidgets are created

    # DEBUG
    leaf = Leaflet( 2 )
    leaf.extension = 255
    leaf2 = Leaflet( 7 )
    leaf2.extension = 175
    # END DEBUG

    engine = QQmlApplicationEngine(QUrl(os.path.join(dirname(__file__), 'main.qml')))
    sys.exit(app.exec_()) # block until window is closed - event handler