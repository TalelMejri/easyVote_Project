-- MariaDB dump 10.19  Distrib 10.4.32-MariaDB, for Win64 (AMD64)
--
-- Host: localhost    Database: easyvote_db
-- ------------------------------------------------------
-- Server version	10.4.32-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `announcements`
--

DROP TABLE IF EXISTS `announcements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `announcements` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `content` varchar(2000) DEFAULT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `title` varchar(200) DEFAULT NULL,
  `candidate_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FKfmh05hfinato8wdsydeoqi2xt` (`candidate_id`),
  CONSTRAINT `FKfmh05hfinato8wdsydeoqi2xt` FOREIGN KEY (`candidate_id`) REFERENCES `candidates` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `announcements`
--

LOCK TABLES `announcements` WRITE;
/*!40000 ALTER TABLE `announcements` DISABLE KEYS */;
/*!40000 ALTER TABLE `announcements` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `candidate_likes`
--

DROP TABLE IF EXISTS `candidate_likes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `candidate_likes` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `created_at` datetime(6) DEFAULT NULL,
  `candidate_id` bigint(20) NOT NULL,
  `user_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UK453pnuxidpcr3mhdu70uurses` (`candidate_id`,`user_id`),
  KEY `FKcue673tq81fj5yvrs5g3xx1ga` (`user_id`),
  CONSTRAINT `FKcue673tq81fj5yvrs5g3xx1ga` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `FKpw8dwfi8rstn2xluy1kxivcxh` FOREIGN KEY (`candidate_id`) REFERENCES `candidates` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `candidate_likes`
--

