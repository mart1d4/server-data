CREATE DATABASE westcoastdreamin;
USE westcoastdreamin;


CREATE TABLE `Users` (
	`id` VARCHAR(40) NOT NULL,
	`group` ENUM('User', 'Moderator', 'Admin') DEFAULT 'User',

	`position` LONGTEXT NOT NULL DEFAULT '',
	`accounts` LONGTEXT NOT NULL DEFAULT '',
	`banking` LONGTEXT NOT NULL DEFAULT '',

	`job` VARCHAR(32) NOT NULL DEFAULT 'Unemployed',
	`job_grade` INT1 UNSIGNED NOT NULL DEFAULT 0,

	`inventory` LONGTEXT NOT NULL DEFAULT '',
	`loadout` LONGTEXT NOT NULL DEFAULT '',
	`vehicles` LONGTEXT NOT NULL DEFAULT '',
	`properties` LONGTEXT NOT NULL DEFAULT '',

	`identity` LONGTEXT NOT NULL DEFAULT '',
	`pincode` VARCHAR(4),
	`phone` VARCHAR(15),

	PRIMARY KEY (`id`)
) ENGINE InnoDB,
  CHARSET utf8mb4,
  COLLATE utf8mb4_unicode_ci;


CREATE TABLE `Items` (
	`name` VARCHAR(32) NOT NULL,
	`weight` DECIMAL UNSIGNED NOT NULL,

	`food_intake` INT1 SIGNED,
	`water_intake` INT1 SIGNED,

	`price` DECIMAL UNSIGNED NOT NULL DEFAULT 1,
	`rarity` INT1 UNSIGNED NOT NULL DEFAULT 0,
	`removable` BOOLEAN NOT NULL DEFAULT 1,

	PRIMARY KEY (`name`)
) ENGINE InnoDB,
  CHARSET utf8mb4,
  COLLATE utf8mb4_unicode_ci;


CREATE TABLE `JobGrades` (
	`id` INT1 UNSIGNED NOT NULL auto_increment,

	`name` VARCHAR(32) NOT NULL,
	`grade` INT1 UNSIGNED NOT NULL DEFAULT 0,
	`salary` DECIMAL UNSIGNED NOT NULL DEFAULT 200,
	`job_name` VARCHAR(32) NOT NULL DEFAULT 'Unemployed',

	`skin_male` LONGTEXT NOT NULL DEFAULT '',
	`skin_female` LONGTEXT NOT NULL DEFAULT '',

	PRIMARY KEY (`id`)
) ENGINE InnoDB,
  CHARSET utf8mb4,
  COLLATE utf8mb4_unicode_ci;


CREATE TABLE `Transactions` (
	`id` INT4 UNSIGNED NOT NULL auto_increment,
    `type` ENUM('Withdraw','Deposit','Transfer') NOT NULL,

    `initiator` VARCHAR(40) NOT NULL,
	`recipient` VARCHAR(40),

    `amount` INT3 UNSIGNED NOT NULL,
	`money_before` INT4 UNSIGNED NOT NULL,
	`money_after` INT4 UNSIGNED NOT NULL,

    `label` VARCHAR(255),
	`date` TIMESTAMP NOT NULL DEFAULT current_timestamp(),

	PRIMARY KEY (`id`),
	FOREIGN KEY (`initiator`) REFERENCES `users` (`id`),
	FOREIGN KEY (`recipient`) REFERENCES `users` (`id`)
) ENGINE InnoDB,
  CHARSET utf8mb4,
  COLLATE utf8mb4_unicode_ci;


CREATE TABLE `Vehicles` (
	`id` INT2 NOT NULL auto_increment,
	`name` VARCHAR(32) NOT NULL,
	`model` VARCHAR(32) NOT NULL,
	`brand` VARCHAR(32) NOT NULL,
	`price` DECIMAL UNSIGNED NOT NULL,
	`carry_weight` INT1 UNSIGNED NOT NULL DEFAULT 20,
    `stock` INT1 UNSIGNED NOT NULL DEFAULT 10,

	PRIMARY KEY (`id`)
) ENGINE InnoDB,
  CHARSET utf8mb4,
  COLLATE utf8mb4_unicode_ci;


CREATE TABLE `OwnedVehicles` (
	`plate` VARCHAR(8) NOT NULL,
	`vehicle` INT2 NOT NULL,
    `mileage` DECIMAL UNSIGNED NOT NULL DEFAULT 0.0,
    `owner` VARCHAR(40) NOT NULL,
    `purchased` TIMESTAMP NOT NULL DEFAULT current_timestamp(),
    `updated` TIMESTAMP NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),

	PRIMARY KEY (`plate`),
	FOREIGN KEY (`vehicle`) REFERENCES `vehicles` (`id`),
	FOREIGN KEY (`owner`) REFERENCES `users` (`id`)
) ENGINE InnoDB,
  CHARSET utf8mb4,
  COLLATE utf8mb4_unicode_ci;
