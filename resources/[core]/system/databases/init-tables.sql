CREATE DATABASE IF NOT EXISTS west_coast_dreamin;


ALTER DATABASE west_coast_dreamin DEFAULT CHARACTER SET UTF8MB4;
ALTER DATABASE west_coast_dreamin DEFAULT COLLATE UTF8MB4_UNICODE_CI;


USE west_coast_dreamin;


CREATE TABLE IF NOT EXISTS users (
	`id` VARCHAR(40) NOT NULL PRIMARY KEY,
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
	`pincode` VARCHAR(4) NULL DEFAULT NULL,
	`phone_number` VARCHAR(12) NULL DEFAULT NULL
);


CREATE TABLE IF NOT EXISTS items (
	`name` VARCHAR(32) NOT NULL PRIMARY KEY,
	`weight` DECIMAL UNSIGNED NOT NULL,
	`food_intake` INT1 SIGNED NULL,
	`water_intake` INT1 SIGNED NULL,
	`sell_price` DECIMAL UNSIGNED NOT NULL DEFAULT 1,
	`rarity` INT1 UNSIGNED NOT NULL DEFAULT 0,
	`can_remove` BOOLEAN NOT NULL DEFAULT 1
);


CREATE TABLE IF NOT EXISTS job_grades (
	`id` INT1 UNSIGNED NOT NULL auto_increment PRIMARY KEY,
	`job_name` VARCHAR(32) NOT NULL DEFAULT 'Unemployed',
	`grade` INT1 UNSIGNED NOT NULL DEFAULT 0,
	`name` VARCHAR(32) NOT NULL,
	`salary` DECIMAL UNSIGNED NOT NULL DEFAULT 200,
	`skin_male` LONGTEXT NOT NULL DEFAULT '',
	`skin_female` LONGTEXT NOT NULL DEFAULT ''
);


CREATE TABLE IF NOT EXISTS banking (
	`id` INT4 UNSIGNED NOT NULL auto_increment PRIMARY KEY,
    `user` VARCHAR(40) NOT NULL,
	`transfer_recipient` VARCHAR(40) NULL,
    `type` ENUM('Withdraw','Deposit','Transfer') NOT NULL,
    `amount` INT3 UNSIGNED NOT NULL,
	`money_before` INT4 UNSIGNED NOT NULL,
	`money_after` INT4 UNSIGNED NOT NULL,
    `label` VARCHAR(255) DEFAULT NULL,
	`date` TIMESTAMP NOT NULL DEFAULT current_timestamp(),

	FOREIGN KEY (`user`) REFERENCES `users` (`id`),
	FOREIGN KEY (`transfer_recipient`) REFERENCES `users` (`id`) 
);


CREATE TABLE IF NOT EXISTS vehicles (
	`id` INT2 NOT NULL auto_increment PRIMARY KEY,
	`name` VARCHAR(32) NOT NULL,
	`model` VARCHAR(32) NOT NULL,
	`brand` VARCHAR(32) NOT NULL,
	`price` DECIMAL UNSIGNED NOT NULL,
	`carry_weight` INT1 UNSIGNED NOT NULL DEFAULT 20,
    `stock` INT1 UNSIGNED NOT NULL DEFAULT 10
);


CREATE TABLE IF NOT EXISTS owned_vehicles (
	`plate` VARCHAR(8) NOT NULL PRIMARY KEY,
	`vehicle` INT2 NOT NULL,
    `mileage` DECIMAL UNSIGNED NOT NULL DEFAULT 0.0,
    `props` LONGTEXT NOT NULL DEFAULT '',
    `mods` LONGTEXT NOT NULL DEFAULT '',
    `owner` VARCHAR(40) NOT NULL,
    `position` LONGTEXT NOT NULL DEFAULT '',
    `state` LONGTEXT NOT NULL DEFAULT '',
    `trunk_inventory` LONGTEXT NOT NULL DEFAULT '',
    `purchased` TIMESTAMP NOT NULL DEFAULT current_timestamp(),
    `updated` TIMESTAMP NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),

	FOREIGN KEY (`vehicle`) REFERENCES `vehicles` (`id`),
	FOREIGN KEY (`owner`) REFERENCES `users` (`id`)
);
