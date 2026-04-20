DELIMITER $$

-- Operazione 4

DROP TRIGGER IF EXISTS inserimentoDoc$$

CREATE TRIGGER inserimentoDoc
BEFORE INSERT ON documento
FOR EACH ROW 
BEGIN
	IF NEW.Scadenza <= CURRENT_DATE() THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "La data di scadenza del documento non è valida";
	END IF;
	UPDATE account A NATURAL JOIN persona P
    SET Stato = "Attivo"
    WHERE P.CodFiscale = NEW.CodFiscale AND A.Stato = "Sospeso";
END$$

-- Operazion 5.1

DROP TRIGGER IF EXISTS inserisciVeicolo$$

CREATE TRIGGER inserisciVeicolo
BEFORE INSERT ON veicolointerno
FOR EACH ROW
BEGIN
	DECLARE controlloStato VARCHAR(100) DEFAULT "";
    DECLARE controlloProponente INT DEFAULT 0;
    SELECT Stato,Proponente INTO controlloStato,controlloProponente
    FROM Account
    WHERE Username = NEW.Username;
	IF controlloStato <> "Attivo" OR controlloProponente <> 1 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Il veicolo non può essere inserito in quanto l'utente non ha i permessi.";
	END IF;
END$$

-- Operazione 30

DROP TRIGGER IF EXISTS inserisciRecensione$$

CREATE TRIGGER inserisciRecensione
BEFORE INSERT ON recensione
FOR EACH ROW
BEGIN
	DECLARE statoRecensore VARCHAR(100) DEFAULT "";
    DECLARE statoDestinatario VARCHAR(100) DEFAULT "";
    
    SELECT Stato INTO statoRecensore
    FROM account
    WHERE Username = NEW.Recensore;
    
    SELECT Stato INTO statoDestinatario
    FROM account
    WHERE Username = NEW.Destinatario;
    
    IF NEW.Destinatario = NEW.Recensore THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Il recensore non può essere il destinatario!";
	END IF;
    
	IF statoRecensore <> "Attivo" OR statoDestinatario <> "Attivo" THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Il recensore o il destinatario non ha lo stato dell'account attivo quindi non può essere fatta nessuna azione";
    END IF;
        
    IF ((NEW.VotoSerieta > 5 OR NEW.VotoSerieta < 0)AND NEW.VotoSerieta IS NOT NULL) OR ((NEW.VotoViaggio > 5 OR NEW.VotoViaggio < 0) AND NEW.VotoViaggio IS NOT NULL) OR ((NEW.VotoComp < 0 OR NEW.VotoComp > 5) AND NEW.VotoComp IS NOT NULL) THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Qualche campo inserito non è valido";
	END IF;
END$$


-- Operazione 26

DROP TRIGGER IF EXISTS creazioneCarSharing$$

CREATE TRIGGER creazioneCarSharing
BEFORE INSERT ON veicolidisponibili
FOR EACH ROW
BEGIN
	IF CURRENT_DATE() >NEW.DataInizio THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Non puoi inserire una proposta antecedente alla data attuale";
    END IF;
    IF controlloDate(NEW.Targa,NEW.DataInizio,NEW.DataFine) > 0 THEN 
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = "La proposta non può essere inserita in quanto il veicolo è già impiegato in un altro servizio.";
    END IF;
    
    -- controllo delle date
    IF NEW.DataInizio > NEW.DataFine THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "La proposta non può essere inserita in quanto le date inserite non sono valide."; 
	END IF;

END$$


-- Operazione 27

DROP TRIGGER IF EXISTS creazioneCarPooling$$

CREATE TRIGGER creazioneCarPooling
BEFORE INSERT ON propostapool
FOR EACH ROW
BEGIN      
	IF CURRENT_TIMESTAMP() > NEW.DataCreazione OR NEW.DataCreazione > NEW.DataPartenza THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "La proposta non può essere inserita in quanto le date inserite non sono valide.";
    END IF;
    IF controlloDate(NEW.Targa, NEW.DataPartenza,NEW.DataArrivo) > 0 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "La proposta non può essere inserita in quanto il veicolo è già impiegato in un altro servizio.";
	END IF;
    
    -- controllo delle date 
    
    IF NEW.DataCreazione + INTERVAL 49 HOUR > NEW.DataPartenza OR NEW.DataPartenza > NEW.DataArrivo OR NEW.durataVal < 48 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "La proposta non può essere inserita in quanto le date inserite non sono valide.";
    END IF;
    
    IF NEW.flessibilita <> 5 AND NEW.flessibilita <> 10 AND NEW.flessibilita <> 15 AND NEW.flessibilita <> 0 THEN -- corretto qua 11/02/2019
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "La proposta non può essere inserita in quanto la flessibilità inserita non è valida.";
    END IF;
    
    -- controllo del tasso variabilità
    
    IF NEW.TassoVar > 10 OR NEW.TassoVar < 0 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "La proposta non può essere inserita in quanto il tasso variabile deve essere compreso tra 0 e 10.";
    END IF;
