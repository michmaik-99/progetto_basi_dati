-- operazione 4

DROP PROCEDURE IF EXISTS inserimentoDoc;

DELIMITER $$

CREATE PROCEDURE inserimentoDoc (IN _Numero VARCHAR(100), IN _Scadenza DATE, IN _CodFiscale VARCHAR (100), IN _Tipo VARCHAR(100))
BEGIN
	DECLARE _doc VARCHAR(100);
    SELECT Numero  INTO _doc
    FROM documento 
    WHERE CodFiscale = _CodFiscale;
    
    INSERT INTO documento
		VALUES(_Numero,_Scadenza,_CodFiscale,_Tipo);
	
    DELETE FROM documento
    WHERE Numero = _doc;
    
END$$

-- operazione 1

DROP PROCEDURE IF EXISTS inserisciUtente$$

CREATE PROCEDURE inserisciUtente(IN _Username VARCHAR(100), IN _Password VARCHAR(100), IN _Fruitore INT, _Proponente INT,IN _Numero VARCHAR(100), IN _Scadenza DATE, IN _CodFiscale VARCHAR(100), IN _Tipo VARCHAR(100),IN _Telefono VARCHAR(100),IN _Nome VARCHAR(100), IN _Cognome VARCHAR(100), IN _Indirizzo VARCHAR(100), IN _CAP VARCHAR(100), IN _Domanda VARCHAR(100), IN _Risposta VARCHAR(100))
BEGIN
	INSERT INTO account (Username, Password, Fruitore, Proponente, Stato)
    VALUES(_Username, _Password, _Fruitore, _Proponente, "Inattivo");
    
    INSERT INTO persona(CodFiscale, Telefono, Nome, Cognome, Indirizzo, CAP, DataReg, Username)
    VALUES(_CodFiscale, _Telefono, _Nome, _Cognome, _Indirizzo, _CAP, CURRENT_DATE(), _Username);
    
    INSERT INTO documento
    VALUES(_Numero, _Scadenza, _CodFiscale, _Tipo);
    
    INSERT INTO datiRecupero
    VALUES(_Domanda, _Risposta, _Username);
END$$

-- operazione 2

DROP PROCEDURE IF EXISTS verificaId$$
/*La persona deve anche confermare il "numero di telefono"*/

CREATE PROCEDURE verificaId(IN _Username VARCHAR(100))
BEGIN
	DECLARE stato VARCHAR(100);
	DECLARE doc VARCHAR(100);
    
    SELECT D.Scadenza INTO doc
    FROM documento D NATURAL JOIN persona P
    WHERE P.Username = _Username;    
    SELECT Stato INTO stato
    FROM account
    WHERE Username = _Username;
    
    IF stato = "Inattivo" THEN
		IF doc <= CURRENT_DATE() OR doc IS NULL THEN
			UPDATE account
            SET Stato = "Sospeso"
            WHERE Username = _Username;
		ELSE
			UPDATE account 
            SET Stato = "Attivo"
			WHERE Username = _Username;
		END IF;
	END IF;
END$$


-- Operazione 5.1

DROP PROCEDURE IF EXISTS inserisciVeicolo$$

CREATE PROCEDURE inserisciVeicolo( IN _Targa VARCHAR(100),IN _Annoimmatricolazione INT, IN _Casaproduttrice VARCHAR(100),IN _Modello VARCHAR(100), IN _Cilindrata INT, IN _Numeroposti INT, IN _Velocita INT, IN _Alimentazione VARCHAR(100), IN _kmPercorsi INT, IN _CapacitaSerbatoio INT, IN _Quantocarburante INT, IN _Username VARCHAR(100))
BEGIN
	INSERT INTO veicoloInterno
	VALUES(_Targa, _Annoimmatricolazione, _Casaproduttrice, _Modello, _Cilindrata, _Numeroposti, _Velocita,_Alimentazione, _kmPercorsi, _CapacitaSerbatoio,_QuantoCarurante,_Username);
END$$

-- Operazione 5.2
DROP PROCEDURE IF EXISTS inserisciConsumi$$

CREATE PROCEDURE inserisciConsumi(IN _Targa VARCHAR(100), IN _Misto INT, IN _Extraurbano INT, IN _Urbano INT)
BEGIN
	INSERT INTO valoriConsumoMedio
    VALUES(_Targa, _Misto, _Extraurbano, _Urbano);
END$$
-- Operazione 5.3
DROP PROCEDURE IF EXISTS inserisciManutenzione$$

CREATE PROCEDURE inserisciManutenzione(IN _Targa VARCHAR(100), IN _Ordinario INT, IN _Straordinario INT)
BEGIN
	INSERT INTO costManutenzione
    VALUES(_Targa,_Ordinario,_Straordinario);
END$$
-- Operazione 5.4
DROP PROCEDURE IF EXISTS inserisciOptional$$

CREATE PROCEDURE inserisciOptional(IN _Targa VARCHAR(100), IN _Airbag INT, IN _Navigatore INT, IN _ABS INT, IN _AriaCond INT,
									IN _TavoliniPost INT, IN _SensoriParch INT, _SensoriFren INT, IN _TettoPan INT,
                                    IN _GuidaAss INT, IN _Trasmissione INT, IN _Connettivita INT, IN _DimBagagliaio INT,
									IN _InquinAcustico INT)
BEGIN
	INSERT INTO optional
	VALUES (_Airbag, _Navigatore, _ABS, _AriaCond, _TavoloniPost, _SensoriParch, _SensoriFren, _TettoPan, _GuidaAss, _Trasmissione, _Connettivita, _DimBagagliaio, _InquinAcustico, _Targa);
END$$

-- Operazione 29
-- il voto è in base all' ambito

DROP PROCEDURE IF EXISTS letturaRecensione$$

CREATE PROCEDURE letturaRecensione (IN _Username VARCHAR(100))
BEGIN
	DECLARE mediaCom DOUBLE DEFAULT 0;
    DECLARE mediaViaggio DOUBLE DEFAULT 0;
    DECLARE mediaSer DOUBLE DEFAULT 0;
    DECLARE mediaSinistri DOUBLE DEFAULT 0;
    
    SELECT MediaSinistri INTO mediaSinistri
    FROM account 
    WHERE Username = _Username;
    
    SELECT AVG(VotoComp) INTO mediaCom
    FROM recensione
    WHERE Destinatario = _Username
		AND VotoComp IS NOT NULL;
        
	SELECT AVG(VotoViaggio) INTO mediaViaggio
    FROM recensione
    WHERE Destinatario = _Username
		AND VotoViaggio IS NOT NULL;
	
    SELECT AVG(VotoSerieta) INTO MediaSer
    FROM recensione
    WHERE Destinatario = _Username
		AND VotoSerieta IS NOT NULL;
    
    SELECT Recensore, Commento
    FROM recensione
	WHERE Destinatario = _Username
		AND Commento IS NOT NULL;
        
	SELECT _Username AS Username, mediaCom AS MediaCompotamento, mediaViaggio AS MediaViaggio, mediaSer AS MediaSerieta, mediaSinistri AS MediaSinistri;
END$$

-- Operazione 30

DROP PROCEDURE IF EXISTS inserisciRecensione$$

CREATE PROCEDURE inserisciRecensione(IN _Destinatario VARCHAR(100), IN _Comportamento INT, IN _Viaggio INT, IN _Serieta INT, IN _Commento TINYTEXT, IN _Recensore VARCHAR(100))
BEGIN
	INSERT INTO recensione(Destinatario,VotoComp,VotoViaggio,VotoSerieta,Commento,Recensore)
	VALUES(_Destinatario,_Comportamento,_Viaggio,_Serieta,_Commento,_Recensore);
END$$

-- Operazione 26

DROP PROCEDURE IF EXISTS creazioneCarSharing$$

CREATE PROCEDURE creazioneCarSharing(IN _targa VARCHAR(100), IN _inizio DATE, IN _fine DATE)
BEGIN    
	INSERT INTO veicolidisponibili(DataInizio, DataFine, Targa)
    VALUES(_inizio, _fine, _targa);
END$$

-- Operazione 10

DROP PROCEDURE IF EXISTS rifiutoAutomaticoConsegnaSharing$$

