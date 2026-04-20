DELIMITER $$
SET GLOBAL event_scheduler = ON$$
-- operazione 3

DROP EVENT IF EXISTS controlloDocumenti$$
-- funziona provato da michele il 14/02/2019
CREATE EVENT controlloDocumenti
ON SCHEDULE
EVERY 1 DAY DO
BEGIN
    UPDATE account
    SET Stato = "Sospeso"
    WHERE Username IN (SELECT Username
					   FROM persona NATURAL JOIN documento
					   WHERE Scadenza <= CURRENT_DATE());
END$$

-- Operazione 6

DROP EVENT IF EXISTS aggiornaVeicoli$$
-- ok
CREATE EVENT aggiornaVeicoli
ON SCHEDULE
EVERY 1 DAY DO
BEGIN 
	DECLARE _codProposta INT;
    DECLARE _codTragitto INT;
    DECLARE finito INT DEFAULT 0;
    DECLARE _consumoMisto INT DEFAULT 0;
    DECLARE _consumoUrbano INT DEFAULT 0;
    DECLARE _consumoExtraurbano INT DEFAULT 0;
    DECLARE _consumo INT DEFAULT 0;
    DECLARE _targa VARCHAR(100);
    DECLARE _capienza INT;
    DECLARE _quantoCarburante INT;
	DECLARE _indicePartenza INT DEFAULT 1;
	DECLARE _indiceArrivo INT DEFAULT 0;

    DECLARE listaPropostePool CURSOR FOR
    SELECT CodPool 
    FROM propostapool
    WHERE DATE_FORMAT(DataArrivo,'%Y%m%d') = CURRENT_DATE() - INTERVAL 1 DAY;
    
    DECLARE listaProposteRide CURSOR FOR
    SELECT CodProposta 
    FROM propostaride
    WHERE DATE_FORMAT(DataFine,'%Y%m%d') = CURRENT_DATE() - INTERVAL 1 DAY;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finito = 1;
    -- FACCIO TUTTE LE PROPOSTE POOL
    OPEN listaPropostePool;
	scan :LOOP
		FETCH listaPropostePool INTO _codProposta;
        IF finito = 1 THEN 
			LEAVE scan;
		END IF;
        
        SELECT Targa, CodTragitto INTO _targa, _codTragitto
        FROM propostaPool
        WHERE CodPool = _codProposta;
        
		SELECT Misto, Extraurbano, Urbano, VI.CapSerbatoio, VI.QuantoCarburante INTO _consumoMisto, _consumoExtraurbano, _consumoUrbano, _capienza, _quantoCarburante
        FROM veicolointerno VI NATURAL JOIN valoriconsumomedio VCM
        WHERE VI.Targa = _targa;
        
        SELECT MIN(Ordine) INTO _indicePartenza
        FROM partenza
        WHERE CodTragitto = _codTragitto;
        
        SELECT MAX(Ordine) INTO _indiceArrivo
        FROM arrivo
        WHERE CodTragitto = _codTragitto;
        
        CALL lunghezzaTragitto(_codTragitto,_indicePartenza,_indiceArrivo,_lunghezzaUrbane,_lunghezzaExtraurbane,_lunghezzaAutostrade);
        SET _consumo = (_lunghezzaExtraurbano * _consumoMisto) + (_lunghezzaAutostrade * _consumoExtraurbano) + (_lunghezzaUrbane * _consumoUrbano);
        IF _consumo > _quantoCarburante THEN
			SET _consumo = _capienza;
		ELSE 
			SET _consumo = _quantoCarburante - _consumo;
		END IF;
        
        UPDATE veicolointerno
        SET QuantoCarburante = _consumo, KmPercorsi = KmPercorsi + _lunghezzaUrbane + _lunghezzaAutostrade + _lunghezzaExtraurbane
        WHERE Targa = _targa;
	END LOOP scan;
    CLOSE listaProposteRide;
    
    -- FACCIO TUTTI I RIDE
    SET finito = 0;
	OPEN listaProposteRide;
	scan2 : LOOP
		FETCH listaProposteRide INTO _codProposta;
        IF finito = 1 THEN
			LEAVE scan2;
		END IF;
        BEGIN
        -- devo contare tutte le chiamate di quella proposta ride
        DECLARE _chiamata INT;
        DECLARE _lunghezzaTotale INT DEFAULT 0;
        DECLARE finitoSub INT DEFAULT 0;
        
        DECLARE listaChiamate CURSOR FOR
        SELECT CodChiamata
        FROM chiamata
        WHERE CodProposta = _codProposta;
        
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET finitoSub = 1;
        OPEN listaChiamate;
        scanSub : LOOP
			FETCH listaChiamate INTO _chiamata;
            IF finitoSub = 1 THEN
				LEAVE scanSub;
			END IF;
            
            SELECT Targa,CodTragitto INTO _targa, _codTragitto
            FROM propostaRide
            WHERE CodProposta = _codProposta;
            
            SELECT Ordine  INTO _indicePartenza
            FROM chiamata C INNER JOIN partenza P ON(C.LatitudinePartenza = P.Latitudine AND C.LongitudinePartenza = P.Longitudine AND C.AltitudinePartenza = P.Altitudine)
            WHERE P.CodTragitto = _codTragitto AND CodChiamata = _chiamata;
            
            SELECT Ordine  INTO _indiceArrivo
            FROM chiamata C INNER JOIN arrivo A ON(C.LatitudineArrivo = A.Latitudine AND C.LongitudineArrivo = A.Longitudine AND C.AltitudineArrivo = A.Altitudine)
            WHERE A.CodTragitto = _codTragitto AND CodChiamata = _chiamata;
            
			SELECT Misto, Extraurbano, Urbano, VI.CapSerbatoio, VI.QuantoCarburante INTO _consumoMisto, _consumoExtraurbano, _consumoUrbano, _capienza, _quantoCarburante
			FROM veicolointerno VI NATURAL JOIN valoriconsumomedio VCM
			WHERE VI.Targa = _targa;
            
            CALL lunghezzaTragitto(_codTragitto,_indicePartenza,_indiceArrivo, _lunghezzaUrbane,_lunghezzaExtraurbane,_lunghezzaAutostrade);
			
            SET _consumo = (_lunghezzaExtraurbano * _consumoMisto) + (_lunghezzaAutostrade * _consumoExtraurbano) + (_lunghezzaUrbane * _consumoUrbano);
			IF _consumo > _quantoCarburante THEN
				SET _consumo = _capienza;
			ELSE 
				SET _consumo = _quantoCarburante - _consumo;
			END IF;
			
			UPDATE veicolointerno
			SET QuantoCarburante = _consumo, KmPercorsi = KmPercorsi + _lunghezzaUrbane + _lunghezzaAutostrade + _lunghezzaExtraurbane
			WHERE Targa = _targa;
            
        END LOOP;
        CLOSE listaChiamate;
        END;
    END LOOP scan2;
    CLOSE listaProposteRide;