END$$

-- Operazione 28

DROP TRIGGER IF EXISTS creazioneRideSharing$$

CREATE TRIGGER creazioneRideSharing
BEFORE INSERT ON propostaride
FOR EACH ROW
BEGIN	
	IF CURRENT_TIMESTAMP() > NEW.DataInizio OR NEW.DataInizio > NEW.DataFine THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "La proposta non può essere inserita in quanto le date inserite non sono valide.";
    END IF;
    
	IF controlloDate(NEW.Targa,NEW.DataInizio,New.DataFine) > 0 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "La proposta non può essere inserita in quanto il veicolo è già impiegato in un altro servizio.";
	END IF;
    -- controllo sul costo
    
    IF NEW.costo < 0 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "La proposta non può essere inserita in quanto il costo al km non è valido.";
    END IF;
END$$


-- Operazione 12
DROP TRIGGER IF EXISTS creazionePrenotazionePool$$

CREATE TRIGGER creazionePrenotazionePool
BEFORE INSERT ON prenotazionePool
FOR EACH ROW
BEGIN
	DECLARE _occupato INT;
	DECLARE _fruitore INT;
	DECLARE _dataPartenza DATETIME;
    DECLARE _numeroPosti INT;
    DECLARE _targa VARCHAR(100);
    
    SELECT Fruitore INTO _fruitore
    FROM account
    WHERE Username = NEW.Username;
    
    SELECT DataPartenza, Targa INTO _dataPartenza, _targa
    FROM propostapool
    WHERE CodPool = NEW.CodPool;
    
    SELECT NumeroPosti INTO _numeroPosti
    FROM veicolointerno
    WHERE Targa = _targa;
    
    IF _fruitore = 0 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT ="L'account che ha fatto la prenotazione non è fruitore.";
    END IF;
    IF CURRENT_DATE() > _dataPartenza THEN
		SIGNAL SQLSTATE'45000'
        SET MESSAGE_TEXT = "La prenotazione che stai facendo è relativa ad un pool già partito";
	END IF;
    
    SELECT COUNT(*) INTO _occupato
    FROM prenotazionepool 
    WHERE StatoAcc = "Accettato" AND CodPool = NEW.CodPool; -- corretto qua  11\02\2019
    -- se voglio mettere il limite delle persone max dopo lo cambio Ale 11/02/2019 17:53
    -- corretto 12/02/2019
    IF _occupato > _numeroPosti -1 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Non puoi prenotare una proposta già accettata";
    END IF;
END$$


-- Operazione 7

DROP TRIGGER IF EXISTS prenotazioneCarSharing$$

CREATE TRIGGER prenotazioneCarSharing
BEFORE INSERT ON prenotazioneveicolo
FOR EACH ROW 
BEGIN
	DECLARE _occupato INT;
	DECLARE _fruitore INT;
	DECLARE _dataInizio DATE;
    DECLARE _dataFine DATE;
    
    SELECT Fruitore INTO _fruitore
    FROM account
    WHERE Username = NEW.Username;
    
    IF CURRENT_DATE() > NEW.DataInizio THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Non puoi fare una prenotazione antecedente alla data attuale";
	END IF;
    
	IF NEW.DataInizio > NEW.DataFine THEN
		SIGNAL SQLSTATE'45000'
        SET MESSAGE_TEXT = "La data di inizio della prenotazione non può essere successiva alla data di fine.";
	END IF;
    
    SELECT DataInizio, DataFine INTO _dataInizio, _dataFine
    FROM veicolidisponibili
    WHERE CodDisponibili = NEW.CodDisponibili;
    
    IF NEW.DataInizio < _DataInizio OR NEW.DataInizio > _dataFine OR (NEW.DataInizio < _dataFine AND NEW.DataFine > _dataFine) THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Qualche data inserita o la data della richiesta non è accettabile.";
    END IF;
    
    SELECT COUNT(*) INTO _occupato
    FROM prenotazioneveicolo 
    WHERE Stato = "Accettato" AND CodDisponibili = NEW.CodDisponibili;
    
    IF _occupato > 0 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Non puoi prenotare una proposta già occupata";
	END IF;