CREATE PROCEDURE rifiutoAutomaticoConsegnaSharing(IN _targa VARCHAR(100),IN _carburante INT, IN _km INT)
BEGIN
	DECLARE quantoCarb INT DEFAULT 0;
    DECLARE capSerb INT DEFAULT 0;
    
    SELECT (QuantoCarburante * 90 / 100), CapSerbatoio INTO quantoCarb, capSerb
    FROM veicolointerno
    WHERE Targa = _targa;
    IF _carburante < quantoCarb THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "La quantità di carburante è troppo inferiore al dovuto, tornare con più carburante";
	END IF;
	UPDATE veicolointerno
    SET QuantoCarburante = _carburante
		AND KmPercorsi = KmPercorsi + _km
	WHERE Targa = _targa;
END$$

-- Operazione 27

DROP PROCEDURE IF EXISTS creazioneCarPooling$$

CREATE PROCEDURE creazioneCarPooling(IN _DataPartenza DATETIME, _DataArrivo DATETIME, IN _durataVal INT, IN _TassoVar INT, IN _flessibilita INT, IN _targa VARCHAR(100), IN _codTragitto INT)
BEGIN    
	DECLARE _lung INT DEFAULT 0;
    DECLARE _costo INT DEFAULT 0;
    DECLARE _lungUrb INT DEFAULT 0;
    DECLARE _lungExt INT DEFAULT 0;
    DECLARE _lungAut INT DEFAULT 0;
    DECLARE _maxIndex INT;
    
    SELECT MAX(Ordine) INTO _maxIndex
    FROM partenza
    WHERE CodTragitto = _codTragitto;
    CALL lunghezzaTragitto(_codTragitto,1,_maxIndex,_lungUrb,_lungExt,_lungAut);
    SET _lung = _lungUrb + _lungExt + _lungAut;

    SELECT (Urbano*_lungUrb + Extraurbano*_lungAut + Misto*_lungExt) INTO _costo 
    FROM valoriconsumomedio
    WHERE Targa = _targa;
    
	INSERT INTO propostapool(LungTragitto,DataPartenza, DataArrivo, DataCreazione, DurataVal, TassoVar, Flessibilita,Costo, Targa, CodTragitto)
        VALUES(_lung,_DataPartenza, _DataArrivo, CURRENT_TIMESTAMP(), _durataVal, _TassoVar, _flessibilita,_costo, _targa, _codTragitto);
END$$

-- operazione 28

DROP PROCEDURE IF EXISTS creazioneRideSharing$$

CREATE PROCEDURE creazioneRideSharing(IN _costo DOUBLE, IN _DataInizio DATETIME, IN _DataFine DATETIME, IN _codTragitto INT, IN _targa VARCHAR(100))
BEGIN
    INSERT INTO propostaride(Costo, DataInizio, DataFine, CodTragitto, Targa)
		VALUES(_costo, _DataInizio, _DataFine, _codTragitto, _targa);
END$$


-- Operazione 12
DROP PROCEDURE IF EXISTS creazionePrenotazionePool$$

CREATE PROCEDURE creazionePrenotazionePool(IN _Username VARCHAR(100), IN _CodPool INT)
BEGIN
	DECLARE stato INT;
    
    SELECT Fruitore INTO stato
    FROM account
    WHERE Username = _Username;
    IF stato = 0 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "L'utente richiedente non è fruitore";
	END IF;
	INSERT INTO prenotazionepool(StatoAcc,DataRichiesta,Username,CodPool)
    VALUES("In Attesa",CURRENT_TIMESTAMP(),_Username,_CodPool); 
END$$

-- Operazione 13

DROP PROCEDURE IF EXISTS creazionePrenotazionePoolConVariazione$$

CREATE PROCEDURE creazionePrenotazionePoolConVariazione(IN _Username VARCHAR(100), IN _CodPool INT, IN _variazione INT)
BEGIN
	DECLARE _CostoVar INT DEFAULT 0;
    DECLARE _CodTragitto INT;
    DECLARE _CodPrenotazione INT;
    DECLARE _TassoVar INT;
    DECLARE _lunghezzaVar INT DEFAULT 0;
    DECLARE _flessibilita INT DEFAULT 0;
    DECLARE _lunghezzaUrbane INT DEFAULT 0;
    DECLARE _lunghezzaExtraurbane INT DEFAULT 0;
    DECLARE _lunghezzaAutostrade INT DEFAULT 0;
    DECLARE _indiceArrivo INT DEFAULT 0;
    DECLARE _lunghezzaOriginale INT DEFAULT 0;
    DECLARE _differenzaLunghezza INT DEFAULT 0;
    DECLARE _fruitore INT;
    DECLARE _stato VARCHAR(100);
    
    SELECT Stato INTO _stato
	FROM propostaPool
	WHERE CodPool = _codPool;
    
    IF _stato <> "Chiuso" THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "La proposta non è in stato chiuso";
	END IF;
    
    SELECT Fruitore INTO _fruitore
    FROM account
    WHERE Username = _Username;
    
    IF _fruitore = 0 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Il richiedente non è fruitore";
	END IF;
    
    SELECT CodTragitto,TassoVar, Flessibilita, LungTragitto INTO _CodTragitto, _TassoVar, _flessibilita, _lunghezzaOriginale
    FROM propostapool
    WHERE CodPool = _CodPool;
    
    SELECT MAX(Ordine) INTO _indiceArrivo
    FROM arrivo
    WHERE CodTragitto = _CodTragitto;
    
    CALL lunghezzaTragitto(_variazione,1,_indiceArrivo,_lunghezzaUrbane,_lunghezzaExtraurbane,_lunghezzaAutostrade);
    SET _lunghezzaVar = _lunghezzaUrbane + _lunghezzaExtraurbane + _lunghezzaAutostrade;
    SET _differenzaLunghezza = _lunghezzaVar - _lunghezzaOriginale;
    
    IF _differenzaLunghezza < 0 THEN
		SET _differenzaLunghezza = 0;
	END IF;
    
    IF _differenzaLunghezza >= _flessibilita THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "La variazione proposta supera la flessibilità massima";
    END IF;
    
    SET _CostoVar = _differenzaLunghezza * _TassoVar/100;
 
 	INSERT INTO prenotazionepool(StatoAcc,DataRichiesta,Username,CodPool)
    VALUES("In Attesa",CURRENT_TIMESTAMP(),_Username,_CodPool);
    
    SELECT MAX(CodPrenotazione) INTO _CodPrenotazione
    FROM prenotazionepool;
    
    INSERT INTO variazionerichiesta
    VALUE(_CostoVar,_variazione,_CodPrenotazione);
    
END$$


-- Operazione 19

DROP PROCEDURE IF EXISTS lunghezzaTragitto$$

