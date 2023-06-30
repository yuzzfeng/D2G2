-- Depending on the country, the xal_source XML tree is different and the paths and data that can be extracted varies

ALTER TABLE citydb.address
    ADD COLUMN xal_locality_name VARCHAR(256);

ALTER TABLE citydb.address
    ADD COLUMN xal_locality_type VARCHAR(256);

ALTER TABLE citydb.address
    ADD COLUMN xal_thoroughfare_name VARCHAR(256);

ALTER TABLE citydb.address
    ADD COLUMN xal_thoroughfare_type VARCHAR(256);

UPDATE citydb.address
SET xal_locality_name = (xpath('/xAL:AddressDetails/xAL:Country/xAL:Locality/xAL:LocalityName/text()', xal_source::xml,
                               ARRAY[ARRAY['xAL', 'urn:oasis:names:tc:ciq:xsdschema:xAL:2.0']]))[1] ;

UPDATE citydb.address
SET xal_locality_type = (xpath('/xAL:AddressDetails/xAL:Country/xAL:Locality/@Type', xal_source::xml,
                               ARRAY[ARRAY['xAL', 'urn:oasis:names:tc:ciq:xsdschema:xAL:2.0']]))[1] ;

UPDATE citydb.address
SET xal_thoroughfare_name = (xpath('/xAL:AddressDetails/xAL:Country/xAL:Locality/xAL:Thoroughfare/xAL:ThoroughfareName/text()', xal_source::xml,
                                   ARRAY[ARRAY['xAL', 'urn:oasis:names:tc:ciq:xsdschema:xAL:2.0']]))[1] ;

UPDATE citydb.address
SET xal_thoroughfare_type = (xpath('/xAL:AddressDetails/xAL:Country/xAL:Locality/xAL:Thoroughfare/@Type', xal_source::xml,
                                   ARRAY[ARRAY['xAL', 'urn:oasis:names:tc:ciq:xsdschema:xAL:2.0']]))[1] ;

--Due to sqlalchemy limitations, adding foreign keys is not possible, hence we do it here
CREATE TABLE citydb."citygml_osm_association" (
    "id" BIGINT NOT NULL PRIMARY KEY,
    "associated_citygmlid" TEXT NOT NULL,
    "associated_osmid" TEXT NOT NULL,
    "association_type" TEXT NOT NULL,
    "osm_type" TEXT NOT NULL
);

-- Based on their discussion https://github.com/3dcitydb/3dcitydb/issues/100 the UNIQUE constraint on the gmlid
-- column has been dropped. However, since for our use cases we will not perform any intertemporal analysis of CityGML
-- data, we can add this constraint aiming to improve Ontop's performance.
ALTER TABLE citydb.cityobject ADD CONSTRAINT unique_gmlid UNIQUE (gmlid);

-- PostgreSQL requires "cityobject"."gmlid" to be declared as UNIQUE before adding foreign key.
ALTER TABLE ONLY citydb."citygml_osm_association"
    ADD CONSTRAINT fk_association_gmlid FOREIGN KEY ("associated_citygmlid") REFERENCES citydb."cityobject" ("gmlid");
-- TODO: osm_id is NOT UNIQUE.
-- ALTER TABLE ONLY citydb."citygml_osm_association"
--     ADD CONSTRAINT fk_association_osmid FOREIGN KEY ("associated_osmid") REFERENCES public."classes" ("osm_id");

-- Add roof types
-- Based on https://www.citygmlwiki.org/images/f/fd/RoofTypeTypeAdV-trans.xml
CREATE TABLE citydb.roof_codelist (
    "name" TEXT NOT NULL PRIMARY KEY,
    "gmlid" TEXT NOT NULL,
    "description_de" TEXT NOT NULL,
    "description_en" TEXT NOT NULL
);

