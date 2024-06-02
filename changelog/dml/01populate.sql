INSERT INTO weather (weathername) VALUES ('Rainy');
INSERT INTO weather (weathername)  VALUES ('Foggy');
INSERT INTO weather (weathername)  VALUES ('Stormy');
INSERT INTO weather (weathername)  VALUES ('Eclipsed');
INSERT INTO weather (weathername)  VALUES ('None');

INSERT INTO rank (rankname, requiredscore) VALUES ('Intern', 0);
INSERT INTO rank (rankname, requiredscore) VALUES ('Part-Timer', 50);
INSERT INTO rank (rankname, requiredscore) VALUES ('Employee', 100);
INSERT INTO rank (rankname, requiredscore) VALUES ('Leader', 200);
INSERT INTO rank (rankname, requiredscore) VALUES ('Boss', 500);

INSERT INTO ship (id, maxload, maxfuel, maxvolume, load, fuel, volume, coordx, coordy, coordz) VALUES (default, 2000, 600, 5000, 200, 500, 2000, 21, 37, 60);
INSERT INTO ship (id, maxload, maxfuel, maxvolume, load, fuel, volume, coordx, coordy, coordz) VALUES (default, 2000, 100, 5000, 100, 100, 2000, 21, 37, 60);
INSERT INTO ship (id, maxload, maxfuel, maxvolume, load, fuel, volume, coordx, coordy, coordz) VALUES (default, 2000, 500, 5000, 400, 200, 2000, 21, 37, 60);
INSERT INTO ship (id, maxload, maxfuel, maxvolume, load, fuel, volume, coordx, coordy, coordz) VALUES (default, 2000, 1000, 5000, 500, 1000, 2000, 21, 37, 60);
INSERT INTO ship (id, maxload, maxfuel, maxvolume, load, fuel, volume, coordx, coordy, coordz) VALUES (default, 4000, 1000, 6000, 1000, 600, 1000, 2000, 3000, 4000);
INSERT INTO ship (id, maxload, maxfuel, maxvolume, load, fuel, volume, coordx, coordy, coordz) VALUES (default, 1000, 1500, 700, 800, 200, 500, 1234, 8765, 9021);


INSERT INTO ship_engine (id, state, power, shipid) VALUES (default, 'Working', 3, 1);
INSERT INTO ship_engine (id, state, power, shipid) VALUES (default, 'Working', 3, 1);
INSERT INTO ship_engine (id, state, power, shipid) VALUES (default, 'Stopped', 9, 2);
INSERT INTO ship_engine (id, state, power, shipid) VALUES (default, 'Working', 1, 3);
INSERT INTO ship_engine (id, state, power, shipid) VALUES (default, 'Working', 1, 3);
INSERT INTO ship_engine (id, state, power, shipid) VALUES (default, 'Working', 3, 4);
INSERT INTO ship_engine (id, state, power, shipid) VALUES (default, 'Working', 3, 5);
INSERT INTO ship_engine (id, state, power, shipid) VALUES (default, 'Working', 3, 6);

INSERT INTO tools (id, name, durability, energy, shipid) VALUES (default, 'Wrench', 2, 1, 3);
INSERT INTO tools (id, name, durability, energy, shipid) VALUES (default, 'Ladder', 9, 0, 2);
INSERT INTO tools (id, name, durability, energy, shipid) VALUES (default, 'Wrench', 3, 1, 2);


INSERT INTO employee (id, name, surname, dateofbirth, joindate, heartrate, shipid, rank) VALUES (default, 'Maciej', 'Tomczuk', to_date('16-10-2001', 'DD-MM-YYYY'), to_date('20-12-2023', 'DD-MM-YYYY'), 120, 1, 'Intern');
INSERT INTO employee (id, name, surname, dateofbirth, joindate, heartrate, shipid, rank) VALUES (default, 'Adam', 'Wysocki', to_date('4-5-2001', 'DD-MM-YYYY'), to_date('20-12-2023', 'DD-MM-YYYY'), 105, 1, 'Boss');

INSERT INTO employee (id, name, surname, dateofbirth, joindate, heartrate, shipid, rank) VALUES (default, 'Bartosz', 'Słomowicz', to_date('12-5-2001', 'DD-MM-YYYY'), to_date('20-12-2023', 'DD-MM-YYYY'), 160, 2, 'Leader');
INSERT INTO employee (id, name, surname, dateofbirth, joindate, heartrate, shipid, rank) VALUES (default, 'Szymon', 'Ludwiniak', to_date('15-12-2000', 'DD-MM-YYYY'), to_date('21-12-2023', 'DD-MM-YYYY'), 95, 2, 'Leader');

INSERT INTO employee (id, name, surname, dateofbirth, joindate, heartrate, shipid, rank) VALUES (default, 'Arkadiusz', 'Pytka', to_date('12-5-2001', 'DD-MM-YYYY'), to_date('20-12-2023', 'DD-MM-YYYY'), 160, 3, 'Boss');
INSERT INTO employee (id, name, surname, dateofbirth, joindate, heartrate, shipid, rank) VALUES (default, 'Dmitry', 'Goltstein', to_date('15-12-2000', 'DD-MM-YYYY'), to_date('21-12-2023', 'DD-MM-YYYY'), 95, 3, 'Boss');


INSERT INTO material (name, density, value) VALUES ('Lead', 12, 0.2);
INSERT INTO material (name, density, value) VALUES ('Gold', 14, 5);
INSERT INTO material (name, density, value) VALUES ('Steel', 6, 3.5);
INSERT INTO material (name, density, value) VALUES ('Aluminium', 3.5, 2);

INSERT INTO moon (name, coordx, coordy, coordz, temperature, dangerlevel, weather) VALUES ('Sigma', 213, 973, 204, 25, 100, 'None');
INSERT INTO moon (name, coordx, coordy, coordz, temperature, dangerlevel, weather) VALUES ('Tau', 1000, 1111, 60, 0, 5, 'Rainy');
INSERT INTO moon (name, coordx, coordy, coordz, temperature, dangerlevel, weather) VALUES ('Beta', 21, 37, 60, 0, 5, 'None');

INSERT INTO Scrap_Name (name) VALUES ('Axle');
INSERT INTO Scrap_Name (name) VALUES ('Apparatus');
INSERT INTO Scrap_Name (name) VALUES ('Big bolt');
INSERT INTO Scrap_Name (name) VALUES ('Bottles');
INSERT INTO Scrap_Name (name) VALUES ('Brass bell');
INSERT INTO Scrap_Name (name) VALUES ('Chemical jug');
INSERT INTO Scrap_Name (name) VALUES ('Clown horn');