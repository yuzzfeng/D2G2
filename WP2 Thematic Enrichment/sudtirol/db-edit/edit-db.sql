-- Add LoD1 CityGML column to the table
-- ALTER TABLE construction_01k
--     ADD COLUMN geom3d GEOMETRY;
--
-- UPDATE construction_01k
-- SET geom3d =
--         CASE
--             WHEN ct1a_alt IS NOT NULL THEN ST_EXTRUDE(ct1a_shape, 0, 0, ct1a_alt)
--             ELSE NULL
--         END;

-- Add official Italian Public Administration data
ALTER TABLE municipalities
    ADD COLUMN istat_code_controlled TEXT;

WITH latest_istat_updates AS (
    SELECT DISTINCT ON (istat_code)
    *
FROM controlled_istat_codes
ORDER BY istat_code, date_last_change DESC)
UPDATE municipalities
SET istat_code_controlled=latest_istat_updates.controlled_istat_code
    FROM latest_istat_updates
WHERE municipalities.istat_code=latest_istat_updates.istat_code;

-- Add table with LGD classes and class id-s
ALTER TABLE public.classes DROP COLUMN id;
INSERT INTO public.classes VALUES
                               ('AerialwayGoods'),
                               ('AerialwayStation'),
                               ('AerialwayThing'),
                               ('AlcoholShop'),
                               ('AntiquesShop'),
                               ('ApartmentBuilding'),
                               ('ApplianceShop'),
                               ('ArtShop'),
                               ('ArtsCentre'),
                               ('ArtShop'),
                               ('Artwork'),
                               ('ATM'),
                               ('Attraction'),
                               ('BabyGoods'),
                               ('BagsShop'),
                               ('Bakery'),
                               ('Bank'),
                               ('Bar'),
                               ('BathroomFurnishing'),
                               ('BeautyShop'),
                               ('BedShop'),
                               ('Bench'),
                               ('BicycleParking'),
                               ('BicycleRental'),
                               ('BicycleShop'),
                               ('Biergarten'),
                               ('BookmakerShop'),
                               ('BooksShop'),
                               ('Boutique'),
                               ('Bridge'),
                               ('Bridleway'),
                               ('Brownfield'),
                               ('Building'),
                               ('BuildingBarn'),
                               ('BuildingBunker'),
                               ('BuildingCabin'),
                               ('BuildingChapel'),
                               ('BuildingChurch'),
                               ('BuildingCommercial'),
                               ('BuildingDormitory'),
                               ('BuildingGarage'),
                               ('BuildingHospital'),
                               ('BuildingHut'),
                               ('BuildingKiosk'),
                               ('BuildingOffice'),
                               ('BuildingResidential'),
                               ('BuildingRetail'),
                               ('BuildingSchool'),
                               ('BureauDeChange'),
                               ('BusStop'),
                               ('Butcher'),
                               ('CableCar'),
                               ('Cafe'),
                               ('CameraShop'),
                               ('Carpet'),
                               ('CarRental'),
                               ('CarSharing'),
                               ('CarShop'),
                               ('CarWash'),
                               ('Casino'),
                               ('Cemetery'),
                               ('ChairLift'),
                               ('CharityShop'),
                               ('Cheese'),
                               ('Chemist'),
                               ('Childcare'),
                               ('Chocolate'),
                               ('Cinema'),
                               ('City'),
                               ('Clinic'),
                               ('Clock'),
                               ('Clothes'),
                               ('CoffeeShop'),
                               ('Collapsed'),
                               ('College'),
                               ('CommercialLanduse'),
                               ('CommunityCentre'),
                               ('Computer'),
                               ('Confectionery'),
                               ('Construction'),
                               ('Convenience'),
                               ('Copyshop'),
                               ('Cosmetics'),
                               ('Courthouse'),
                               ('Crafts'),
                               ('Courthouse'),
                               ('Cycling'),
                               ('Cycleway'),
                               ('Dance'),
                               ('Deli'),
                               ('Dentist'),
                               ('DepartmentStore'),
                               ('Detached'),
                               ('Doctors'),
                               ('DragLift'),
                               ('DrinkingWater'),
                               ('DryCleaning'),
                               ('ElectronicsShop'),
                               ('Elevator'),
                               ('EstateAgent'),
                               ('Fabric'),
                               ('FashionShop'),
                               ('FastFood'),
                               ('FireStation'),
                               ('FitnessCentre'),
                               ('Florist'),
                               ('Footway'),
                               ('Fountain'),
                               ('Fraternity'),
                               ('FuneralDirectors'),
                               ('Furniture'),
                               ('Gallery'),
                               ('Gambling'),
                               ('Games'),
                               ('Garage'),
                               ('Garden'),
                               ('Gift'),
                               ('GiveWaySign'),
                               ('Glaziery'),
                               ('GovernmentBuilding'),
                               ('GrassLanduse'),
                               ('Greengrocer'),
                               ('GritBin'),
                               ('GuestHouse'),
                               ('Hackerspace'),
                               ('Hairdresser'),
                               ('Hardware'),
                               ('HealthFood'),
                               ('HearingAids'),
                               ('Hifi'),
                               ('HighwayConstruction'),
                               ('HighwayCrossing'),
                               ('HighwayPrimaryLink'),
                               ('HighwaySecondaryLink'),
                               ('HighwayService'),
                               ('HighwayTertiaryLink'),
                               ('HobbyShop'),
                               ('HomeFurnishing'),
                               ('Hospital'),
                               ('Hostel'),
                               ('Hotel'),
                               ('House'),
                               ('Housewares'),
                               ('IceCream'),
                               ('IndustrialLanduse'),
                               ('IndustrialProductionBuilding'),
                               ('InternetCafe'),
                               ('Jewelry'),
                               ('Kindergarten'),
                               ('Kiosk'),
                               ('KitchenShop'),
                               ('LanguageSchool'),
                               ('Laundry'),
                               ('Leisure'),
                               ('Library'),
                               ('Lighting'),
                               ('LivingStreet'),
                               ('Locksmith'),
                               ('MassageShop'),
                               ('Marketplace'),
                               ('Meadow'),
                               ('MiniRoundabout'),
                               ('MixedLift'),
                               ('MobilePhone'),
                               ('Monastery'),
                               ('Motorcycle'),
                               ('Motorway'),
                               ('Museum'),
                               ('Music'),
                               ('MusicalInstrument'),
                               ('NaturalThing'),
                               ('Newsagent'),
                               ('Nightclub'),
                               ('OpticianShop'),
                               ('Outdoor'),
                               ('Paint'),
                               ('Park'),
                               ('Parking'),
                               ('ParkingEntrance'),
                               ('ParkingSpace'),
                               ('Pastry'),
                               ('Path'),
                               ('PedestrianUse'),
                               ('Perfumery'),
                               ('PetShop'),
                               ('Pharmacy'),
                               ('Photo'),
                               ('PicnicSite'),
                               ('Pitch'),
                               ('PlaceOfWorship'),
                               ('Platform'),
                               ('Playground'),
                               ('Police'),
                               ('PostBox'),
                               ('PostOffice'),
                               ('Pottery'),
                               ('PrimaryHighway'),
                               ('ProposedHighway'),
                               ('Pub'),
                               ('PublicBuilding'),
                               ('Road'),
                               ('Raceway'),
                               ('RailwayLanduse'),
                               ('Recycling'),
                               ('Religious'),
                               ('Rent'),
                               ('ResidentialHighway'),
                               ('ResidentialLanduse'),
                               ('RestArea'),
                               ('Restaurant'),
                               ('RetailLanduse'),
                               ('Ruins'),
                               ('Sauna'),
                               ('School'),
                               ('Scrub'),
                               ('SecondaryHighway'),
                               ('SecondaryLink'),
                               ('SecondHand'),
                               ('Service'),
                               ('Shed'),
                               ('Shelter'),
                               ('Shoes'),
                               ('Shop'),
                               ('SocialFacility'),
                               ('SpeedCamera'),
                               ('SportsCentre'),
                               ('SportsShop'),
                               ('Stationery'),
                               ('Steps'),
                               ('StreetLamp'),
                               ('Stripclub'),
                               ('Studio'),
                               ('Supermarket'),
                               ('Synagogue'),
                               ('Tailor'),
                               ('Tanning'),
                               ('Tattoo'),
                               ('Taxi'),
                               ('Tea'),
                               ('Telecommunication'),
                               ('Telephone'),
                               ('Terrace'),
                               ('TertiaryHighway'),
                               ('Ticket'),
                               ('Tobacco'),
                               ('Toilets'),
                               ('TourismInformation'),
                               ('TourismThing'),
                               ('Townhall'),
                               ('Toys'),
                               ('Track'),
                               ('TrafficSignals'),
                               ('TrainStation'),
                               ('TravelAgency'),
                               ('Tree'),
                               ('TreeRow'),
                               ('Trunk'),
                               ('TrunkLink'),
                               ('TurningCircle'),
                               ('University'),
                               ('UnclassifiedHighway'),
                               ('Vacant'),
                               ('VendingMachine'),
                               ('Veterinary'),
                               ('VideoGames'),
                               ('VideoShop'),
                               ('Viewpoint'),
                               ('VillageGreen'),
                               ('WasteBasket'),
                               ('WasteDisposal'),
                               ('Watches'),
                               ('Water'),
                               ('Wine'),
                               ('Wood');
