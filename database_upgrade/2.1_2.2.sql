/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

DROP TABLE IF EXISTS `available_apps`;
DROP TABLE IF EXISTS `apps`;

CREATE TABLE IF NOT EXISTS `userloginkeys` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `key` VARCHAR(255) NOT NULL,
  `expires` DATETIME NULL DEFAULT NULL,
  `uid` INT(11) NULL DEFAULT NULL,
  PRIMARY KEY (`id`, `key`),
  UNIQUE INDEX `id_UNIQUE` (`id` ASC),
  UNIQUE INDEX `key_UNIQUE` (`key` ASC),
  INDEX `fk_userloginkeys_accounts1_idx` (`uid` ASC),
  CONSTRAINT `fk_userloginkeys_accounts1`
    FOREIGN KEY (`uid`)
    REFERENCES `accounts` (`uid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;

ALTER TABLE `userloginkeys`
ADD COLUMN `appname` VARCHAR(255) NOT NULL AFTER `uid`;
ALTER TABLE `userloginkeys`
ADD COLUMN `appicon` TINYTEXT NULL DEFAULT NULL AFTER `appname`;
ALTER TABLE `apikeys`
ADD COLUMN `type` VARCHAR(45) NOT NULL DEFAULT 'FULL' AFTER `notes`;

CREATE TABLE IF NOT EXISTS `apppasswords` (
  `passid` INT(11) NOT NULL AUTO_INCREMENT,
  `hash` VARCHAR(255) NOT NULL,
  `uid` INT(11) NOT NULL,
  `description` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`passid`, `uid`),
  UNIQUE INDEX `passid_UNIQUE` (`passid` ASC),
  INDEX `fk_apppasswords_accounts1_idx` (`uid` ASC),
  CONSTRAINT `fk_apppasswords_accounts1`
    FOREIGN KEY (`uid`)
    REFERENCES `accounts` (`uid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;