INSERT INTO citydb.roof_codelist VALUES
(1000, 'AdVid357', 'Flachdach', 'flat roof'),
(2100, 'AdVid358', 'Pultdach', 'pent roof'),
(2200, 'AdVid359', 'Versetztes Pultdach', 'offset pent roof'),
(3100, 'AdVid360', 'Satteldach', 'gabled roof'),
(3200, 'AdVid361', 'Walmdach', 'hipped roof'),
(3300, 'AdVid362', 'Krüppelwalmdach', 'half hipped roof'),
(3400, 'AdVid363', 'Mansardendach', 'mansard roof'),
(3500, 'AdVid364', 'Zeltdach', 'tented roof'),
(3600, 'AdVid365', 'Kegeldach', 'cone roof'),
(3700, 'AdVid366', 'Kuppeldach', 'copula roof'),
(3800, 'AdVid367', 'Sheddach', 'sawtooth roof'),
(3900, 'AdVid368', 'Bogendach', 'arch roof'),
(4000, 'AdVid369', 'Turmdach', 'pyramidal broach roof'),
(5000, 'AdVid370', 'Mischform', 'combination of roof forms'),
(9999, 'AdVid371', 'Sonstiges', 'other');

ALTER TABLE ONLY citydb.building
    ADD CONSTRAINT fk_roof_type FOREIGN KEY ("roof_type") REFERENCES citydb.roof_codelist ("name");


-- Add transformed geometry to WGS84 directly for surfaces in citydb table
-- ALTER TABLE citydb.surface_geometry
--     ADD COLUMN geometry_wgs84 GEOMETRY;

-- UPDATE citydb.surface_geometry
--     SET geometry_wgs84 = ST_TRANSFORM("geometry", 4326);

-- Add more spatial indexes for GEOGRAPHY datatype
CREATE INDEX surfacegeom_geog ON citydb.surface_geometry USING gist(CAST(ST_TRANSFORM("geometry",4326) AS GEOGRAPHY));
-- CREATE INDEX surfacegeom_geog2 ON citydb.surface_geometry USING gist(CAST("geometry_wgs84" AS GEOGRAPHY));
CREATE INDEX classes_geog ON public.entities USING gist(CAST(geom AS geography));


-- Add https://postgis.net/docs/reference.html#reference_sfcgal support for SCFGAL
create extension postgis_sfcgal;




