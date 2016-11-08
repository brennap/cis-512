#!/usr/bin/env python3

# Requires:
# requests
# json

import requests
import json

bea_uri = "https://www.bea.gov/api/data"
bea_key = "CCF322B4-FA15-44F1-BAC6-3E0482CEB810"

bls_uri = "http://api.bls.gov/publicAPI/v2/timeseries/data/"

census_uri = ""
census_key = "c532c1ae672d36dbb72227c7f8aeea48bd3c6045"

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

# For furute use:
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
csv = open("RealValueAddedbyIndustry_US.csv", "w")
get = requests.get(bea_uri + '?&UserID=' + bea_key 
                   +'&method=GetData&DatasetName=GDPbyIndustry&Frequency=A&Industry=ALL&TableID=ALL'  
                   +'&Year=2005,2006,2007,2008,2009,2010,2011,2012,2013,2014,2015&')
get_json = json.loads(get.text.replace('\n',''))
csv.write('Industry,Industry Description,Year,Value\n')
for data in get_json['BEAAPI']['Results']['Data']:
    if data['TableID'] == '10':
        csv.write(",".join((data['Industry'], '"'+data['IndustrYDescription']+'"', data['Year'], data['DataValue']))+'\n')
csv.close()
csv = open("RealGrossOutputbyIndustry_US.csv", "w")
get = requests.get(bea_uri + '?&UserID=' + bea_key
                   +'&method=GetData&DatasetName=GDPbyIndustry&Frequency=A&Industry=ALL&TableID=ALL'
                   +'&Year=2005,2006,2007,2008,2009,2010,2011,2012,2013,2014,2015&')
get_json = json.loads(get.text.replace('\n',''))
csv.write('Industry,Industry Description,Year,Value\n')
for data in get_json['BEAAPI']['Results']['Data']:
    if data['TableID'] == '208':
        csv.write(",".join((data['Industry'], '"'+data['IndustrYDescription']+'"', data['Year'], data['DataValue']))+'\n')
csv.close()
csv = open("RealIntermediateInputsbyIndustry_US.csv", "w")
get = requests.get(bea_uri + '?&UserID=' + bea_key 
                   +'&method=GetData&DatasetName=GDPbyIndustry&Frequency=A&Industry=ALL&TableID=ALL'
                   +'&Year=2005,2006,2007,2008,2009,2010,2011,2012,2013,2014,2015&')
get_json = json.loads(get.text.replace('\n',''))
csv.write('Industry,Industry Description,Year,Value\n')
for data in get_json['BEAAPI']['Results']['Data']:
    if data['TableID'] == '209':
        csv.write(",".join((data['Industry'], '"'+data['IndustrYDescription']+'"', data['Year'], data['DataValue']))+'\n')
csv.close()

# Regional Data
#get = requests.get(bea_uri + '?&UserID=' + bea_key + '&method=GetParameterValues&DatasetName=RegionalProduct&ParameterName=GeoFips&')
#get_json = json.loads(get.text.replace('\n',''))
#for tbl in get_json['BEAAPI']['Results']['ParamValue']:
#    print(tbl['Key'] +"\t\t"+ tbl['Desc'])

get = requests.get(bea_uri + '?&UserID=' + bea_key + '&method=GetParameterValuesFiltered&DatasetName=RegionalProduct&TargetParameter=IndustryID&Component=GDP_SAN&')
get_json = json.loads(get.text.replace('\n',''))
SAN_IND = {}
for tbl in get_json['BEAAPI']['Results']['ParamValue']:
    SAN_IND[tbl['Key']] = tbl['Desc']

# Write out CSVs on State stats
csv = open("RealIntermediateInputsbyIndustry_VT.csv", "w")
csv.write('Industry,Industry Description,Year,Value\n')
for IND in SAN_IND.keys():
    get = requests.get(bea_uri + '?&UserID=' + bea_key 
                       +'&method=GetData&DatasetName=RegionalProduct&GeoFips=50000&Component=GDP_SAN&IndustryID='+IND
                       +'&Year=2005,2006,2007,2008,2009,2010,2011,2012,2013,2014,2015&')
    get_json = json.loads(get.text.replace('\n',''))
    for data in get_json['BEAAPI']['Results']['Data']:
        if 'DataValue' in data.keys():
            csv.write(",".join((IND, '"'+SAN_IND[IND]+'"', data['TimePeriod'], data['DataValue']))+'\n')
csv.close()