END$$


-- Operazione 11

DROP TRIGGER IF EXISTS accettazioneNoleggio$$

CREATE TRIGGER accettazioneNoleggio
AFTER UPDATE ON prenotazioneveicolo
FOR EACH ROW
BEGIN
	DECLARE _codDisp INT ;
    DECLARE _dataInizio DATE;
    DECLARE _dataFine DATE;
    DECLARE _targa VARCHAR(7);
    DECLARE _username VARCHAR(100);
    
    SELECT CodDisponibili INTO _codDisp
    FROM prenotazioneveicolo
    WHERE CodPrenotazione = NEW.CodPrenotazione;
    
    SELECT DataInizio, DataFine, Targa INTO _dataInizio,_dataFine,_targa
    FROM veicolidisponibili
    WHERE CodDisponibili = _codDisp;
    
	IF NEW.Stato = "Accettato" THEN 
		IF _dataInizio < NEW.DataInizio - INTERVAL 1 DAY THEN
        	INSERT INTO veicolidisponibili(Targa,DataInizio, DataFine)
			VALUES(_targa,_dataInizio, NEW.DataInizio - INTERVAL 1 DAY);
			-- CALL creazioneCarSharing(_targa, _dataInizio,NEW.DataInizio - INTERVAL 1 DAY);
		END IF;
        IF _dataFine > NEW.DataFine + INTERVAL 1 DAY THEN
        	INSERT INTO veicolidisponibili( Targa, DataInizio, DataFine)
			VALUES(_targa, NEW.DataFine + INTERVAL 1 DAY, _dataFine);
			-- CALL creazioneCarSharing(_targa,NEW.DataFine + INTERVAL 1 DAY, _dataFine);
		END IF;
	
		SELECT Username INTO _username 
        FROM prenotazioneveicolo
        WHERE CodPrenotazione = NEW.CodPrenotazione;
        
		UPDATE account
        SET NoleggiEffettuati = NoleggiEffettuati + 1
        WHERE Username = _username;
        
		INSERT INTO accEscape
        SELECT CodPrenotazione
        FROM prenotazioneveicolo
		WHERE CodDisponibili = _codDisp AND CodPrenotazione <> NEW.CodPrenotazione AND 
			((DataInizio <= _DataInizio AND DataFine >= _DataInizio) 
			OR (DataInizio <= _DataFine AND DataFine >= _DataInizio) 
			OR(DataInizio >= _DataInizio AND DataFine <= _DataFine) 
			OR (DataInizio <= _DataInizio AND DataFine >= _DataFine));
    END IF;
END$$

-- Operazion 11.2
DROP TABLE IF EXISTS accEscape$$
CREATE TABLE accEscape(
CodPrenotazione INT PRIMARY KEY)$$

DROP EVENT IF EXISTS pushEscape$$

CREATE EVENT pushEscape
ON SCHEDULE 
EVERY 1 MINUTE DO
BEGIN
	UPDATE prenotazioneveicolo
    SET Stato = "Rifiutato", DataRisposta = CURRENT_TIMESTAMP()
    WHERE CodPrenotazione IN (SELECT * 
							 FROM accEscape);
	TRUNCATE TABLE accEscape;
END$$
-- Operazione 19

DROP TRIGGER IF EXISTS creazionePrenotazioneRideSingolo$$

