-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
-- -----------------------------------------------------
-- Schema progettodatabase
-- -----------------------------------------------------

DROP SCHEMA IF EXISTS `progettodatabase` ;

-- -----------------------------------------------------
-- Schema progettodatabase
-- -----------------------------------------------------

CREATE SCHEMA IF NOT EXISTS `progettodatabase` DEFAULT CHARACTER SET utf8 ;
USE `progettodatabase` ;

-- -----------------------------------------------------
-- Table `progettodatabase`.`account`
-- -----------------------------------------------------

DROP TABLE IF EXISTS `progettodatabase`.`account` ;

CREATE TABLE IF NOT EXISTS `progettodatabase`.`account` (
  `Username` VARCHAR(100) NOT NULL,
  `Password` VARCHAR(100) NOT NULL,
  `Fruitore` TINYINT(4) NOT NULL,
  `Proponente` TINYINT(4) NOT NULL,
  `MediaSinistri` DOUBLE NOT NULL DEFAULT '0',
  `NoleggiEffettuati` INT(11) NOT NULL DEFAULT '0',
  `Stato` VARCHAR(100) NOT NULL DEFAULT 'In Attesa',
  PRIMARY KEY (`Username`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;

-- -----------------------------------------------------
-- Table `progettodatabase`.`posizione`
-- -----------------------------------------------------

DROP TABLE IF EXISTS `progettodatabase`.`posizione` ;

CREATE TABLE IF NOT EXISTS `progettodatabase`.`posizione` (
  `Altitudine` INT(11) NOT NULL,
  `Latitudine` DOUBLE NOT NULL,
  `Longitudine` DOUBLE NOT NULL,
  PRIMARY KEY (`Latitudine`, `Longitudine`, `Altitudine`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;

-- -----------------------------------------------------
-- Table `progettodatabase`.`tragitto`
-- -----------------------------------------------------

DROP TABLE IF EXISTS `progettodatabase`.`tragitto` ;

CREATE TABLE IF NOT EXISTS `progettodatabase`.`tragitto` (
  `CodTragitto` INT(11) NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`CodTragitto`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;

-- -----------------------------------------------------
-- Table `progettodatabase`.`arrivo`
-- -----------------------------------------------------

DROP TABLE IF EXISTS `progettodatabase`.`arrivo` ;

CREATE TABLE IF NOT EXISTS `progettodatabase`.`arrivo` (
  `Ordine` INT(11) NULL DEFAULT NULL,
  `CodTragitto` INT(11) NOT NULL,
  `Latitudine` DOUBLE NOT NULL,
  `Longitudine` DOUBLE NOT NULL,
  `Altitudine` INT(11) NOT NULL,
  PRIMARY KEY (`CodTragitto`, `Latitudine`, `Longitudine`, `Altitudine`),
  INDEX `fk_arrivo_tragitto1_idx` (`CodTragitto` ASC),
  INDEX `fk_arrivo_posizione1_idx` (`Latitudine` ASC, `Longitudine` ASC, `Altitudine` ASC),
  CONSTRAINT `fk_arrivo_posizione1`
    FOREIGN KEY (`Latitudine` , `Longitudine` , `Altitudine`)
    REFERENCES `progettodatabase`.`posizione` (`Latitudine` , `Longitudine` , `Altitudine`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_arrivo_tragitto1`
    FOREIGN KEY (`CodTragitto`)
    REFERENCES `progettodatabase`.`tragitto` (`CodTragitto`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;

-- -----------------------------------------------------
-- Table `progettodatabase`.`veicolointerno`
-- -----------------------------------------------------

DROP TABLE IF EXISTS `progettodatabase`.`veicolointerno` ;

CREATE TABLE IF NOT EXISTS `progettodatabase`.`veicolointerno` (
  `Targa` VARCHAR(7) NOT NULL,
  `AnnoImm` INT(11) NULL DEFAULT NULL,
  `CasaProd` VARCHAR(45) NULL DEFAULT NULL,
  `Modello` VARCHAR(45) NULL DEFAULT NULL,
  `Cilindrata` INT(11) NULL DEFAULT NULL,
  `NumeroPosti` INT(11) NULL DEFAULT NULL,
  `VelocitaMax` INT(11) NULL DEFAULT NULL,
  `Alimentazione` VARCHAR(45) NULL DEFAULT NULL,
  `KmPercorsi` INT(11) NULL DEFAULT '0',
  `CapSerbatoio` INT(11) NULL DEFAULT NULL,
  `QuantoCarburante` INT(11) NULL DEFAULT '0',
  `Username` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`Targa`),
  INDEX `fk_veicoloInterno_account1_idx` (`Username` ASC),
  CONSTRAINT `fk_veicoloInterno_account1`
    FOREIGN KEY (`Username`)
    REFERENCES `progettodatabase`.`account` (`Username`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `progettodatabase`.`propostaride`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `progettodatabase`.`propostaride` ;

CREATE TABLE IF NOT EXISTS `progettodatabase`.`propostaride` (
  `CodProposta` INT(11) NOT NULL AUTO_INCREMENT,
  `Costo` INT(11) NULL DEFAULT NULL CHECK (Costo > 0),
  `DataInizio` DATETIME NULL DEFAULT NULL,
  `DataFine` DATETIME NULL DEFAULT NULL,
  `CodTragitto` INT(11) NOT NULL,
  `Targa` VARCHAR(7) NOT NULL,
  PRIMARY KEY (`CodProposta`),
  INDEX `fk_propostaRide_tragitto1_idx` (`CodTragitto` ASC),
  INDEX `fk_propostaRide_veicoloInterno1_idx` (`Targa` ASC),
  CONSTRAINT `fk_propostaRide_tragitto1`
    FOREIGN KEY (`CodTragitto`)
    REFERENCES `progettodatabase`.`tragitto` (`CodTragitto`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_propostaRide_veicoloInterno1`
    FOREIGN KEY (`Targa`)
    REFERENCES `progettodatabase`.`veicolointerno` (`Targa`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `progettodatabase`.`chiamata`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `progettodatabase`.`chiamata` ;

CREATE TABLE IF NOT EXISTS `progettodatabase`.`chiamata` (
  `CodChiamata` INT(11) NOT NULL AUTO_INCREMENT,
  `DataRichiesta` DATETIME NULL DEFAULT NULL,
  `DataFineCorsa` DATETIME NULL DEFAULT NULL,
  `Stato` VARCHAR(45) NULL DEFAULT NULL,
  `DataRisposta` DATETIME NULL DEFAULT NULL,
  `Username` VARCHAR(100) NOT NULL,
  `CodProposta` INT(11) NOT NULL,
  `LatitudinePartenza` DOUBLE NOT NULL,
  `LongitudinePartenza` DOUBLE NOT NULL,
  `AltitudinePartenza` INT(11) NOT NULL,
  `LatitudineArrivo` DOUBLE NOT NULL,
  `LongitudineArrivo` DOUBLE NOT NULL,
  `AltitudineArrivo` INT(11) NOT NULL,
  `CodMultiplo` INT (11),
  PRIMARY KEY (`CodChiamata`),
  INDEX `fk_chiamata_account1_idx` (`Username` ASC),
  INDEX `fk_chiamata_propostaRide1_idx` (`CodProposta` ASC),
  INDEX `fk_chiamata_posizione1_idx` (`LatitudinePartenza` ASC, `LongitudinePartenza` ASC, `AltitudinePartenza` ASC),
  INDEX `fk_chiamata_posizione2_idx` (`LatitudineArrivo` ASC, `LongitudineArrivo` ASC, `AltitudineArrivo` ASC),
  CONSTRAINT `fk_chiamata_account1`
    FOREIGN KEY (`Username`)
    REFERENCES `progettodatabase`.`account` (`Username`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_chiamata_propostaRide1`
    FOREIGN KEY (`CodProposta`)
    REFERENCES `progettodatabase`.`propostaride` (`CodProposta`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_chiamata_posizione1`
    FOREIGN KEY (`LatitudinePartenza` , `LongitudinePartenza` , `AltitudinePartenza`)
    REFERENCES `progettodatabase`.`posizione` (`Latitudine` , `Longitudine` , `Altitudine`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_chiamata_posizione2`
    FOREIGN KEY (`LatitudineArrivo` , `LongitudineArrivo` , `AltitudineArrivo`)
    REFERENCES `progettodatabase`.`posizione` (`Latitudine` , `Longitudine` , `Altitudine`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_chiamata_ridemultiplo1`
    FOREIGN KEY (`CodMultiplo`)
    REFERENCES `progettodatabase`.`ridemultiplo` (`CodMultiplo`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `progettodatabase`.`sinistro`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `progettodatabase`.`sinistro` ;

CREATE TABLE IF NOT EXISTS `progettodatabase`.`sinistro` (
  `CodSinistro` INT(11) NOT NULL AUTO_INCREMENT,
  `Data` DATETIME NULL DEFAULT NULL,
  `Responsabile` VARCHAR(45) NULL DEFAULT NULL,
  `Latitudine` DOUBLE NOT NULL,
  `Longitudine` DOUBLE NOT NULL,
  `Altitudine` INT(11) NOT NULL,
  PRIMARY KEY (`CodSinistro`),
  INDEX `fk_sinistro_posizione1_idx` (`Latitudine` ASC, `Longitudine` ASC, `Altitudine` ASC),
  CONSTRAINT `fk_sinistro_posizione1`
    FOREIGN KEY (`Latitudine` , `Longitudine` , `Altitudine`)
    REFERENCES `progettodatabase`.`posizione` (`Latitudine` , `Longitudine` , `Altitudine`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `progettodatabase`.`veicoliesterni`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `progettodatabase`.`veicoliesterni` ;

CREATE TABLE IF NOT EXISTS `progettodatabase`.`veicoliesterni` (
  `Targa` VARCHAR(7) NOT NULL,
  `Proprietario` VARCHAR(45) NULL DEFAULT NULL,
  PRIMARY KEY (`Targa`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `progettodatabase`.`coinvesterni`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `progettodatabase`.`coinvesterni` ;

CREATE TABLE IF NOT EXISTS `progettodatabase`.`coinvesterni` (
  `CodSinistro` INT(11) NOT NULL,
  `Targa` VARCHAR(7) NOT NULL,
  PRIMARY KEY (`CodSinistro`, `Targa`),
  INDEX `fk_coinvEsterni_sinistro1_idx` (`CodSinistro` ASC),
  INDEX `fk_coinvEsterni_veicoliEsterni1_idx` (`Targa` ASC),
  CONSTRAINT `fk_coinvEsterni_sinistro1`
    FOREIGN KEY (`CodSinistro`)
    REFERENCES `progettodatabase`.`sinistro` (`CodSinistro`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_coinvEsterni_veicoliEsterni1`
    FOREIGN KEY (`Targa`)
    REFERENCES `progettodatabase`.`veicoliesterni` (`Targa`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `progettodatabase`.`coinvinterni`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `progettodatabase`.`coinvinterni` ;

CREATE TABLE IF NOT EXISTS `progettodatabase`.`coinvinterni` (
  `CodSinistro` INT(11) NOT NULL,
  `Targa` VARCHAR(7) NOT NULL,
  PRIMARY KEY(`CodSinistro`,`Targa`),
  INDEX `fk_coinvInterni_sinistro1_idx` (`CodSinistro` ASC),
  INDEX `fk_coinvInterni_veicoloInterno1_idx` (`Targa` ASC),
  CONSTRAINT `fk_coinvInterni_sinistro1`
    FOREIGN KEY (`CodSinistro`)
    REFERENCES `progettodatabase`.`sinistro` (`CodSinistro`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_coinvInterni_veicoloInterno1`
    FOREIGN KEY (`Targa`)
    REFERENCES `progettodatabase`.`veicolointerno` (`Targa`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `progettodatabase`.`tratta`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `progettodatabase`.`tratta` ;

CREATE TABLE IF NOT EXISTS `progettodatabase`.`tratta` (
  `CodTratta` INT(11) NOT NULL,
  `CAP` VARCHAR(45) NULL DEFAULT NULL,
  `IDNumerico` INT(11) NULL DEFAULT NULL,
  `Categoria` VARCHAR(45) NULL DEFAULT NULL,
  `Nome` VARCHAR(45) NULL DEFAULT NULL,
  `Lunghezza` DOUBLE NULL DEFAULT NULL,
  `NumeroCorsie` INT(11) NULL DEFAULT NULL,
  `Tipologia` VARCHAR(45) NULL DEFAULT NULL,
  `Costo` INT(11) NULL DEFAULT NULL CHECK(Costo >= 0),
  `NumeroCarr` INT(11) NULL DEFAULT NULL,
  `NumeroSensi` INT(11) NULL DEFAULT NULL,
  `TempoPercorrenza` INT(11) NULL DEFAULT NULL,
  PRIMARY KEY (`CodTratta`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `progettodatabase`.`collegamentotratte`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `progettodatabase`.`collegamentotratte` ;

CREATE TABLE IF NOT EXISTS `progettodatabase`.`collegamentotratte` (
  `Incrocio` INT(11) NULL DEFAULT NULL,
  `Km` INT(11) NULL DEFAULT NULL CHECK(Km >= 0),
  `LimVelocita` INT(11) NULL DEFAULT NULL,
  `CodTratta` INT(11) NOT NULL,
  `Latitudine` DOUBLE NOT NULL,
  `Longitudine` DOUBLE NOT NULL,
  `Altitudine` INT(11) NOT NULL,
  PRIMARY KEY (`CodTratta`, `Latitudine`, `Longitudine`, `Altitudine`),
  INDEX `fk_collegamentoTratte_tratta1_idx` (`CodTratta` ASC),
  INDEX `fk_collegamentoTratte_posizione1_idx` (`Latitudine` ASC, `Longitudine` ASC, `Altitudine` ASC),
  CONSTRAINT `fk_collegamentoTratte_posizione1`
    FOREIGN KEY (`Latitudine` , `Longitudine` , `Altitudine`)
    REFERENCES `progettodatabase`.`posizione` (`Latitudine` , `Longitudine` , `Altitudine`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_collegamentoTratte_tratta1`
    FOREIGN KEY (`CodTratta`)
    REFERENCES `progettodatabase`.`tratta` (`CodTratta`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `progettodatabase`.`costomanutenzione`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `progettodatabase`.`costomanutenzione` ;

CREATE TABLE IF NOT EXISTS `progettodatabase`.`costomanutenzione` (
  `Targa` VARCHAR(7) NOT NULL,
  `Ordinario` INT(11) NOT NULL,
  `Straordinario` INT(11) NOT NULL,
  PRIMARY KEY (`Targa`),
  INDEX `fk_costoManutenzione_veicoloInterno1_idx` (`Targa` ASC),
  CONSTRAINT `fk_costoManutenzione_veicoloInterno1`
    FOREIGN KEY (`Targa`)
    REFERENCES `progettodatabase`.`veicolointerno` (`Targa`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `progettodatabase`.`persona`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `progettodatabase`.`persona` ;

CREATE TABLE IF NOT EXISTS `progettodatabase`.`persona` (
  `CodFiscale` VARCHAR(16) NOT NULL,
  `Telefono` VARCHAR(100) NULL DEFAULT NULL,
  `Nome` VARCHAR(100) NULL DEFAULT NULL,
  `Cognome` VARCHAR(100) NULL DEFAULT NULL,
  `Indirizzo` VARCHAR(45) NULL DEFAULT NULL,
  `CAP` VARCHAR(5) NULL DEFAULT NULL,
  `DataReg` DATE NULL DEFAULT NULL,
  `Username` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`CodFiscale`),
  INDEX `fk_persona_account1_idx` (`Username` ASC),
  CONSTRAINT `fk_persona_account1`
    FOREIGN KEY (`Username`)
    REFERENCES `progettodatabase`.`account` (`Username`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `progettodatabase`.`tipodocumento`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `progettodatabase`.`tipodocumento` ;

CREATE TABLE IF NOT EXISTS `progettodatabase`.`tipodocumento` (
  `Tipo` VARCHAR(100) NOT NULL,
  `EnteRilascio` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`Tipo`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `progettodatabase`.`documento`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `progettodatabase`.`documento` ;

CREATE TABLE IF NOT EXISTS `progettodatabase`.`documento` (
  `Numero` VARCHAR(10) NOT NULL,
  `Scadenza` DATE NOT NULL,
  `CodFiscale` VARCHAR(16) NOT NULL,
  `Tipo` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`Numero`),
  INDEX `fk_documento_persona1_idx` (`CodFiscale` ASC),
  INDEX `fk_documento_tipoDocumento1_idx` (`Tipo` ASC),
  CONSTRAINT `fk_documento_persona1`
    FOREIGN KEY (`CodFiscale`)
    REFERENCES `progettodatabase`.`persona` (`CodFiscale`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_documento_tipoDocumento1`
    FOREIGN KEY (`Tipo`)
    REFERENCES `progettodatabase`.`tipodocumento` (`Tipo`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `progettodatabase`.`optional`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `progettodatabase`.`optional` ;

CREATE TABLE IF NOT EXISTS `progettodatabase`.`optional` (
  `Airbag` TINYINT(4) NULL DEFAULT NULL,
  `Navigatore` TINYINT(4) NULL DEFAULT NULL,
  `ABS` TINYINT(4) NULL DEFAULT NULL,
  `AriaCond` TINYINT(4) NULL DEFAULT NULL,
  `TavoliniPost` TINYINT(4) NULL DEFAULT NULL,
  `SensoriParch` TINYINT(4) NULL DEFAULT NULL,
  `SensoriFren` TINYINT(4) NULL DEFAULT NULL,
  `TettoPan` TINYINT(4) NULL DEFAULT NULL,
  `GuidaAss` TINYINT(4) NULL DEFAULT NULL,
  `Trasmissione` VARCHAR(45) NULL DEFAULT NULL,
  `Connettivita` TINYINT(4) NULL DEFAULT NULL,
  `DimBagagliaio` INT(11) NULL DEFAULT NULL,
  `InquinAcustico` INT(11) NULL DEFAULT NULL,
  `Targa` VARCHAR(7) NOT NULL,
  PRIMARY KEY (`Targa`),
  INDEX `fk_optional_veicoloInterno1_idx` (`Targa` ASC),
  CONSTRAINT `fk_optional_veicoloInterno1`
    FOREIGN KEY (`Targa`)
    REFERENCES `progettodatabase`.`veicolointerno` (`Targa`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `progettodatabase`.`partenza`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `progettodatabase`.`partenza` ;

CREATE TABLE IF NOT EXISTS `progettodatabase`.`partenza` (
  `Ordine` INT(11) NULL DEFAULT NULL,
  `CodTragitto` INT(11) NOT NULL,
  `Latitudine` DOUBLE NOT NULL,
  `Longitudine` DOUBLE NOT NULL,
  `Altitudine` INT(11) NOT NULL,
  PRIMARY KEY (`CodTragitto`, `Latitudine`, `Longitudine`, `Altitudine`),
  INDEX `fk_partenza_tragitto1_idx` (`CodTragitto` ASC),
  INDEX `fk_partenza_posizione1_idx` (`Latitudine` ASC, `Longitudine` ASC, `Altitudine` ASC),
  CONSTRAINT `fk_partenza_posizione1`
    FOREIGN KEY (`Latitudine` , `Longitudine` , `Altitudine`)
    REFERENCES `progettodatabase`.`posizione` (`Latitudine` , `Longitudine` , `Altitudine`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_partenza_tragitto1`
    FOREIGN KEY (`CodTragitto`)
    REFERENCES `progettodatabase`.`tragitto` (`CodTragitto`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `progettodatabase`.`propostapool`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `progettodatabase`.`propostapool` ;

CREATE TABLE IF NOT EXISTS `progettodatabase`.`propostapool` (
  `CodPool` INT(11) NOT NULL AUTO_INCREMENT,
  `LungTragitto` INT(11) NULL DEFAULT NULL,
  `DataPartenza` DATETIME NULL DEFAULT NULL,
  `DataArrivo` DATETIME NULL DEFAULT NULL,
  `DataCreazione` DATETIME NULL DEFAULT NULL,
  `Stato` VARCHAR(45) NULL DEFAULT "Aperto",
  `DurataVal` INT(11) NULL DEFAULT NULL,
  `TassoVar` INT(11) NULL DEFAULT NULL,
  `Flessibilita` INT(11) NULL DEFAULT NULL,
  `Costo` INT(11) NULL DEFAULT NULL CHECK(costo >= 0),
  `CodTragitto` INT(11) NOT NULL,
  `Targa` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`CodPool`),
  INDEX `fk_propostaPool_tragitto1_idx` (`CodTragitto` ASC),
  INDEX `fk_propostaPool_veicoloInterno1_idx` (`Targa` ASC),
  CONSTRAINT `fk_propostaPool_tragitto1`
    FOREIGN KEY (`CodTragitto`)
    REFERENCES `progettodatabase`.`tragitto` (`CodTragitto`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_propostaPool_veicoloInterno1`
    FOREIGN KEY (`Targa`)
    REFERENCES `progettodatabase`.`veicolointerno` (`Targa`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `progettodatabase`.`prenotazionepool`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `progettodatabase`.`prenotazionepool` ;

CREATE TABLE IF NOT EXISTS `progettodatabase`.`prenotazionepool` (
  `CodPrenotazione` INT(11) NOT NULL AUTO_INCREMENT,
  `StatoAcc` VARCHAR(45) NULL DEFAULT NULL,
  `DataRichiesta` DATETIME NULL DEFAULT NULL,
  `DataRisposta` DATETIME NULL DEFAULT NULL,
  `Username` VARCHAR(100) NOT NULL,
  `CodPool` INT(11) NOT NULL,
  PRIMARY KEY (`CodPrenotazione`),
  INDEX `fk_prenotazionePool_account1_idx` (`Username` ASC),
  INDEX `fk_prenotazionePool_propostaPool1_idx` (`CodPool` ASC),
  CONSTRAINT `fk_prenotazionePool_account1`
    FOREIGN KEY (`Username`)
    REFERENCES `progettodatabase`.`account` (`Username`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_prenotazionePool_propostaPool1`
    FOREIGN KEY (`CodPool`)
    REFERENCES `progettodatabase`.`propostapool` (`CodPool`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `progettodatabase`.`veicolidisponibili`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `progettodatabase`.`veicolidisponibili` ;

CREATE TABLE IF NOT EXISTS `progettodatabase`.`veicolidisponibili` (
  `CodDisponibili` INT(11) NOT NULL AUTO_INCREMENT,
  `DataInizio` DATE NULL DEFAULT NULL,
  `DataFine` DATE NULL DEFAULT NULL,
  `Targa` VARCHAR(7) NOT NULL,
  PRIMARY KEY (`CodDisponibili`),
  INDEX `fk_veicoliDisponibili_veicoloInterno1_idx` (`Targa` ASC),
  CONSTRAINT `fk_veicoliDisponibili_veicoloInterno1`
    FOREIGN KEY (`Targa`)
    REFERENCES `progettodatabase`.`veicolointerno` (`Targa`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `progettodatabase`.`prenotazioneveicolo`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `progettodatabase`.`prenotazioneveicolo` ;

CREATE TABLE IF NOT EXISTS `progettodatabase`.`prenotazioneveicolo` (
  `CodPrenotazione` INT(11) NOT NULL AUTO_INCREMENT,
  `DataInizio` DATE NULL DEFAULT NULL,
  `DataFine` DATE NULL DEFAULT NULL,
  `Stato` VARCHAR(45) NULL DEFAULT NULL,
  `DataRichiesta` DATETIME NULL DEFAULT NULL,
  `DataRisposta` DATETIME NULL DEFAULT NULL,
  `Username` VARCHAR(100) NOT NULL,
  `CodDisponibili` INT(11) NOT NULL,
  PRIMARY KEY (`CodPrenotazione`),
  INDEX `fk_prenotazioneVeicolo_account1_idx` (`Username` ASC),
  INDEX `fk_prenotazioneVeicolo_veicoliDisponibili1_idx` (`CodDisponibili` ASC),
  CONSTRAINT `fk_prenotazioneVeicolo_account1`
    FOREIGN KEY (`Username`)
    REFERENCES `progettodatabase`.`account` (`Username`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_prenotazioneVeicolo_veicoliDisponibili1`
    FOREIGN KEY (`CodDisponibili`)
    REFERENCES `progettodatabase`.`veicolidisponibili` (`CodDisponibili`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `progettodatabase`.`recensione`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `progettodatabase`.`recensione` ;

CREATE TABLE IF NOT EXISTS `progettodatabase`.`recensione` (
  `CodRecensione` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `Destinatario` VARCHAR(100) NOT NULL,
  `VotoComp` INT(10) UNSIGNED NOT NULL,
  `VotoViaggio` INT(10) UNSIGNED NOT NULL,
  `VotoSerieta` INT(10) UNSIGNED NOT NULL,
  `Commento` TINYTEXT NOT NULL,
  `Recensore` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`CodRecensione`),
  INDEX `fk_recensione_account1_idx` (`Recensore` ASC),
  CONSTRAINT `fk_recensione_account1`
    FOREIGN KEY (`Recensore`)
    REFERENCES `progettodatabase`.`account` (`Username`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `progettodatabase`.`recuperodati`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `progettodatabase`.`recuperodati` ;

CREATE TABLE IF NOT EXISTS `progettodatabase`.`recuperodati` (
  `Domanda` VARCHAR(100) NOT NULL,
  `Risposta` VARCHAR(100) NOT NULL,
  `Username` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`Username`),
  INDEX `fk_recuperoDati_account1_idx` (`Username` ASC),
  CONSTRAINT `fk_recuperoDati_account1`
    FOREIGN KEY (`Username`)
    REFERENCES `progettodatabase`.`account` (`Username`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `progettodatabase`.`ridemultiplo`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `progettodatabase`.`ridemultiplo` ;

CREATE TABLE IF NOT EXISTS `progettodatabase`.`ridemultiplo` (
  `CodMultiplo` INT(11) NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`CodMultiplo`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;

/*
-- -----------------------------------------------------
-- Table `progettodatabase`.`richiestasharingmultiplo`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `progettodatabase`.`richiestasharingmultiplo` ;

CREATE TABLE IF NOT EXISTS `progettodatabase`.`richiestasharingmultiplo` (
  `CodMultiplo` INT(11) NOT NULL,
  `CodChiamata` INT(11) NOT NULL,
  INDEX `fk_richiestaSharingMultiplo_rideMultiplo1_idx` (`CodMultiplo` ASC),
  INDEX `fk_richiestaSharingMultiplo_chiamata1_idx` (`CodChiamata` ASC),
  CONSTRAINT `fk_richiestaSharingMultiplo_chiamata1`
    FOREIGN KEY (`CodChiamata`)
    REFERENCES `progettodatabase`.`chiamata` (`CodChiamata`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_richiestaSharingMultiplo_rideMultiplo1`
    FOREIGN KEY (`CodMultiplo`)
    REFERENCES `progettodatabase`.`ridemultiplo` (`CodMultiplo`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;

*/
-- -----------------------------------------------------
-- Table `progettodatabase`.`tracking`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `progettodatabase`.`tracking` ;

CREATE TABLE IF NOT EXISTS `progettodatabase`.`tracking` (
  `Data` DATETIME NULL DEFAULT NULL,
  `Targa` VARCHAR(7) NOT NULL,
  `Latitudine` DOUBLE NOT NULL,
  `Longitudine` DOUBLE NOT NULL,
  `Altitudine` INT(11) NOT NULL,
  PRIMARY KEY (`Targa`, `Latitudine`, `Longitudine`, `Altitudine`),
  INDEX `fk_tracking_veicoloInterno1_idx` (`Targa` ASC),
  INDEX `fk_tracking_posizione1_idx` (`Latitudine` ASC, `Longitudine` ASC, `Altitudine` ASC),
  CONSTRAINT `fk_tracking_posizione1`
    FOREIGN KEY (`Latitudine` , `Longitudine` , `Altitudine`)
    REFERENCES `progettodatabase`.`posizione` (`Latitudine` , `Longitudine` , `Altitudine`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_tracking_veicoloInterno1`
    FOREIGN KEY (`Targa`)
    REFERENCES `progettodatabase`.`veicolointerno` (`Targa`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `progettodatabase`.`valoriconsumomedio`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `progettodatabase`.`valoriconsumomedio` ;

CREATE TABLE IF NOT EXISTS `progettodatabase`.`valoriconsumomedio` (
  `Targa` VARCHAR(7) NOT NULL,
  `Misto` INT(11) NOT NULL,
  `Extraurbano` INT(11) NOT NULL,
  `Urbano` INT(11) NOT NULL,
  PRIMARY KEY (`Targa`),
  INDEX `fk_valoriConsumoMedio_veicoloInterno1_idx` (`Targa` ASC),
  CONSTRAINT `fk_valoriConsumoMedio_veicoloInterno1`
    FOREIGN KEY (`Targa`)
    REFERENCES `progettodatabase`.`veicolointerno` (`Targa`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `progettodatabase`.`variazionerichiesta`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `progettodatabase`.`variazionerichiesta` ;

CREATE TABLE IF NOT EXISTS `progettodatabase`.`variazionerichiesta` (
  `CostoVar` INT(11) NULL DEFAULT NULL,
  `CodTragitto` INT(11) NOT NULL,
  `CodPrenotazione` INT(11) NOT NULL,
  PRIMARY KEY (`CodTragitto`, `CodPrenotazione`),
  INDEX `fk_variazioneRichiesta_tragitto1_idx` (`CodTragitto` ASC),
  INDEX `fk_variazioneRichiesta_prenotazionePool1_idx` (`CodPrenotazione` ASC),
  CONSTRAINT `fk_variazioneRichiesta_prenotazionePool1`
    FOREIGN KEY (`CodPrenotazione`)
    REFERENCES `progettodatabase`.`prenotazionepool` (`CodPrenotazione`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_variazioneRichiesta_tragitto1`
    FOREIGN KEY (`CodTragitto`)
    REFERENCES `progettodatabase`.`tragitto` (`CodTragitto`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
