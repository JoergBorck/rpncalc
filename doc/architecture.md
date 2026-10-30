# Architektur-Dokumentation: RPN-Calculator (Compiler-Design)

Dieses Dokument beschreibt die Softwarearchitektur des **CLI RPN Calculators**. Die Anwendung nutzt ein klassisches Compiler-Frontend-Design (Grammatik, DEA, Parser), um Benutzereingaben zu validieren und in Befehle für die RPN-Engine (Calculator) zu übersetzen.

## 1. Systemübersicht & Schichtenmodell

Die Architektur ist ein Schichtenmodell. Jede Schicht hat ihre Aufgabe beim Verarbeiten der Eingabe, der Zustandstransformation oder der Ausgabe.

*   **Main & Menu:** Der Einstiegspunkt der Anwendung. Koordiniert den Start und die Menüführung.
*   **UI Layer (Eingabe / Ausgabe):** 
    *   *UI Eingabe:* Nimmt Zeichen/Zeilen vom Benutzer entgegen und schiebt sie in den Parser.
    *   *UI Ausgabe:* Empfängt Resultate oder Fehler über einen **Callback-Mechanismus**, der bis zum Calculator durchgereicht wird. (Noch nicht implementiert)
*   **Lexer- & Parser-Schicht (Grammatik, DEA, Parser):**
    *   *DEA (Deterministischer Endlicher Automat):* Konsumiert Zeichen und wandelt sie anhand der Grammatik in Token/Kommandos um.
    *   *Parser:* Holt Kommandos vom DEA und steuert die Evaluierung.
*   **Execution Layer (ParserToken, Calculator):**
    *   *Grammatik:* Hält die Symbol- und Übergangstabellen für den Calculator.
    *   *ParserToken:* Repräsentiert die semantische Aktion (z.B. Puffer füllen, Zahl erzeugen, Calculator triggern).
    *   *Calculator & Stack:* Verwaltet den LIFO-Speicher (Stack) und führt die eigentlichen mathematischen Operationen aus. (noch nicht implementiert)

---
## 2. Komponenten- und Schichten / Säulen-Diagramm

Das folgende Diagramm zeigt die Klassenstruktur und wie die Abhängigkeiten verlaufen.

```mermaid
graph TD
    %% ==========================================
    %% SÄULE 1: PRÄSENTATION
    %% ==========================================
    subgraph S1 [1. Präsentation]
        Menu[Menü]
        UI_In[UI Eingabe]
        UI_Out[UI Ausgabe]
        
        Menu -->|Steuert / Nutzt| UI_In
        Menu -.->|Aktualisiert| UI_Out
    end


    %% ==========================================
    %% SÄULE 2: AUFBEREITUNG
    %% ==========================================
    subgraph S2 [2. Aufbereitung]
        Parser[Parser]
        DEA[DEA]
        
        Parser -->|Erstellt & durchläuft| DEA
    end

 
    %% ==========================================
    %% SÄULE 3: AUSFÜHRUNG
    %% ==========================================
    subgraph S3 [3. Ausführung]
        Token[ParserToken]
        Gramma[Gramma]
        Callbacks[Callbacks]
        Calc[Calculator]
        Stack[Stack]

        Callbacks -.->|nutzt|Token
        Callbacks -->|steuert| Calc
        Calc -->|Manipuliert / Nutzt| Stack
    
        
        %% Interne Zuweisung zum Sammelpunkt
        Calc ---> UI_Out
     
    end

    %% ==========================================
    %% SÄULENÜBERGREIFENDE VERBINDUNGEN
    %% ==========================================
    UI_In -->|Übergibt Eingabe an| Parser

    
    %% Gramma speist die Aufbereitung
    Parser -.->|liest| Gramma
    DEA -.->|bekommt / nutzt| Gramma   
    %% Parser erzeugt Tokens
    Parser -->|Generiert / Füttert| Token

   %% Parser erzeugt Tokens
    Parser -->|ruft auf| Callbacks
    
    %% Logische Abhängigkeit der Grammatik
    Gramma -.->|„Beschreibt die Art, wie der<br>Calculator benutzt werden kann“| Calc

 

    %% ==========================================
    %% DESIGN & STYLING
    %% ==========================================
    style S1 fill:#03a12b,stroke:#666,stroke-width:2px
    style S2 fill:##0710fa,stroke:#0066cc,stroke-width:2px
    style S3 fill:#783302,stroke:#ff9933,stroke-width:2px
    
    style Menu fill:#1a1a1a,stroke:#333,color:#fff
    style UI_In fill:#1a1a1a,stroke:#333,color:#fff
    style UI_Out fill:#1a1a1a,stroke:#333,color:#fff
    style Parser fill:#1a1a1a,stroke:#333,color:#fff
    style DEA fill:#1a1a1a,stroke:#333,color:#fff
    style Token fill:#1a1a1a,stroke:#333,color:#fff
    
    style Stack fill:#fff,stroke:#ff9933,color:#000
    style Gramma fill:#ffe4b5,stroke:#ff9933,color:#000
    style Calc fill:#fff,stroke:#ff9933,color:#000

```
---

