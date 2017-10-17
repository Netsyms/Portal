-- MySQL Script generated by MySQL Workbench
-- Tue 17 Oct 2017 03:30:32 AM MDT
-- Model: New Model    Version: 1.0
-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

-- -----------------------------------------------------
-- Schema sso
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema sso
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `sso` DEFAULT CHARACTER SET utf8 ;
USE `sso` ;

-- -----------------------------------------------------
-- Table `sso`.`acctstatus`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sso`.`acctstatus` (
  `statusid` INT NOT NULL AUTO_INCREMENT,
  `statuscode` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`statusid`),
  UNIQUE INDEX `statusid_UNIQUE` (`statusid` ASC),
  UNIQUE INDEX `statuscode_UNIQUE` (`statuscode` ASC))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `sso`.`accttypes`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sso`.`accttypes` (
  `typeid` INT NOT NULL AUTO_INCREMENT,
  `typecode` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`typeid`),
  UNIQUE INDEX `typeid_UNIQUE` (`typeid` ASC),
  UNIQUE INDEX `typecode_UNIQUE` (`typecode` ASC))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `sso`.`accounts`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sso`.`accounts` (
  `uid` INT NOT NULL AUTO_INCREMENT,
  `username` VARCHAR(190) NOT NULL,
  `password` VARCHAR(255) NULL,
  `realname` VARCHAR(255) NOT NULL,
  `email` VARCHAR(255) NULL DEFAULT 'NOEMAIL@EXAMPLE.COM',
  `authsecret` VARCHAR(100) NULL,
  `phone1` VARCHAR(45) NOT NULL,
  `phone2` VARCHAR(45) NOT NULL,
  `acctstatus` INT NOT NULL DEFAULT 0,
  `accttype` INT NOT NULL,
  `deleted` TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`uid`, `username`),
  UNIQUE INDEX `userid_UNIQUE` (`uid` ASC),
  UNIQUE INDEX `username_UNIQUE` (`username` ASC),
  INDEX `fk_accounts_acctstatus_idx` (`acctstatus` ASC),
  INDEX `email_index` (`email` ASC),
  INDEX `fk_accounts_accttypes1_idx` (`accttype` ASC),
  CONSTRAINT `fk_accounts_acctstatus`
    FOREIGN KEY (`acctstatus`)
    REFERENCES `sso`.`acctstatus` (`statusid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_accounts_accttypes1`
    FOREIGN KEY (`accttype`)
    REFERENCES `sso`.`accttypes` (`typeid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `sso`.`apps`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sso`.`apps` (
  `appid` INT NOT NULL AUTO_INCREMENT,
  `appname` VARCHAR(45) NULL,
  `appcode` VARCHAR(45) NULL,
  PRIMARY KEY (`appid`),
  UNIQUE INDEX `appid_UNIQUE` (`appid` ASC))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `sso`.`available_apps`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sso`.`available_apps` (
  `appid` INT NOT NULL,
  `uid` INT NOT NULL,
  PRIMARY KEY (`appid`, `uid`),
  INDEX `fk_apps_has_accounts_accounts1_idx` (`uid` ASC),
  INDEX `fk_apps_has_accounts_apps1_idx` (`appid` ASC),
  CONSTRAINT `fk_apps_has_accounts_apps1`
    FOREIGN KEY (`appid`)
    REFERENCES `sso`.`apps` (`appid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_apps_has_accounts_accounts1`
    FOREIGN KEY (`uid`)
    REFERENCES `sso`.`accounts` (`uid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `sso`.`apikeys`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sso`.`apikeys` (
  `key` VARCHAR(60) NOT NULL,
  `notes` TEXT NULL,
  PRIMARY KEY (`key`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `sso`.`groups`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sso`.`groups` (
  `groupid` INT NOT NULL,
  `groupname` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`groupid`),
  UNIQUE INDEX `groupid_UNIQUE` (`groupid` ASC),
  UNIQUE INDEX `groupname_UNIQUE` (`groupname` ASC))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `sso`.`assigned_groups`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sso`.`assigned_groups` (
  `groupid` INT NOT NULL,
  `uid` INT NOT NULL,
  PRIMARY KEY (`groupid`, `uid`),
  INDEX `fk_groups_has_accounts_accounts1_idx` (`uid` ASC),
  INDEX `fk_groups_has_accounts_groups1_idx` (`groupid` ASC),
  CONSTRAINT `fk_groups_has_accounts_groups1`
    FOREIGN KEY (`groupid`)
    REFERENCES `sso`.`groups` (`groupid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_groups_has_accounts_accounts1`
    FOREIGN KEY (`uid`)
    REFERENCES `sso`.`accounts` (`uid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `sso`.`managers`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sso`.`managers` (
  `managerid` INT NOT NULL,
  `employeeid` INT NOT NULL,
  PRIMARY KEY (`managerid`, `employeeid`),
  INDEX `fk_managers_accounts2_idx` (`employeeid` ASC),
  CONSTRAINT `fk_managers_accounts1`
    FOREIGN KEY (`managerid`)
    REFERENCES `sso`.`accounts` (`uid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_managers_accounts2`
    FOREIGN KEY (`employeeid`)
    REFERENCES `sso`.`accounts` (`uid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `sso`.`logtypes`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sso`.`logtypes` (
  `logtype` INT NOT NULL,
  `typename` VARCHAR(45) NULL,
  PRIMARY KEY (`logtype`),
  UNIQUE INDEX `logtype_UNIQUE` (`logtype` ASC))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `sso`.`authlog`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sso`.`authlog` (
  `logid` INT NOT NULL AUTO_INCREMENT,
  `logtime` DATETIME NOT NULL,
  `logtype` INT NOT NULL,
  `uid` INT NULL,
  `ip` VARCHAR(45) NULL,
  `otherdata` VARCHAR(255) NULL,
  PRIMARY KEY (`logid`),
  UNIQUE INDEX `logid_UNIQUE` (`logid` ASC),
  INDEX `fk_authlog_logtypes1_idx` (`logtype` ASC),
  INDEX `fk_authlog_accounts1_idx` (`uid` ASC),
  CONSTRAINT `fk_authlog_logtypes1`
    FOREIGN KEY (`logtype`)
    REFERENCES `sso`.`logtypes` (`logtype`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_authlog_accounts1`
    FOREIGN KEY (`uid`)
    REFERENCES `sso`.`accounts` (`uid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `sso`.`permissions`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sso`.`permissions` (
  `permid` INT NOT NULL AUTO_INCREMENT,
  `permcode` VARCHAR(45) NOT NULL,
  `perminfo` VARCHAR(200) NULL,
  PRIMARY KEY (`permid`),
  UNIQUE INDEX `permid_UNIQUE` (`permid` ASC))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `sso`.`assigned_permissions`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sso`.`assigned_permissions` (
  `uid` INT NOT NULL,
  `permid` INT NOT NULL,
  PRIMARY KEY (`uid`, `permid`),
  INDEX `fk_permissions_has_accounts_accounts1_idx` (`uid` ASC),
  INDEX `fk_permissions_has_accounts_permissions1_idx` (`permid` ASC),
  CONSTRAINT `fk_permissions_has_accounts_permissions1`
    FOREIGN KEY (`permid`)
    REFERENCES `sso`.`permissions` (`permid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_permissions_has_accounts_accounts1`
    FOREIGN KEY (`uid`)
    REFERENCES `sso`.`accounts` (`uid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `sso`.`mobile_codes`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sso`.`mobile_codes` (
  `codeid` INT NOT NULL AUTO_INCREMENT,
  `uid` INT NOT NULL,
  `code` VARCHAR(45) NULL,
  PRIMARY KEY (`codeid`),
  UNIQUE INDEX `codeid_UNIQUE` (`codeid` ASC),
  INDEX `fk_mobile_codes_accounts1_idx` (`uid` ASC),
  UNIQUE INDEX `code_UNIQUE` (`code` ASC),
  CONSTRAINT `fk_mobile_codes_accounts1`
    FOREIGN KEY (`uid`)
    REFERENCES `sso`.`accounts` (`uid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `sso`.`rate_limit`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sso`.`rate_limit` (
  `ipaddr` VARCHAR(45) NOT NULL,
  `lastaction` DATETIME NULL,
  PRIMARY KEY (`ipaddr`))
ENGINE = MEMORY;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

-- -----------------------------------------------------
-- Data for table `sso`.`acctstatus`
-- -----------------------------------------------------
START TRANSACTION;
USE `sso`;
INSERT INTO `sso`.`acctstatus` (`statusid`, `statuscode`) VALUES (1, 'NORMAL');
INSERT INTO `sso`.`acctstatus` (`statusid`, `statuscode`) VALUES (2, 'LOCKED_OR_DISABLED');
INSERT INTO `sso`.`acctstatus` (`statusid`, `statuscode`) VALUES (3, 'CHANGE_PASSWORD');
INSERT INTO `sso`.`acctstatus` (`statusid`, `statuscode`) VALUES (4, 'TERMINATED');
INSERT INTO `sso`.`acctstatus` (`statusid`, `statuscode`) VALUES (5, 'ALERT_ON_ACCESS');

COMMIT;


-- -----------------------------------------------------
-- Data for table `sso`.`accttypes`
-- -----------------------------------------------------
START TRANSACTION;
USE `sso`;
INSERT INTO `sso`.`accttypes` (`typeid`, `typecode`) VALUES (1, 'LOCAL');
INSERT INTO `sso`.`accttypes` (`typeid`, `typecode`) VALUES (2, 'LDAP');
INSERT INTO `sso`.`accttypes` (`typeid`, `typecode`) VALUES (3, 'LIGHT');

COMMIT;


-- -----------------------------------------------------
-- Data for table `sso`.`logtypes`
-- -----------------------------------------------------
START TRANSACTION;
USE `sso`;
INSERT INTO `sso`.`logtypes` (`logtype`, `typename`) VALUES (1, 'PORTAL_LOGIN_OK');
INSERT INTO `sso`.`logtypes` (`logtype`, `typename`) VALUES (2, 'PORTAL_LOGIN_FAILED');
INSERT INTO `sso`.`logtypes` (`logtype`, `typename`) VALUES (3, 'PASSWORD_CHANGED');
INSERT INTO `sso`.`logtypes` (`logtype`, `typename`) VALUES (4, 'API_LOGIN_OK');
INSERT INTO `sso`.`logtypes` (`logtype`, `typename`) VALUES (5, 'API_LOGIN_FAILED');
INSERT INTO `sso`.`logtypes` (`logtype`, `typename`) VALUES (6, 'PORTAL_BAD_AUTHCODE');
INSERT INTO `sso`.`logtypes` (`logtype`, `typename`) VALUES (7, 'API_BAD_AUTHCODE');
INSERT INTO `sso`.`logtypes` (`logtype`, `typename`) VALUES (8, 'BAD_CAPTCHA');
INSERT INTO `sso`.`logtypes` (`logtype`, `typename`) VALUES (9, '2FA_ADDED');
INSERT INTO `sso`.`logtypes` (`logtype`, `typename`) VALUES (10, '2FA_REMOVED');
INSERT INTO `sso`.`logtypes` (`logtype`, `typename`) VALUES (11, 'PORTAL_LOGOUT');
INSERT INTO `sso`.`logtypes` (`logtype`, `typename`) VALUES (12, 'API_AUTH_OK');
INSERT INTO `sso`.`logtypes` (`logtype`, `typename`) VALUES (13, 'API_AUTH_FAILED');
INSERT INTO `sso`.`logtypes` (`logtype`, `typename`) VALUES (14, 'API_BAD_KEY');
INSERT INTO `sso`.`logtypes` (`logtype`, `typename`) VALUES (15, 'LOG_CLEARED');
INSERT INTO `sso`.`logtypes` (`logtype`, `typename`) VALUES (16, 'USER_REMOVED');
INSERT INTO `sso`.`logtypes` (`logtype`, `typename`) VALUES (17, 'USER_ADDED');
INSERT INTO `sso`.`logtypes` (`logtype`, `typename`) VALUES (18, 'USER_EDITED');
INSERT INTO `sso`.`logtypes` (`logtype`, `typename`) VALUES (19, 'MOBILE_LOGIN_OK');
INSERT INTO `sso`.`logtypes` (`logtype`, `typename`) VALUES (20, 'MOBILE_LOGIN_FAILED');
INSERT INTO `sso`.`logtypes` (`logtype`, `typename`) VALUES (21, 'MOBILE_BAD_KEY');

COMMIT;


-- -----------------------------------------------------
-- Data for table `sso`.`permissions`
-- -----------------------------------------------------
START TRANSACTION;
USE `sso`;
INSERT INTO `sso`.`permissions` (`permid`, `permcode`, `perminfo`) VALUES (1, 'ADMIN', 'System administrator');
INSERT INTO `sso`.`permissions` (`permid`, `permcode`, `perminfo`) VALUES (100, 'INV_VIEW', 'Access inventory system');
INSERT INTO `sso`.`permissions` (`permid`, `permcode`, `perminfo`) VALUES (101, 'INV_EDIT', 'Edit inventory system');
INSERT INTO `sso`.`permissions` (`permid`, `permcode`, `perminfo`) VALUES (200, 'TASKFLOOR', 'Access TaskFloor');
INSERT INTO `sso`.`permissions` (`permid`, `permcode`, `perminfo`) VALUES (300, 'QWIKCLOCK', 'Access QwikClock and punch in/out');
INSERT INTO `sso`.`permissions` (`permid`, `permcode`, `perminfo`) VALUES (301, 'QWIKCLOCK_MANAGE', 'Edit punches and other data for managed users');
INSERT INTO `sso`.`permissions` (`permid`, `permcode`, `perminfo`) VALUES (302, 'QWIKCLOCK_EDITSELF', 'Edit own punches and other data');

COMMIT;