CREATE PROCEDURE lunghezzaTragitto(IN _codTragitto INT,IN _indicePartenza INT, IN _indiceArrivo INT, OUT lunghezzaUrbane_ INT, OUT lunghezzaExtraurbane_ INT, OUT lunghezzaAutostrade_ INT) 
BEGIN
        DECLARE _lunghezzaUrbane INT DEFAULT 0;
        DECLARE _lunghezzaExtraurbane INT DEFAULT 0;
        DECLARE _lunghezzaAutostrade INT DEFAULT 0;
        DECLARE finito INT DEFAULT 0;
		DECLARE partenzaLat DOUBLE ;
		DECLARE partenzaLong DOUBLE;
		DECLARE partenzaAlt DOUBLE;
		DECLARE arrivoLat DOUBLE;
		DECLARE arrivoLong DOUBLE;
		DECLARE arrivoAlt DOUBLE;
		DECLARE _tratta INT;
		/*DECLARE kmPartenza INT;
		DECLARE kmArrivo INT;*/
        DECLARE _tipologia VARCHAR(100);
        DECLARE diff INT DEFAULT 0;
        
        DECLARE listaPart CURSOR FOR
        SELECT Latitudine,Longitudine,Altitudine
        FROM partenza
        WHERE CodTragitto = _codTragitto AND Ordine BETWEEN _indicePartenza AND  _indiceArrivo
        ORDER BY Ordine ASC; 
        
        DECLARE listaArr CURSOR FOR 
        SELECT Latitudine,Longitudine,Altitudine
        FROM arrivo
        WHERE CodTragitto = _codTragitto AND Ordine BETWEEN _indicePartenza AND  _indiceArrivo
        ORDER BY Ordine ASC;

        DECLARE CONTINUE HANDLER FOR NOT FOUND SET finito = 1;

        OPEN listaPart;
        OPEN listaArr;
			scan : LOOP
				FETCH listaPart INTO partenzaLat, partenzaLong, partenzaAlt;
                FETCH listaArr INTO arrivoLat, arrivoLong, arrivoAlt;
                IF finito = 1 THEN
					
					LEAVE scan;
				END IF;
                
                SELECT (CT2.Km - CT.Km) , CT.CodTratta INTO diff, _tratta
                FROM collegamentotratte CT INNER JOIN collegamentotratte CT2 USING(CodTratta)
                WHERE CT.Latitudine = partenzaLat AND 
					  CT.Longitudine = partenzaLong AND 
                      CT.Altitudine = partenzaAlt AND 
                      CT2.Latitudine = arrivoLat AND 
                      CT2.Longitudine = arrivoLong AND 
                      CT2.Altitudine = arrivoAlt AND 
                      CT.Km < CT2.Km AND
                      (CT2.Km - CT.Km)=(SELECT MIN(CT4.Km - CT3.Km)
										FROM collegamentotratte CT3 INNER JOIN collegamentotratte CT4 USING(CodTratta)
										WHERE CT3.Latitudine = partenzaLat AND 
											  CT3.Longitudine = partenzaLong AND 
                                              CT3.Altitudine = partenzaAlt AND 
                                              CT4.Latitudine = arrivoLat AND 
                                              CT4.Longitudine = arrivoLong AND 
                                              CT4.Altitudine = arrivoAlt AND 
                                              CT3.Km < CT4.Km); 
				/*SELECT  CodTratta INTO _tratta
				FROM collegamentotratte CT INNER JOIN partenza P USING(Latitudine, Longitudine,Altitudine) INNER JOIN arrivo USING(CodTragitto,Ordine)) 
				WHERE (Latitudine = partenzaLat AND Longitudine = partenzaLong AND Altitudine = partenzaAlt) 
						OR (Latitudine = arrivoLat AND Longitudine = arrivoLong AND Altitudine = arrivoAlt)
				GROUP BY CodTratta
				HAVING COUNT(*) >1;
                
				SELECT Km INTO kmPartenza
				FROM collegamentotratte
				WHERE CodTratta = _tratta AND Latitudine = partenzaLat AND Longitudine = partenzaLong AND Altitudine = patenzaAlt;
				
				SELECT Km INTO kmArrivo
				FROM collegamentotratte
				WHERE CodTratta = _tratta AND Latitudine = arrivoLat AND Longitudine = arrivoLong AND Altitudine = arrivoAlt;*/

                SELECT Tipologia INTO _tipologia
                FROM tratta
                WHERE CodTratta = _tratta;
                IF _tipologia = "Extraurbana" THEN
					SET _lunghezzaExtraurbane = _lunghezzaExtraurbane + ABS(diff);
				ELSEIF _tipologia = "Urbana" THEN
					SET _lunghezzaUrbane = _lunghezzaUrbane + ABS(diff);
				ELSEIF _tipologia = "Autostrada" OR _tipologia = "Raccordo" OR _tipologia = "Traforo" THEN
					SET _lunghezzaAutostrade = _lunghezzaAutostrade + ABS(diff);
				END IF;
            END LOOP scan;
        CLOSE listaPart;
        CLOSE listaArr;
        SET lunghezzaUrbane_ = _lunghezzaUrbane;
        SET lunghezzaExtraurbane_ = _lunghezzaExtraurbane;
        SET lunghezzaAutostrade_ = _lunghezzaAutostrade;
END$$


-- Operazione 7
-- controllo che data inizio e data fine sono dopo 
DROP PROCEDURE IF EXISTS prenotazioneCarSharing$$

CREATE PROCEDURE prenotazioneCarSharing(IN _DataInizio DATE, IN _DataFine DATE, IN _Username VARCHAR(100), IN _CodDisponibili INT)
BEGIN
	DECLARE _fruitore INT;
    
    SELECT Fruitore INTO _fruitore
	FROM account
    WHERE Username = _Username;
    
    IF _fruitore = 0 THEN
		SIGNAL SQLSTATE'45000'
        SET MESSAGE_TEXT = "Il richiedente non è fruitore";
	END IF;
	INSERT INTO prenotazioneveicolo(DataInizio,DataFine,Stato,DataRichiesta,Username,CodDisponibili)
    VALUES(_DataInizio,_DataFine,"In Attesa", CURRENT_TIMESTAMP(),_Username,_CodDisponibili);
END$$

-- Operazione 8

DROP PROCEDURE IF EXISTS visionePrenotazioneRecente$$

CREATE PROCEDURE visionePrenotazioneRecente(IN CodProposta INT)
BEGIN
	DECLARE _dataFine DATE;
	
    SELECT DataFine INTO _dataFine
    FROM veicolidisponibili
    WHERE CodDisponibili = CodProposta;
    
	IF CURRENT_DATE() > _dataFine THEN
		SIGNAL SQLSTATE'45000'
        SET MESSAGE_TEXT = "La proposta di car sharing è già terminata, non puoi più guardare le prenotazioni attive su di essa.";
    END IF;
    
    SELECT Username, DataInizio, DataFine, DataRichiesta
    FROM prenotazioneveicolo
    WHERE CodDisponibili = CodProposta
		AND Stato = "In Attesa"
	ORDER BY DataRichiesta ASC
    LIMIT 1; -- DA CONTROLLARE ASC O DESC
    
END$$


-- Operazione 11 

DROP PROCEDURE IF EXISTS accettazioneNoleggio$$

CREATE PROCEDURE accettazioneNoleggio(IN _codPrenotazione INT,IN _stato VARCHAR(100))
BEGIN
	DECLARE _vecchioStato VARCHAR(100);
	IF _stato != "Accettato" AND _stato != "Rifiutato" THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Il valore dello stato non va bene.";
    END IF;
    
    SELECT Stato INTO _vecchioStato
    FROM prenotazioneveicolo
    WHERE CodPrenotazione = _codPrenotazione;
    
    IF _vecchioStato = "Accettato" OR _vecchioStato = "Rifiutato" THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Non puoi modificare lo stato di una prenotazione già decisa.";
    END IF;
    
	UPDATE prenotazioneveicolo
    SET Stato = _stato, DataRisposta = CURRENT_DATE()
    WHERE CodPrenotazione = _codPrenotazione;
END$$


-- Operazione 19 

DROP PROCEDURE IF EXISTS creazionePrenotazioneRideSingolo$$

CREATE PROCEDURE creazionePrenotazioneRideSingolo(IN _latitudinePartenza DOUBLE, _longitudinePartenza DOUBLE,IN _altitudinePartenza INT,IN _latitudineArrivo DOUBLE, IN _longitudineArrivo DOUBLE, IN _altitudineArrivo INT, IN _Username VARCHAR(100), IN _codProposta INT, IN DataRichiesta DATETIME)
BEGIN
	DECLARE _fruitore INT;
    SELECT Fruitore INTO _fruitore
    FROM account
    WHERE Username = _Username;
    IF _fruitore = 0 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT ="Il richiedente non è un fruitore";
	END IF;
	INSERT INTO chiamata(DataRichiesta,DataFineCorsa,Stato,LatitudinePartenza,LongitudinePartenza,AltitudinePartenza,LatitudineArrivo,LongitudineArrivo,AltitudineArrivo,Username,CodProposta)
    VALUES(DataRichiesta, NULL, "In Attesa", _latitudinePartenza, _longitudinePartenza, _altitudinePartenza, _latitudineArrivo, _longitudineArrivo, _altitudineArrivo, _Username, _codProposta);
END$$

-- Operazione 19.2

DROP PROCEDURE IF EXISTS fineChiamataRideSharing$$

CREATE PROCEDURE fineChiamataRideSharing(IN  _codChiamata INT, IN _dataFineCorsa DATETIME)
BEGIN
	UPDATE chiamata
    SET DataFineCorsa = _dataFineCorsa
    WHERE CodChiamata = _codChiamata;
END$$

-- Operazione 20

DROP PROCEDURE IF EXISTS accettazionePrenotazioneRide$$

CREATE PROCEDURE accettazionePrenotazioneRide(IN _codPrenotazione INT, IN _stato VARCHAR(100))
BEGIN
	DECLARE _risposta DATETIME;
    
	IF _stato <> "Accettato" AND _stato <> "Rifiutato" THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Lo stato della risposta non è valida.";
	END IF;
    
    SELECT	DataRisposta INTO _risposta
    FROM chiamata
    WHERE CodChiamata = _codPrenotazione;
    
    IF _risposta IS NOT NULL THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Impossibile modificare lo stato della chiamata.";
	END IF;
    
	UPDATE chiamata
    SET Stato = _stato , DataRisposta = CURRENT_TIMESTAMP()
    WHERE CodChiamata = _codPrenotazione; 
