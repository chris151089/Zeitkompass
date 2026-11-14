## Speichern und Laden als JSON mit Versionsnummer (Umsetzung in M4).
extends Node

## Bei jeder inkompatiblen Formatänderung erhöhen und eine Migration ergänzen.
const SAVE_VERSION := 1
const SAVE_DIR := "user://saves"