ALTER TABLE public.classes ADD COLUMN class_id SERIAL PRIMARY KEY;


-- Clean up entities table and add constraints
-- Clean up some weird id-s
UPDATE public."association_osm" SET osm_id= -osm_id WHERE association_osm.osm_id<0;

-- DEPRECATED: ctid is INEFFICIENT for large tables
-- Remove duplicates based on osm_id
DELETE FROM public."entities"
WHERE ctid NOT IN (
    SELECT min(ctid)                    -- ctid is NOT NULL by definition
    FROM public."entities"
    GROUP BY osm_id);  -- list columns defining duplicates

-- Remove duplicates based on osm_id
DELETE
FROM public.entities
WHERE ctid IN
      (
          SELECT ctid
          FROM(
                  SELECT
                      *,
                      ctid,
                      row_number() OVER (PARTITION BY osm_id ORDER BY ctid)
                  FROM public.entities
              )s
          WHERE row_number >= 2
      );
DROP

-- Add respective constraints and primary keys
ALTER TABLE public."entities" ADD CONSTRAINT unique_osmid UNIQUE ("osm_id");
ALTER TABLE ONLY public."entities"
    ADD CONSTRAINT prk_osmid PRIMARY KEY ("osm_id");

-- Reshape linkage table
-- Add constraints to linkage table
ALTER TABLE public.association_osm ADD COLUMN id SERIAL PRIMARY KEY;
-- Ensure all osm_id values are TEXT
ALTER TABLE public.entities
ALTER COLUMN osm_id type TEXT using osm_id::TEXT;


