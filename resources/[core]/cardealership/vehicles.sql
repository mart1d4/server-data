CREATE TABLE IF NOT EXISTS vehicles (
	`id` int NOT NULL AUTO_INCREMENT,
	`name` varchar(255) NOT NULL,
	`model` varchar(255) NOT NULL,
	`price` int NOT NULL DEFAULT 20000,
	`carryWeight` int NOT NULL DEFAULT 20,
    `stock` int NOT NULL DEFAULT 10,

	PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS owned_vehicles (
	`plate` varchar(8) NOT NULL,
	`name` varchar(255) NOT NULL,
	`model` varchar(255) NOT NULL,
    `sellPrice` int NOT NULL DEFAULT 0,
    `mods` LONGTEXT NOT NULL,
    `inventory` LONGTEXT NOT NULL,
    `props` LONGTEXT NOT NULL,
    `mileage` float NOT NULL DEFAULT 0,
    `owner` varchar(255) NOT NULL,
    `garage` varchar(255) NOT NULL,
    `position` LONGTEXT NOT NULL,
    `heading` LONGTEXT NOT NULL,
    `state` LONGTEXT NOT NULL,
    `purchased` int NOT NULL DEFAULT 0,
    `updated` int NOT NULL DEFAULT 0,

	PRIMARY KEY (`plate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO vehicles (name, model, price) VALUES
	( 'Mercedes E55 W211', 'benze55', 100000 ),
    ( 'Mercedes C63 S Coupe W205', 'c63s', 115000 ),
    ( 'Mercedes CL63 AMG', 'cl63amg', 180000 ),
    ( 'Mercedes E63 AMG', 'e63amg', 125000 ),
    ( 'Mercedes S63 W222', 's63w222', 190000 ),
    ( 'Mercedes S63 W221', 'w221s63', 185000 ),
    ( 'Mercedes Maybach MR 500', 'oycmr500', 250000 ),
    ( 'Mercedes E400 4Matic', 'e400', 85000 ),
    ( 'Mercedes AMG GTR R20', 'amggtrr20', 180000 ),
    ( 'Mercedes A45 AMG', 'a45amg', 60000 ),
    ( 'Mercedes A45 S AMG', 'gxa45', 70000 ),
    ( 'Mercedes Brabus 850', 'brabus850', 300000 ),
    ( 'Mercedes CLS 63', 'cls2015', 130000 ),
    ( 'Mercedes CLS 53', 'cls53', 105000 ),
    ( 'Mercedes E63 S AMG 4Matic', 'e63s', 150000 ),
    ( 'Mercedes G500', 'g500', 210000 ),
    ( 'Mercedes GLE 53', 'gle53', 125000 ),
    ( 'Mercedes GLS 63', 'gls63', 160000 ),
    ( 'Mercedes C63 AMG W204', 'c63w204', 130000 ),
    ( 'Mercedes McLaren 722 S', '722s', 1024000 ),
    ( 'Mercedes S65 AMG W220', 's65amg', 200000 ),
	
    ( 'BMW M760i V12', '17m760i', 192000 ),
    ( 'BMW i8', 'acs8', 134000),
    ( 'BMW M5 F90', 'bmci', 125000 ),
    ( 'BMW M8', 'bmwm8', 175000 ),
    ( 'BMW E60 V10', 'e60', 110000 ),
    ( 'BMW M3 E30', 'm3e30', 67000 ),
    ( 'BMW M3 E36', 'm3e36', 75000 ),
    ( 'BMW M3 F80', 'm3f80', 90000 ),
    ( 'BMW M5 F10', 'm5f10', 100000 ),
    ( 'BMW M6 GC', 'm6gc', 145000 ),
    ( 'BMW M4 GTS', 'rmodm4gts', 138000 ),
    ( 'BMW X6M', 'x6m', 159000 ),
    ( 'BMW M6 F13', 'm6f13', 137000 ),
    ( 'BMW M5 Competition', '2019M5', 152000 ),
    ( 'BMW X5 E53', 'x5e53', 68000 ),
    ( 'BMW M4 Competition', 'm422', 110000 ),
	
    ( 'Audi R8 20', 'r820', 168000 ),
    ( 'Audi RS7', 'rs7', 135000 ),
    ( 'Audi RS6', 'rs62', 140000 ),
    ( 'Audi A4 Quattro ABT', 'aaq4', 47500 ),
    ( 'Audi A8 L W12', 'a8lw12', 149000 ),
    ( 'Audi A8 FSI', 'a8fsi', 164300 ),
    ( 'Audi RS3 Sportback', 'rs318', 58000 ),
    ( 'Audi RS5', 'rs5', 84900 ),
    ( 'Audi RS7 2021', 'rs721', 140200 ),
    ( 'Audi RS Q8 M', 'rsq8m', 273600 ),

    ( 'Porsche 911 Turbo S', '911turbos', 201100 ),
    ( 'Porsche Cayenne S18', 'pcs18', 173000 ),
    ( 'Porsche Panamera 17 Turbo', 'panamera17turbo', 167450 ),
    ( 'Porsche Taycan', 'taycan', 204500 ),

    ( 'Ferrari 599 GTO', '599gto', 332000 ),
    ( 'Ferrari La Ferrari', 'laferrari', 4100000 ),
    ( 'Ferrari F8 Spider Tributo', 'f8t', 272900 ),
    ( 'Ferrari Portofino', 'fpino', 216000 ),

    ( 'Lamborghini LP 700R', 'lp700r', 375000 ),
    ( 'Lamborghini Urus', 'urus2018', 242000 ),
    ( 'Lamborghini Aventador', 'aventador', 325000 ),
    ( 'Lamborghini LP 670 SV', 'lp670sv', 374700 ),

    ( 'Bentley Bentayga 2017', 'bentayga17', 260000 ),
    ( 'Bentley Continental GT', 'bcgt', 230100 ),
    ( 'Bentley Mulsanne', 'bmm', 471130 ),

    ( 'Volkswagen Golf 75R', 'golf75r', 47000 ),
    ( 'Volkswagen MK3 VR6', 'mk3vr6', 35500 ),
    ( 'Volkswagen Touareg R50', 'r50', 32000 ),

    ( 'Toyota Camry', 'camry55', 39850 ),
    ( 'Toyota Supra 80', 'a80', 92000 ),

    ( 'Cadillac ATS', 'cats', 22000 ),
    ( 'Cadillac CTS 350T', 'ct5v', 49000 ),

    ( 'Bugatti Veyron Super Sport', 'supersport', 1800000 ),
    ( 'Bugatti Divo', 'divo', 5400000 ),

    ( 'Ford Focus RS', 'focusrs', 38600 ),
    ( 'Ford Expedition Max', 'expmax20', 61200 ),

    ( 'Range Rover Velar', '18Velar', 74000 ),
    ( 'Range Rover SVR Mansory', 'mansrr', 163500 ),

    ( 'Rolls Royce Wraith', 'wraith', 348000 ),
    ( 'Rolls Royce Cullinan', 'rculi', 382000 ),

    ( 'Nissan GTR R35', 'gtr', 117000 ),
    ( 'Nissan Titan 17', 'titan17', 47680 ),

    ( 'Renault Clio RS', 'cliors', 29000 ),

    ( 'Pagani Huayra', 'huayra', 3450000 ),

    ( 'Koenigsegg Jesko', 'jesko2020', 3000000 ),

    ( 'Lexus LX', 'lx2018', 89160 ),

    ( 'Mitsubishi EVO 10', 'evo10', 28088 ),

    ( 'Tesla Model 3', 'tmodel', 53240 ),

    ( 'Jeep SRT8', 'srt8', 69165 ),

    ( 'Kawasaki Ninja H2R', 'nh2r', 57500 ),

    ( 'Yamaha YZF-R1', 'r1', 18000 )
;