CREATE TRIGGER creazionePrenotazioneRideSingolo
BEFORE INSERT ON chiamata
FOR EACH ROW 
BEGIN
	DECLARE _ultimoIndicePartenza INT DEFAULT 0;
    DECLARE _ultimoIndiceArrivo INT DEFAULT 0;
    DECLARE _periodoPartenzaProposta DATETIME;
    DECLARE _periodoFineProposta DATETIME;
    DECLARE _periodoArrivoProposta DATETIME;
    DECLARE _tragitto INT;
    DECLARE _indicePartenza INT;
    DECLARE _indiceArrivo INT;
    
    SELECT DataInizio, DataFine, CodTragitto INTO _periodoPartenzaProposta, _periodoFineProposta, _tragitto
    FROM propostaride
    WHERE CodProposta = NEW.CodProposta;
    
    SELECT Ordine INTO _IndicePartenza
    FROM partenza P NATURAL JOIN chiamata C INNER JOIN propostaride PR ON(C.CodProposta = PR.CodProposta)
    WHERE PR.CodTragitto = _tragitto AND Latitudine = NEW.LatitudinePartenza AND Longitudine = NEW.LongitudinePartenza AND Altitudine = NEW.AltitudinePartenza;
    
    SELECT MAX(Ordine) INTO _ultimoIndicePartenza
    FROM partenza P NATURAL JOIN chiamata C INNER JOIN propostaride PR ON(C.CodProposta = PR.CodProposta)
    WHERE PR.CodTragitto = _tragitto;
    
	SELECT MAX(Ordine) INTO _ultimoIndiceArrivo
    FROM Arrivo A NATURAL JOIN chiamata C INNER JOIN propostaride PR ON(C.CodProposta = PR.CodProposta)
    WHERE PR.CodTragitto = _tragitto;
    
	
    SELECT Ordine INTO _IndiceArrivo
    FROM Arrivo A NATURAL JOIN chiamata C INNER JOIN propostaride PR ON(C.CodProposta = PR.CodProposta)
    WHERE PR.CodTragitto = _tragitto AND Latitudine = NEW.LatitudineArrivo AND Longitudine = NEW.LongitudineArrivo AND Altitudine = NEW.AltitudineArrivo;

    IF NEW.DataRichiesta < _periodoPartenzaProposta THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "La proposta ride non è ancora partita.";
	END IF;
    
    IF NEW.DataRichiesta >= _periodoArrivoProposta THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "La proposta ride è già conclusa.";
	END IF;
    
    IF _ultimoIndicePartenza < _IndicePartenza OR _IndicePartenza <= 0 OR _ultimoIndiceArrivo < _IndiceArrivo OR _IndiceArrivo <= 0 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Gli indici di partenza e/o arrivo non sono corretti rispetto al tragitto proposto.";
	END IF;
END$$


-- Operazione 19.2

DROP TRIGGER IF EXISTS fineChiamataRideSharing$$

CREATE TRIGGER fineChiamataRideSharing
BEFORE UPDATE ON chiamata
FOR EACH ROW 
BEGIN/*
	IF OLD.DataRisposta IS NULL THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT ="Non è stata data risposta alla chiamata quindi non può esserci una data di fine corsa.";
	END IF;*/
    IF OLD.DataFineCorsa <> NULL THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT ="La data di fine corsa è già stata inserita.";
	END IF;
	IF NEW.DataFineCorsa <> NULL AND NEW.DataFineCorsa < OLD.DataRisposta THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "La data di fine corsa non può essere prima della data di risposta";
    END IF;
	IF NEW.DataFineCorsa <> NULL AND NEW.DataFineCorsa < OLD.DataRichiesta THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "La data di fine corsa non può essere prima della data di richiesta";
    END IF;
END$$

-- Operazione 20

DROP TRIGGER IF EXISTS accettazionePrenotazioneRide$$

CREATE TRIGGER accettazionePrenotazioneRide
AFTER UPDATE ON chiamata
FOR EACH ROW
BEGIN
	IF NEW.Stato = "Rifiutato" AND NEW.DataFineCorsa IS NULL THEN
        INSERT INTO RifiutaRide
        SELECT CodChiamata, "Rifiutato Multiplo"
        FROM chiamata
        WHERE CodMultiplo = NEW.CodMultiplo 
			AND CodMultiplo IS NOT NULL;
    END IF;
END$$

CREATE TABLE rifiutaRide(
CodChiamata INT PRIMARY KEY,
Stato VARCHAR(100))$$

