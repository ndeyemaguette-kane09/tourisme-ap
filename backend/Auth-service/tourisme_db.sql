/*M!999999\- enable the sandbox mode */ 
-- MariaDB dump 10.19-11.8.2-MariaDB, for osx10.20 (arm64)
--
-- Host: localhost    Database: tourisme_db
-- ------------------------------------------------------
-- Server version	11.8.2-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*M!100616 SET @OLD_NOTE_VERBOSITY=@@NOTE_VERBOSITY, NOTE_VERBOSITY=0 */;

--
-- Table structure for table `beach`
--

DROP TABLE IF EXISTS `beach`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `beach` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `address` varchar(255) DEFAULT NULL,
  `city` varchar(255) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `image` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `rating` double NOT NULL,
  `image_url` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `beach`
--

LOCK TABLES `beach` WRITE;
/*!40000 ALTER TABLE `beach` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `beach` VALUES
(1,'','Dakar','',NULL,'Plage test ',5,'https://images.unsplash.com/photo-1507525428034-b723cf961d3e'),
(2,'','Dakar','',NULL,'plage 2',2,'https://images.unsplash.com/photo-1507525428034-b723cf961d3e'),
(3,'Île de Ngor, Dakar','Dakar','Une plage magnifique avec une eau claire, parfaite pour se détendre et profiter du soleil.',NULL,'Plage de Ngor',4.7,'https://www.bonjoursenegal.com/wp-content/uploads/2019/06/3-1.jpg');
/*!40000 ALTER TABLE `beach` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `city`
--

DROP TABLE IF EXISTS `city`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `city` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `description` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `city`
--

LOCK TABLES `city` WRITE;
/*!40000 ALTER TABLE `city` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `city` VALUES
(7,NULL,'Dakar'),
(8,NULL,'Diourbel');
/*!40000 ALTER TABLE `city` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `hotel`
--

DROP TABLE IF EXISTS `hotel`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `hotel` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `address` varchar(255) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `image` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `price` double NOT NULL,
  `rating` double NOT NULL,
  `city_id` bigint(20) DEFAULT NULL,
  `image_url` varchar(255) DEFAULT NULL,
  `city_name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FKf1iabdv6bi2yohh9h48wce42x` (`city_id`),
  CONSTRAINT `FKf1iabdv6bi2yohh9h48wce42x` FOREIGN KEY (`city_id`) REFERENCES `city` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `hotel`
--

LOCK TABLES `hotel` WRITE;
/*!40000 ALTER TABLE `hotel` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `hotel` VALUES
(4,'Corniche Dakar','Hotel luxe','hotel.jpg','Hotel Terrou Bi',150,4.8,NULL,'https://images.unsplash.com/photo-1566073771259-6a8506099945',NULL),
(5,'Corniche Dakar','Hotel luxe','hotel.jpg','Hotel Terrou Bi',150,4.8,NULL,'https://images.unsplash.com/photo-1566073771259-6a8506099945',NULL),
(6,'point E Dakar','Hotel luxe','hotel.jpg','Hotel de LYS',150000,4.7,NULL,'https://images.unsplash.com/photo-1566073771259-6a8506099945',NULL),
(7,'coniche ouakam','Hotel standard','hotel.jpg','Hotel de la renaissance',15000,3.5,NULL,'https://images.unsplash.com/photo-1566073771259-6a8506099945',NULL),
(8,'centre ville ','hôtel perso',NULL,'hôtel magui',30000,0,NULL,'https://images.unsplash.com/photo-1607712617949-8c993d290809?q=80&w=1335&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',NULL),
(9,'à côté du stade elimanel Fall ','adonnez vous à une expérience immersive dans notre hôtel 4 étoiles',NULL,'hôtel baobab',25000,4.4,NULL,'https://media.istockphoto.com/id/628172096/photo/african-safari-tent.webp?s=612x612&w=is&k=20&c=pXegf7Uzf0wS7hu4eElx4iEJLXVEK35fzOFLbQKOKi8=',NULL),
(10,'route de gossas, diourbel ','L\'Hôtel Balkan, situé sur la Route de Gossas à Diourbel, est un établissement proposant des chambres ventilées et climatisées pour vos séjours. ',NULL,'hôtel Balkan ',20000,1.1,NULL,'https://media.istockphoto.com/id/129179660/photo/luxurious-apartment-in-the-night.jpg?s=1024x1024&w=is&k=20&c=JinVEZ9W-kpfk1l9OM3e2rFtB8Svc8W8f9oyEhG92a8=','Diourbel ');
/*!40000 ALTER TABLE `hotel` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `restaurant`
--

DROP TABLE IF EXISTS `restaurant`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `restaurant` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `address` varchar(255) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `image` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `rating` double NOT NULL,
  `city_id` bigint(20) DEFAULT NULL,
  `city` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FKl968d8d7966yymvsxtdsni1vw` (`city_id`),
  CONSTRAINT `FKl968d8d7966yymvsxtdsni1vw` FOREIGN KEY (`city_id`) REFERENCES `city` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `restaurant`
--

LOCK TABLES `restaurant` WRITE;
/*!40000 ALTER TABLE `restaurant` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `restaurant` VALUES
(1,'Ngor','Restaurant poisson','ngor.jpg','Le Ngor',4.5,NULL,NULL),
(2,'ouakam','Restaurant poisson','ngor.jpg','dakaroise',4.5,NULL,NULL),
(3,'camps de garde ','restau et fast-food ',NULL,'restaurant magui',4.5,NULL,NULL),
(4,'sacré cœur 3','Grill Time est un steakhouse et restaurant de grillades réputé situé à Dakar, spécialisé dans les viandes importées et les plats au wok. Il se trouve au quartier Sacré-Cœur 3, au premier étage de l\'im',NULL,'Grill Time',4.5,NULL,NULL),
(16,'corniche des almadies','Chez Fatou est un restaurant emblématique de Dakar, situé sur la Corniche des Almadies. C\'est une adresse prisée pour son cadre décontracté \"les pieds dans le sable\" et sa vue imprenable sur l\'océan.','https://www.au-senegal.com/IMG/jpg/chez_fatou2.jpg','Chez Fatou',4,NULL,'Dakar ');
/*!40000 ALTER TABLE `restaurant` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `review`
--

DROP TABLE IF EXISTS `review`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `review` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `comment` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `entity_id` bigint(20) DEFAULT NULL,
  `entity_type` varchar(255) DEFAULT NULL,
  `rating` double NOT NULL,
  `username` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `review`
--

LOCK TABLES `review` WRITE;
/*!40000 ALTER TABLE `review` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `review` VALUES
(1,'magnifique 😍','2026-04-24 13:35:48.234830',4,'hotel',4,'ndeye maguette kane'),
(2,'j’ai fais comment pour ne jamais avoir connu cet hôtel avant 😭😍🧨','2026-04-24 13:41:09.751580',6,'hotel',5,'ndeye maguette kane'),
(3,'😍','2026-04-24 14:11:58.482469',4,'hotel',5,'ndeye maguette kane ');
/*!40000 ALTER TABLE `review` ENABLE KEYS */;
UNLOCK TABLES;
commit;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*M!100616 SET NOTE_VERBOSITY=@OLD_NOTE_VERBOSITY */;

-- Dump completed on 2026-04-26  5:51:34