LOCK TABLES `candidate_likes` WRITE;
/*!40000 ALTER TABLE `candidate_likes` DISABLE KEYS */;
/*!40000 ALTER TABLE `candidate_likes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `candidates`
--

DROP TABLE IF EXISTS `candidates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `candidates` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `created_at` datetime(6) DEFAULT NULL,
  `photo_url` varchar(255) DEFAULT NULL,
  `program` text DEFAULT NULL,
  `slogan` varchar(200) DEFAULT NULL,
  `status` enum('PENDING','REJECTED','VALIDATED') NOT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `validated_at` datetime(6) DEFAULT NULL,
  `election_id` bigint(20) NOT NULL,
  `user_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UKn1awf3kaerbp88aoqtqc30smv` (`user_id`,`election_id`),
  KEY `FKmdu3yssghrl36wth97l9b9a9d` (`election_id`),
  CONSTRAINT `FKmdu3yssghrl36wth97l9b9a9d` FOREIGN KEY (`election_id`) REFERENCES `elections` (`id`),
  CONSTRAINT `FKme4fkelukmx2s63tlcrft6hio` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `candidates`
--

LOCK TABLES `candidates` WRITE;
/*!40000 ALTER TABLE `candidates` DISABLE KEYS */;
INSERT INTO `candidates` VALUES (1,'2026-10-19 20:28:28.000000',NULL,'1. Plus de salles d\'étude. 2. Wifi partout.','Un campus pour tous','VALIDATED','2026-10-19 20:28:28.000000','2026-10-19 20:28:28.000000',1,2),(2,'2026-10-19 20:29:25.000000',NULL,'y','x','VALIDATED','2026-10-19 20:29:25.000000','2026-10-19 20:29:25.000000',2,3),(3,'2026-10-19 21:21:56.000000',NULL,'Programme','Test exploratoire','VALIDATED','2026-10-19 21:21:56.000000','2026-10-19 21:21:56.000000',3,3),(4,'2026-10-20 13:19:12.000000',NULL,'1. Plus de salles d\'étude. 2. Wifi partout.','Un campus pour tous','VALIDATED','2026-10-20 13:19:12.000000','2026-10-20 13:19:12.000000',4,2),(5,'2026-10-20 13:22:41.000000',NULL,'1. Plus de salles d\'étude. 2. Wifi partout.','Un campus pour tous','VALIDATED','2026-10-20 13:22:41.000000','2026-10-20 13:22:41.000000',5,2),(6,'2026-10-20 13:24:44.000000',NULL,'1. Plus de salles d\'étude. 2. Wifi partout.','Un campus pour tous','VALIDATED','2026-10-20 13:24:44.000000','2026-10-20 13:24:44.000000',6,2),(7,'2026-10-21 22:39:35.000000',NULL,'1. Plus de salles d\'étude. 2. Wifi partout.','Un campus pour tous','VALIDATED','2026-10-21 22:39:35.000000','2026-10-21 22:39:35.000000',7,2);
/*!40000 ALTER TABLE `candidates` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `chat_messages`
--

DROP TABLE IF EXISTS `chat_messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `chat_messages` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `content` varchar(4000) NOT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `role` enum('ASSISTANT','USER') NOT NULL,
  `session_id` varchar(100) DEFAULT NULL,
  `user_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK6f0y4l43ihmgfswkgy9yrtjkh` (`user_id`),
  CONSTRAINT `FK6f0y4l43ihmgfswkgy9yrtjkh` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chat_messages`
--

LOCK TABLES `chat_messages` WRITE;
/*!40000 ALTER TABLE `chat_messages` DISABLE KEYS */;
/*!40000 ALTER TABLE `chat_messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `comments`
--

DROP TABLE IF EXISTS `comments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `comments` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `content` varchar(1000) NOT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `candidate_id` bigint(20) NOT NULL,
  `user_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FKphho2w3ud8wl2eqlb2w1ltas2` (`candidate_id`),
  KEY `FK8omq0tc18jd43bu5tjh6jvraq` (`user_id`),
  CONSTRAINT `FK8omq0tc18jd43bu5tjh6jvraq` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `FKphho2w3ud8wl2eqlb2w1ltas2` FOREIGN KEY (`candidate_id`) REFERENCES `candidates` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `comments`
--

LOCK TABLES `comments` WRITE;
/*!40000 ALTER TABLE `comments` DISABLE KEYS */;
/*!40000 ALTER TABLE `comments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `elections`
--

DROP TABLE IF EXISTS `elections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `elections` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `campaign_end` datetime(6) NOT NULL,
  `campaign_start` datetime(6) NOT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `description` varchar(2000) DEFAULT NULL,
  `status` enum('CAMPAIGN_ACTIVE','CLOSED','DRAFT','VOTE_ACTIVE') NOT NULL,
  `title` varchar(255) NOT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `vote_end` datetime(6) NOT NULL,
  `vote_start` datetime(6) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `elections`
--

LOCK TABLES `elections` WRITE;
/*!40000 ALTER TABLE `elections` DISABLE KEYS */;
INSERT INTO `elections` VALUES (1,'2026-10-21 20:28:00.000000','2026-10-20 20:28:00.000000','2026-10-19 20:28:28.000000','Créée par system-tests.mjs','CLOSED','Élection BDE (test système 2026-10-19T20:28:27.811Z)','2026-10-19 20:28:29.000000','2026-10-22 20:28:00.000000','2026-10-21 20:28:00.000000'),(2,'2026-10-21 20:29:00.000000','2026-10-20 20:29:00.000000','2026-10-19 20:29:25.000000',NULL,'VOTE_ACTIVE','Exploratoire','2026-10-19 20:29:25.000000','2026-10-22 20:29:00.000000','2026-10-21 20:29:00.000000'),(3,'2026-10-21 21:21:00.000000','2026-10-20 21:21:00.000000','2026-10-19 21:21:56.000000',NULL,'VOTE_ACTIVE','Exploratoire 2026-10-19T21:21:56.590Z','2026-10-19 21:21:56.000000','2026-10-22 21:21:00.000000','2026-10-21 21:21:00.000000'),(4,'2026-10-22 13:19:00.000000','2026-10-21 13:19:00.000000','2026-10-20 13:19:12.000000','Créée par system-tests.mjs','CLOSED','Élection BDE (test système 2026-10-20T13:19:12.165Z)','2026-10-20 13:19:12.000000','2026-10-23 13:19:00.000000','2026-10-22 13:19:00.000000'),(5,'2026-10-22 13:22:00.000000','2026-10-21 13:22:00.000000','2026-10-20 13:22:41.000000','Créée par system-tests.mjs','CLOSED','Élection BDE (test système 2026-10-20T13:22:41.087Z)','2026-10-20 13:22:41.000000','2026-10-23 13:22:00.000000','2026-10-22 13:22:00.000000'),(6,'2026-10-22 13:24:00.000000','2026-10-21 13:24:00.000000','2026-10-20 13:24:44.000000','Créée par system-tests.mjs','CLOSED','Élection BDE (test système 2026-10-20T13:24:44.755Z)','2026-10-20 13:24:44.000000','2026-10-23 13:24:00.000000','2026-10-22 13:24:00.000000'),(7,'2026-10-23 22:39:00.000000','2026-10-22 22:39:00.000000','2026-10-21 22:39:35.000000','Créée par system-tests.mjs','CLOSED','Élection BDE (test système 2026-10-21T22:39:34.868Z)','2026-10-21 22:39:35.000000','2026-10-24 22:39:00.000000','2026-10-23 22:39:00.000000');
/*!40000 ALTER TABLE `elections` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notifications`
--

DROP TABLE IF EXISTS `notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `notifications` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `content` varchar(500) DEFAULT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `link` varchar(500) DEFAULT NULL,
  `is_read` bit(1) NOT NULL,
  `title` varchar(200) DEFAULT NULL,
  `type` enum('CAMPAIGN_STARTED','CANDIDATE_VALIDATED','NEW_COMMENT','NEW_QUESTION','QUESTION_ANSWERED','RESULTS_PUBLISHED','VOTE_ENDED','VOTE_STARTED') NOT NULL,
  `user_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK9y21adhxn0ayjhfocscqox7bh` (`user_id`),
  CONSTRAINT `FK9y21adhxn0ayjhfocscqox7bh` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=103 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notifications`
--

LOCK TABLES `notifications` WRITE;
/*!40000 ALTER TABLE `notifications` DISABLE KEYS */;
INSERT INTO `notifications` VALUES (1,'La campagne pour \'Élection BDE (test système 2026-10-19T20:28:27.811Z)\' vient d\'ouvrir !','2026-10-19 20:28:28.000000','/elections/1','\0','Nouvelle campagne ouverte','CAMPAIGN_STARTED',1),(2,'La campagne pour \'Élection BDE (test système 2026-10-19T20:28:27.811Z)\' vient d\'ouvrir !','2026-10-19 20:28:28.000000','/elections/1','\0','Nouvelle campagne ouverte','CAMPAIGN_STARTED',2),(3,'La campagne pour \'Élection BDE (test système 2026-10-19T20:28:27.811Z)\' vient d\'ouvrir !','2026-10-19 20:28:28.000000','/elections/1','\0','Nouvelle campagne ouverte','CAMPAIGN_STARTED',3),(4,'La campagne pour \'Élection BDE (test système 2026-10-19T20:28:27.811Z)\' vient d\'ouvrir !','2026-10-19 20:28:28.000000','/elections/1','\0','Nouvelle campagne ouverte','CAMPAIGN_STARTED',4),(5,'La campagne pour \'Élection BDE (test système 2026-10-19T20:28:27.811Z)\' vient d\'ouvrir !','2026-10-19 20:28:28.000000','/elections/1','\0','Nouvelle campagne ouverte','CAMPAIGN_STARTED',5),(6,'Votre candidature pour Élection BDE (test système 2026-10-19T20:28:27.811Z) a été validée.','2026-10-19 20:28:28.000000','/elections/1','\0','Candidature validée ! 🎉','CANDIDATE_VALIDATED',2),(7,'Votez maintenant pour \'Élection BDE (test système 2026-10-19T20:28:27.811Z)\'','2026-10-19 20:28:28.000000','/elections/1/vote','\0','Le vote est ouvert ! 🗳️','VOTE_STARTED',1),(8,'Votez maintenant pour \'Élection BDE (test système 2026-10-19T20:28:27.811Z)\'','2026-10-19 20:28:28.000000','/elections/1/vote','\0','Le vote est ouvert ! 🗳️','VOTE_STARTED',2),(9,'Votez maintenant pour \'Élection BDE (test système 2026-10-19T20:28:27.811Z)\'','2026-10-19 20:28:28.000000','/elections/1/vote','\0','Le vote est ouvert ! 🗳️','VOTE_STARTED',3),(10,'Votez maintenant pour \'Élection BDE (test système 2026-10-19T20:28:27.811Z)\'','2026-10-19 20:28:28.000000','/elections/1/vote','\0','Le vote est ouvert ! 🗳️','VOTE_STARTED',4),(11,'Votez maintenant pour \'Élection BDE (test système 2026-10-19T20:28:27.811Z)\'','2026-10-19 20:28:28.000000','/elections/1/vote','\0','Le vote est ouvert ! 🗳️','VOTE_STARTED',5),(12,'Les résultats de \'Élection BDE (test système 2026-10-19T20:28:27.811Z)\' sont publiés.','2026-10-19 20:28:29.000000','/elections/1/results','\0','Résultats disponibles','RESULTS_PUBLISHED',1),(13,'Les résultats de \'Élection BDE (test système 2026-10-19T20:28:27.811Z)\' sont publiés.','2026-10-19 20:28:29.000000','/elections/1/results','\0','Résultats disponibles','RESULTS_PUBLISHED',2),(14,'Les résultats de \'Élection BDE (test système 2026-10-19T20:28:27.811Z)\' sont publiés.','2026-10-19 20:28:29.000000','/elections/1/results','\0','Résultats disponibles','RESULTS_PUBLISHED',3),(15,'Les résultats de \'Élection BDE (test système 2026-10-19T20:28:27.811Z)\' sont publiés.','2026-10-19 20:28:29.000000','/elections/1/results','\0','Résultats disponibles','RESULTS_PUBLISHED',4),(16,'Les résultats de \'Élection BDE (test système 2026-10-19T20:28:27.811Z)\' sont publiés.','2026-10-19 20:28:29.000000','/elections/1/results','\0','Résultats disponibles','RESULTS_PUBLISHED',5),(17,'Votre candidature pour Exploratoire a été validée.','2026-10-19 20:29:25.000000','/elections/2','\0','Candidature validée ! 🎉','CANDIDATE_VALIDATED',3),(18,'La campagne pour \'Exploratoire\' vient d\'ouvrir !','2026-10-19 20:29:25.000000','/elections/2','\0','Nouvelle campagne ouverte','CAMPAIGN_STARTED',1),(19,'La campagne pour \'Exploratoire\' vient d\'ouvrir !','2026-10-19 20:29:25.000000','/elections/2','\0','Nouvelle campagne ouverte','CAMPAIGN_STARTED',2),(20,'La campagne pour \'Exploratoire\' vient d\'ouvrir !','2026-10-19 20:29:25.000000','/elections/2','\0','Nouvelle campagne ouverte','CAMPAIGN_STARTED',3),(21,'La campagne pour \'Exploratoire\' vient d\'ouvrir !','2026-10-19 20:29:25.000000','/elections/2','\0','Nouvelle campagne ouverte','CAMPAIGN_STARTED',4),(22,'La campagne pour \'Exploratoire\' vient d\'ouvrir !','2026-10-19 20:29:25.000000','/elections/2','\0','Nouvelle campagne ouverte','CAMPAIGN_STARTED',5),(23,'Votez maintenant pour \'Exploratoire\'','2026-10-19 20:29:25.000000','/elections/2/vote','\0','Le vote est ouvert ! 🗳️','VOTE_STARTED',1),(24,'Votez maintenant pour \'Exploratoire\'','2026-10-19 20:29:25.000000','/elections/2/vote','\0','Le vote est ouvert ! 🗳️','VOTE_STARTED',2),(25,'Votez maintenant pour \'Exploratoire\'','2026-10-19 20:29:25.000000','/elections/2/vote','\0','Le vote est ouvert ! 🗳️','VOTE_STARTED',3),(26,'Votez maintenant pour \'Exploratoire\'','2026-10-19 20:29:25.000000','/elections/2/vote','\0','Le vote est ouvert ! 🗳️','VOTE_STARTED',4),(27,'Votez maintenant pour \'Exploratoire\'','2026-10-19 20:29:25.000000','/elections/2/vote','\0','Le vote est ouvert ! 🗳️','VOTE_STARTED',5),(28,'Votre candidature pour Exploratoire 2026-10-19T21:21:56.590Z a été validée.','2026-10-19 21:21:56.000000','/elections/3','\0','Candidature validée ! 🎉','CANDIDATE_VALIDATED',3),(29,'La campagne pour \'Exploratoire 2026-10-19T21:21:56.590Z\' vient d\'ouvrir !','2026-10-19 21:21:56.000000','/elections/3','\0','Nouvelle campagne ouverte','CAMPAIGN_STARTED',1),(30,'La campagne pour \'Exploratoire 2026-10-19T21:21:56.590Z\' vient d\'ouvrir !','2026-10-19 21:21:56.000000','/elections/3','\0','Nouvelle campagne ouverte','CAMPAIGN_STARTED',2),(31,'La campagne pour \'Exploratoire 2026-10-19T21:21:56.590Z\' vient d\'ouvrir !','2026-10-19 21:21:56.000000','/elections/3','\0','Nouvelle campagne ouverte','CAMPAIGN_STARTED',3),(32,'La campagne pour \'Exploratoire 2026-10-19T21:21:56.590Z\' vient d\'ouvrir !','2026-10-19 21:21:56.000000','/elections/3','\0','Nouvelle campagne ouverte','CAMPAIGN_STARTED',4),(33,'La campagne pour \'Exploratoire 2026-10-19T21:21:56.590Z\' vient d\'ouvrir !','2026-10-19 21:21:56.000000','/elections/3','\0','Nouvelle campagne ouverte','CAMPAIGN_STARTED',5),(34,'Votez maintenant pour \'Exploratoire 2026-10-19T21:21:56.590Z\'','2026-10-19 21:21:56.000000','/elections/3/vote','\0','Le vote est ouvert ! 🗳️','VOTE_STARTED',1),(35,'Votez maintenant pour \'Exploratoire 2026-10-19T21:21:56.590Z\'','2026-10-19 21:21:56.000000','/elections/3/vote','\0','Le vote est ouvert ! 🗳️','VOTE_STARTED',2),(36,'Votez maintenant pour \'Exploratoire 2026-10-19T21:21:56.590Z\'','2026-10-19 21:21:56.000000','/elections/3/vote','\0','Le vote est ouvert ! 🗳️','VOTE_STARTED',3),(37,'Votez maintenant pour \'Exploratoire 2026-10-19T21:21:56.590Z\'','2026-10-19 21:21:56.000000','/elections/3/vote','\0','Le vote est ouvert ! 🗳️','VOTE_STARTED',4),(38,'Votez maintenant pour \'Exploratoire 2026-10-19T21:21:56.590Z\'','2026-10-19 21:21:56.000000','/elections/3/vote','\0','Le vote est ouvert ! 🗳️','VOTE_STARTED',5),(39,'La campagne pour \'Élection BDE (test système 2026-10-20T13:19:12.165Z)\' vient d\'ouvrir !','2026-10-20 13:19:12.000000','/elections/4','\0','Nouvelle campagne ouverte','CAMPAIGN_STARTED',1),(40,'La campagne pour \'Élection BDE (test système 2026-10-20T13:19:12.165Z)\' vient d\'ouvrir !','2026-10-20 13:19:12.000000','/elections/4','\0','Nouvelle campagne ouverte','CAMPAIGN_STARTED',2),(41,'La campagne pour \'Élection BDE (test système 2026-10-20T13:19:12.165Z)\' vient d\'ouvrir !','2026-10-20 13:19:12.000000','/elections/4','\0','Nouvelle campagne ouverte','CAMPAIGN_STARTED',3),(42,'La campagne pour \'Élection BDE (test système 2026-10-20T13:19:12.165Z)\' vient d\'ouvrir !','2026-10-20 13:19:12.000000','/elections/4','\0','Nouvelle campagne ouverte','CAMPAIGN_STARTED',4),(43,'La campagne pour \'Élection BDE (test système 2026-10-20T13:19:12.165Z)\' vient d\'ouvrir !','2026-10-20 13:19:12.000000','/elections/4','\0','Nouvelle campagne ouverte','CAMPAIGN_STARTED',5),(44,'Votre candidature pour Élection BDE (test système 2026-10-20T13:19:12.165Z) a été validée.','2026-10-20 13:19:12.000000','/elections/4','\0','Candidature validée ! 🎉','CANDIDATE_VALIDATED',2),(45,'Votez maintenant pour \'Élection BDE (test système 2026-10-20T13:19:12.165Z)\'','2026-10-20 13:19:12.000000','/elections/4/vote','\0','Le vote est ouvert ! 🗳️','VOTE_STARTED',1),(46,'Votez maintenant pour \'Élection BDE (test système 2026-10-20T13:19:12.165Z)\'','2026-10-20 13:19:12.000000','/elections/4/vote','\0','Le vote est ouvert ! 🗳️','VOTE_STARTED',2),(47,'Votez maintenant pour \'Élection BDE (test système 2026-10-20T13:19:12.165Z)\'','2026-10-20 13:19:12.000000','/elections/4/vote','\0','Le vote est ouvert ! 🗳️','VOTE_STARTED',3),(48,'Votez maintenant pour \'Élection BDE (test système 2026-10-20T13:19:12.165Z)\'','2026-10-20 13:19:12.000000','/elections/4/vote','\0','Le vote est ouvert ! 🗳️','VOTE_STARTED',4),(49,'Votez maintenant pour \'Élection BDE (test système 2026-10-20T13:19:12.165Z)\'','2026-10-20 13:19:12.000000','/elections/4/vote','\0','Le vote est ouvert ! 🗳️','VOTE_STARTED',5),(50,'Les résultats de \'Élection BDE (test système 2026-10-20T13:19:12.165Z)\' sont publiés.','2026-10-20 13:19:12.000000','/elections/4/results','\0','Résultats disponibles','RESULTS_PUBLISHED',1),(51,'Les résultats de \'Élection BDE (test système 2026-10-20T13:19:12.165Z)\' sont publiés.','2026-10-20 13:19:12.000000','/elections/4/results','\0','Résultats disponibles','RESULTS_PUBLISHED',2),(52,'Les résultats de \'Élection BDE (test système 2026-10-20T13:19:12.165Z)\' sont publiés.','2026-10-20 13:19:12.000000','/elections/4/results','\0','Résultats disponibles','RESULTS_PUBLISHED',3),(53,'Les résultats de \'Élection BDE (test système 2026-10-20T13:19:12.165Z)\' sont publiés.','2026-10-20 13:19:12.000000','/elections/4/results','\0','Résultats disponibles','RESULTS_PUBLISHED',4),(54,'Les résultats de \'Élection BDE (test système 2026-10-20T13:19:12.165Z)\' sont publiés.','2026-10-20 13:19:12.000000','/elections/4/results','\0','Résultats disponibles','RESULTS_PUBLISHED',5),(55,'La campagne pour \'Élection BDE (test système 2026-10-20T13:22:41.087Z)\' vient d\'ouvrir !','2026-10-20 13:22:41.000000','/elections/5','\0','Nouvelle campagne ouverte','CAMPAIGN_STARTED',1),(56,'La campagne pour \'Élection BDE (test système 2026-10-20T13:22:41.087Z)\' vient d\'ouvrir !','2026-10-20 13:22:41.000000','/elections/5','\0','Nouvelle campagne ouverte','CAMPAIGN_STARTED',2),(57,'La campagne pour \'Élection BDE (test système 2026-10-20T13:22:41.087Z)\' vient d\'ouvrir !','2026-10-20 13:22:41.000000','/elections/5','\0','Nouvelle campagne ouverte','CAMPAIGN_STARTED',3),(58,'La campagne pour \'Élection BDE (test système 2026-10-20T13:22:41.087Z)\' vient d\'ouvrir !','2026-10-20 13:22:41.000000','/elections/5','\0','Nouvelle campagne ouverte','CAMPAIGN_STARTED',4),(59,'La campagne pour \'Élection BDE (test système 2026-10-20T13:22:41.087Z)\' vient d\'ouvrir !','2026-10-20 13:22:41.000000','/elections/5','\0','Nouvelle campagne ouverte','CAMPAIGN_STARTED',5),(60,'Votre candidature pour Élection BDE (test système 2026-10-20T13:22:41.087Z) a été validée.','2026-10-20 13:22:41.000000','/elections/5','\0','Candidature validée ! 🎉','CANDIDATE_VALIDATED',2),(61,'Votez maintenant pour \'Élection BDE (test système 2026-10-20T13:22:41.087Z)\'','2026-10-20 13:22:41.000000','/elections/5/vote','\0','Le vote est ouvert ! 🗳️','VOTE_STARTED',1),(62,'Votez maintenant pour \'Élection BDE (test système 2026-10-20T13:22:41.087Z)\'','2026-10-20 13:22:41.000000','/elections/5/vote','\0','Le vote est ouvert ! 🗳️','VOTE_STARTED',2),(63,'Votez maintenant pour \'Élection BDE (test système 2026-10-20T13:22:41.087Z)\'','2026-10-20 13:22:41.000000','/elections/5/vote','\0','Le vote est ouvert ! 🗳️','VOTE_STARTED',3),(64,'Votez maintenant pour \'Élection BDE (test système 2026-10-20T13:22:41.087Z)\'','2026-10-20 13:22:41.000000','/elections/5/vote','\0','Le vote est ouvert ! 🗳️','VOTE_STARTED',4),(65,'Votez maintenant pour \'Élection BDE (test système 2026-10-20T13:22:41.087Z)\'','2026-10-20 13:22:41.000000','/elections/5/vote','\0','Le vote est ouvert ! 🗳️','VOTE_STARTED',5),(66,'Les résultats de \'Élection BDE (test système 2026-10-20T13:22:41.087Z)\' sont publiés.','2026-10-20 13:22:41.000000','/elections/5/results','\0','Résultats disponibles','RESULTS_PUBLISHED',1),(67,'Les résultats de \'Élection BDE (test système 2026-10-20T13:22:41.087Z)\' sont publiés.','2026-10-20 13:22:41.000000','/elections/5/results','\0','Résultats disponibles','RESULTS_PUBLISHED',2),(68,'Les résultats de \'Élection BDE (test système 2026-10-20T13:22:41.087Z)\' sont publiés.','2026-10-20 13:22:41.000000','/elections/5/results','\0','Résultats disponibles','RESULTS_PUBLISHED',3),(69,'Les résultats de \'Élection BDE (test système 2026-10-20T13:22:41.087Z)\' sont publiés.','2026-10-20 13:22:41.000000','/elections/5/results','\0','Résultats disponibles','RESULTS_PUBLISHED',4),(70,'Les résultats de \'Élection BDE (test système 2026-10-20T13:22:41.087Z)\' sont publiés.','2026-10-20 13:22:41.000000','/elections/5/results','\0','Résultats disponibles','RESULTS_PUBLISHED',5),(71,'La campagne pour \'Élection BDE (test système 2026-10-20T13:24:44.755Z)\' vient d\'ouvrir !','2026-10-20 13:24:44.000000','/elections/6','\0','Nouvelle campagne ouverte','CAMPAIGN_STARTED',1),(72,'La campagne pour \'Élection BDE (test système 2026-10-20T13:24:44.755Z)\' vient d\'ouvrir !','2026-10-20 13:24:44.000000','/elections/6','\0','Nouvelle campagne ouverte','CAMPAIGN_STARTED',2),(73,'La campagne pour \'Élection BDE (test système 2026-10-20T13:24:44.755Z)\' vient d\'ouvrir !','2026-10-20 13:24:44.000000','/elections/6','\0','Nouvelle campagne ouverte','CAMPAIGN_STARTED',3),(74,'La campagne pour \'Élection BDE (test système 2026-10-20T13:24:44.755Z)\' vient d\'ouvrir !','2026-10-20 13:24:44.000000','/elections/6','\0','Nouvelle campagne ouverte','CAMPAIGN_STARTED',4),(75,'La campagne pour \'Élection BDE (test système 2026-10-20T13:24:44.755Z)\' vient d\'ouvrir !','2026-10-20 13:24:44.000000','/elections/6','\0','Nouvelle campagne ouverte','CAMPAIGN_STARTED',5),(76,'Votre candidature pour Élection BDE (test système 2026-10-20T13:24:44.755Z) a été validée.','2026-10-20 13:24:44.000000','/elections/6','\0','Candidature validée ! 🎉','CANDIDATE_VALIDATED',2),(77,'Votez maintenant pour \'Élection BDE (test système 2026-10-20T13:24:44.755Z)\'','2026-10-20 13:24:44.000000','/elections/6/vote','\0','Le vote est ouvert ! 🗳️','VOTE_STARTED',1),(78,'Votez maintenant pour \'Élection BDE (test système 2026-10-20T13:24:44.755Z)\'','2026-10-20 13:24:44.000000','/elections/6/vote','\0','Le vote est ouvert ! 🗳️','VOTE_STARTED',2),(79,'Votez maintenant pour \'Élection BDE (test système 2026-10-20T13:24:44.755Z)\'','2026-10-20 13:24:44.000000','/elections/6/vote','\0','Le vote est ouvert ! 🗳️','VOTE_STARTED',3),(80,'Votez maintenant pour \'Élection BDE (test système 2026-10-20T13:24:44.755Z)\'','2026-10-20 13:24:44.000000','/elections/6/vote','\0','Le vote est ouvert ! 🗳️','VOTE_STARTED',4),(81,'Votez maintenant pour \'Élection BDE (test système 2026-10-20T13:24:44.755Z)\'','2026-10-20 13:24:44.000000','/elections/6/vote','\0','Le vote est ouvert ! 🗳️','VOTE_STARTED',5),(82,'Les résultats de \'Élection BDE (test système 2026-10-20T13:24:44.755Z)\' sont publiés.','2026-10-20 13:24:44.000000','/elections/6/results','\0','Résultats disponibles','RESULTS_PUBLISHED',1),(83,'Les résultats de \'Élection BDE (test système 2026-10-20T13:24:44.755Z)\' sont publiés.','2026-10-20 13:24:44.000000','/elections/6/results','\0','Résultats disponibles','RESULTS_PUBLISHED',2),(84,'Les résultats de \'Élection BDE (test système 2026-10-20T13:24:44.755Z)\' sont publiés.','2026-10-20 13:24:44.000000','/elections/6/results','\0','Résultats disponibles','RESULTS_PUBLISHED',3),(85,'Les résultats de \'Élection BDE (test système 2026-10-20T13:24:44.755Z)\' sont publiés.','2026-10-20 13:24:44.000000','/elections/6/results','\0','Résultats disponibles','RESULTS_PUBLISHED',4),(86,'Les résultats de \'Élection BDE (test système 2026-10-20T13:24:44.755Z)\' sont publiés.','2026-10-20 13:24:44.000000','/elections/6/results','\0','Résultats disponibles','RESULTS_PUBLISHED',5),(87,'La campagne pour \'Élection BDE (test système 2026-10-21T22:39:34.868Z)\' vient d\'ouvrir !','2026-10-21 22:39:35.000000','/elections/7','\0','Nouvelle campagne ouverte','CAMPAIGN_STARTED',1),(88,'La campagne pour \'Élection BDE (test système 2026-10-21T22:39:34.868Z)\' vient d\'ouvrir !','2026-10-21 22:39:35.000000','/elections/7','\0','Nouvelle campagne ouverte','CAMPAIGN_STARTED',2),(89,'La campagne pour \'Élection BDE (test système 2026-10-21T22:39:34.868Z)\' vient d\'ouvrir !','2026-10-21 22:39:35.000000','/elections/7','\0','Nouvelle campagne ouverte','CAMPAIGN_STARTED',3),(90,'La campagne pour \'Élection BDE (test système 2026-10-21T22:39:34.868Z)\' vient d\'ouvrir !','2026-10-21 22:39:35.000000','/elections/7','\0','Nouvelle campagne ouverte','CAMPAIGN_STARTED',4),(91,'La campagne pour \'Élection BDE (test système 2026-10-21T22:39:34.868Z)\' vient d\'ouvrir !','2026-10-21 22:39:35.000000','/elections/7','\0','Nouvelle campagne ouverte','CAMPAIGN_STARTED',5),(92,'Votre candidature pour Élection BDE (test système 2026-10-21T22:39:34.868Z) a été validée.','2026-10-21 22:39:35.000000','/elections/7','\0','Candidature validée ! 🎉','CANDIDATE_VALIDATED',2),(93,'Votez maintenant pour \'Élection BDE (test système 2026-10-21T22:39:34.868Z)\'','2026-10-21 22:39:35.000000','/elections/7/vote','\0','Le vote est ouvert ! 🗳️','VOTE_STARTED',1),(94,'Votez maintenant pour \'Élection BDE (test système 2026-10-21T22:39:34.868Z)\'','2026-10-21 22:39:35.000000','/elections/7/vote','\0','Le vote est ouvert ! 🗳️','VOTE_STARTED',2),(95,'Votez maintenant pour \'Élection BDE (test système 2026-10-21T22:39:34.868Z)\'','2026-10-21 22:39:35.000000','/elections/7/vote','\0','Le vote est ouvert ! 🗳️','VOTE_STARTED',3),(96,'Votez maintenant pour \'Élection BDE (test système 2026-10-21T22:39:34.868Z)\'','2026-10-21 22:39:35.000000','/elections/7/vote','\0','Le vote est ouvert ! 🗳️','VOTE_STARTED',4),(97,'Votez maintenant pour \'Élection BDE (test système 2026-10-21T22:39:34.868Z)\'','2026-10-21 22:39:35.000000','/elections/7/vote','\0','Le vote est ouvert ! 🗳️','VOTE_STARTED',5),(98,'Les résultats de \'Élection BDE (test système 2026-10-21T22:39:34.868Z)\' sont publiés.','2026-10-21 22:39:35.000000','/elections/7/results','\0','Résultats disponibles','RESULTS_PUBLISHED',1),(99,'Les résultats de \'Élection BDE (test système 2026-10-21T22:39:34.868Z)\' sont publiés.','2026-10-21 22:39:35.000000','/elections/7/results','\0','Résultats disponibles','RESULTS_PUBLISHED',2),(100,'Les résultats de \'Élection BDE (test système 2026-10-21T22:39:34.868Z)\' sont publiés.','2026-10-21 22:39:35.000000','/elections/7/results','\0','Résultats disponibles','RESULTS_PUBLISHED',3),(101,'Les résultats de \'Élection BDE (test système 2026-10-21T22:39:34.868Z)\' sont publiés.','2026-10-21 22:39:35.000000','/elections/7/results','\0','Résultats disponibles','RESULTS_PUBLISHED',4),(102,'Les résultats de \'Élection BDE (test système 2026-10-21T22:39:34.868Z)\' sont publiés.','2026-10-21 22:39:35.000000','/elections/7/results','\0','Résultats disponibles','RESULTS_PUBLISHED',5);
/*!40000 ALTER TABLE `notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `otp_codes`
--

DROP TABLE IF EXISTS `otp_codes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `otp_codes` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `code` varchar(6) NOT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `expires_at` datetime(6) NOT NULL,
  `used` bit(1) NOT NULL,
  `user_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FKt9j4to767daef0ws3fiixis0y` (`user_id`),
  CONSTRAINT `FKt9j4to767daef0ws3fiixis0y` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `otp_codes`
--

LOCK TABLES `otp_codes` WRITE;
/*!40000 ALTER TABLE `otp_codes` DISABLE KEYS */;
/*!40000 ALTER TABLE `otp_codes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `questions`
--

DROP TABLE IF EXISTS `questions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `questions` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `answer` varchar(2000) DEFAULT NULL,
  `answered_at` datetime(6) DEFAULT NULL,
  `content` varchar(1000) NOT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `candidate_id` bigint(20) NOT NULL,
  `user_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FKib488d8xm7ksovaguj106l8ym` (`candidate_id`),
  KEY `FKjoo8hp6d3gfwctr68dl2iaemj` (`user_id`),
  CONSTRAINT `FKib488d8xm7ksovaguj106l8ym` FOREIGN KEY (`candidate_id`) REFERENCES `candidates` (`id`),
  CONSTRAINT `FKjoo8hp6d3gfwctr68dl2iaemj` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `questions`
--

LOCK TABLES `questions` WRITE;
/*!40000 ALTER TABLE `questions` DISABLE KEYS */;
/*!40000 ALTER TABLE `questions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `created_at` datetime(6) DEFAULT NULL,
  `email` varchar(255) NOT NULL,
  `full_name` varchar(255) NOT NULL,
  `is_verified` bit(1) NOT NULL,
  `password` varchar(255) NOT NULL,
  `profile_picture` varchar(255) DEFAULT NULL,
  `role` enum('ADMIN','CANDIDATE','STUDENT') NOT NULL,
  `student_id` varchar(255) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UK6dotkott2kjsp8vw4d0m25fb7` (`email`),
  UNIQUE KEY `UKqh3otyipv2k9hqte4a1abcyhq` (`student_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'2026-10-19 21:27:27.000000','ahmed@test.com','Ahmed Ltayef','','$2a$10$7lywx8rux6dSc2JntHxX4.CinQEW.pQh1iLNIh1tscN1WcwRA/akO',NULL,'ADMIN',NULL,'2026-10-19 21:27:27.000000'),(2,'2026-10-19 21:27:27.000000','achref@test.com','Achref Ben Ali','','$2a$10$7lywx8rux6dSc2JntHxX4.CinQEW.pQh1iLNIh1tscN1WcwRA/akO',NULL,'CANDIDATE',NULL,'2026-10-19 20:28:28.000000'),(3,'2026-10-19 21:27:27.000000','dali@test.com','Dali Trabelsi','','$2a$10$7lywx8rux6dSc2JntHxX4.CinQEW.pQh1iLNIh1tscN1WcwRA/akO',NULL,'CANDIDATE',NULL,'2026-10-19 20:29:25.000000'),(4,'2026-10-19 21:27:27.000000','moez@test.com','Moez Gharbi','','$2a$10$7lywx8rux6dSc2JntHxX4.CinQEW.pQh1iLNIh1tscN1WcwRA/akO',NULL,'STUDENT',NULL,'2026-10-19 21:27:27.000000'),(5,'2026-10-19 21:27:27.000000','talel@test.com','Talel Mejri','','$2a$10$7lywx8rux6dSc2JntHxX4.CinQEW.pQh1iLNIh1tscN1WcwRA/akO',NULL,'STUDENT',NULL,'2026-10-19 21:27:27.000000');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `vote_tokens`
--

DROP TABLE IF EXISTS `vote_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `vote_tokens` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `created_at` datetime(6) DEFAULT NULL,
  `token_hash` varchar(255) NOT NULL,
  `used` bit(1) NOT NULL,
  `used_at` datetime(6) DEFAULT NULL,
  `election_id` bigint(20) NOT NULL,
  `user_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UKqam5q19v03vwpoyldg41q1k07` (`user_id`,`election_id`),
  UNIQUE KEY `UKc3br7jwl5ugkxww84w1wupm3h` (`token_hash`),
  KEY `FK1ac0s4y68oo8begkpbibltt5u` (`election_id`),
  CONSTRAINT `FK1ac0s4y68oo8begkpbibltt5u` FOREIGN KEY (`election_id`) REFERENCES `elections` (`id`),
  CONSTRAINT `FKdm77x44ptmqeyw49e9x8x9k8` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vote_tokens`
--

LOCK TABLES `vote_tokens` WRITE;
/*!40000 ALTER TABLE `vote_tokens` DISABLE KEYS */;
INSERT INTO `vote_tokens` VALUES (1,'2026-10-19 20:28:28.000000','ce846748812cff54445c5264ebc6d8a16ed06c14a4ad01e1b19639f6a1891d1a','\0',NULL,1,1),(2,'2026-10-19 20:28:28.000000','d1d2d7ffb03339181ad05f04d12c749e6fd6e51bb22276b4b84605889a82262b','\0',NULL,1,2),(3,'2026-10-19 20:28:28.000000','0e204819eb8be3d3bbc388d1f2b9536801eace35ed8e4813d422c9650d990672','\0',NULL,1,3),(4,'2026-10-19 20:28:28.000000','696e519f39bcbed8acbcbb640d2d1284d42a7a52efaaeafa285119ec2b829423','\0',NULL,1,4),(5,'2026-10-19 20:28:28.000000','f2493105e50af0864066f5cf1509f4e7c14ad06317c49ee15d5612cac0507591','','2026-10-19 20:28:28.000000',1,5),(6,'2026-10-19 20:29:25.000000','e93b2dc0dc66fd8eaaa5376f59ddb994fad24d7ed4512db4db27fe37de0f9ba4','','2026-10-19 20:29:25.000000',2,1),(7,'2026-10-19 21:21:56.000000','46b857823adbf65a5a403baab1ea13979bc7c54f498f79a269d895389aff837f','','2026-10-19 21:21:56.000000',3,1),(8,'2026-10-20 13:19:12.000000','e9f42f023fc33d68b76ddb8cb39b0a0fab310c8e041092ebbb1abdb2c6204b85','\0',NULL,4,1),(9,'2026-10-20 13:19:12.000000','2ae184dfeb41fc1d8e2805d2ed43a4b09b15133c7f1bdb404d9c0c464402855c','\0',NULL,4,2),(10,'2026-10-20 13:19:12.000000','8b10e0f288b0c7f6517fbcec7369730dc9c256295bcef88fd958a68c3af64a6d','\0',NULL,4,3),(11,'2026-10-20 13:19:12.000000','3b9f61d5aa5d854d200bb2745b4b93fdc1b708de67c0b3fe8bae914885b8bb3b','\0',NULL,4,4),(12,'2026-10-20 13:19:12.000000','f2925d17bf90b2d68657152e1d0286840584b7514b15581fdf915ff816a6a2a1','','2026-10-20 13:19:12.000000',4,5),(13,'2026-10-20 13:22:41.000000','1e87693d715bddf0e10af1b070386775d8045d7b0c76fde298addd8ce5ca9320','\0',NULL,5,1),(14,'2026-10-20 13:22:41.000000','6920717c3e68d35b66c751f8a29c1acec2fae3b452cf4af74de5fb161164e0c6','\0',NULL,5,2),(15,'2026-10-20 13:22:41.000000','9314b4d76736076aef40c239a31e8bcb8ef0ed0982b02bee0674ae871a2797a2','\0',NULL,5,3),(16,'2026-10-20 13:22:41.000000','31c22295d2ae7b8ba7fbfe4d3c7ea01af9da1c53e9debbf180d78956172ce391','\0',NULL,5,4),(17,'2026-10-20 13:22:41.000000','b4bf14fb71dcf78b717da4200d452fa2ef82b9b6a82824482975097bc9c2eb1d','','2026-10-20 13:22:41.000000',5,5),(18,'2026-10-20 13:24:44.000000','d4021bb67a225b61508dbdc25b3dc99194383d37dd4a9a1035bed4ecd9a19dab','\0',NULL,6,1),(19,'2026-10-20 13:24:44.000000','c771a920deb9419320271944609b5bd3f70f990bf855e81fde1687029eafbfb5','\0',NULL,6,2),(20,'2026-10-20 13:24:44.000000','1569f83e2c6552f813cf6f92d3390081c49315dffafd6e0226b54b92f63adf8a','\0',NULL,6,3),(21,'2026-10-20 13:24:44.000000','93d7cf29065d4dc66287533f3eb88d8e45eb6c52c751d14c0866ef28fab16910','\0',NULL,6,4),(22,'2026-10-20 13:24:44.000000','f53d9b15e65178e5d7169c0af7e61170e8f824b2f57ff1c029e123e177508e30','','2026-10-20 13:24:44.000000',6,5),(23,'2026-10-21 22:39:35.000000','d9e9ce39e0b80f6edc073b76b9a57f2c88956076fc2e7c264e0280f84351eebe','\0',NULL,7,1),(24,'2026-10-21 22:39:35.000000','5442f693e4d6e681656b737a83968b8d973814fba7cb6a169b04a9bf856f2600','\0',NULL,7,2),(25,'2026-10-21 22:39:35.000000','afdf3cfb975e71102d3231d9295068780b72d298b421931a476d6202a53b0ffc','\0',NULL,7,3),(26,'2026-10-21 22:39:35.000000','e6074fc0e0c586c1863431cc6e778885bd06be9c1811f2f4b732c83ef0c8042d','\0',NULL,7,4),(27,'2026-10-21 22:39:35.000000','9c749f6f1fd4cf54d3f9b7da06bb06c0ede2b356a431c27a2d5010f1a54f84fc','','2026-10-21 22:39:35.000000',7,5);
/*!40000 ALTER TABLE `vote_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `votes`
--

DROP TABLE IF EXISTS `votes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `votes` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `token_hash` varchar(255) NOT NULL,
  `voted_at` datetime(6) NOT NULL,
  `candidate_id` bigint(20) NOT NULL,
  `election_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_vote_token_hash` (`token_hash`),
  KEY `FKgr0htccc82fco8rhtkxcuct4g` (`candidate_id`),
  KEY `FKodk7ilbhf33jk4bm3b526j8ir` (`election_id`),
  CONSTRAINT `FKgr0htccc82fco8rhtkxcuct4g` FOREIGN KEY (`candidate_id`) REFERENCES `candidates` (`id`),
  CONSTRAINT `FKodk7ilbhf33jk4bm3b526j8ir` FOREIGN KEY (`election_id`) REFERENCES `elections` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `votes`
--

LOCK TABLES `votes` WRITE;
/*!40000 ALTER TABLE `votes` DISABLE KEYS */;
INSERT INTO `votes` VALUES (1,'f2493105e50af0864066f5cf1509f4e7c14ad06317c49ee15d5612cac0507591','2026-10-19 20:28:28.000000',1,1),(2,'e93b2dc0dc66fd8eaaa5376f59ddb994fad24d7ed4512db4db27fe37de0f9ba4','2026-10-19 20:29:25.000000',2,2),(3,'46b857823adbf65a5a403baab1ea13979bc7c54f498f79a269d895389aff837f','2026-10-19 21:21:56.000000',3,3),(4,'f2925d17bf90b2d68657152e1d0286840584b7514b15581fdf915ff816a6a2a1','2026-10-20 13:19:12.000000',4,4),(5,'b4bf14fb71dcf78b717da4200d452fa2ef82b9b6a82824482975097bc9c2eb1d','2026-10-20 13:22:41.000000',5,5),(6,'f53d9b15e65178e5d7169c0af7e61170e8f824b2f57ff1c029e123e177508e30','2026-10-20 13:24:44.000000',6,6),(7,'9c749f6f1fd4cf54d3f9b7da06bb06c0ede2b356a431c27a2d5010f1a54f84fc','2026-10-21 22:39:35.000000',7,7);
/*!40000 ALTER TABLE `votes` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-10-21 23:40:08
