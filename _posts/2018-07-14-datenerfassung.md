---
layout: post
title: "Datenerfassung aller Medien"
categories: IT
author: "burkhard"
---

Unsere kleine aber feine Westerheimer Bücherei ist nun online. Wir befinden uns noch in einer Testphase bzw. im Parallelbetrieb mit dem bisherigen Karteikartensystem, aber die Technik funktioniert bereits, und die Datenerfassung ist fast abgeschlossen. Wie kam es dazu, und was musste geschehen, damit unsere 3200 Medien im Internet sichtbar gemacht werden konnten?

Im März 2018 entschlossen wir uns, den Leihverkehr der Bücherei vom Karteikartensystem auf eine Bibliothekssoftware umzustellen und den Gesamtbestand aller unserer Bücher, CDs und DVDs in einem **[Online-Katalog](https://www.biblino.de/westerheim){:target="_blank"}** im Internet bereitzustellen.

Im  so einem Online-Katalog (auch [OPAC](https://de.wikipedia.org/wiki/OPAC){:target="_blank"}  genannt) kann man sich über Neuanschaffungen informieren, den Bestand durchsuchen oder einfach darin stöbern, und die Inhaltsangaben der Bücher studieren. So lassen sich schon zu Hause Anregungen für den nächsten Büchereibesuch sammeln. Der Online-Katalog informiert außerdem darüber, ob und bis wann ein Medium gerade ausgeliehen ist. Auch Vormerkungen sind online möglich.

Die dafür nötige Anschaffung von Hard- und Software wurde durch eine **großzügige Spende des Westerheimer Basarteams** ermöglicht. Hierfür auch an dieser Stelle noch einmal herzlichen Dank!

Inzwischen sind fast alle Medien in der Datenbank erfasst und auch im Online-Katalog sichtbar. Wie sind wir dabei vorgegangen? Das wollen wir hier am Beispiel eines Buchs zeigen, das hier vor mir liegt:

{% include lightcase.html src="/images/2018-07-14-datenerfassung/buch-offline.jpg" group="bilder-dieser-seite"
           title="Zu erfassendes Buch" %}

Zunächst sind wir von der bestehenden Systematik der Bücherei ausgegangen. Jedes Buch, jede CD und jede DVD hatte bereits in der "Karteikarten-Zeit" eine eigene Büchereinummer, zusammengesetzt aus der aktuellen Jahreszahl und einer fortlaufenden Nummer. Üblicherweise war z.B. "2017001" das erste im Jahr 2017 angeschaffte Buch. 

Die Nummer findet sich auf den ersten Seiten des Buchs...

{% include lightcase.html src="/images/2018-07-14-datenerfassung/nummer-im-buch.jpg" group="bilder-dieser-seite"
           title="Als erstes brauchen wir die Nummer unter dem Stempel..." %}

...und auch auf der Karteikarte, die beim Ausleihen entnommen wurde und im Benutzer-Karteikasten mit der jeweiligen Benutzer-Karte abgelegt wurde.

Aus praktischen Gründen haben wir uns dafür entschieden, das bisherige Schema auch zukünftig beizubehalten. Die Software bevorzugt achtstellige Mediennummern, so dass wir bei der Datenerfassung normalerweise lediglich eine führende "1" voranstellen mussten.

Allerdings gab es einige Fälle, in denen früher Mediennummern doppelt vergeben worden sind. Die mussten dann für die Erfassung im Computer geändert werden, denn dort muss eine Mediennummer sich eindeutig auf ein einzelnes Medium beziehen.

Die Mediennummer brauchen wir zum Auffinden eines Exemplars in der Datenbank. Dort finden sich dann die typischen Angaben wie Titel, Autor, Erscheinungsjahr, Kategorie ("Sachgruppe") und - für den Onlinekatalog wichtig - eine möglichst aussagekräftige Inhaltsangabe.

Zum Glück mussten wir in den meisten Fällen all diese Daten nicht manuell in den Computer eintippen! Diese kann die Bibliothekssoftware aus externen Datenbanken einlesen. Benötigt wird hierfür aber immer die ISBN-Nummer des jeweiligen Buchs. Wenn sie wie hier als Barcode auf dem Buch zu finden war, genügte ein gezielter "Schuss" des Barcodescanners, um sie zu erfassen.

{% include lightcase.html src="/images/2018-07-14-datenerfassung/isbn.jpg" group="bilder-dieser-seite"
           title="Über die ISBN-Nummer finden wir die Daten zum Buch im Internet" %}

Nicht alle Bücher haben so einen Barcode. Dann musste man die Nummer abtippen... Manche Bücher in unserem Bestand sind Sonderausgaben (Bertelsmann, Weltbild o.ä.) und haben daher gar keine ISBN-Nummer. Hier haben wir uns dann in den vielen Fällen die ISBN-Nummer der Originalausgabe "googeln" können. 

Doch nun zum eigentlichen Vorgang unserer Datenerfassung. Im März begannen wir damit, uns die Regale der Bücherei systematisch vorzunehmen, Buch für Buch und bewaffnet mit unserem Barcodescanner.  Medien- und ISBN-Nummern haben wir dann im Büchereicomputer in eine Tabelle eingetragen:

{% include lightcase.html src="/images/2018-07-14-datenerfassung/medienliste.png" group="bilder-dieser-seite"
           title="Offline-Ersterfassung in der Bücherei, in einer Excel-Tabelle" %}

Jedes auf diese Weise erfasste Buch haben wir dann noch auf seiner Karteikarte mit einem grünen Haken markiert und dann ins Regal zurückgestellt. Bei der Rückgabe eines Buchs konnten wir dann mit einem Blick auf die Karteikarte feststellen, ob es noch in die Tabelle eingetragen werden musste. Denn der Leihverkehr lief natürlich während all der Monate ganz normal weiter, so dass sich aus den Rückgaben immer wieder Nachzügler für die Datenerfassung ergaben.

{% include lightcase.html src="/images/2018-07-14-datenerfassung/Karteikarte.jpg" group="bilder-dieser-seite"
           title="Grüner Haken: Dieses Buch ist schon in unserer Medienliste" %}

Für die Ersterfassung der minimal benötigten Daten - Mediennummer und ISBN-Nummer - in der Tabelle wurde noch kein Internetzugang benötigt, und auch der Umgang mit der Büchereisoftware war dafür noch nicht notwendig. So konnten sich von Anfang an alle Mitglieder des Büchereiteams an diesem Vorgang beteiligen, auch wenn sie kein internetfähiges Smartphone dabei hatten (das Büchereigebäude selbst hat leider noch keinen eigenen DSL-Anschluss). Auch außerhalb des regulären Büchereidienstes haben wir viele weitere Stunden in der Bücherei verbracht, um die Regale durchzuarbeiten.

Den aktuellen Stand der Medienliste habe ich mir dann regelmäßig auf einen USB-Stick kopiert und nach Hause mitgenommen, um die Daten in der Bücherei-Datenbank zu vervollständigen. Dafür musste für jedes Medium dessen Mediennummer und ISBN-Nummer in die Eingabemaske unserer Büchereisoftware eingetragen werden. Also kopierte ich diese Nummern aus einem Excel-Fenster in die Maske. Nach Klick auf einen weiteren Button versucht das Programm dann, die restlichen Daten aus dem Internet zu laden.

{% include lightcase.html src="/images/2018-07-14-datenerfassung/erfassung-ps-biblio.png" group="bilder-dieser-seite"
           title="Jetzt wird das Buch in die Büchereisoftware aufgenommen" %}

Im Idealfall sah das Ergebnis dann so wie in diesem Screenshot aus. Im Normalfall musste aber an einigen Stellen nachbearbeitet werden. In Hinblick auf den Online-Katalog war uns besonders wichtig, dass soweit wie möglich die Inhaltsangaben vorhanden waren, was teilweise weitere Online-Recherche erforderte. Manchmal wurde auch der Klappentext abgetippt...

Für den zukünftigen Leihverkehr benötigt nun jedes Medium einen Aufkleber, auf den die Mediennummer und dessen Barcode gedruckt ist. Beim Ausleihen oder Zurückgeben muss dann nur die Buchrückseite unter den Scanner gehalten werden, um das Medium in der Datenbank als verliehen oder verfügbar zu kennzeichnen.

Die Barcode-Aufkleber können bequem aus der Software heraus gedruckt werden, 40 Aufkleber passen auf einen Bogen mit Zweckform-Etiketten. Aufwendiger war wiederum das Heraussuchen und Bekleben jedes einzelnen Mediums. Dabei müssen die Barcode-Aufkleber zusätzlich noch mit einer Klebefolie geschützt werden, damit sie den manchmal rauen Büchereialltag überstehen.

{% include lightcase.html src="/images/2018-07-14-datenerfassung/barcode-aufkleber.jpg" group="bilder-dieser-seite"
           title="...aus der Software drucken wir die Barcode-Aufkleber" %}

Nach der Ersterfassung aller Daten wurde schließlich die Datenbank auf den Büchereicomputer übertragen. Der Online-Katalog wird von uns nun regelmäßig mit dieser Datenbank synchronisiert, so dass Medien- und Verfügbarkeitsinformationen auf dem aktuellen Stand bleiben.

Und nun ist auch unser Buch online!

{% include lightcase.html group="bilder-dieser-seite"
           src="/images/2018-07-14-datenerfassung/buch-online.png" 
           big="/images/2018-07-14-datenerfassung/buch-online-gross.png" 
           title="Nach der Synchronisation findet man unser Buch auch im Online-Katalog" %}

Und ebenso wie das Buch "So kommt der Motor unter die Haube" haben uns von März bis Juli 2018 gut 3200 weitere Bücher, CDs und DVDs etliche Stunden lang beschäftigt.

Zum IT-gestützten Büchereibetrieb gehören auch Ausweise mit Benutzernummern und Barcodes für jeden Benutzer. Diese bereiten wir ebenfalls vor. Doch das wäre eine andere Geschichte...