END$$

-- Operazione 17

DROP PROCEDURE IF EXISTS visioneNoleggiDisponibili$$

CREATE PROCEDURE visioneNoleggiDisponibili(IN _dataInizio DATE)
BEGIN
	DECLARE _indirizzo VARCHAR(100);
    DECLARE _targa VARCHAR(100);
	
    IF _dataInizio <= CURRENT_DATE() THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Puoi selezionare solo date dopo il giorno corrente.";
    END IF;
    SELECT DISTINCT D.CodDisponibili, D.DataInizio, D.DataFine, VI.Targa, P.Indirizzo, A.Username
    FROM (SELECT VD.CodDisponibili, VD.DataInizio, VD.DataFine, VD.Targa
		  FROM veicolidisponibili VD
          WHERE NOT EXISTS(SELECT * 
						   FROM prenotazioneveicolo VD2 
						   WHERE VD2.CodDisponibili = VD.CodDisponibili AND Stato = "Accettato")) AS D
                           NATURAL JOIN veicolointerno VI NATURAL JOIN `account` A NATURAL JOIN persona P
    WHERE D.DataInizio > _dataInizio;
END$$

-- Operazione 15
-- opinabile come operazione
DROP PROCEDURE IF EXISTS visionePoolInPartenza$$

CREATE PROCEDURE visionePoolInPartenza(IN _codPool VARCHAR(100))
BEGIN
	
    DECLARE _stato VARCHAR(100);
    
    IF _stato != "Partito" THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Il pool non è in partenza quindi può avere modifiche.";
	END IF;
    
    SELECT Username, CostoVar, VR.CodTragitto 
    FROM prenotazionepool PP LEFT OUTER JOIN variazionerichiesta VR USING (CodPrenotazione)
    WHERE PP.CodPool = _codPool AND StatoAcc = "Accettato";
END$$

-- Operazione 14

DROP PROCEDURE IF EXISTS accettaPoolConVariazione$$

CREATE PROCEDURE accettaPoolConVariazione(IN _codPrenotazione INT)
BEGIN
	DECLARE _codTragitto INT DEFAULT NULL;
    DECLARE _codPool INT DEFAULT NULL;
    DECLARE _lunghezzaUrbana INT DEFAULT 0;
    DECLARE _lunghezzaAutostrada INT DEFAULT 0;
    DECLARE _lunghezzaExtraurbana INT DEFAULT 0;
    DECLARE _maxIndice INT DEFAULT 0;
    DECLARE _lunghezzaOriginale INT DEFAULT 0;
    DECLARE _lunghezzaTotale INT DEFAULT 0;
    DECLARE _flessibilita INT;
    
    
    SELECT CodTragitto INTO _codTragitto
    FROM variazioneRichiesta
    WHERE CodPrenotazione = _codPrenotazione;
    
    IF _codTragitto IS NULL THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT ="La prenotazione non ha variazione.";
	END IF;
    
    SELECT CodPool INTO _codPool 
    FROM prenotazionepool
    WHERE CodPrenotazione = _codPrenotazione;
    
    SELECT Flessibilita INTO _flessibilita
    FROM propostapool
    WHERE CodPool = _codPool;
    
    SELECT LungTragitto INTO _lunghezzaOriginale
    FROM propostapool
    WHERE CodPool = _codPool;
    
    SELECT MAX(Ordine) INTO _maxIndice
    FROM arrivo
    WHERE CodTragitto = _codTragitto;
    
    CALL lunghezzaTragitto(_codTragitto , 1 , _maxIndice, _lunghezzaUrbana, _lunghezzaExtraurbana, _lunghezzaAutostrada);
	
    UPDATE prenotazionePool
    SET StatoAcc = "Accettato" , DataRisposta = CURRENT_TIMESTAMP()
    WHERE CodPrenotazione = _codPrenotazione;
    
    SET _lunghezzaTotale = _lunghezzaUrbana + _lunghezzaExtraurbana + _lunghezzaAutostrada;
    IF _flessibilita <> 0 AND _flessibilita > _lunghezzaTotale - _lunghezzaOriginale THEN
		IF _lunghezzaTotale > _lunghezzaOriginale THEN
			UPDATE propostaPool
			SET CodTragitto = _codTragitto ,  LungTragitto = _lunghezzaTotale , Flessibilita = _flessibilita - (_lunghezzaTotale - _lunghezzaOriginale)
			WHERE CodPool = _codPool;
		ELSE 
			UPDATE propostaPool
			SET CodTragitto = _codTragitto ,  LungTragitto = _lunghezzaTotale , Flessibilita = _flessibilita
			WHERE CodPool = _codPool;
        END IF;
    END IF;
END$$

-- Operazione 16
-- Il controllo del veicolo completamente occupato non è stato implementato 
DROP PROCEDURE IF EXISTS visionePoolDisponibili$$

CREATE PROCEDURE visionePoolDisponibili(IN _codTragitto INT)
BEGIN
	SELECT CodPool, LungTragitto, DataPartenza, DataArrivo,Stato, DurataVal, TassoVar ,Costo,CodTragitto, IF(Flessibilita BETWEEN 0 AND 5, "Bassa", IF(Flessibilita BETWEEN  6 AND 10 , "Media","Alta")) AS Flessibilita
    FROM propostapool
    WHERE (Stato = "Aperto" OR Stato = "Chiuso") AND CodTragitto = _codTragitto AND DataPartenza > CURRENT_TIMESTAMP();
END$$


-- Operazione 24

DROP PROCEDURE IF EXISTS visioneRideDisponibili$$

CREATE PROCEDURE visioneRideDisponibili(IN _codTragitto INT)
BEGIN
	SELECT * 
    FROM propostaride
    WHERE CodTragitto = _codTragitto AND CURRENT_TIMESTAMP() BETWEEN DataInizio AND DataFine;
END$$

-- Operazione 32

DROP PROCEDURE IF EXISTS calcolaTempo$$

CREATE PROCEDURE calcolaTempo(IN _codTratta VARCHAR(100), OUT _tempo INT)
BEGIN
	DECLARE _limVelocitaSucc INT DEFAULT 0;
    DECLARE _limVelocitaPrec INT DEFAULT 0;
    DECLARE _kmPrec INT DEFAULT 0;
    DECLARE _kmSucc INT DEFAULT 0;
    DECLARE tempoIdeale FLOAT(10,2) DEFAULT 0;
    DECLARE aumento INT DEFAULT 0;
    DECLARE finito INT DEFAULT 0;
    DECLARE listaPos CURSOR FOR
    SELECT Km, LimVelocita 
    FROM collegamentotratte
    WHERE CodTratta = _codTratta
    ORDER BY Km ASC;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finito = 1;
    
    OPEN listaPos;
    scan : LOOP
		IF _kmSucc != 0 THEN
			SET tempoIdeale = tempoIdeale + ABS(_kmSucc - _kmPrec) / _limVelocitaPrec * 60;
		END IF;
		SET _kmPrec = _kmSucc;
        SET _limVelocitaPrec = _limVelocitaSucc;
		FETCH listaPos INTO _kmSucc,_limVelocitaSucc;
        IF finito = 1 THEN
			LEAVE scan;
        END IF;
    END LOOP scan;
    CLOSE listaPos;
    SELECT COUNT(DISTINCT T.Targa)/_kmSucc INTO aumento
    FROM tracking T INNER JOIN collegamentotratte CT ON (T.Latitudine = CT.Latitudine AND T.Longitudine = CT.Longitudine AND T.Altitudine = CT.Altitudine)
    WHERE CT.CodTratta = _codTratta AND T.Data BETWEEN CURRENT_TIMESTAMP() - INTERVAL 4 DAY AND CURRENT_TIMESTAMP ();
    
    SET _tempo = tempoIdeale + aumento;
