CREATE TABLE IF NOT EXISTS banking (
    `identifier` varchar(46) DEFAULT NULL,
    `type` varchar(50) DEFAULT NULL,
    `amount` int(64) DEFAULT NULL,
    `time` bigint(20) DEFAULT NULL,
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `balance` int(11) DEFAULT 0,
    `label` varchar(255) DEFAULT NULL,
    
    PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;