-- Add more spatial indexes for GEOGRAPHY datatype
CREATE INDEX classes_geog ON public.entities USING gist(CAST(geom AS geography));

-- Drop tables generated by default by osm2pgsql
DROP TABLE citydb.planet_osm_nodes;
DROP TABLE citydb.planet_osm_ways;
DROP TABLE citydb.planet_osm_rels;

-- Create view for what we are interested in comparing
-- We focus only on instances where we have at least 250 entities
CREATE VIEW business_entities AS
SELECT *
FROM entities
WHERE class IN ('159', '127', '186', '44', '15', '209', '237', '62', '14', '115', '13', '71');
--Parking=159
--Hotel=127
--Restaurant=186
--Cafe=44
--Bar=15
--Supermarket=209
--VendingMachine=237
--Clothes=62
--Bank=14
--Hairdresser=115
--Bakery=13
--Convenience=71


/*CREATE TABLE business_similarity AS
SELECT t1.osm_id AS id1, t1.osm_type AS osm_type1, t2.osm_id AS id2, t2.osm_type AS osm_type2,
       CASE
           WHEN (
                   t1.class = t2.class
                   AND t1.osm_id <> t2.osm_id
                       -- Arbitrary distance threshold of 500 meters
                   AND ST_DistanceSphere(t1.geom, t2.geom) <= 500
                   --TODO: Formulate the goal as finding future competitive companies not covered by this algorithm
                   --TODO: Idea, only add some of these edges, and see if they can be predicted??? Assume SecondaryHighways are an imperfect tool
                   -- Draw line between the two entities and check if it intersects with a SecondaryHighway
                   AND NOT ST_Intersects(ST_MakeLine(
                                             -- Special handling for polygons, st_makeline will not work directly
                                                 CASE WHEN (GeometryType(t1.geom)='POINT' OR GeometryType(t1.geom)='LINESTRING') THEN t1.geom ELSE st_exteriorring(t1.geom) END,
                                                 CASE WHEN (GeometryType(t2.geom)='POINT' OR GeometryType(t2.geom)='LINESTRING') THEN t2.geom ELSE st_exteriorring(t2.geom) END),
                   -- Class 192 is SecondaryHighway
                                         (SELECT st_collect(geom) FROM entities WHERE class='192'))
               ) THEN 1
           ELSE 0
           END AS result
FROM business_entities AS t1
CROSS JOIN business_entities AS t2;*/


CREATE TABLE business_similarity AS
SELECT t1.osm_id AS id1, t1.osm_type AS osm_type1, t2.osm_id AS id2, t2.osm_type AS osm_type2, 1 AS result
FROM business_entities AS t1
         CROSS JOIN business_entities AS t2
WHERE t1.class = t2.class
  AND t1.osm_id <> t2.osm_id
  AND ST_DistanceSphere(t1.geom, t2.geom) <= 500
  --AND GeometryType(t1.geom)='POINT' AND GeometryType(t2.geom)='POINT'
  --TODO: Formulate the goal as finding future competitive companies not covered by this algorithm
  --TODO: Idea, only add some of these edges, and see if they can be predicted??? Assume SecondaryHighways are an imperfect tool
  --AND NOT ST_intersects(st_makeline(t1.geom, t2.geom), (SELECT st_collect(geom) FROM entities WHERE class='192'))
  AND NOT ST_Intersects(ST_MakeLine(
                            -- Special handling for polygons, st_makeline will not work directly
                                CASE WHEN (GeometryType(t1.geom)='POINT' OR GeometryType(t1.geom)='LINESTRING') THEN t1.geom ELSE st_exteriorring(t1.geom) END,
                                CASE WHEN (GeometryType(t2.geom)='POINT' OR GeometryType(t2.geom)='LINESTRING') THEN t2.geom ELSE st_exteriorring(t2.geom) END),
    -- Class 197 is SecondaryHighway
    -- Class 216 is SecondaryHighway
                        (SELECT st_collect(geom) FROM entities WHERE class='192' OR class='216'));