# Monitoraggio degli Endpoint ESET tramite Zabbix
Il template permette di monitorare molte delle informazioni direttamente sugli Endpoint in modalità RMM Safe (solo lettura, senza scrittura).
Ci sono 2 template, uno passivo ed uno attivo.
Il template passivo è stato testato con e senza proxy.

## Cosa permette di leggere il template
- Stato dei servizi e dei processi con alert
- Utilizzo di CPU, RAM e disco in lettura e scrittura per ogni processo con alert
- Stato e informazioni aggiornamenti
- Informazioni sulla licenza principale e sulla licenza EDTD
- Informazioni dettagliate sulla minaccia appena trovata sul computer (nome, percorso, utente, azione eseguita ecc.)
- Informazioni varie sul software installato e sulla dimensione dei log

## Abilitare RMM da console Protect o dai singoli Endpoint
Per poter usufruire del template bisogna abilitare le opzioni di RMM sugli Endpoint tramite console Protect o sui singoli computer.
Per farlo basta andare su Configurazione Avanzata -> Strumenti -> ESET RMM.
Qui bisogna:
- Attivare RMM
- Modalità operativa impostare "Solo operazioni sicure"
- Metodo di autorizzazione impostiamo "Percorso Applicazione"
- Percorsi Applicazione impostiamo il percorso della cartella delle applicazioni di Zabbix "C:\Program Files\Zabbix Agent\*"

## Funzionamento
Il template dei log utilizza 4 elementi con cui recupera i log dall' Endpoint per creare tutti gli elementi ed i Trigger.
I log sulle minacce sono impostati per essere recuperati ogni 10 secondi così da dare uno stato del software quasi in tempo reale.
Per una lista dei comandi RMM utilizzati:
https://help.eset.com/eea/7/en-US/rmm_json_commands_application.html?rmm_json_commands.html
Oltre ai log il template controlla i processi di ESET, il loro stato e salva l'utilizzo di CPU, RAM e Disco tramite WMI dei singoli servizi.

## Script esterni
Il template fa uso del file checkviruslog.ps1 per creare dei log temporanei per inviare a Zabbix informazioni sul rilevamento dei Virus negli ultimi 5 minuti.

## Template collegati
Non ci sono template collegati

## Regole di Discovery
Non ci sono regole di discovery

## Tag
`Antivirus: ESET`

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


## Mappatura Valori
| Nome        | Valore           | Mappato  |
| ------------- |:-------------|:-------------|
|Stato Servizi|0|In Esecuzione|
|Stato Servizi|1|In Pausa|
|Stato Servizi|2|In attesa di essere avviato|
|Stato Servizi|3|In attesa di essere messo in pausa|
|Stato Servizi|4|In attesa di ripartire|
|Stato Servizi|5|In attesa di essere fermato|
|Stato Servizi|6|Fermato|
|Stato Servizi|7|Sconosciuto|
|Stato Servizi|255|Il servizio non esiste|