CREATE EVENT svuotaRifiutaRide
ON SCHEDULE EVERY 1 MINUTE DO
BEGIN
	DECLARE finito INT DEFAULT 0;
    DECLARE _codChiamata INT;
    DECLARE _stato VARCHAR(100);
    DECLARE lista CURSOR FOR 
    SELECT * 
    FROM rifiutaRide;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finito = 1;
    
    OPEN lista;
    scan: LOOP
		FETCH lista INTO _codChiamata, _stato;
        IF finito = 1 THEN
			LEAVE scan;
		END IF;
        UPDATE chiamata
        SET Stato = _stato, DataRisposta = CURRENT_TIMESTAMP()
        WHERE CodChiamata = _codChiamata;
    END LOOP scan;
    CLOSE lista;
    TRUNCATE TABLE rifiutaRide;
END$$

-- Operazione 24
-- si considera che un fruitore fa al massimo 1 solo sinistro per prenotazione, idealmente se succede un sinistro, la prenotazione finisce
DROP TRIGGER IF EXISTS aggiornaResponsabile$$

CREATE TRIGGER aggiornaResponsabile
AFTER INSERT ON sinistro
FOR EACH ROW 
BEGIN
	DECLARE _media DOUBLE DEFAULT 0;
    DECLARE _ViaggiSenzaSinistro INT DEFAULT 0;
    DECLARE _ViaggiTotali INT DEFAULT 0;
    DECLARE _responsabile VARCHAR(100);
    DECLARE _mediaAggiornata DEC(2,1) DEFAULT 0.0;
    
    SELECT Username INTO _responsabile
    FROM veicolidisponibili VD INNER JOIN prenotazioneveicolo PV ON VD.CodDisponibili = PV.CodDisponibili
    WHERE VD.Targa = NEW.Responsabile AND PV.Stato = "Accettato" AND current_timestamp() BETWEEN VD.DataInizio AND VD.DataFine;
    
    SELECT MediaSinistri/5, NoleggiEffettuati INTO _media, _ViaggiTotali
    FROM account
    WHERE Username = _responsabile;
    
    SET _ViaggiSenzaSinistro = _media * _ViaggiTotali;

	SET _mediaAggiornata = (_ViaggiSenzaSinistro - 1) / _ViaggiTotali *5;
    
    IF _mediaAggiornata IS NULL THEN
		SET _mediaAggiornata = 0.0;
	END IF;
	UPDATE account
    SET MediaSinistri = _mediaAggiornata
    WHERE Username = _responsabile;
END$$

-- Operazione boh

DROP TRIGGER IF EXISTS aggiornaMedia$$

CREATE TRIGGER aggiornaMedia
AFTER UPDATE ON `Account`
FOR EACH ROW
BEGIN
	IF OLD.NoleggiEffettuati = NEW.NoleggiEffettuati - 1 THEN
		BEGIN
			DECLARE _media DEC(2,1) DEFAULT 0;
            DECLARE _noleggiSenzaSinistri INT;
            SELECT MediaSinistri/5 INTO _media
            FROM account
            WHERE Username = NEW.Username;
            
            SET _noleggiSenzaSinistri = _media * OLD.NoleggiEffettuati;
            SET _media = (_noleggiSenzaSinistri + 1) / NEW.NoleggiEffettuati;
            IF _media IS NULL THEN 
				SET _media = 0;
			END IF;
            INSERT INTO escapeMedia
            VALUES(NULL,NEW.Username,_media*5);
            /*
            UPDATE account
            SET MediaSinistri = _media 
            WHERE Username = NEW.Username;*/
            
        END;
    END IF;
END$$

DROP TABLE IF EXISTS escapeMedia$$

CREATE TABLE escapeMedia(
	Ordine INT AUTO_INCREMENT PRIMARY KEY,
	Username VARCHAR(100),
    Media DEC(2,1)
)$$


DROP EVENT IF EXISTS eventEscapeMedia$$
SET GLOBAL event_scheduler = ON$$

CREATE EVENT eventEscapeMedia
ON SCHEDULE
EVERY 1 second
DO BEGIN
	DECLARE _username VARCHAR(100);
    DECLARE _media DOUBLE;
    DECLARE finito INT DEFAULT 0;
    DECLARE lista CURSOR FOR
    SELECT Username, Media
    FROM escapeMedia;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finito = 1;
    
    OPEN lista;
    scan: LOOP
		FETCH lista INTO _username, _media;
        IF finito = 1 THEN
			LEAVE scan;
		END IF;
		
        IF _username IS NOT NULL THEN
			UPDATE account
			SET MediaSinistri = _media
			WHERE Username = _username;
		END IF;
    END LOOP scan;
    CLOSE lista;
    truncate table escapeMedia;
END$$






















