# Wecker
Warning german text ahead!!!!

#Funktion:
    • Wecker
        ◦ „Unbegrenzte“ Anzahl der Alarme → durch RAM begrenzt
        ◦ Automatisches Finden der nächsten Werkzeit
        ◦ Licht beginnt x Min vorher
            ▪ einstellbar (1-100 Min)
    • Licht
        ◦ Jede LED einzeln ansteuerbar.
        ◦ Funktionen:
            ▪ Sonnenaufgang Version 2
                • mit rückwärts Funktion
                • Farbe überblenden
            ▪ Fade
            ▪ Binär Uhr
            ▪ Rainbow
    • Uhr
        ◦ RTC mit ±2ppm (max. 1Minute Ungenauigkeit pro Jahr)
        ◦ auch wenn der Strom weg ist
    • Fehlende Funktionen
        ◦ Wecken bei Stromausfall → Backup Batterie fürs komplette System.
#LOG:
vorher:
    • Geplant auf Arduino Basis
        ◦ Speicherfehler in ROM
        ◦ Begrenzter ROM
            ▪ wenige Schriftarten
        ◦ zu wenig „RAM“
        ◦ zu langsam
          → ESP32
    • ESP32
        ◦ Keine passende Display library → Christian
        ◦ RTC Chip keine library → Hilfe von Christian
        ◦ MP3 Player keine library
            ▪ benötigt Checksumme in UART Protokoll→ Hilfe von Christian
#20190118:
    • Holz Box
    • Schalter intrigieren
    • RTC zerstört, beim entölten von Header
        ◦ ersetzt am 20180210
Probleme:
Display zu tief für die Box → in Frontplatte eingelassen
#20190215:
    • Alarm Bildschirm
        ◦ Nerviges Ausschalten
        ◦ Ton beim Alarm
    • Tasten emulieren per Terminal
    • Error-Seite behoben
Probleme:
math.random() liefert gleiche Zahlen → math.randomseed(int) vorher ausführen
#20190222
    • LEDs am Gehäuse befestigt
    • Sonnenaufgang V2
        ◦ revers added
    • Alarm Display update
        ◦ Countdown Fehler behoben
    • RTC Modifikation
        ◦ Ladefunktion deaktiviert (da RTC für LIR2032 ausgelegt ist→Funktion bei 5V)
        ◦ LED entfernt
    • Logik Level Konverter Modifikation
        ◦ LED entfernt
#20190322
    • Implementierung der Knöpfe geändert.
        ◦ Weniger Stack/RAM
        ◦ lang-drück Funktion verfügbar
    • Nachladen vom Modi durch mehr freien Stack/RAM endlich möglich
    • Licht Einstellungs-menü
    • Zufälliger Titel beim Wecken
    • Notfall Alarm hinzugefügt
        ◦ Wenn Display/Uhr nicht erkannt wird
        ◦ damit man immer wach wird, solange Strom da ist
#20190425
    • Zufälliger Titel Beim Wecken → Fehlerquelle „Kein Titel gewählt“ behoben
    • Fehler: Abstürzen beim Wecken behoben.
    • UI Verbesserungen
        ◦ mit Rechtecken, anstatt von Leerzeichen Bereiche auf dem Display leeren
        ◦ Listen Menü – Blättern in richtige Richtung
        ◦ Neue Menüanordnung.
            ▪ Kürzeres Hauptmenü→ Einstellungsmenü hinzugefügt
            ▪ Mehr Knöpfe frei
            ▪ Belegung der Buttons verbessert → Funktion der Buttons springt weniger hin und her

#20190610
    • Sleep Timer funktioniert
    • Interne Funktionalität geändert
        ◦ Basis: TODO-Liste
    • Button Klicks Stapel sich nicht
#20190625
    • Speaker-library Verbessert
        ◦ Erkennt Zustände des MP3 Players
        ◦ Kann das MP3 nach bedarf zurücksetzen, wenn es fehlerhaft arbeitet
        ◦ keine Abstürze des „listener“
            ▪ Rückmeldung jetzt immer möglich
        ◦ verständlichere Rückmeldung im DEBUG
            ▪ nur noch selten HEX-Strings zum selbst entschlüsseln
    • Wecker verbessert
        ◦ Bessere Titelauswahl aus library direkt
        ◦ Rotes Blinken, wenn der Wecker sich automatisch deaktiviert
    • Selbst gebautes LUA-RTOS
        ◦ keine Stack Probleme mehr
        ◦ Unnötige Teile Entfernt
        ◦ Interne RTC endlich möglich
    • Fehler in BinaryClock behoben
        ◦ Symptom: Farbstreifen
#TODO:
    • LED Lichtband
        ◦ Logic-Level Converter loswerden
            ▪ braucht viel Strom (0,2W)
    • Lautsprecher
        ◦ Rauscht leise
        ◦ entstören
            ▪ MP3 Modul abschirmen → hardware
    • Wecker per WLAN stellen
    • Sync mit ntp server