END$$ 


-- Operazione 9
-- funziona provato il 15/02/2019
DROP EVENT IF EXISTS rifiutoAutomaticoSharing$$

CREATE EVENT rifiutoAutomaticoSharing
ON SCHEDULE
EVERY 1 DAY DO
BEGIN
	UPDATE prenotazioneveicolo
    SET Stato = "Rifiutato", DataRisposta = CURRENT_TIMESTAMP()
    WHERE Stato = "In Attesa" AND DataInizio = CURRENT_DATE();
END$$


-- Operazione 22
-- FUNZIONA PROVATO IL 15/02/2019
DROP EVENT IF EXISTS rifiutoAutomaticoRide$$

CREATE EVENT rifiutoAutomaticoRide
ON SCHEDULE 
EVERY 15 MINUTE DO 
BEGIN
    
    UPDATE chiamata 
    SET Stato = "Rifiutato",DataRisposta = CURRENT_TIMESTAMP()
    WHERE DataRisposta IS NULL AND DataRichiesta > CURRENT_TIMESTAMP() - INTERVAL 15 MINUTE;
END$$

-- Operazione 32

DROP EVENT IF EXISTS aggiornamentoTempoMedioPercorrenza$$
-- ok
CREATE EVENT aggiornamentoTempoMedioPercorrenza
ON SCHEDULE 
EVERY 6 HOUR DO
BEGIN
	DECLARE _tempo INT DEFAULT 0;
    DECLARE finito INT DEFAULT 0;
    DECLARE _tratta INT;
    DECLARE listaTratte CURSOR FOR
    SELECT CodTratta
    FROM tratta;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finito = 1;
    OPEN listaTratte;
    scan : LOOP
		FETCH listaTratte INTO _tratta;
        IF finito = 1 THEN
			LEAVE scan;
		END IF;
        CALL calcolaTempo(_tratta,_tempo);
        UPDATE tratta
        SET TempoPercorrenza = _tempo
        WHERE CodTratta = _tratta;
    END LOOP scan;
    CLOSE listaTratte;
    
END$$


-- Operazione Elimia Tracking vecchi

DROP EVENT IF EXISTS eliminaTrackingVecchi$$

CREATE EVENT eliminaTrackingVecchi
ON SCHEDULE
EVERY 1 DAY DO
BEGIN
	-- SI CANCELLANO I TRACKING VECCHI OLTRE I 4 GIORNI PRIMA
    DELETE FROM tracking
    WHERE Data < CURRENT_TIMESTAMP() - INTERVAL 4 DAY;
	END$$

-- SERVE L'EVENT PER CANCELLARE I TRACKING
-- serve l'update degli stati delle proposte.
-- il cambio da chiuso a partito funziona provato il 15/02/2019
DROP EVENT IF EXISTS aggiornaStatoPropostaPool$$

CREATE EVENT aggiornaStatoPropostaPool
ON SCHEDULE 
EVERY 1 MINUTE DO BEGIN
	DECLARE finito INT DEFAULT 0;
    DECLARE _durataVal INT;
    DECLARE _dataPartenza DATETIME;
    DECLARE _codPool INT ;
    DECLARE lista CURSOR FOR
    SELECT CodPool, DurataVal, DataPartenza
    FROM propostapool
    WHERE CURRENT_TIMESTAMP() <= DataPartenza;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finito = 1;
    OPEN lista;
    scan : LOOP
		FETCH lista INTO _codPool, _durataVal, _dataPartenza;
        IF finito = 1 THEN
			LEAVE scan;
		END IF;
        
        IF DATE_FORMAT(CURRENT_TIMESTAMP(),"%Y%m%d %H") >= DATE_FORMAT(_dataPartenza - INTERVAL 1 HOUR,"%Y%m%d %H") THEN
			UPDATE propostapool
            SET Stato = "Partito"
            WHERE CodPool =_codPool;
		ELSEIF DATE_FORMAT(CURRENT_TIMESTAMP(),"%Y%m%d %H") >= DATE_FORMAT(_dataPartenza - INTERVAL _durataVal HOUR,"%Y%m%d %H") THEN
			UPDATE propostapool
            SET Stato ="Chiuso"
            WHERE CodPool = _codPool;
        END IF;
    END LOOP ;
    CLOSE lista;
END$$














