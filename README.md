# progetto_basi_dati
# Progetto di Basi di Dati - Sistema Car Sharing & Pooling

Progetto realizzato per l'esame di **Basi di Dati** (A.A. 2017/18) presso l'Università di Pisa.

## 📌 Descrizione del Progetto
Il progetto consiste nella progettazione e implementazione di una base di dati per la gestione di un sistema integrato di mobilità sostenibile, che include:
- **Car Sharing**: Prenotazione e utilizzo di veicoli aziendali.
- **Car Pooling**: Condivisione di tragitti privati tra utenti per ottimizzare i costi e ridurre l'impatto ambientale.
- **Ride Sharing**: Servizio di trasporto on-demand.
- **Social & Feedback**: Sistema di recensioni e ranking degli utenti basato sul comportamento e sull'affidabilità.

## 🛠 Caratteristiche Tecniche
- **Database**: MySQL.
- **Strumenti**: MySQL Workbench per la progettazione del diagramma E-R e la generazione dello schema fisico.
- **Logica di Business**: Implementata interamente lato database tramite:
  - **Stored Procedures**: Per gestire operazioni complesse (inserimenti, prenotazioni, calcoli).
  - **Triggers**: Per la validazione dei dati (es. controllo scadenza documenti) e aggiornamenti automatici (es. calcolo media sinistri).
  - **Events**: Per la manutenzione automatica (es. sospensione account con documenti scaduti, pulizia tracking vecchi).

## 📁 Struttura della Repository
Il progetto è organizzato nei seguenti file SQL:

| File | Descrizione |
| :--- | :--- |
| `DataBase.sql` | Schema DDL completo delle tabelle e dei vincoli di integrità. |
| `Procedure.sql` | Implementazione di tutte le procedure e funzioni memorizzate. |
| `Triggered.sql` | Definizione dei trigger per l'automazione e il controllo dei vincoli. |
| `Event.sql` | Scheduler di eventi per la gestione temporale del database. |
| `esempio_popolamento_db.sql` | Script completo per l'inizializzazione del DB con dati di test. |
| `TutteLeCall.sql` | Esempi di chiamate alle procedure per testare le funzionalità. |

## 🚀 Installazione e Utilizzo
1. Assicurati di avere un'istanza di **MySQL Server** attiva.
2. Crea lo schema eseguendo il file:
   ```sql
   SOURCE DataBase.sql;
3. Carica la logica applicativa (procedure, trigger ed eventi):
   ```sql
   SOURCE Procedure.sql;
   SOURCE Triggered.sql;
   SOURCE Event.sql;
4. (Opzionale) Popola il database con dati di esempio:
   ```sql
   SOURCE esempio_popolamento_db.sql;


## 📊 Funzionalità Principali
Gestione Utenti: Registrazione, verifica documenti e sistema di ranking (basato su serietà, comportamento e sinistri).
Prenotazioni: Algoritmi per il controllo della disponibilità dei veicoli e la gestione dei tragitti.
Manutenzione: Eventi giornalieri per la sospensione automatica degli account con patente scaduta.
Statistiche: Procedure per il monitoraggio delle criticità del traffico e dei consumi dei veicoli.
Sviluppatori:
- Antonio **Burato**
- Alessandro **Jin**
- Michele **Sestito**