END$$
/*
-- Operazione 31 non possiamo usare funzioni strane

DROP PROCEDURE IF EXISTS creaTragitto$$

-- DA RICONTROLLARE LA FUNZIONE SUBSTRING
-- FORMATO PROCEDURE:
-- CALL creaTragitto("lat1 long1 alt1,lat2 long2 alt2,...)
-- CONTROLLA SEDEVI CONVERTIREDA STRINGA A DOUBLE/INT

CREATE PROCEDURE creaTragitto(IN _posizioni TEXT)
BEGIN
	DECLARE _lat DOUBLE;
    DECLARE _long DOUBLE;
    DECLARE _alt INT;
    DECLARE separatore INT;
    DECLARE _coords VARCHAR(100);
    DECLARE _codTragitto INT;
    DECLARE positionSpace INT;
    
    INSERT INTO tragitto
    VALUE(NULL);
    
    SELECT MAX(CodTragitto) INTO _codTragitto
    FROM tragitto;
    
	DROP TEMPORARY TABLE posizioniDaInserire;
        
    CREATE TEMPORARY TABLE posizioniDaInserire(
		CodTragitto INT,
		altitudine INT,
		latitudine DEC(3,1),
		longitudine DEC(3,1),
		ordine INT AUTO_INCREMENT,
		PRIMARY KEY(altitudine,latitidine,longitudine));
    
    scan:LOOP
		IF _posizioni = "" THEN
			LEAVE scan;
		END IF;
        
        SET separatore = POSITION(',' IN _posizioni);
        
        SET _coords = SUBSTRING(_posizioni,1,separatore-1);
        
        SET positionSpace = POSITION(' ' IN _coords);
        SET _lat = SUBSTRING(_coords, 1, positionSpace-1);
        SET _coords = SUBSTRING(_coords, positionSpace+1, LENGTH(_coords)-positionSpace);
        SET positionSpace = POSITION(' ' IN _coords);
        SET _long = SUBSTRING(_coords, 1, positionSpace - 1);
        SET _alt = SUBSTRING(_coords, positionSpace + 1,LENGTH(_coords)-positionSpace);
        INSERT INTO posizioniDaInserire(CodTragitto,latitudine,longitudine,altitudine,ordine)
        VALUES(_codTragitto,CAST(_lat AS DECIMAL(3,2)),CAST(_long AS DECIMAL(3,2)),CAST(_alt AS DECIMAL(3,0)),NULL);
        
        SET _posizioni = SUBSTRING(_posizioni,separatore+1,LENGTH(_posizioni)-separatore);
    END LOOP scan;
    
    INSERT INTO partenza(Ordine,CodTragitto,Latitudine,Longitudine,Altitudine)
    SELECT ordine,CodTragitto,latitudine,longitudine,altitudine
    FROM posizioniDaInserire
    WHERE ordine <> (SELECT MAX(ordine)
					 FROM posizioniDaInserire);
                     
    INSERT INTO partenza(Ordine,CodTragitto,Latitudine,Longitudine,Altitudine)
    SELECT ordine-1,CodTragitto,latitudine,longitudine,altitudine
    FROM posizioniDaInserire
    WHERE ordine <> (SELECT MIN(ordine)
					 FROM posizioniDaInserire);
    
END$$*/


-- Operazione 24  non possiamo usare funzioni strane
-- FORMATO PROCEDURE:
-- CALL inserisciSinistro("Responsabile","Latitudine","Longitudine","Altitudine","Targa Nome Cognome,...");

DROP PROCEDURE IF EXISTS inserisciSinistro$$

CREATE PROCEDURE inserisciSinistro(IN _responsabile VARCHAR(100),IN _lat DOUBLE, IN _long DOUBLE, IN _alt INT, IN _coinvolti TINYTEXT)
BEGIN
	DECLARE _codSinistro INT;
    DECLARE _targa VARCHAR(7);
    DECLARE _proprietario VARCHAR(100);
    DECLARE _separatore INT;
    DECLARE _positionSpace INT;
    
    INSERT INTO sinistro(CodSinistro,Data,Responsabile,Latitudine,Longitudine,Altitudine)
    VALUES(NULL,CURRENT_TIMESTAMP(),_responsabile,_lat,_long,_alt);
    
    SELECT MAX(CodSinistro) INTO _codSinistro
    FROM sinistro;
    
    scan : LOOP
		IF _coinvolti = "" THEN
			LEAVE scan;
		END IF;
        SET _positionSpace = POSITION(' ' IN _coinvolti);
        SET _separatore = POSITION(',' IN _coinvolti);
        
        SET _targa = SUBSTRING(_coinvolti,1,_positionSpace-1);
        IF _separatore <> 0 THEN
			SET _proprietario = SUBSTRING(_coinvolti,_positionSpace+1,_separatore-1-_positionSpace);
        ELSE
			SET _proprietario = SUBSTRING(_coinvolti,_positionSpace+1,LENGTH(_coinvolti)-_positionSpace);
        END IF;
        IF EXISTS(SELECT *
				  FROM veicolointerno
                  WHERE Targa = _targa) THEN
			INSERT INTO coinvinterni(CodSinistro,Targa)
            VALUES(_codSinistro,_targa);
		ELSE
			IF NOT EXISTS(SELECT * 
						  FROM veicoliesterni
                          WHERE Targa = _targa) THEN
			INSERT INTO veicoliesterni(Targa,Proprietario)
            VALUES(_targa,_proprietario);
            END IF;
            INSERT INTO coinvesterni(CodSinistro,Targa)
            VALUES(_codSinistro,_targa);
		END IF;
        SET _coinvolti = SUBSTRING(_coinvolti,_separatore + 1, LENGTH(_coinvolti) - _separatore);
        IF _separatore = 0 THEN
			SET _coinvolti = "";
		END IF;
    END LOOP scan;
END$$

-- Operazione Ranking account Ambito non possiamo usare funzioni strane

DROP PROCEDURE IF EXISTS rankingAccount$$
-- FORMATO PROCEDURE:
-- CALL rankingAccount("ambito");
-- Ambiti : Sinistri,Serieta,Viaggio,Comportamento

CREATE PROCEDURE rankingAccount(IN _ambito VARCHAR(100))
BEGIN
	/*DECLARE _ambito1 VARCHAR(100);
    DECLARE _ambito2 VARCHAR(100);
    DECLARE _ambito3 VARCHAR(100);
    DECLARE _ambito4 VARCHAR(100);
    DECLARE separatore INT;*/
    DECLARE finito INT DEFAULT 0;
    DECLARE _username VARCHAR(100);
    DECLARE _mediaSinistri DEC(3,2);
    DECLARE _mediaViaggio DEC(3,2);
    DECLARE _mediaComportamento DEC(3,2);
    DECLARE _mediaSerieta DEC(3,2);
    DECLARE listaAccount CURSOR FOR
    SELECT Username
    FROM account;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finito = 1;
    
    CREATE TEMPORARY TABLE IF NOT EXISTS medie(
    Username VARCHAR(100),
    MediaSinistri DEC(3,2) DEFAULT 0,
    MediaViaggio DEC(3,2) DEFAULT 0,
    MediaComportamento DEC(3,2) DEFAULT 0,
    MediaSerieta DEC(3,2) DEFAULT 0,
    PRIMARY KEY(Username)) ENGINE = InnoDB;
    
    /*-- TROVA GLI AMBITI
	SET _ambito1 = SUBSTRING(_ordineAmbiti,1,POSITION(',' IN _ordineAmbiti)-1);
    SET _ordineAmbiti = SUBSTRING(_ordineAmbiti,POSITION(',' IN _ordineAmbiti)+1,LENGTH(_ordineAmbiti)-LENGTH(_ambito1)+1);
    SET _ambito2= SUBSTRING(_ordineAmbiti,1,POSITION(',' IN _ordineAmbiti)-1);
    SET _ordineAmbiti = SUBSTRING(_ordineAmbiti,POSITION(',' IN _ordineAmbiti)+1,LENGTH(_ordineAmbiti) - LENGTH(_ambito2)+1);
    SET _ambito3 = SUBSTRING(_ordineAmbiti,1,POSITION(',' IN _ordineAmbiti)-1);
    SET _ambito4 = SUBSTRING(_ordineAmbiti, POSITION(',' IN _ordineAmbiti)+1,LENGTH(_ordineAmbiti)-LENGTH(_ambito3)+1);
    
    SET _ambito1 = CONCAT('Media',_ambito1);
    SET _ambito2 = CONCAT('Media',_ambito2);
    SET _ambito3 = CONCAT('Media',_ambito3);
    SET _ambito4 = CONCAT('Media',_ambito4);*/
    
    -- Riempi la temporary table con le medie
    OPEN listaAccount;
    scan : LOOP
		FETCH listaAccount INTO _username;
        IF finito = 1 THEN
			LEAVE scan;
		END IF;
        
        SELECT AVG(VotoComp) INTO _MediaComportamento
        FROM recensione 
        WHERE Destinatario = _username AND VotoComp IS NOT NULL;
		
		SELECT AVG(VotoViaggio) INTO _MediaViaggio
        FROM recensione
        WHERE Destinatario = _username AND VotoViaggio IS NOT NULL;
		
        SELECT AVG(VotoSerieta) INTO _MediaSerieta
        FROM recensione
        WHERE Destinatario = _username AND VotoSerieta IS NOT NULL;
		
		SELECT MediaSinistri INTO _MediaSinistri
        FROM account
        WHERE Username = _username;
        
        INSERT INTO medie(Username,MediaSinistri,MediaViaggio,MediaComportamento,MediaSerieta)
        VALUES(_username,_mediaSinistri,_mediaViaggio,_mediaComportamento,_mediaSerieta);
    END LOOP scan;
    CLOSE listaAccount;
    
    IF _ambito = "Serieta" THEN
		SELECT @rank := @rank +1 AS Rank,M.Username, M.MediaSerieta
		FROM medie M , (SELECT @rank := 0) AS D
        WHERE M.MediaSerieta IS NOT NULL
		ORDER BY MediaSerieta DESC;
	ELSEIF _ambito = "Viaggio" THEN
		SELECT @rank := @rank +1 AS Rank,M.Username, M.MediaViaggio
		FROM medie M , (SELECT @rank := 0) AS D
        WHERE M.MediaViaggio IS NOT NULL
		ORDER BY MediaViaggio DESC;
	ELSEIF _ambito = "Comportamento" THEN
		SELECT @rank := @rank +1 AS Rank,M.Username, M.MediaComportamento
		FROM medie M , (SELECT @rank := 0) AS D
        WHERE M.MediaComportamento IS NOT NULL
		ORDER BY MediaComportamento DESC;
	ELSEIF _ambito = "Sinistro" THEN
		SELECT @rank := @rank +1 AS Rank,M.Username, M.MediaSinistri
		FROM medie M , (SELECT @rank := 0) AS D
        WHERE M.MediaSinistri IS NOT NULL
		ORDER BY MediaSinistri DESC;
	END IF;
	TRUNCATE TABLE medie;
