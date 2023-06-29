CREATE DATABASE IF NOT EXISTS west_coast_dreamin;

ALTER DATABASE west_coast_dreamin DEFAULT CHARACTER SET UTF8MB4;
ALTER DATABASE west_coast_dreamin DEFAULT COLLATE UTF8MB4_UNICODE_CI;

USE west_coast_dreamin;

CREATE TABLE users (
	`id` VARCHAR(60) NOT NULL,
	`group` VARCHAR(10) NULL DEFAULT 'User',
	`position` LONGTEXT NULL DEFAULT NULL,
	`accounts` LONGTEXT NULL DEFAULT NULL,
	`banking` LONGTEXT NULL DEFAULT NULL,
	`job` VARCHAR(50) NULL DEFAULT 'Unemployed',
	`job_grade` INT NULL DEFAULT 0,
	`inventory` LONGTEXT NULL DEFAULT NULL,
	`loadout` LONGTEXT NULL DEFAULT NULL,
	`vehicles` LONGTEXT NULL DEFAULT NULL,
	`properties` LONGTEXT NULL DEFAULT NULL,
	`identity` LONGTEXT NULL DEFAULT NULL,
	`pincode` INT NULL,
	`phone_number` VARCHAR(20) NULL DEFAULT NULL,

	PRIMARY KEY (`id`)
) ENGINE=InnoDB;


CREATE TABLE items (
	`name` VARCHAR(20) NOT NULL,
	`weight` INT NOT NULL DEFAULT 1,
	`sell_price` INT DEFAULT 0,
	`rarity` TINYINT NOT NULL DEFAULT 0,
	`can_remove` TINYINT NOT NULL DEFAULT 1,

	PRIMARY KEY (`name`)
) ENGINE=InnoDB;

CREATE TABLE job_grades (
	`id` INT NOT NULL AUTO_INCREMENT,
	`job_name` VARCHAR(50) DEFAULT NULL,
	`grade` INT NOT NULL,
	`name` VARCHAR(50) NOT NULL,
	`salary` INT NOT NULL,
	`skin_male` LONGTEXT NOT NULL,
	`skin_female` LONGTEXT NOT NULL,

	PRIMARY KEY (`id`)
) ENGINE=InnoDB;