INSERT INTO public.classes VALUES
    (1, 'AlcoholShop'),
    (2, 'AntiquesShop'),
    (3, 'ApartmentBuilding'),
    (4, 'ApplianceShop'),
    (5, 'ArtShop'),
    (6, 'ArtsCentre'),
    (7, 'ArtShop'),
    (8, 'Artwork'),
    (9, 'ATM'),
    (10, 'Attraction'),
    (11, 'BabyGoods'),
    (12, 'BagsShop'),
    (13, 'Bakery'),
    (14, 'Bank'),
    (15, 'Bar'),
    (16, 'BathroomFurnishing'),
    (17, 'BedShop'),
    (18, 'Bench'),
    (19, 'BicycleParking'),
    (20, 'BicycleRental'),
    (21, 'BicycleShop'),
    (22, 'Biergarten'),
    (23, 'BookmakerShop'),
    (24, 'BooksShop'),
    (25, 'Boutique'),
    (26, 'Bridge'),
    (27, 'Brownfield'),
    (28, 'Building'),
    (29, 'BuildingChapel'),
    (30, 'BuildingChurch'),
    (31, 'BuildingCommercial'),
    (32, 'BuildingDormitory'),
    (33, 'BuildingGarage'),
    (34, 'BuildingHospital'),
    (35, 'BuildingKiosk'),
    (36, 'BuildingOffice'),
    (37, 'BuildingResidential'),
    (38, 'BuildingRetail'),
    (39, 'BuildingSchool'),
    (40, 'BureauDeChange'),
    (41, 'BusStop'),
    (42, 'Butcher'),
    (43, 'Cafe'),
    (44, 'CameraShop'),
    (45, 'Carpet'),
    (46, 'CarRental'),
    (47, 'CarSharing'),
    (48, 'CarShop'),
    (49, 'CarWash'),
    (50, 'Casino'),
    (51, 'Cemetery'),
    (52, 'CharityShop'),
    (53, 'Cheese'),
    (54, 'Chemist'),
    (55, 'Childcare'),
    (56, 'Chocolate'),
    (57, 'Cinema'),
    (58, 'City'),
    (59, 'Clinic'),
    (60, 'Clock'),
    (61, 'Clothes'),
    (62, 'CoffeeShop'),
    (63, 'Collapsed'),
    (64, 'College'),
    (65, 'CommercialLanduse'),
    (66, 'CommunityCentre'),
    (67, 'Computer'),
    (68, 'Confectionery'),
    (69, 'Construction'),
    (70, 'Convenience'),
    (71, 'Copyshop'),
    (72, 'Cosmetics'),
    (73, 'Courthouse'),
    (74, 'Crafts'),
    (75, 'Courthouse'),
    (76, 'Cycling'),
    (77, 'Cycleway'),
    (78, 'Dance'),
    (79, 'Deli'),
    (80, 'Dentist'),
    (81, 'DepartmentStore'),
    (82, 'Detached'),
    (83, 'Doctors'),
    (84, 'DrinkingWater'),
    (85, 'DryCleaning'),
    (86, 'ElectronicsShop'),
    (87, 'Elevator'),
    (88, 'EstateAgent'),
    (89, 'Fabric'),
    (90, 'FashionShop'),
    (91, 'FastFood'),
    (92, 'FireStation'),
    (93, 'FitnessCentre'),
    (94, 'Footway'),
    (95, 'Fountain'),
    (96, 'FuneralDirectors'),
    (97, 'Furniture'),
    (98, 'Gallery'),
    (99, 'Gambling'),
    (100, 'Games'),
    (101, 'Garage'),
    (102, 'Garden'),
    (103, 'Gift'),
    (104, 'GiveWaySign'),
    (105, 'Glaziery'),
    (106, 'GovernmentBuilding'),
    (107, 'GrassLanduse'),
    (108, 'GreenGrocer'),
    (109, 'GritBin'),
    (110, 'GuestHouse'),
    (111, 'Hackerspace'),
    (112, 'Hairdresser'),
    (113, 'Hardware'),
    (114, 'HealthFood'),
    (115, 'HearingAids'),
    (116, 'Hifi'),
    (117, 'HighwayConstruction'),
    (118, 'HighwayCrossing'),
    (119, 'HighwayService'),
    (120, 'HobbyShop'),
    (121, 'HomeFurnishing'),
    (122, 'Hospital'),
    (123, 'Hostel'),
    (124, 'House'),
    (125, 'Housewares'),
    (126, 'IceCream'),
    (127, 'IndustrialLanduse'),
    (128, 'IndustrialProductionBuilding'),
    (129, 'InternetCafe'),
    (130, 'Jewelry'),
    (131, 'Kindergarten'),
    (132, 'Kiosk'),
    (133, 'KitchenShop'),
    (134, 'Laundry'),
    (135, 'Library'),
    (136, 'Lighting'),
    (137, 'LivingStreet'),
    (138, 'Locksmith'),
    (139, 'MassageShop'),
    (140, 'Marketplace'),
    (141, 'Meadow'),
    (142, 'MobilePhone'),
    (143, 'Monastery'),
    (144, 'Motorcycle'),
    (145, 'Museum'),
    (146, 'Music'),
    (147, 'MusicalInstrument'),
    (148, 'Newsagent'),
    (149, 'Nightclub'),
    (150, 'OpticianShop'),
    (151, 'Outdoor'),
    (152, 'Paint'),
    (153, 'Park'),
    (154, 'Parking'),
    (155, 'ParkingEntrance'),
    (156, 'ParkingSpace'),
    (157, 'Pastry'),
    (158, 'Path'),
    (159, 'PedestrianUse'),
    (160, 'Perfumery'),
    (161, 'PetShop'),
    (162, 'Pharmacy'),
    (163, 'Photo'),
    (164, 'PicnicSite'),
    (165, 'Pitch'),
    (166, 'Platform'),
    (167, 'Playground'),
    (168, 'Police'),
    (169, 'PostBox'),
    (170, 'PostOffice'),
    (171, 'Pottery'),
    (172, 'Pub'),
    (173, 'PublicBuilding'),
    (174, 'RailwayLanduse'),
    (175, 'Recycling'),
    (176, 'Religious'),
    (177, 'Rent'),
    (178, 'ResidentialHighway'),
    (179, 'ResidentialLanduse'),
    (180, 'Restaurant'),
    (181, 'RetailLanduse'),
    (182, 'Ruins'),
    (183, 'Sauna'),
    (184, 'Scrub'),
    (185, 'SecondaryHighway'),
    (186, 'SecondaryLink'),
    (187, 'SecondHand'),
    (188, 'Service'),
    (189, 'Shed'),
    (190, 'Shelter'),
    (191, 'Shoes'),
    (192, 'Shop'),
    (193, 'SocialFacility'),
    (194, 'SpeedCamera'),
    (195, 'SportsCentre'),
    (196, 'SportsShop'),
    (197, 'Stationery'),
    (198, 'Steps'),
    (199, 'StreetLamp'),
    (200, 'Stripclub'),
    (201, 'Studio'),
    (202, 'Supermarket'),
    (203, 'Synagogue'),
    (204, 'Tailor'),
    (205, 'Tanning'),
    (206, 'Taxi'),
    (207, 'Tea'),
    (208, 'Telecommunication'),
    (209, 'Telephone'),
    (210, 'Terrace'),
    (211, 'TertiaryHighway'),
    (212, 'Ticket'),
    (213, 'Tobacco'),
    (214, 'Toilets'),
    (215, 'TourismInformation'),
    (216, 'TourismThing'),
    (217, 'Townhall'),
    (218, 'Toys'),
    (219, 'Track'),
    (220, 'TrafficSignals'),
    (221, 'TrainStation'),
    (222, 'TravelAgency'),
    (223, 'Tree'),
    (224, 'TreeRow'),
    (225, 'TurningCircle'),
    (226, 'University'),
    (227, 'UnclassifiedHighway'),
    (228, 'Vacant'),
    (229, 'VendingMachine'),
    (230, 'Veterinary'),
    (231, 'VideoGames'),
    (232, 'VideoShop'),
    (233, 'Viewpoint'),
    (234, 'VillageGreen'),
    (235, 'WasteBasket'),
    (236, 'WasteDisposal'),
    (237, 'Watches'),
    (238, 'Water'),
    (239, 'Wine'),
    (240, 'Wood');