## 2. Komponenten- und Schichten-Diagramm

Das folgende Diagramm zeigt deine exakte Klassenstruktur und wie die Abhängigkeiten verlaufen.

```mermaid
graph TD
    %% Main & Steuerung
    RpnCalc[RpnCalc / Main] --> Menu[Menu]
    Menu --> UI_In[UI Eingabe]

    %% UI Schicht
    subgraph UI_Layer [UI / Präsentation]
        UI_In
        UI_Out[UI Ausgabe / CLI]
    end

    %% Compiler Frontend
    subgraph Compiler_Frontend [Lexer & Parser Schicht]
        Parser[Parser]
        DEA[DEA]
        Grammar[Grammatik]
        
        Parser --> DEA
        DEA --> Grammar
    end

    %% Execution & State
    subgraph Execution_Layer [Logik & Zustand]
        ParserToken[ParserToken]
        Calc[Calculator]
        Stack[(Stack)]
        
        Calc --> Stack
    end

    %% Datenfluss
    UI_In -->|Übergibt Text/Zeichen| Parser
    Parser -->|Erzeugt/Steuert| ParserToken
    ParserToken -->|Ruft auf| Calc
    
    %% Callback für Ausgabe
    Calc -.->|Callback: Ausgabe| UI_Out
    ParserToken -.->|Callback: Ausgabe| UI_Out

    %% Styles
    style UI_Layer fill:#f9f,stroke:#333,stroke-width:2px
    style Compiler_Frontend fill:#bbf,stroke:#333,stroke-width:2px
    style Execution_Layer fill:#bfb,stroke:#333,stroke-width:2px
```

---

## 3. Sequenzdiagramm: Von der Eingabe zur Berechnung

Dieses Diagramm zeigt den genauen Ablauf, wenn die UI-Eingabe eine Zeichenkette verarbeitet (z.B. eine Zahl oder einen Operator). Es verdeutlicht auch, wie der DEA Kommandos generiert und wie die Ausgabe per Callback zurückfließt.

---

## 4. Detaillierte Funktionsweise der Kernkomponenten

### 1. Grammatik & DEA
Die **Grammatik** definiert das Alphabet und die gültigen Zustandsübergänge (Zustandsmatrix). Der **DEA** liest den Eingabestrom Zeichen für Zeichen aus der **UI Eingabe**. Bei jedem gültigen Zustandsübergang emittiert der DEA ein Kommando an den **Parser**.

### 2. Parser & ParserToken
Der **Parser** agiert als Steuereinheit. Er wartet auf die Kommandos des DEA. Sobald ein valides Kommando erkannt wird, instanziiert oder füttert er das **ParserToken**. 
Das **ParserToken** besitzt die Logik für die Akkumulation von Daten (z. B. einen String-Buffer für mehrstellige Zahlen wie `123`) und weiß, wann es die Geschäftslogik des **Calculators** aufrufen muss.

### 3. Calculator & Stack
Der **Calculator** kapselt den eigentlichen RPN-Speicher (**Stack**). Er führt die Pop- und Push-Operationen aus. Er bleibt vollständig entkoppelt von der UI, indem er Berechnungsresultate oder Fehler (z.B. *Division durch Null* oder *Zu wenige Operanden*) über einen Funktionszeiger / ein Interface (**Callback**) direkt an die **UI Ausgabe** meldet.