END$$

-- Operazione Ranking criticità traffico
-- Situazione : Poco Trafficata, Traffico Agevole, Molto Trafficata
-- da pensare a come risolvere il problema della tratta - posizione e controllare un altra procedure in cui usi lo stesso metodo
DROP PROCEDURE IF EXISTS criticitaTraffico$$

CREATE PROCEDURE criticitaTraffico()
BEGIN
	DECLARE situazione VARCHAR(100) DEFAULT NULL;
	DECLARE finito INT DEFAULT 0;
    DECLARE _tratta INT;
    DECLARE _NumeroVeicoli INT DEFAULT 0;
    DECLARE _NumeroVeicoliMedia INT DEFAULT 0;
    DECLARE _NumeroVeicoliAttuale INT DEFAULT 0;
    DECLARE _numeroOre INT DEFAULT 0;
    DECLARE listaTratte CURSOR FOR
    SELECT DISTINCT CodTratta 
    FROM tratta T INNER JOIN collegamentotratte CT USING(CodTratta)
    WHERE CodTratta NOT IN(SELECT CodTratta 
					 FROM sinistro S inner join collegamentotratte CT2 using(latitudine,longitudine,altitudine)
                     WHERE  S.Data BETWEEN CURRENT_TIMESTAMP() - INTERVAL 3 HOUR AND CURRENT_TIMESTAMP());
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finito = 1;
     
	CREATE TEMPORARY TABLE IF NOT EXISTS traffico(
    Tratta INT PRIMARY KEY,
    Situazione VARCHAR(100))ENGINE = InnoDB;
    
    OPEN listaTratte;
    scan: LOOP
		FETCH listaTratte INTO _tratta; 
        IF finito = 1 THEN
			LEAVE scan;
		END IF;
        SELECT COUNT(*) INTO _numeroVeicoli
        FROM tracking T NATURAL JOIN collegamentotratte CT
        WHERE CT.CodTratta = _tratta AND DATE_FORMAT(T.Data,'%Y%m%d') < CURRENT_DATE();
        
        SELECT DATEDIFF(DATE_FORMAT(CURRENT_DATE(),'%Y%m%d')- INTERVAL 1 DAY,DATE_FORMAT(MIN(Data),'%Y%m%d'))*48 INTO _numeroOre -- 2 tracking ogni ora per 24 ore
        FROM tracking T NATURAL JOIN collegamentotratte CT
        WHERE CT.CodTratta = _tratta;
        
        SET _NumeroVeicoliMedia = IFNULL(_numeroVeicoli / _numeroOre,0);
        
        SELECT COUNT(*)/IF(DATE_FORMAT(CURRENT_TIMESTAMP(),'%i')<30,1,2) INTO _NumeroVeicoliAttuale
        FROM tracking T NATURAL JOIN collegamentotratte CT
        WHERE CT.CodTratta = _tratta AND DATE_FORMAT(T.Data,'%Y%m%d %H') = DATE_FORMAT(CURRENT_TIMESTAMP(),'%Y%m%d %H');
       /* select(_tratta);
        SELECT (_NumeroVeicoliAttuale);
        select(_numeroVeicolimedia);*/
        IF _NumeroVeicoliAttuale > 1.25*_NumeroVeicoliMedia  THEN
			SET situazione = "Traffico Intenso";
		ELSEIF _NumeroVeicoliMedia < _NumeroVeicoliAttuale  THEN
			SET situazione = "Traffico scorrevole";
		ELSE 
			SET situazione = "Traffico regolare";
		END IF;
        INSERT INTO traffico
        VALUES(_tratta,situazione);
        
    END LOOP scan;
    CLOSE listaTratte;
    INSERT INTO traffico
    SELECT CodTratta, "Tratta con incidente nelle ultime 3 ore"
    FROM collegamentotratte CT INNER JOIN sinistro S USING(latitudine,longitudine,altitudine)
	WHERE S.Data BETWEEN CURRENT_TIMESTAMP()  - INTERVAL 3 HOUR AND CURRENT_TIMESTAMP();
    
    SELECT *
    FROM traffico;
    TRUNCATE TABLE traffico;
END$$


-- Operazione 21
/*CALCOLA LA DISTANZA -> ok
CONTROLLA CHE LA DISTANZA NON SIA INFERIORE A 1 KM (0.1 GRADI)->ok
AGGIUNGI UNA COSTANTE ALLA DISTANZA E USALA PER FARE AREA DEL QUADRATO -> ok
		
CREA UNA LISTA DEI RIDE NEI DITORNI CON RELATIVO ORDINE DI PARTENZA E CODICE TRAGITTO->ok
CREA UN CICLO CHE :
	FACCIA UNA CHIAMATA A FUNZIONE CHE PRENDA : POSIZIONI, AREA, ORDINE, CODICETRAGITTO,NUMERO DI VOLTE CHE HA GIA PRESO UN RIDE, CODICE RIDE, TEMPO IMPIEGATO NEI RIDE -> ok*/
/*	
LA CHIAMATA DEVE:
	CONTROLLARE CHE QUEL TRAGITTO ARRIVI O MENO A DESTINAZIONE E IN CASO USCIRE ->ok
    SE IL NUMERO DI RIDE ARRIVA A 3 ALLORA NON FARE LE COSE DOPO ->Ok
	FARE UNA LISTA DEGLI ARRIVI DI QUEL TRAGITTO CON ORDINE SUPERIORE ->ok
    CICLO:
    CONTROLLARE CHE AREA SIA INFERIORE A QUELLA PRECEDENTE -> ok
    CALCOLARE IL TEMPO IMPIEGATO PER ANDARE DA QUEL PUNTO ALL ALTRO
    PER QUELL ARRIVO CREARE UNA LISTA CON NUOVE PARTENZE  E CODICE DIVERSO DA QUELLO PRECEDENTE
    CONCATENARE L ORDINE E IL CODICE TRAGITTO
    CHIAMARE SE STESSA CON I VALORI NUOVI E IL NUMERO DI RIDE AUMENTATO
*/	

DROP PROCEDURE IF EXISTS visioneSharingMultipliMain$$
DROP PROCEDURE IF EXISTS visioneSharingMultipliIter$$

