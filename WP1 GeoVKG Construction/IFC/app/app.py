import ifcopenshell
import pandas as pd
import sqlalchemy
from sqlalchemy import text

def open_ifc(file_path):
    return ifcopenshell.open(file_path)

# Extract ID in order to create FK
def createReference(xval):
    if pd.isnull(xval):
        return None
    else:
        return (xval.split('#'))[1].split('=')[0]

# Extract Directions
def extractDirection(xval):
    if pd.isnull(xval):
        return None
    else:
        dirval = (xval.split('(('))[1].split('))')[0]
        dirval2 = '(' + dirval + ')'
        dirval3 = dirval2.replace(".,", ".0," )
        dirval4 = dirval3.replace(",", ", " )
        dirval5 = dirval4.replace("E-", "e-0")
        return dirval5.replace(".)", ".0)")

model = open_ifc(r'AC20-FZK-Haus.ifc')
engine = sqlalchemy.create_engine(f'postgresql://ifcsql:ifcsql@host.docker.internal:7778/ifcsql')

### 1. IfcSite
sites = model.by_type("IfcSite")
SiteList = []
for element in sites:
    SiteList.append(element.get_info())
df_site = pd.DataFrame.from_dict(SiteList)
# TODO: There can be 3 or 4 elements, the 4th is optional, we need to account for that
# NOTE: This is WGS84
df_site2 = df_site.join(pd.DataFrame(df_site['RefLatitude'].to_list(), columns=['lat_degrees', 'lat_minutes', 'lat_seconds', 'lat_millionthseconds']))
df_site3 = df_site2.join(pd.DataFrame(df_site['RefLongitude'].to_list(), columns=['lng_degrees', 'lgn_minutes', 'lng_seconds', 'lng_millionthseconds']))
df_site3['OwnerHistory_id'] = (df_site3['OwnerHistory'].astype('string').iloc[0].split('#'))[1].split('=')[0]
df_site3['ObjectPlacement_id'] = (df_site3['ObjectPlacement'].astype('string').iloc[0].split('#'))[1].split('=')[0]
df_site3['Representation_id'] = (df_site3['Representation'].astype('string').iloc[0].split('#'))[1].split('=')[0]
df_site3.drop(columns=['RefLatitude', 'RefLongitude', 'OwnerHistory', 'ObjectPlacement', 'Representation'], inplace=True)

# Numpy arrays do not seem to be supported
df_site3.to_sql("IfcSite", engine, if_exists='replace', index=False)
t = text('ALTER TABLE "IfcSite" ADD PRIMARY KEY ("id");')
with engine.connect() as con:
    con.execute(t)