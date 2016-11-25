#!/usr/bin/env python3

# Requires:
# requests
# json

import requests
import json
import os

bea_uri = "https://www.bea.gov/api/data"
bea_key = "CCF322B4-FA15-44F1-BAC6-3E0482CEB810"

bls_uri = "http://api.bls.gov/publicAPI/v2/timeseries/data/"

census_uri = ""
census_key = "c532c1ae672d36dbb72227c7f8aeea48bd3c6045"

os.makedirs('data',mode=0o755, exist_ok=True)

# Example from BLS:
#headers = {'Content-type': 'application/json'}
#data = json.dumps({"seriesid": ['CUUR0000SA0','SUUR0000SA0'],"startyear":"2011", "endyear":"2014"})
#p = requests.post(bls_uri, data=data, headers=headers)
#json_data = json.loads(p.text)

# Ran manually to see list of Data Sets
#get = requests.get(bea_uri + '?&UserID=' + bea_key + '&method=GETDATASETLIST&')
#get_json = json.loads(get.text)
#print("Data Set Name,\t\t\tData Set Description\n")
#for ds in get_json['BEAAPI']['Results']['Dataset']:
#    print(ds['DatasetName'] + "\t\t\t" + ds['DatasetDescription'])

# Ran manually for GDP by Industry options
#get = requests.get(bea_uri + '?&UserID=' + bea_key + '&method=GetParameterList&DatasetName=GDPbyIndustry&')
#get_json = json.loads(get.text)
#for par in get_json['BEAAPI']['Results']['Parameter']:
#    print(par)

# For future use:
get = requests.get(bea_uri + '?&UserID=' + bea_key + '&method=GetParameterValues&DatasetName=GDPbyIndustry&ParameterName=TableID&')
get_json = json.loads(get.text.replace('\n',''))
GDPbInd_tables = {}
for tbl in get_json['BEAAPI']['Results']['ParamValue']:
    GDPbInd_tables[tbl['Key']] = tbl['Desc']

get = requests.get(bea_uri + '?&UserID=' + bea_key + '&method=GetParameterValues&DatasetName=GDPbyIndustry&ParameterName=Industry&')
get_json = json.loads(get.text.replace('\n',''))
scode = {}
for tbl in get_json['BEAAPI']['Results']['ParamValue']:
    scode[tbl['Key']] = tbl['Desc']

# Write our CSVs on National stats
csv = open("data/RealValueAddedbyIndustry_US.csv", "w")
get = requests.get(bea_uri + '?&UserID=' + bea_key 
                   +'&method=GetData&DatasetName=GDPbyIndustry&Frequency=A&Industry=ALL&TableID=10'  
                   +'&Year=2005,2006,2007,2008,2009,2010,2011,2012,2013,2014,2015&')
get_json = json.loads(get.text.replace('\n',''))
csv.write('Industry,Industry Description,Year,Value Added (Billions Chained 2009)\n')
for data in get_json['BEAAPI']['Results']['Data']:
    csv.write(",".join((data['Industry'], '"'+data['IndustrYDescription']+'"', data['Year'], data['DataValue']))+'\n')
csv.close()

csv = open("data/RealGrossOutputbyIndustry_US.csv", "w")
get = requests.get(bea_uri + '?&UserID=' + bea_key
                   +'&method=GetData&DatasetName=GDPbyIndustry&Frequency=A&Industry=ALL&TableID=208'
                   +'&Year=2005,2006,2007,2008,2009,2010,2011,2012,2013,2014,2015&')
get_json = json.loads(get.text.replace('\n',''))
csv.write('Industry,Industry Description,Year,GDP (Billions Chained 2009)\n')
for data in get_json['BEAAPI']['Results']['Data']:
    csv.write(",".join((data['Industry'], '"'+data['IndustrYDescription']+'"', data['Year'], data['DataValue']))+'\n')
csv.close()

csv = open("data/RealIntermediateInputsbyIndustry_US.csv", "w")
get = requests.get(bea_uri + '?&UserID=' + bea_key 
                   +'&method=GetData&DatasetName=GDPbyIndustry&Frequency=A&Industry=ALL&TableID=209'
                   +'&Year=2005,2006,2007,2008,2009,2010,2011,2012,2013,2014,2015&')