CREATE PROCEDURE visioneSharingMultipliMain( IN latP DOUBLE, IN longP DOUBLE , IN latA DOUBLE , IN longA DOUBLE)
BEGIN
	DECLARE distanza DOUBLE DEFAULT 0;
    DECLARE finito INT DEFAULT 0;
    DECLARE area DOUBLE DEFAULT 0;
    DECLARE _codTragitto INT;
    DECLARE _codProposta INT;
    DECLARE _ordine INT;
    DECLARE listaRide CURSOR FOR
    SELECT CodTragitto,CodProposta,Ordine
    FROM propostaride PR NATURAL JOIN partenza P
    WHERE CURRENT_TIMESTAMP() BETWEEN PR.DataInizio AND PR.DataFine AND
			ABS(latP- P.Latitudine) <= 0.1 AND ABS(longP - P.Longitudine)<= 0.1;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finito = 1;
    CREATE TEMPORARY TABLE IF NOT EXISTS tabellaMultipli(
	CodMultiplo INT AUTO_INCREMENT PRIMARY KEY,
    listaCodiciProposte VARCHAR(100),
    listaOrdini VARCHAR(100),
    listaTempo VARCHAR(100));
    TRUNCATE TABLE tabellaMultipli;
    
    SET distanza = SQRT((POW(latP-latA,2))+(POW(longP - longA,2))) ;
    -- SE LA DISTANZA NON SUPERA LO 0.1 ALLORA NON FA LO SHARING MULTIPLO
    IF distanza < 0.1 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "La distanza per fare un ride multiplo deve essere superiore a 1 km";
	END IF;
    -- TROVO QUANTO VALE L'AREA LA PRIMA VOLTA
    SET area = POW(distanza+0.4 ,2);
    OPEN listaRide;
    -- PROVO TUTTI I RIDE TROVATI 
    scan: LOOP
		FETCH listaRide INTO _codTragitto,_codProposta,_ordine;
        IF finito = 1 THEN
			LEAVE scan;
		END IF;
-- fino a qui è corretto
        CALL visioneSharingMultipliIter(latA,longA,_ordine,area,_codTragitto,0,_codProposta,0,_codProposta,_ordine,"0");
    END LOOP scan;
    CLOSE listaRide;
    --  MOSTRO IL RISULTATO
    SELECT * 
    FROM tabellaMultipli;

END$$

CREATE PROCEDURE visioneSharingMultipliIter(IN latA DOUBLE,IN longA DOUBLE,IN _ordine INT,IN area DOUBLE,IN _codTragitto INT ,IN volte INT,IN _codProposta INT,IN tempoInRide INT,IN listaCodProposte VARCHAR(100),IN listaOrdini VARCHAR(100),IN listaTempo VARCHAR(100))
BEGIN
	DECLARE _distanzaMinima DOUBLE;
    DECLARE _ordineMinimo INT;
    DECLARE finito INT DEFAULT 0;
    DECLARE tempoPrec INT DEFAULT 0;
    DECLARE tempo INT DEFAULT 0;
    DECLARE _ordine2 INT;
    DECLARE _lat2 DOUBLE;
    DECLARE _long2 DOUBLE;
    DECLARE _alt2 INT;
    
    DECLARE listaArrivi CURSOR FOR
    SELECT Ordine,Latitudine,Longitudine, Altitudine
    FROM arrivo
    WHERE Ordine >= _ordine AND CodTragitto = _codTragitto
    ORDER BY Ordine ASC;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finito = 1;
    SET max_sp_recursion_depth=255;
    
    SELECT MIN(SQRT((POW(latA - Latitudine,2)+POW(longA - Longitudine,2)))) INTO _distanzaMinima
    FROM arrivo
    WHERE CodTragitto = _codTragitto;
    
    -- select(_distanzaMinima);
    -- SE ESISTE UN PUNTO DEL TRAGITTO ATTUALE CHE NON SUPERA 0.1 DI DISTANZA ALLORA HO FINITO
    IF _distanzaMinima < 0.1 THEN
		SELECT A.Ordine INTO _ordineMinimo
		FROM arrivo A
		WHERE CodTragitto = _codTragitto AND
			(SQRT(POW(latA - A.Latitudine,2)+POW(longA - A.Longitudine,2))) = _distanzaMinima;-- _distanzaMinima

        INSERT INTO tabellaMultipli
        VALUES(NULL,listaCodProposte,CONCAT(listaOrdini," ",_ordineMinimo),listaTempo);
	ELSE
		IF volte < 3 THEN
			OPEN listaArrivi;
			scan:LOOP
				FETCH listaArrivi INTO _ordine2,_lat2,_long2,_alt2;
                -- select("Entra a fare fetch lista Arrivi");
               /* select (_ordine2);
                select (_lat2);
                select(_long2);*/
                IF finito = 1 THEN
					LEAVE scan;
				END IF;
				BEGIN
					DECLARE area2 DOUBLE DEFAULT 0;
					DECLARE _codTragitto2 INT;
					DECLARE _codProposta2 INT ;
					DECLARE _ordine3 INT ;
					SET tempo = calcolaTempo(_ordine,_codTragitto,_ordine2)+5;
					-- CONTROLLO SE L'AREA DEL QUADRATO CON IL NUOVO ARRIVO è INFERIORE A QUELLO PRECEDENTE
					SET area2 = POW(SQRT(POW(_lat2-latA,2)+POW(_long2-longA,2))+0.4,2);
					IF area2 < area THEN
						BEGIN
						-- DECLARE _ordine3 INT;
						DECLARE finito2 INT DEFAULT 0;
						DECLARE listaPartenze CURSOR FOR
						SELECT CodTragitto,CodProposta,Ordine
						FROM propostaride PR NATURAL JOIN partenza P
						WHERE CURRENT_TIMESTAMP + INTERVAL tempoInRide+tempo MINUTE BETWEEN DataInizio AND DataFine AND
							ABS(_lat2- P.Latitudine) <= 0.1 AND ABS(_long2 - P.Longitudine)<= 0.1 AND CodTragitto <> _codTragitto;
						DECLARE CONTINUE HANDLER FOR NOT FOUND SET finito2 = 1;
						OPEN listaPartenze;
						scan2 :LOOP
							FETCH listaPartenze INTO _codTragitto2, _codProposta2, _ordine3;
							IF finito2 = 1 THEN 
								LEAVE scan2;
							END IF;
                            -- select(_codTragitto2);
							CALL visioneSharingMultipliIter(latA,longA,_ordine2,area2,_codTragitto2,volte + 1,_codProposta2,tempoInRide+tempo,CONCAT(listaCodProposte,",",_codProposta2),CONCAT(listaOrdini," ",_ordine2,",",_ordine3),CONCAT(listaTempo,",",tempo));
						END LOOP scan2;
						CLOSE listaPartenze;
					END;
					END IF;
				END;
			END LOOP scan;
			CLOSE listaArrivi;
		END IF;
    END IF;
END$$
-- togli i select che hai messo come breakpoint
DROP FUNCTION IF EXISTS calcolaTempo$$
CREATE FUNCTION calcolaTempo(_ordine INT, _codTragitto INT , _ordine2 INT) RETURNS INT
BEGIN
	DECLARE lat1 DOUBLE;
    DECLARE long1 DOUBLE;
    DECLARE lat2 DOUBLE;
    DECLARE long2 DOUBLE;
    
    SELECT Latitudine,Longitudine INTO lat1,long1
    FROM partenza
    WHERE CodTragitto = _codTragitto AND Ordine = _ordine;
    
    SELECT Latitudine, Longitudine INTO lat2,long2
    FROM arrivo
    WHERE CodTragitto = _codTragitto AND Ordine = _ordine2;
    
    RETURN (SQRT(POW(lat1-lat2,2)+POW(long1-long2,2)) *12);
