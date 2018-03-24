drop schema if exists carschema cascade;
create schema carschema;
set search_path to carschema;

-- As per https://piazza.com/class/jc8j5fv9n7e39n?cid=742 we obey the schema
-- implicity in Car-data.txt

--TODO: Need to worry about UPDATE or DELETE? Realistically we should, but
-- who knows?

-- TODO: Dealing with only being able to modify CONFIRMED reservations
-- TODO: 1) Should we also have the constraint that the number of customers for a given reservation should not exceed the vehicle's capacity?
-- TODO: 2) Should we also have the constraint that a vehicle cannot be in 2 reservations whose dates overlap?

create domain resvStatus as varchar(9)
  default 'Confirmed'
  check (value in ('Confirmed', 'Ongoing', 'Completed', 'Cancelled'));

create table Model (
  id INTEGER PRIMARY KEY,
  name VARCHAR NOT NULL,
  type VARCHAR NOT NULL,
  model_num INTEGER NOT NULL UNIQUE,
  capacity INTEGER NOT NULL
);

create table RentalStation (
  id INTEGER PRIMARY KEY, -- This is the rental station id
  name VARCHAR NOT NULL,
  address VARCHAR NOT NULL,
  area_code CHAR(6) NOT NULL,
  city VARCHAR NOT NULL
);

create table Car (
  id INTEGER PRIMARY KEY,
  license_plate VARCHAR(7) NOT NULL UNIQUE, -- Unique as per 
  rental_station_code INTEGER NOT NULL,
  model_id INTEGER NOT NULL,
  FOREIGN KEY (rental_station_code) REFERENCES RentalStation,
  FOREIGN KEY (model_id) REFERENCES Model
);

create table Reservation(
  id INTEGER PRIMARY KEY,
  from_res DATE NOT NULL,
  to_res DATE NOT NULL,
  car INTEGER NOT NULL,
  old_details INTEGER UNIQUE, -- Either NULL, or changed once
  resvStatus NOT NULL,
  FOREIGN KEY (car) REFERENCES Car,
  FOREIGN KEY (old_details) REFERENCES Reservation,
  check (from_res <= to_res) -- TODO: Not sure if needed
);

-- TODO: GRRRR. PSQL create assertion and checks are not yet fully implemented.
--create assertion change check (NOT EXISTS (SELECT * FROM Reservation r 
--                                    WHERE r.old_details IS NOT NULL AND 
--                                      EXISTS (SELECT * FROM Reservation r2 
--                                              WHERE r2.id = r.old_details 
--                                              AND r2.old_details IS NOT NULL)));

-- According to @734 "E-mail is used as proxy for customer ID in this schema."
-- I think this is a terrible idea (it makes having customer email mandatory,
-- requires massive cascading updates if the customer ever changes their email,
-- etc... but I defer to the TAs prescribed design)
create table Customer(
  name VARCHAR NOT NULL,
  age INTEGER NOT NULL,
  email VARCHAR PRIMARY KEY,
  check (age >= 17)
);

-- Table links all customers to their reservation
create table Customer_Reservation(
  cust_id VARCHAR NOT NULL,
  res_id INTEGER NOT NULL,
  FOREIGN KEY (res_id) REFERENCES Reservation,
  FOREIGN KEY (cust_id) REFERENCES Customer,
  UNIQUE(res_id, cust_id)
);