get_json = json.loads(get.text.replace('\n',''))
csv.write('Industry,Industry Description,Year,Intermediate Inputs (Billions Chained 2009)\n')
for data in get_json['BEAAPI']['Results']['Data']:
    csv.write(",".join((data['Industry'], '"'+data['IndustrYDescription']+'"', data['Year'], data['DataValue']))+'\n')
csv.close()

# Regional Data
#get = requests.get(bea_uri + '?&UserID=' + bea_key + '&method=GetParameterValues&DatasetName=RegionalProduct&ParameterName=GeoFips&')
#get_json = json.loads(get.text.replace('\n',''))
#for tbl in get_json['BEAAPI']['Results']['ParamValue']:
#    print(tbl['Key'] +"\t\t"+ tbl['Desc'])

# Obtain a list of NIAC Industry codes
get = requests.get(bea_uri + '?&UserID=' + bea_key + '&method=GetParameterValuesFiltered&DatasetName=RegionalProduct&TargetParameter=IndustryID&Component=GDP_SAN&')
get_json = json.loads(get.text.replace('\n',''))
SAN_IND = {}
for tbl in get_json['BEAAPI']['Results']['ParamValue']:
    SAN_IND[tbl['Key']] = tbl['Desc']

# Write out CSVs on State stats
# Loop through Above Industry Codes, requesting data for VT (GeoFips 50000)
csv = open("data/RealGrossOutputbyIndustry_VT.csv", "w")
csv.write('Industry,Industry Description,Year,GDP (Millions Chained 2009)\n')
for IND in SAN_IND.keys():
    get = requests.get(bea_uri + '?&UserID=' + bea_key 
                       +'&method=GetData&DatasetName=RegionalProduct&GeoFips=50000&Component=RGDP_SAN&IndustryID='+IND
                       +'&Year=2005,2006,2007,2008,2009,2010,2011,2012,2013,2014,2015&')
    get_json = json.loads(get.text.replace('\n',''))
    for data in get_json['BEAAPI']['Results']['Data']:
        if 'DataValue' in data.keys():
             csv.write(",".join((IND, '"'+SAN_IND[IND]+'"', data['TimePeriod'], data['DataValue']))+'\n')
csv.close()

# Build List of Counties (and associated codes) in VT
get = requests.get('http://www2.census.gov/geo/docs/reference/codes/files/st50_vt_cou.txt')
VT_CNTY = {'50000' : 'Vermont'}
for line in get.text.split('\r\n'):
    fields = line.split(',')
    VT_CNTY[fields[1]+fields[2]] = fields[3]

get = requests.get(bea_uri + '?&UserID=' + bea_key 
                   +'&method=GetData&DatasetName=RegionalIncome&GeoFips=' 
                   +','.join(VT_CNTY.keys())
                   +'&TableName=CA1&LineCode=1'
                   +'&Year=2005,2006,2007,2008,2009,2010,2011,2012,2013,2014,2015&')
get_json = json.loads(get.text.replace('\n',''))
DATA_TBL = {}
for data in get_json['BEAAPI']['Results']['Data']:
    if 'DataValue' in data.keys():
        DATA_TBL[(data['GeoFips'],data['TimePeriod'])] = {'Income' : data['DataValue'] }

get = requests.get(bea_uri + '?&UserID=' + bea_key 
                   +'&method=GetData&DatasetName=RegionalIncome&GeoFips=' 
                   +','.join(VT_CNTY.keys())
                   +'&TableName=CA1&LineCode=2'
                   +'&Year=2005,2006,2007,2008,2009,2010,2011,2012,2013,2014,2015&')
get_json = json.loads(get.text.replace('\n',''))
for data in get_json['BEAAPI']['Results']['Data']:
    if 'DataValue' in data.keys():
        DATA_TBL[(data['GeoFips'],data['TimePeriod'])]['Population'] = data['DataValue'] 


csv = open("data/RegionalIncome_VT.csv", "w")
csv.write('GeoFips,Location,Year,Total Personal Income (Thousands),Population\n')
for tup in DATA_TBL.keys():
    csv.write(','.join(( tup[0], VT_CNTY[tup[0]], tup[1], DATA_TBL[tup]['Income'], DATA_TBL[tup]['Population'] ))+'\n')
csv.close()

del DATA_TBL