## Grafici
![grafici-eset-zabbix](https://user-images.githubusercontent.com/44651109/165154683-7fa66d9a-2383-447f-a0f9-0c9ada039474.png)
- Utilizzo CPU per i singoli servizi.
- Utilizzo RAM per i singoli servizi.
- I/O Lettura per i singoli servizi sul disco.
- I/O Scrittura per i singoli servizi sul disco.

## Dashboard
![dashboard](https://user-images.githubusercontent.com/44651109/165153489-6b69c88b-5b8e-42cc-8bdc-18260f72f4d0.jpg)
- Orologio.
- Ultimo Rilevamento (Data e ora, Tipo di minaccia, Nome minaccia, Azine intrapresa, Link, Nome Processo che ha generato la minaccia).
- Informazioni sul prodotto installato (Stato licenza, Tipo di licenza, Spazio Occupato dalla cartella eScan, Versione Endpoint, Lingua Endpoint, Software Endpoint).
- Stato Protezione (Stato servizio ESET, Stato servizio ESET Agent, Stato servizio ESET Firewall Helper, Stato protezione ESET).
- Stato Aggiornamento Definizioni (Ultimo tentativo di aggiornamento, Ultimo aggiornamento eseguito con successo, Esito ultimo tentativo di aggiornamento).
- Grafico - Utilizzo CPU per i singoli servizi.
- Grafico - Utilizzo RAM per i singoli servizi.
- Grafico - I/O Lettura per i singoli servizi sul disco.
- Grafico - I/O Scrittura per i singoli servizi sul disco.

## Trigger
| Nome        |Descrizione|Severity          | Chiave  |Tag|
| ------------- |:-------------|:-------------|:-------------|:-------------|
|Cartella ESET eScan superiore ai {$LOG.SPACE.WARNING}Gb|Invia un alert quando la cartella eScan supera le dimensioni impostate nella Macro|Bassa  |`last(/ESET Endpoint/vfs.dir.size[C:\ProgramData\ESET\ESET Security\Logs\eScan,,,disk,])>{$LOG.SPACE.WARNING}`| `Antivirus:ESET` `ESET:Avvisi`|
|Il prodotto ESET non è aggiornato|Invia un alert quando esce una nuova versione del prodotto|Bassa  |`last(/ESET Endpoint/versione.endpoint)<>{$LATEST.VERSION.ENDPOINT.SECURITY.WARNING}`| `Antivirus:ESET` `ESET:Avvisi`|
|Licenza ESET in scadenza|La licenza sta per scadere|Bassa  |`last(/ESET Endpoint/ESET.licenza.stato)<>"ok"`| `Antivirus:ESET` `ESET:Avvisi`|
|	Minaccia Rilevata|ESET ha rilevato una minaccia|Alta|`last(/ESET Endpoint/ESET.Rilevamento)="Minaccia Rilevata"`| `Antivirus:ESET` `ESET:Avvisi`|
|Protezione ESET Disattivata|La protezione è stata disattivata|Alta|`last(/ESET Endpoint/system.run[C:\PROGRA~1\ESET\ESETSE~1\eRmm.exe get protection-status],#10)<>"Protezione attiva"`| `Antivirus:ESET` `ESET:Avvisi`|
|Servizio "ESET Firewall Helper" Non Attivo|Il servizio Firewall Helper non è attivo|Media|`min(/ESET Endpoint/service.info["ekrnEpfw",state],#3)<>0`| `Antivirus:ESET` `ESET:Avvisi`|
|Servizio "ESET Management Agent" Non Attivo|Il servizio di Management non è attivo, la console non riesce a comunicare con il client|Disastro|`min(/ESET Endpoint/service.info["EraAgentSvc",state],#3)<>0`| `Antivirus:ESET` `ESET:Avvisi`|
|Servizio "ESET Service" Non Attivo|Il servizio di protezione ESET non è attivo, il PC non è protetto|Disastro|`min(/ESET Endpoint/service.info["ekrn",state],#3)<>0`| `Antivirus:ESET` `ESET:Avvisi`|
|Utilizzo CPU eccessivo ESET Agent (Piu del {$CPU.WARNING}% in 5 minuti)|Il servizio ESET Agent utilizza la CPU oltre la soglia critica stabilita nelle macro per più di 5 minuti|Media|`min(/ESET Endpoint/eset.agent.process.percentage,5m)>{$CPU.WARNING}`| `Antivirus:ESET` `ESET:Avvisi`|
|Utilizzo CPU eccessivo ESET Proxy GUI (Piu del {$CPU.WARNING}% in 5 minuti)|Il servizio ESET Proxy GUI utilizza la CPU oltre la soglia critica stabilita nelle macro per più di 5 minuti|Media|`min(/ESET Endpoint/eset.proxy.process.percentage,5m)>{$CPU.WARNING}`| `Antivirus:ESET` `ESET:Avvisi`|
|Utilizzo CPU eccessivo servizio ESET (Piu del {$CPU.WARNING}% in 5 minuti)|Il servizio ESET utilizza la CPU oltre la soglia critica stabilita nelle macro per più di 5 minuti|Media|`min(/ESET Endpoint/eset.process.percentage,5m)>{$CPU.WARNING}`| `Antivirus:ESET` `ESET:Avvisi`|
|Utilizzo RAM eccessivo ESET Agent (Piu del {$CPU.WARNING}% in 5 minuti)|Il servizio ESET Agent utilizza la RAM oltre la soglia critica stabilita nelle macro per più di 5 minuti|Media|`min(/ESET Endpoint/wmi.getall["ROOT\CIMV2","SELECT WorkingSetPrivate FROM Win32_PerfFormattedData_PerfProc_Process where Name like '%ERAAgent%'"],5m)>last(/ESET Endpoint/eset.warning.ram.space)`| `Antivirus:ESET` `ESET:Avvisi`|
|Utilizzo RAM eccessivo ESET Proxy GUI (Piu del {$CPU.WARNING}% in 5 minuti)|Il servizio ESET Proxy GUI utilizza la RAM oltre la soglia critica stabilita nelle macro per più di 5 minuti|Media|`min(/ESET Endpoint/wmi.getall["ROOT\CIMV2","SELECT WorkingSetPrivate FROM Win32_PerfFormattedData_PerfProc_Process where Name like '%eguiProxy%'"],5m)>last(/ESET Endpoint/eset.warning.ram.space)`| `Antivirus:ESET` `ESET:Avvisi`|
|Utilizzo RAM eccessivo servizio ESET (Piu del {$CPU.WARNING}% in 5 minuti)|Il servizio ESET utilizza la RAM oltre la soglia critica stabilita nelle macro per più di 5 minuti|Media|`min(/ESET Endpoint/wmi.getall["ROOT\CIMV2","SELECT WorkingSetPrivate FROM Win32_PerfFormattedData_PerfProc_Process where Name like '%ekrn%'"],5m)>last(/ESET Endpoint/eset.warning.ram.space)`| `Antivirus:ESET` `ESET:Avvisi`|

## Elementi Componenti
| Nome        |Descrizione| Tipo|Unità  | Chiave  | Tipo di informazione  | Intervallo| Tag | Preprocesso|Formula|
| ------------- |:-------------|:-------------|:-------------|:-------------|:-----|:-----|:-----|:-----|:-----|
|Deploy ESET Script|Scarica nella cartella script di Zabbix lo script per il controllo delle minacce di ESET|Agente Zabbix|```system.run[mkdir C:\PROGRA~1\ZABBIX~1\script & powershell.exe -NoProfile -ExecutionPolicy Bypass -command Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/clanto/Zabbix/main/ESET_ENDPOINT/checkviruslog.ps1' -OutFile "$Env:Programfiles\ZABBIX~1\script\checkviruslog.ps1",nowait]```|Log|1d|`Antivirus:ESET` `ESET:Componenti`||
|Numero Core Processore|Numero Core del processore per calcolare l'utilizzo CPU dei servizi|Agente Zabbix|Core|```wmi.get["root\cimv2","SELECT NumberOfCores from Win32_Processor"]```|Numero(senza segno)|1d|`Antivirus:ESET` `ESET:Componenti`||
|RAM Totale Sistema|Memoria RAM in Mb totale del sistema per calcolare l'utilizzo della RAM|Agente Zabbix|Mb|```wmi.getall["ROOT\CIMV2","SELECT TotalPhysicalMemory FROM Win32_ComputerSystem"]```|Numero(float)|1d|`Antivirus:ESET` `ESET:Componenti`|```Trim Destro -> "}]```<br><br>```Espressione Regolare -> ([^"/]+$) -> \0```<br><br>```Javascript -> return (value / 1024 / 1024)```||
|Spazio Occupato Log ESET|Spazio totale occupato dalla cartella eScan di ESET|Agente Zabbix|Gb|```vfs.dir.size[C:\ProgramData\ESET\ESET Security\Logs\eScan,,,disk,]```|Numero(float)|1d|`Antivirus:ESET` `ESET:Componenti`|```Javascript -> return (value / 1024 / 1024)```||
|{$RAM.WARNING}% della RAM totale|Calcolo della soglia di RAM in base al valore warning della macro|Agente Zabbix|Mb|```eset.warning.ram.space```|Numero(float)|1d|`Antivirus:ESET` `ESET:Componenti`||```({$RAM.WARNING}/100)*last(//wmi.getall["ROOT\CIMV2","SELECT TotalPhysicalMemory FROM Win32_ComputerSystem"])```|

## Elementi Servizi
| Nome        |Descrizione| Tipo|Unità  | Chiave  | Tipo di informazione  | Intervallo| Tag |Mappatura Valori|
| ------------- |:-------------|:-------------|:-------------|:-------------|:-----|:-----|:-----|:-----|
|Stato del servizio "ekrn" (ESET Service)|Stato del servizio|Agente Zabbix||```service.info["ekrn",state]```|Numero(float)|1m|`Antivirus:ESET` `ESET:Servizi`|Stato Servizi|
|Stato del servizio "ekrnEpfw" (ESET Firewall Helper)|Stato del servizio|Agente Zabbix||```service.info["ekrnEpfw",state]```|Numero(float)|1m|`Antivirus:ESET` `ESET:Servizi`|Stato Servizi|
|Stato del servizio "EraAgentSvc" (ESET Management Agent)|Stato del servizio|Agente Zabbix||```service.info["EraAgentSvc",state]```|Numero(float)|1m|`Antivirus:ESET` `ESET:Servizi`|Stato Servizi|

## Elementi Prestazioni
Questi elementi sono tutti generati in WMI per avere un valore più veritiero possibile senza inficiare sulle performance.
- Lettura e scrittura del disco per i servizi ESET.
- Utilizzo CPU per i servizi ESET.
- Utilizzo RAM per i servizi ESET.

| Nome        |Descrizione| Tipo           | Chiave  | Tipo di informazione  |Unità| Intervallo| Tag | Preprocesso|Formula|
| ------------- |:-------------|:-------------|:-------------|:-----|:-----|:-----|:-----|:-----|:-----|
|I/O Lettura (ESET Management Agent)|Valori in Mb\s di lettura del disco per il servizio|Agente Zabbix|```wmi.getall["ROOT\CIMV2","SELECT IOReadOperationsPerSec FROM Win32_PerfFormattedData_PerfProc_Process where Name like '%ERAAgent%'"]```|Numerico(float)|Mb\s|1m|`Antivirus:ESET` `ESET:Prestazioni`|```Trim Sinistro -> [{"IOReadOperationsPersec":"```<br><br>```Trim Destro -> ","Name":"ERAAgent"}]```<br><br>```Javascript -> return (value / 1024 / 1024)```|
|I/O Lettura (ESET Proxy GUI)|Valori in Mb\s di lettura del disco per il servizio|Agente Zabbix|```wmi.getall["ROOT\CIMV2","SELECT IOReadOperationsPerSec FROM Win32_PerfFormattedData_PerfProc_Process where Name like '%eguiProxy%'"]```|Numerico(float)|Mb\s|1m|`Antivirus:ESET` `ESET:Prestazioni`|```Trim Sinistro -> [{"IOReadOperationsPersec":"```<br><br>```Trim Destro -> ","Name":"eguiProxy"}]```<br><br>```Javascript -> return (value / 1024 / 1024)```|
|I/O Lettura (ESET Service)|Valori in Mb\s di lettura del disco per il servizio|Agente Zabbix|```wmi.getall["ROOT\CIMV2","SELECT IOReadOperationsPerSec FROM Win32_PerfFormattedData_PerfProc_Process where Name like '%ekrn%'"]```|Numerico(float)|Mb\s|1m|`Antivirus:ESET` `ESET:Prestazioni`|```Trim Sinistro -> [{"IOReadOperationsPersec":"```<br><br>```Trim Destro -> ","Name":"ekrn"}]```<br><br>```Javascript -> return (value / 1024 / 1024)```|
|I/O Scrittura (ESET Management Agent)|Valori in Mb\s di scrittura del disco per il servizio|Agente Zabbix|```wmi.getall["ROOT\CIMV2","SELECT IOWriteOperationsPerSec FROM Win32_PerfFormattedData_PerfProc_Process where Name like '%ERAAgent%'"]```|Numerico(float)|Mb\s|1m|`Antivirus:ESET` `ESET:Prestazioni`|```Trim Sinistro -> [{"IOWriteOperationsPersec":"```<br><br>```Trim Destro -> ","Name":"ERAAgent"}]```<br><br>```Javascript -> return (value / 1024 / 1024)```|
|I/O Scrittura (ESET Proxy GUI)|Valori in Mb\s di scrittura del disco per il servizio|Agente Zabbix|```wmi.getall["ROOT\CIMV2","SELECT IOWriteOperationsPerSec FROM Win32_PerfFormattedData_PerfProc_Process where Name like '%eguiProxy%'"]```|Numerico(float)|Mb\s|1m|`Antivirus:ESET` `ESET:Prestazioni`|```Trim Sinistro -> [{"IOWriteOperationsPersec":"```<br><br>```Trim Destro -> ","Name":"eguiProxy"}]```<br><br>```Javascript -> return (value / 1024 / 1024)```|
|I/O Scrittura (ESET Service)|Valori in Mb\s di scrittura del disco per il servizio|Agente Zabbix|```wmi.getall["ROOT\CIMV2","SELECT IOWriteOperationsPerSec FROM Win32_PerfFormattedData_PerfProc_Process where Name like '%ekrn%'"]```|Numerico(float)|Mb\s|1m|`Antivirus:ESET` `ESET:Prestazioni`|```Trim Sinistro -> [{"IOWriteOperationsPersec":"```<br><br>```Trim Destro -> ","Name":"ekrn"}]```<br><br>```Javascript -> return (value / 1024 / 1024)```|
|Uso RAM (ESET Management Agent)|Valori in Mb di utilizzo della RAM per il servizio|Agente Zabbix|```wmi.getall["ROOT\CIMV2","SELECT WorkingSetPrivate FROM Win32_PerfFormattedData_PerfProc_Process where Name like '%ERAAgent%'"]```|Numerico(float)|Mb|1m|`Antivirus:ESET` `ESET:Prestazioni`|```Trim Sinistro -> [{"Name":"ERAAgent","WorkingSetPrivate":"```<br><br>```Trim Destro -> "}]```<br><br>```Javascript -> return (value / 1024 / 1024)```|
|Uso RAM (ESET Proxy GUI)|Valori in Mb di utilizzo della RAM per il servizio|Agente Zabbix|```wmi.getall["ROOT\CIMV2","SELECT WorkingSetPrivate FROM Win32_PerfFormattedData_PerfProc_Process where Name like '%eguiProxy%'"]```|Numerico(float)|Mb|1m|`Antivirus:ESET` `ESET:Prestazioni`|```Trim Sinistro -> [{"Name":"eguiProxy","WorkingSetPrivate":"```<br><br>```Trim Destro -> "}]```<br><br>```Javascript -> return (value / 1024 / 1024)```|
|Uso RAM (ESET Service)|Valori in Mb di utilizzo della RAM per il servizio|Agente Zabbix|```wmi.getall["ROOT\CIMV2","SELECT WorkingSetPrivate FROM Win32_PerfFormattedData_PerfProc_Process where Name like '%ekrn%'"]```|Numerico(float)|Mb|1m|`Antivirus:ESET` `ESET:Prestazioni`|```Trim Sinistro -> [{"Name":"ekrn","WorkingSetPrivate":"```<br><br>```Trim Destro -> "}]```<br><br>```Javascript -> return (value / 1024 / 1024)```|
|Uso CPU grezzo (ESET Management Agent)|Valori grezzi di utilizzo della CPU per il servizio|Agente Zabbix|```wmi.getall["ROOT\CIMV2","SELECT PercentUserTime FROM Win32_PerfFormattedData_PerfProc_Process where Name like '%ErAAgent%'"]```|Numerico(float)||1m|`Antivirus:ESET` `ESET:Prestazioni`|```Trim Sinistro -> [{"Name":"ERAAgent","PercentUserTime":"```<br><br>```Trim Destro -> "}]```|
|Uso CPU grezzo (ESET Proxy GUI)|Valori grezzi di utilizzo della CPU per il servizio|Agente Zabbix|```wmi.getall["ROOT\CIMV2","SELECT PercentUserTime FROM Win32_PerfFormattedData_PerfProc_Process where Name like '%eguiProxy%'"]```|Numerico(float)||1m|`Antivirus:ESET` `ESET:Prestazioni`|```Trim Sinistro -> [{"Name":"eguiProxy","PercentUserTime":"```<br><br>```Trim Destro -> "}]```|
|Uso CPU grezzo (ESET Service)|Valori grezzi di utilizzo della CPU per il servizio|Agente Zabbix|```wmi.getall["ROOT\CIMV2","SELECT PercentUserTime FROM Win32_PerfFormattedData_PerfProc_Process where Name like '%ekrn%'"]```|Numerico(float)||1m|`Antivirus:ESET` `ESET:Prestazioni`|```Trim Sinistro -> [{"Name":"ekrn","PercentUserTime":"```<br><br>```Trim Destro -> "}]```|
|Utilizzo CPU (ESET Management Agent) %|Valori in % di utilizzo della CPU per il servizio|Calculated|```eset.agent.process.percentage```|Numerico(float)|%|1m|`Antivirus:ESET` `ESET:Prestazioni`||```last(//wmi.getall["ROOT\CIMV2","SELECT PercentUserTime FROM Win32_PerfFormattedData_PerfProc_Process where Name like '%ErAAgent%'"])/last(//wmi.get["root\cimv2","SELECT NumberOfCores from Win32_Processor"])```|
|Utilizzo CPU (ESET Proxy GUI) %|Valori in % di utilizzo della CPU per il servizio|Calculated|```eset.proxy.process.percentage```|Numerico(float)|%|1m|`Antivirus:ESET` `ESET:Prestazioni`||```last(//wmi.getall["ROOT\CIMV2","SELECT PercentUserTime FROM Win32_PerfFormattedData_PerfProc_Process where Name like '%eguiProxy%'"])/last(//wmi.get["root\cimv2","SELECT NumberOfCores from Win32_Processor"])```|
|Uso CPU grezzo (ESET Service)|Valori grezzi di utilizzo della CPU per il servizio|Calculated|```eset.process.percentage```|Numerico(float)|%|1m|`Antivirus:ESET` `ESET:Prestazioni`||```last(//wmi.getall["ROOT\CIMV2","SELECT PercentUserTime FROM Win32_PerfFormattedData_PerfProc_Process where Name like '%ekrn%'"])/last(//wmi.get["root\cimv2","SELECT NumberOfCores from Win32_Processor"])```|

## Elementi Principali Log
| Nome        | Tipo           | Chiave  | Tipo di informazione  | Intervallo| Tag | Preprocesso|
| ------------- |:-------------|:-------------|:-------------|:-----|:-----|:-----|
|Log Info Endpoint ESET|Agente Zabbix|```system.run[C:\PROGRA~1\ESET\ESETSE~1\eRmm.exe get application-info]```|Testo|1d|`Antivirus:ESET` `ESET:Log`|
|Log Licenza Endpoint ESET|Agente Zabbix|```system.run[C:\PROGRA~1\ESET\ESETSE~1\eRmm.exe get license-info]```|Testo|1d|`Antivirus:ESET` `ESET:Log`|
|Log Stato Protezione Endpoint ESET|Agente Zabbix|```system.run[C:\PROGRA~1\ESET\ESETSE~1\eRmm.exe get protection-status]```|Testo|1m|`Antivirus:ESET` `ESET:Log`|```JSONPath -> $.result.description```<br><br>```Sostituisci: You are protected -> Protezione attiva```<br><br>```Sostituisci: Security alert -> Protezione Disattivata```|
|Log Aggiornamenti Endpoint ESET|Agente Zabbix|```system.run[C:\PROGRA~1\ESET\ESETSE~1\eRmm.exe get update-status]```|Testo|10m|`Antivirus:ESET` `ESET:Log`|
|Log Minacce ultimi 5 minuti<br><br>All'interno della chiave il valore ```-time_check 5``` equivale ai 5 minuti, si può modificare questo numero ed impostare il numero di minuti per cui si vuole recuperare il log|Agente Zabbix|```system.run[powershell -NoProfile -ExecutionPolicy bypass -File "C:\PROGRA~1\ZABBIX~1\script\checkviruslog.ps1" -time_check 5]```|Testo|10s|`Antivirus:ESET` `ESET:Log`|

## Elementi derivati dal log aggiornamenti
| Nome        | Tipo           | Chiave  |Master Item|Tipo informazione| Tag | Preprocesso|
|:------------- |:-------------|:-------------|:-------------|:-----|:-----|:-----|
|Aggiornamenti Risultato ultimo tentativo|Dependent Item|aggiornamento.risultato|`Log Aggiornamenti Endpoint ESET`|Testo|`Antivirus:ESET` `ESET:Aggiornamenti`|```jSONPath -> $.result.last_update_result```|
|Aggiornamenti ultimo eseguito con successo|Dependent Item|aggiornamento.riuscito|`Log Aggiornamenti Endpoint ESET`|Testo|`Antivirus:ESET` `ESET:Aggiornamenti`|```jSONPath -> $.result.last_successful_update_time```|
|Aggiornamenti Ultimo Tentativo ESET|Dependent Item|aggiornamento.tentato|`Log Aggiornamenti Endpoint ESET`|Testo|`Antivirus:ESET` `ESET:Aggiornamenti`|```jSONPath -> $.result.last_update_time```|

## Elementi derivati dal log info endpoint
| Nome        | Tipo           | Chiave  |Master Item|Tipo informazione| Tag | Preprocesso|
|:------------- |:-------------|:-------------|:-------------|:-----|:-----|:-----|
|Info Prodotto Endpoint ESET|Dependent Item|prodotto.endpoint|`Log Info Endpoint ESET`|Testo|`Antivirus:ESET` `ESET:Info`|```jSONPath -> $.result.description```|
|Info Versione Endpoint ESET|Dependent Item|versione.endpoint|`Log Info Endpoint ESET`|Testo|`Antivirus:ESET` `ESET:Info`|```jSONPath -> $.result.version```|
|Info Lingua Endpoint ESET|Dependent Item|info.endpoint.lang|`Log Info Endpoint ESET`|Testo|`Antivirus:ESET` `ESET:Info`|```jSONPath -> $.result.lang_id```<br><br>```Sostituisci -> 1040 -> Italiano```|

## Elementi derivati dal log licenza
| Nome        | Tipo           | Chiave  |Master Item|Tipo informazione| Tag | Preprocesso|
|:------------- |:-------------|:-------------|:-------------|:-----|:-----|:-----|
|Licenza ESET Tipo|Dependent Item|ESET.licenza.tipo|`Log Licenza Endpoint ESET`|Testo|`Antivirus:ESET` `ESET:Licenza`|```jSONPath -> $.result.type```<br><br>```Sostituisci -> PAID -> A Pagamento```|
|Licenza ESET Stato|Dependent Item|ESET.licenza.stato|`Log Licenza Endpoint ESET`|Testo|`Antivirus:ESET` `ESET:Licenza`|```jSONPath -> $.result.version```|
|Licenza ESET Nome Postazione|Dependent Item|ESET.licenza.seatname|`Log Licenza Endpoint ESET`|Testo|`Antivirus:ESET` `ESET:Licenza`|```jSONPath -> $.result.seat_name```|
|Licenza ESET ID Pubblico|Dependent Item|ESET.licenza.publicID|`Log Licenza Endpoint ESET`|Testo|`Antivirus:ESET` `ESET:Licenza`|```jSONPath -> $.result.public_id```|
|Licenza ESET ID Postazione|Dependent Item|ESET.licenza.seatID|`Log Licenza Endpoint ESET`|Testo|`Antivirus:ESET` `ESET:Licenza`|```jSONPath -> $.result.seat_id```|
|Licenza ESET EDTD Tipo|Dependent Item|ESET.licenza.edtd.type|`Log Licenza Endpoint ESET`|Testo|`Antivirus:ESET` `ESET:Licenza`|```jSONPath -> $.result.edtd.type```<br><br>```Sostituisci -> PAID -> A Pagamento```|
|Licenza ESET EDTD Stato|Dependent Item|ESET.licenza.edtd.state|`Log Licenza Endpoint ESET`|Testo|`Antivirus:ESET` `ESET:Licenza`|```jSONPath -> $.result.edtd.expiration_state```|
|Licenza ESET EDTD Nome Postazione|Dependent Item|ESET.licenza.edtd.seat_name|`Log Licenza Endpoint ESET`|Testo|`Antivirus:ESET` `ESET:Licenza`|```jSONPath -> $.result.edtd.seat_name```|
|Licenza ESET EDTD ID Publico|Dependent Item|ESET.licenza.edtd.publicid|`Log Licenza Endpoint ESET`|Testo|`Antivirus:ESET` `ESET:Licenza`|```jSONPath -> $.result.edtd.public_id```|
|Licenza ESET EDTD ID Postazione|Dependent Item|ESET.licenza.edtd.seatid|`Log Licenza Endpoint ESET`|Testo|`Antivirus:ESET` `ESET:Licenza`|```jSONPath -> $.result.edtd.seat_id```|

## Elementi derivati dal log minacce recuperati ogni 10 secondi
| Nome        | Tipo           | Chiave  |Master Item|Tipo informazione| Tag | Preprocesso|
|:------------- |:-------------|:-------------|:-------------|:-----|:-----|:-----|
|Minaccia Rilevamento|Dependent Item|ESET.Rilevamento|`Log Minacce ultimi 5 minuti`|Testo|`Antivirus:ESET` `ESET:Minaccia`|```jSONPath -> $.result.virlog.display_name```<br><br>```Espressione Regolare -> Rilevamenti -> Minaccia Rilevata```<br><br>Custom fail Set value to `Nessuna Minaccia`|
|Minaccia Azione Intrapresa|Dependent Item|ESET.Rilevamento.azioneintrapresa|`Log Minacce ultimi 5 minuti`|Testo|`Antivirus:ESET` `ESET:Minaccia`|```jSONPath -> $.result.virlog.logs[0].['Action Taken']```<br><br>Custom fail Set value to `Nessuna Minaccia`|
|Minaccia Circostanza|Dependent Item|ESET.Rilevamento.circostanza|`Log Minacce ultimi 5 minuti`|Testo|`Antivirus:ESET` `ESET:Minaccia`|```jSONPath ->$.result.virlog.logs[0].Circumstances```<br><br>Custom fail Set value to `Nessuna Minaccia`|
|Minaccia Data e ora Rilevamento|Dependent Item|ESET.Rilevamento.dataora|`Log Minacce ultimi 5 minuti`|Testo|`Antivirus:ESET` `ESET:Minaccia`|```jSONPath -> $.result.virlog.logs[0].Time```<br><br>Custom fail Set value to `Nessuna Minaccia`|
|Minaccia Hash|Dependent Item|ESET.Rilevamento.hash|`Log Minacce ultimi 5 minuti`|Testo|`Antivirus:ESET` `ESET:Minaccia`|```jSONPath -> $.result.virlog.logs[0].Hash```<br><br>Custom fail Set value to `Nessuna Minaccia`|
|Minaccia Nome|Dependent Item|ESET.Rilevamento.nomeminaccia|`Log Minacce ultimi 5 minuti`|Testo|`Antivirus:ESET` `ESET:Minaccia`|```jSONPath -> $.result.virlog.logs[0].['Threat Name']```<br><br>Custom fail Set value to `Nessuna Minaccia`|
|Minaccia Nome Processo|Dependent Item|ESET.Rilevamento.nomeprocesso|`Log Minacce ultimi 5 minuti`|Testo|`Antivirus:ESET` `ESET:Minaccia`|```jSONPath -> $.result.virlog.logs[0].['Process Name']```<br><br>Custom fail Set value to `Nessuna Minaccia`|
|Minaccia Tipologia|Dependent Item|ESET.Rilevamento.tipominaccia|`Log Minacce ultimi 5 minuti`|Testo|`Antivirus:ESET` `ESET:Minaccia`|```jSONPath -> $.result.virlog.logs[0].['Threat Type']```<br><br>Custom fail Set value to `Nessuna Minaccia`|
|Minaccia URL|Dependent Item|ESET.Rilevamento.urlminaccia|`Log Minacce ultimi 5 minuti`|Testo|`Antivirus:ESET` `ESET:Minaccia`|```jSONPath -> $.result.virlog.logs[0].['Object URI']```<br><br>Custom fail Set value to `Nessuna Minaccia`|
|Minaccia Utente Incriminato|Dependent Item|ESET.Rilevamento.utente|`Log Minacce ultimi 5 minuti`|Testo|`Antivirus:ESET` `ESET:Minaccia`|```jSONPath -> $.result.virlog.logs[0].['User Name']```<br><br>Custom fail Set value to `Nessuna Minaccia`|
