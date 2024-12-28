-- MySQL Script generated by MySQL Workbench
-- Sat Dec 28 03:46:02 2024
-- Model: New Model    Version: 1.0
-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema SmartParking
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema SmartParking
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `SmartParking` DEFAULT CHARACTER SET utf8 ;
USE `SmartParking` ;

-- -----------------------------------------------------
-- Table `SmartParking`.`users`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `SmartParking`.`users` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `user_name` VARCHAR(255) NOT NULL,
  `email` VARCHAR(45) NOT NULL,
  `password` VARCHAR(255) NOT NULL,
  `role` ENUM("admin", "driver", "manager") NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `idx_email` (`email`), -- Index for faster lookup by email
  INDEX `idx_user_name` (`user_name`), -- Index for faster lookup by user_name
  INDEX `idx_role` (`role`) -- Index for faster filtering by role
  )
  ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `SmartParking`.`driver`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `SmartParking`.`driver` (
  `license` VARCHAR(20) NOT NULL,
  `id` INT NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `id`
    FOREIGN KEY (`id`)
    REFERENCES `SmartParking`.`users` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
    INDEX `idx_license_id` (`license`, `id`)
    )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `SmartParking`.`parking_lot`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `SmartParking`.`parking_lot` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `manager_id` INT NULL,
  `lot_name` VARCHAR(45) NOT NULL,
  `location` VARCHAR(255) NOT NULL,
  `capacity` INT NOT NULL,
  `pricing_structure` INT NOT NULL,
  `start_peek_time` INT NULL,
  `end_peek_time` INT NULL,
  `price_multiplier` INT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `ManagerLotID`
    FOREIGN KEY (`manager_id`)
    REFERENCES `SmartParking`.`users` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
    INDEX `idx_manager_id` (`manager_id`), -- Index for manager_id for faster lookups
  INDEX `idx_lot_name` (`lot_name`), -- Index for lot_name for faster filtering
  INDEX `idx_location` (`location`), -- Index for location for faster filtering
  INDEX `idx_capacity` (`capacity`), -- Index for capacity for faster sorting or filtering
  INDEX `idx_pricing_structure` (`pricing_structure`), -- Index for pricing_structure for faster filtering
  INDEX `idx_manager_lot_name` (`manager_id`, `lot_name`), -- Composite index for manager_id and lot_name
  INDEX `idx_manager_location` (`manager_id`, `location`) -- Composite index for manager_id and location
  )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `SmartParking`.`spot`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `SmartParking`.`spot` (
  `lot_id` INT NOT NULL,
  `spot_id` INT AUTO_INCREMENT,
  `status` ENUM("occupied", "available", "reserved") NOT NULL,
  `type` ENUM("regular", "disabled", "EV") NOT NULL,
  PRIMARY KEY (`spot_id`),
  CONSTRAINT `LotID`
    FOREIGN KEY (`lot_id`)
    REFERENCES `SmartParking`.`parking_lot` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
    INDEX `idx_lot_id` (`lot_id`), -- Index for lot_id for faster lookup
  INDEX `idx_status` (`status`), -- Index for status for faster filtering
  INDEX `idx_type` (`type`), -- Index for type if frequently used for filtering
  INDEX `idx_lot_status` (`lot_id`, `status`), -- Composite index for lot_id and status
  INDEX `idx_lot_type` (`lot_id`, `type`) -- Composite index for lot_id and type)
  )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `SmartParking`.`reservation`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `SmartParking`.`reservation` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `spot_id` INT NOT NULL,
  `lot_id` INT NOT NULL,
  `driver_id` INT NOT NULL,
  `reservation_status` ENUM("Accepted", "Rejected", "Pending") NOT NULL,
  `reservation_hours` INT NOT NULL,
  `reservation_time` DATETIME NOT NULL,
  `reservation_fee`  float,
  PRIMARY KEY (`id`),
  CONSTRAINT `Spot`
    FOREIGN KEY (`spot_id`)
    REFERENCES `SmartParking`.`spot` (`spot_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `Lot`
    FOREIGN KEY (`lot_id`)
    REFERENCES `SmartParking`.`parking_lot` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `Driver`
    FOREIGN KEY (`driver_id`)
    REFERENCES `SmartParking`.`driver` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
    INDEX `idx_spot_id` (`spot_id`), -- Index for faster lookup by spot_id
  INDEX `idx_lot_id` (`lot_id`), -- Index for faster lookup by lot_id
  INDEX `idx_driver_id` (`driver_id`), -- Index for faster lookup by driver_id
  INDEX `idx_reservation_status` (`reservation_status`), -- Index for faster filtering by reservation status
  INDEX `idx_reservation_time` (`reservation_time`), -- Index for faster sorting or filtering by reservation time
  INDEX `idx_spot_reservation_time` (`spot_id`, `reservation_time`) -- Composite index for faster lookup by spot_id and reservation_time
  )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `SmartParking`.`penalities`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `SmartParking`.`penalities` (
  `reservation_id` INT NOT NULL,
  `penality_fee` FLOAT NULL,
  PRIMARY KEY (`reservation_id`),
  CONSTRAINT `ReservationID`
    FOREIGN KEY (`reservation_id`)
    REFERENCES `SmartParking`.`reservation` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
     INDEX `idx_reservation_id` (`reservation_id`) -- Explicit index on reservation_id
     )
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;