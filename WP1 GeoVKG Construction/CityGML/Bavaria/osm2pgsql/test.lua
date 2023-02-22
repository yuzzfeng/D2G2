-- This config example file is released into the Public Domain.

-- Taken from https://github.com/openstreetmap/osm2pgsql/blob/master/flex-config/unitable.lua
-- Put all OSM data into a single table

-- inspect = require('inspect')

-- We define a single table that can take any OSM object and any geometry.
-- OSM nodes are converted to Points, ways to LineStrings and relations
-- to GeometryCollections. If an object would create an invalid geometry
-- it is still added to the table with a NULL geometry.
-- XXX expire will currently not work on these tables.
-- A place to store the SQL tables we will define shortly.
local tables = {}

tables.classes = osm2pgsql.define_table{
    name = "classes",
    -- This will generate a column "osm_id INT8" for the id, and a column
    -- "osm_type CHAR(1)" for the type of object: N(ode), W(way), R(relation)
    ids = { type = 'any', id_column = 'osm_id', type_column = 'osm_type' },
    columns = {
        -- Ignore attributes
        -- { column = 'attrs', type = 'jsonb' },
        { column = 'class',  type = 'text' },
        { column = 'geom',  type = 'geometry', projection = 4326, not_null = true },
        { column = 'name',  type = 'text' },
        { column = 'name_en',  type = 'text' },
        { column = 'name_de',  type = 'text' },
        { column = 'name_fr',  type = 'text' },
        { column = 'name_it',  type = 'text' },
        { column = 'height',  type = 'text' },
        { column = 'country', type = 'text' },
        { column = 'state', type = 'text' },
        { column = 'postcode', type = 'text' },
        { column = 'city', type = 'text' },
        { column = 'place', type = 'text' },
        { column = 'street', type = 'text' },
        { column = 'housenumber', type = 'text' },
    }
}


-- Helper function to remove some of the tags we usually are not interested in.
-- Returns true if there are no tags left.
function clean_tags(tags)
    tags.odbl = nil
    tags.created_by = nil
    tags.source = nil
    tags['source:ref'] = nil

    return next(tags) == nil
end

-- Helper function to check value is not empty
local function isempty(x)
  return x == nil or x == ''
end

-- Helper function to fill up table
local function filluptable(object, geometry, lookup)
    if not isempty(lookup) then
    tables.classes:insert({
        class = lookup,
        geom = geometry,
        name = object.tags.name,
        name_en = object.tags['name:en'],
        name_de = object.tags['name:de'],
        name_fr = object.tags['name:fr'],
        name_it = object.tags['name:it'],
        height = object.tags['height'],
        country = object.tags["addr:country"],
        state = object.tags["addr:state"],
        postcode = object.tags["addr:postcode"],
        city = object.tags["addr:city"],
        place = object.tags["addr:place"],
        street = object.tags["addr:street"],
        housenumber = object.tags["addr:housenumber"],
    })
    end
end

-- str_house = object.tags["addr:street"].tostring() .. " " .. object.tags["addr:housenumber"].tostring()

function process(object, geometry)
    -- If after removing the useless tags there is nothing left, ignore,
    -- we do not know what the object is
    if clean_tags(object.tags) then
        return
    end

    filluptable(object, geometry, object.tags.amenity)
    filluptable(object, geometry, object.tags.natural)
    filluptable(object, geometry, object.tags.highway)
    filluptable(object, geometry, object.tags.shop)
    filluptable(object, geometry, object.tags.place)
    filluptable(object, geometry, object.tags.landuse)
    filluptable(object, geometry, object.tags.tourism)
    filluptable(object, geometry, object.tags.leisure)
    filluptable(object, geometry, object.tags.aeroway)
    filluptable(object, geometry, object.tags.aerialway)
    -- We cannot know whether the category is first in the list of tags or not
    -- We need to do some checks
    -- Set a list of superclasses/keys we care about
    --local superclasses_file = io.open("superclasses.txt", "r")
    --for line in superclasses_file:lines() do
    superclasses = {'amenity', 'natural'}
--     local tag2 = object.tags
--     for _, key in ipairs(superclasses) do
--         local alpha = tag2[key]
--         print(alpha)
--         filluptable(object, geometry, alpha)
--     end



    --i=1,#table
--     for index, value in ipairs(superclasses) do
--         print(value)
--         var1 = string.format('%s', value.tostring)
--         print(object.tags[value])
--         value = 'amenity'
--         var1 = string.format('object.tags.%s', value)
        --print(var1)
        -- variable expansion failing
--         if not isempty(object.tags[var1]) then
--             tables.classes:insert({
--                 tags = object.tags[value],
--                 geom = geometry,
--                             name = object.tags.name,
--                             name_en = object.tags['name:en'],
--                             name_de = object.tags['name:en'],
--                             name_fr = object.tags['name:en'],
--                             name_it = object.tags['name:en'],
--                             height = object.tags['height']
--             })
--         end
--     end

end

function osm2pgsql.process_node(object)
    process(object, object:as_point())
end

function osm2pgsql.process_way(object)
    process(object, object:as_linestring())
end

function osm2pgsql.process_relation(object)
    process(object, object:as_geometrycollection())
end