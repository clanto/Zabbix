# Monitoraggio degli Endpoint ESET tramite Zabbix
Il template permette di monitorare molte delle informazioni direttamente sugli Endpoint in modalità RMM Safe (solo lettura, senza scrittura).

## Abilitare RMM da console Protect o dai singoli Endpoint
Per poter usufruire del template bisogna abilitare le opzioni di RMM sugli Endpoint tramite console Protect o sui singoli computer.
Per farlo basta andare su Configurazione Avanzata -> Strumenti -> ESET RMM.
Qui bisogna:
- Attivare RMM
- Modalità operativa impostare "Solo operazioni sicure"
- Metodo di autorizzazione impostiamo "Percorso Applicazione"
- Percorsi Applicazione impostiamo il percorso della cartella delle applicazioni di Zabbix "C:\Program Files\Zabbix Agent\*"

## Funzionamento
Il template utilizza di base 4 elementi con cui recupera i log dall' Endpoint per creare tutti gli elementi ed i Trigger.
I log sono impostati per essere recuperati ogni 10 secondi così da dare uno stato del software quasi in tempo reale.
Per una lista dei comandi RMM utilizzati:
https://help.eset.com/eea/7/en-US/rmm_json_commands_application.html?rmm_json_commands.html
Oltre ai log il template controlla i processi di ESET, il loro stato e salva l'utilizzo di CPU, RAM e Disco tramite WMI dei singoli servizi.

## Script esterni
Il template fa uso del file checkviruslog.ps1 per creare dei log temporanei per inviare a Zabbix informazioni sul rilevamento dei Virus negli ultimi 5 minuti.

## Template collegati
Non ci sono template collegati

## Regole di Discovery
Non ci sono regole di discovery

## Macro usate
| Macro        | Valore           | Descrizione  |
| ------------- |:-------------|:-------------|
|{$CPU.WARNING}|15|Percentuale di attenzione di CPU utilizzata per 5 minuti|
|{$RAM.WARNING}|5|Percentuale di attenzione di RAM utilizzata per 5 minuti|
|{$IOREAD.WARNING}|20|Valore di attenzione lettura utilizzato per 5 minuti|
|{$IOWRITE.WARNING}|20|Valore di attenzione scrittura utilizzato per 5 minuti|
|{$LATEST.VERSION.ENDPOINT.SECURITY.WARNING}|9.0.2046.0|Ultima versione endpoint security|
|{$LOG.SPACE.WARNING}|20|Valore in Gb di alert dimensioni per la cartella eScan|
|{$PROTECT.CONSOLE}|Indirizzo https della console|Indirizzo del proprio portale ESET Protect (facoltativo, non ancora utilizzato)|

## Grafici
- Utilizzo CPU per i singoli servizi.
- Utilizzo RAM per i singoli servizi.
- I/O Lettura per i singoli servizi sul disco.
- I/O Scrittura per i singoli servizi sul disco.

## Dashboard
- Orologio
- Ultimo Rilevamento
- Informazioni sul prodotto installato.
- Stato Protezione
- Stato Aggiornamenti

## Elementi Principali Log
| Nome        | Tipo           | Chiave  | Tipo di informazione  | Intervallo| Tag | Preprocesso|
| ------------- |:-------------|:-------------|:-------------|:-----|:-----|:-----|
|Log Info Endpoint ESET|Agente Zabbix|```system.run[C:\PROGRA~1\ESET\ESETSE~1\eRmm.exe get application-info]```|Testo|1d|`Antivirus:ESET` `ESET:Log`|
|Log Licenza Endpoint ESET|Agente Zabbix|```system.run[C:\PROGRA~1\ESET\ESETSE~1\eRmm.exe get license-info]```|Testo|1d|`Antivirus:ESET` `ESET:Log`|
|Log Stato Protezione Endpoint ESET|Agente Zabbix|```system.run[C:\PROGRA~1\ESET\ESETSE~1\eRmm.exe get protection-status]```|Testo|1m|`Antivirus:ESET` `ESET:Log`|```JSONPath -> $.result.description```<br><br>```Sostituisci: You are protected -> Protezione attiva```<br><br>```Sostituisci: Security alert -> Protezione Disattivata```|
|Log Aggiornamenti Endpoint ESET|Agente Zabbix|```system.run[C:\PROGRA~1\ESET\ESETSE~1\eRmm.exe get update-status]```|Testo|10m|`Antivirus:ESET` `ESET:Log`|
|Log Minacce ultimi 5 minuti<br><br>All'interno della chiave il valore ```-time_check 5``` equivale ai 5 minuti, si può modificare questo numero ed impostare il numero di minuti per cui si vuole recuperare il log|Agente Zabbix|```system.run[powershell -NoProfile -ExecutionPolicy bypass -File "C:\PROGRA~1\ZABBIX~1\script\checkviruslog.ps1" -time_check 5]```|Testo|10s|`Antivirus:ESET` `ESET:Log`|

## Elementi Principali Componenti
| Nome        | Tipo           | Chiave  | Tipo di informazione  | Intervallo| Tag | Preprocesso|
