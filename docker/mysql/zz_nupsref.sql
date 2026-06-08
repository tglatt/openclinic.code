USE `openclinic_dbo`;

CREATE TABLE IF NOT EXISTS `nupsref` (
  `ID` int(11) DEFAULT NULL,
  `MUID` double DEFAULT NULL,
  `CSU` varchar(255) DEFAULT NULL,
  `NUPS` varchar(255) DEFAULT NULL,
  `ORIGINALCODE` varchar(255) DEFAULT NULL,
  `DOMAIN` varchar(255) DEFAULT NULL,
  `FR` varchar(500) DEFAULT NULL,
  `EN` varchar(500) DEFAULT NULL,
  `ES` varchar(500) DEFAULT NULL,
  `PT` varchar(500) DEFAULT NULL,
  `sectioncode` double DEFAULT NULL,
  `SECTION` varchar(255) DEFAULT NULL,
  `PARENT` varchar(255) DEFAULT NULL,
  `NRG-DETAIL` varchar(255) DEFAULT NULL,
  `NRG-SUMMARY` varchar(255) DEFAULT NULL,
  KEY `nups` (`NUPS`),
  KEY `parent` (`PARENT`),
  KEY `original` (`ORIGINALCODE`),
  KEY `fr` (`FR`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
