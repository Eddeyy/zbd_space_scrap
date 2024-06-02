CREATE TABLE Employee (
  ID              BIGSERIAL NOT NULL, 
  Name            varchar(32) NOT NULL, 
  Surname         varchar(32) NOT NULL, 
  DateOfBirth     date NOT NULL, 
  JoinDate        date NOT NULL, 
  HeartRate       int2 NOT NULL, 
  Health          int2 NOT NULL,
  ShipID          int8 NOT NULL, 
  Rank            varchar(32) NOT NULL,
  Experience      int8 NOT NULL,
  PRIMARY KEY (ID));
CREATE TABLE Ship (
  ID            BIGSERIAL NOT NULL, 
  MaxLoad       numeric(10, 2) NOT NULL, 
  MaxFuel       numeric(10, 2) NOT NULL, 
  MaxVolume     numeric(10, 2) NOT NULL, 
  Load          numeric(10, 2) NOT NULL, 
  Fuel          numeric(10, 2) NOT NULL, 
  Volume        numeric(10, 2) NOT NULL, 
  CoordX        int4 NOT NULL, 
  CoordY        int4 NOT NULL, 
  CoordZ        int4 NOT NULL, 
  PRIMARY KEY (ID));
CREATE TABLE Scrap (
  ID            BIGSERIAL NOT NULL, 
  Name          varchar(32) NOT NULL,
  Weight        numeric(10, 2) NOT NULL, 
  Value         numeric(8, 2), 
  Volume        int4, 
  ShipID        int8, 
  EmployeeID    int8 NOT NULL,
  ExpeditionID  int8 NOT NULL,
  MoonName      varchar(32),
  PRIMARY KEY (ID));
CREATE TABLE Moon (
  Name           varchar(32) NOT NULL, 
  CoordX         int4 NOT NULL, 
  CoordY         int4 NOT NULL, 
  CoordZ         int4 NOT NULL, 
  Temperature    int2, 
  DangerLevel    int4, 
  Weather        varchar(16) NOT NULL, 
  PRIMARY KEY (Name));
CREATE TABLE Tools (
  ID         BIGSERIAL NOT NULL, 
  Name       varchar(32) NOT NULL, 
  Durability numeric(3, 2) NOT NULL, 
  Energy     numeric(3, 2), 
  ShipID     int8 NOT NULL, 
  PRIMARY KEY (ID));
CREATE TABLE Expedition (
  ID                  BIGSERIAL NOT NULL, 
  DateOfDeparture     date NOT NULL, 
  DateOfReturn        date, 
  TotalScrap          numeric(8, 2), 
  ShipID              int8 NOT NULL, 
  MoonName            varchar(32) NOT NULL, 
  PRIMARY KEY (ID));
CREATE TABLE Ship_Engine (
  ID     SERIAL NOT NULL, 
  State  varchar(32) NOT NULL, 
  Power  numeric(3, 2) NOT NULL, 
  ShipID int8 NOT NULL, 
  PRIMARY KEY (ID));
CREATE TABLE Rank (
  RankName      varchar(32) NOT NULL, 
  RequiredScore int8 NOT NULL, 
  PRIMARY KEY (RankName));
CREATE TABLE Weather (
  WeatherName varchar(16) NOT NULL, 
  PRIMARY KEY (WeatherName));
CREATE TABLE Material (
  Name    varchar(16) NOT NULL, 
  Density numeric(4, 2) NOT NULL, 
  Value   numeric(4, 2) NOT NULL, 
  PRIMARY KEY (Name));
CREATE TABLE Employee_Expedition (
  EmployeeID   int8 NOT NULL, 
  ExpeditionID int8 NOT NULL, 
  PRIMARY KEY (EmployeeID, 
  ExpeditionID));
CREATE TABLE Material_Scrap (
  MaterialName varchar(16) NOT NULL, 
  ScrapID      int8 NOT NULL, 
  PRIMARY KEY (MaterialName, 
  ScrapID));
CREATE TABLE Scrap_Name (
  Name  varchar(32) NOT NULL,
  PRIMARY KEY (Name));
CREATE TABLE Excavation_Event (
  ExpeditionID  BIGINT,
  EmployeeID    BIGINT,
  EventCount    int2
);
ALTER TABLE Employee ADD CONSTRAINT FKEmployee772082 FOREIGN KEY (ShipID) REFERENCES Ship (ID);
ALTER TABLE Scrap ADD CONSTRAINT FKScrap172778 FOREIGN KEY (ShipID) REFERENCES Ship (ID);
ALTER TABLE Tools ADD CONSTRAINT FKTools894302 FOREIGN KEY (ShipID) REFERENCES Ship (ID);
ALTER TABLE Expedition ADD CONSTRAINT FKExpedition353510 FOREIGN KEY (ShipID) REFERENCES Ship (ID);
ALTER TABLE Expedition ADD CONSTRAINT FKExpedition210732 FOREIGN KEY (ScrapID) REFERENCES Scrap (ID);
ALTER TABLE Scrap ADD CONSTRAINT FKScrap639576 FOREIGN KEY (EmployeeID) REFERENCES Employee (ID);
ALTER TABLE Scrap ADD CONSTRAINT FKScrapExp420 FOREIGN KEY (ExpeditionID) REFERENCES Expedition (ID);
ALTER TABLE Scrap ADD CONSTRAINT FKScrapName FOREIGN KEY (Name) REFERENCES Scrap_Name (Name);
ALTER TABLE Ship_Engine ADD CONSTRAINT FKShip_engine806708 FOREIGN KEY (ShipID) REFERENCES Ship (ID);
ALTER TABLE Employee ADD CONSTRAINT FKEmployee873402 FOREIGN KEY (Rank) REFERENCES Rank (RankName);
ALTER TABLE Scrap ADD CONSTRAINT FKScrap514826 FOREIGN KEY (MoonName) REFERENCES Moon (Name);
ALTER TABLE Moon ADD CONSTRAINT FKMoon54772 FOREIGN KEY (Weather) REFERENCES Weather (WeatherName);
ALTER TABLE Expedition ADD CONSTRAINT FKExpedition304441 FOREIGN KEY (MoonName) REFERENCES Moon (Name);
ALTER TABLE Employee_Expedition ADD CONSTRAINT FKEmployee_E487929 FOREIGN KEY (EmployeeID) REFERENCES Employee (ID);
ALTER TABLE Employee_Expedition ADD CONSTRAINT FKEmployee_E230357 FOREIGN KEY (ExpeditionID) REFERENCES Expedition (ID);
ALTER TABLE Material_Scrap ADD CONSTRAINT FKMaterial_S903034 FOREIGN KEY (MaterialName) REFERENCES Material (Name);
ALTER TABLE Material_Scrap ADD CONSTRAINT FKMaterial_S933359 FOREIGN KEY (ScrapID) REFERENCES Scrap (ID);