UPDATE public."association_osm" SET osm_id= -osm_id WHERE association_osm.osm_id<0;

--DELETE FROM public."association_osm" WHERE osm_id =100000000000014897


DELETE FROM public."entities"
WHERE ctid NOT IN (
   SELECT min(ctid)                    -- ctid is NOT NULL by definition
   FROM public."entities"
   GROUP BY osm_id);  -- list columns defining duplicates

ALTER TABLE public."entities" ADD CONSTRAINT unique_osmid UNIQUE ("osm_id");
ALTER TABLE public."classes" ADD CONSTRAINT unique_classid UNIQUE ("class_id");

ALTER TABLE ONLY public."entities"
    ADD CONSTRAINT prk_osmid PRIMARY KEY ("osm_id");

ALTER TABLE ONLY public."classes"
    ADD CONSTRAINT prk_classid PRIMARY KEY ("class_id");

ALTER TABLE public.association_osm ADD COLUMN id SERIAL PRIMARY KEY;

-- Remove any unknown records remaining
DELETE FROM public."association_osm"
WHERE osm_id NOT IN (
    SELECT entities.osm_id                    -- ctid is NOT NULL by definition
    FROM public."entities");  -- list columns defining duplicates

ALTER TABLE ONLY public.association_osm
    ADD CONSTRAINT fk_association_osm_entities FOREIGN KEY ("osm_id") REFERENCES public."entities" ("osm_id");

ALTER TABLE ONLY public.association_osm
    ADD CONSTRAINT fk_association_osm_classes FOREIGN KEY ("class_id") REFERENCES public."classes" ("class_id");

-- It does not actually hold, it cannot be added
ALTER TABLE ONLY citydb."citygml_osm_association"
    ADD CONSTRAINT fk_association_osmid FOREIGN KEY ("associated_osmid") REFERENCES public."entities" ("osm_id");