END$$
/*
-- Prenotazione Sharing Multiplo
DROP PROCEDURE IF EXISTS prenotazioneSharingMultiplo$$

CREATE PROCEDURE prenotazioneSharingMultiplo(IN _codMultiplo INT,IN _Username VARCHAR(100))
BEGIN
	DECLARE listaChiamate VARCHAR(100);
    DECLARE listaOrdine VARCHAR(100);
    DECLARE listaTempo VARCHAR(100);
    DECLARE _chiamata INT;
    DECLARE _nomePrenotazione VARCHAR(100);
    DECLARE _ordine VARCHAR(100);
    DECLARE _ordineP INT;
    DECLARE _ordineA INT;
    DECLARE _tempo INT;
    DECLARE _latitudineP DOUBLE;
    DECLARE _longitudineP DOUBLE;
    DECLARE _altitudineP DOUBLE;
	DECLARE _latitudineA DOUBLE;
    DECLARE _longitudineA DOUBLE;
    DECLARE _altitudineA INT;
    DECLARE _codiceTragitto INT;
    DECLARE _codiceMultiplo INT;
    DECLARE _nomeOrdineP VARCHAR(100);
    DECLARE _nomeOrdineA VARCHAR(100);
    DECLARE _nomeTempo VARCHAR(100);
    
   
    SELECT listaCodiciProposte,listaOrdini,listaTempo INTO listaChiamate,listaOrdine,listaTempo
    FROM tabellaMultipli
    WHERE CodMultiplo = _codMultiplo;
    
	INSERT INTO ridemultiplo
	VALUE(NULL);
    SELECT MAX(CodMultiplo) INTO _codMultiplo
    FROM ridemultiplo;
   
    WHILE listaChiamate <> "" DO
		IF POSITION(',' IN listaChiamate) <> 0 THEN
			SET _nomePrenotazione = SUBSTRING(listaChiamate,1,POSITION(',' IN listaChiamate)-1);
			SET _ordine = SUBSTRING(listaOrdine,1,POSITION(',' IN listaOrdine)-1);
			SET _nomeTempo = SUBSTRING(listaTempo,1,POSITION(',' IN listaTempo)-1);
			SET _nomeOrdineP = SUBSTRING(_ordine,1,POSITION(' 'IN _ordine)-1);
			SET _nomeOrdineA = SUBSTRING(_ordine,POSITION(' ' IN _ordine)+1,LENGTH(_ordine)-POSITION(' 'IN _ordine));
			SET _ordineP = CONVERT(_nomeOrdineP, UNSIGNED);
			SET _ordineA = CONVERT(_nomeOrdineA, UNSIGNED);
			SET _chiamata = CONVERT(_nomePrenotazione , UNSIGNED);
            SET _tempo = CONVERT(_nomeTempo, UNSIGNED);
        ELSE
			SET _chiamata = CONVERT(listaChiamate, UNSIGNED);
            SET _nomeOrdineP = SUBSTRING(listaOrdine,1,POSITION(',' IN listaOrdine)-1);
            SET _nomeOrdineA = SUBSTRING(listaOrdine,POSITION(',' IN listaOrdine) + 1, LENGTH(listaOrdine) - POSITION(',' IN listaOrdine));
            SET _ordineP = CONVERT(_nomeOrdineP,UNSIGNED);
            SET _ordineA = CONVERT(_nomeOrdineA , UNSIGNED);
            SET _tempo = CONVERT(listaTempo,UNSIGNED);
        END IF;

        SELECT CodTragitto INTO _codiceTragitto
        FROM propostaride
        WHERE CodProposta = _chiamata;
        
        SELECT Latitudine, Longitudine, Altitudine INTO _latitudineP,_longitudineP,_altitudineP
        FROM partenza
        WHERE Ordine = _ordine AND CodTragitto = _codiceTragitto;
        
        SELECT Latitudine, Longitudine, Altitudine INTO _latitudineA,_longitudineA,_altitudineA
        FROM arrivo
        WHERE Ordine = _ordine AND CodTragitto = _codiceTragitto;
        
        INSERT INTO chiamata(CodChiamata,DataRichiesta,DataFineCorsa,Stato,DataRisposta,Username,CodProposta,LatitudinePartenza,LongitudinePartenza,AltitudinePartenza,LatitudineArrivo,LongitudineArrivo,AltitudineArrivo,CodMultiplo)
        VALUES(NULL,CURRENT_TIMESTAMP() + INTERVAL _tempo MINUTE,NULL,"In Attesa",NULL,_username,_chiamata,_latitudineP,_longitudineP,_altitudineP,_latitudineA,_longitudineA,_altitudineA,_codMultiplo);

        IF POSITION(',' IN listaChiamate) = 0 THEN
			SET listaChiamate = "";
		ELSE
			SET listaChiamate = SUBSTRING(listaChiamate,POSITION(',' IN listaChiamate)+1,LENGTH(listaChiamate)-POSITION(',' IN listaChiamate));
			SET listaOrdine = SUBSTRING(listaOrdine,POSITION(',' IN listaOrdine)+1,LENGTH(listaOrdine)-POSITION(',' IN listaOrdine));
			SET listaTempo = SUBSTRING(listaTempo,POSITION(',' IN listaTempo)+1,LENGTH(listaTempo)-POSITION(',' IN listaTempo));
		END IF;
    END WHILE;
END$$
*/

-- prenotazioneSharingMultipoManuale
DROP PROCEDURE IF EXISTS prenotazioneMultiploMan$$

CREATE PROCEDURE prenotazioneMultiploMan(IN _codMultiplo INT , IN _codProposta INT, _ordineP INT , IN _ordineA INT,IN _tempo INT, IN _username VARCHAR(100))
BEGIN
    DECLARE _latitudineP DOUBLE;
    DECLARE _longitudineP DOUBLE;
    DECLARE _altitudineP DOUBLE;
	DECLARE _latitudineA DOUBLE;
    DECLARE _longitudineA DOUBLE;
    DECLARE _altitudineA INT;
    DECLARE _codiceTragitto INT;
    DECLARE _codiceMultiplo INT;
    
    
    SELECT CodTragitto INTO _codiceTragitto
    FROM propostaride
    WHERE CodProposta = _codProposta;
        
    SELECT Latitudine, Longitudine, Altitudine INTO _latitudineP,_longitudineP,_altitudineP
    FROM partenza
    WHERE Ordine = _ordineP AND CodTragitto = _codiceTragitto;
        
    SELECT Latitudine, Longitudine, Altitudine INTO _latitudineA,_longitudineA,_altitudineA
    FROM arrivo
    WHERE Ordine = _ordineA AND CodTragitto = _codiceTragitto;
        
    INSERT INTO chiamata(CodChiamata,DataRichiesta,DataFineCorsa,Stato,DataRisposta,Username,CodProposta,LatitudinePartenza,LongitudinePartenza,AltitudinePartenza,LatitudineArrivo,LongitudineArrivo,AltitudineArrivo,CodMultiplo)
    VALUES(NULL,CURRENT_TIMESTAMP() + INTERVAL _tempo MINUTE,NULL,"In Attesa",NULL,_username,_codProposta,_latitudineP,_longitudineP,_altitudineP,_latitudineA,_longitudineA,_altitudineA,_codMultiplo);
END$$
-- va modificato lo schema in chiamata

DROP FUNCTION IF EXISTS controlloDate$$

CREATE FUNCTION controlloDate( _targa VARCHAR(100), _dataInizio DATETIME, _dataFine DATETIME)
RETURNS INT
BEGIN
	DECLARE accettabile INT DEFAULT 0;
    
    SELECT COUNT(*) INTO accettabile
    FROM (
		SELECT CodDisponibili AS Codice
        FROM veicolidisponibili
        WHERE Targa = _targa AND
			((_dataInizio < DataInizio AND (_dataFine BETWEEN DataInizio AND DataFine)) OR
            (_dataInizio > DataInizio AND _dataFine < DataFine)OR
            ((_dataInizio BETWEEN DataInizio AND DataFine) AND _dataFine > DataFine)OR
            (_dataInizio < DataInizio AND _dataFine > DataFine))
		
        UNION
        
        SELECT CodPool AS Codice
        FROM propostapool
		WHERE Targa = _targa AND
			((_dataInizio < DataPartenza AND (_dataFine BETWEEN DataPartenza AND DataArrivo)) OR
            (_dataInizio > DataPartenza AND _dataFine < DataArrivo)OR
            ((_dataInizio BETWEEN DataPartenza AND DataArrivo) AND _dataFine > DataArrivo)OR
            (_dataInizio < DataPartenza AND _dataFine > DataArrivo))
            
		UNION
        
        SELECT CodProposta AS Codice
        FROM propostaride
		WHERE Targa = _targa AND
			((_dataInizio < DataInizio AND (_dataFine BETWEEN DataInizio AND DataFine)) OR
            (_dataInizio > DataInizio AND _dataFine < DataFine)OR
            ((_dataInizio BETWEEN DataInizio AND DataFine) AND _dataFine > DataFine)OR
            (_dataInizio < DataInizio AND _dataFine > DataFine)))AS D;
		RETURN accettabile;
END$$

















