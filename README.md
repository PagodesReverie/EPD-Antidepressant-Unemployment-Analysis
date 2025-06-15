# EPD-Antidepressant-Unemployment-Analysis
English Prescribing Dataset Local Authority Antidepressant Analysis

Simple code overview

1.Postcodes.R
- Combines and cleans individual postcode data taken from the ONS postcode directory 
- Final output is England_Postcodes.csv which describes the relevant Local Authority (LA) and Region codes for every unique England postcode

2.EPD_Outputs_Combined.R
- Secion #2 Runs a series of identical processing scripts (EPD_XXXX.R) for each year. These scripts are the bulk of all data processing and manipulation work. Described below:

   EPD_2014.R example
   - Sections #2-4 build SQL API queries to pull single and multimonth antidepressant prescription data (British National Formulary code 0403) for all England postcodes (using 
     NHSBSA API query guidance on Github)
   - Sections #5 and #6 match unique postcodes in the antidepressant prescription data with their respective local authorities and regions, adds census population estimates, 
     and calculate per capita antidepressant prescription estimates (monthly)
 
- Section #3 reads, sorts and combines each annual file into a unified dataset (one for LA level and one for regional level)

The final script (which unfortunately has been lost to the digital ether!!) simply joined (by local authority and date) the following datasets taken from the ONS:
- Unemployment rate
- Gross disposable household income
- Population disability data
- Population ethnicity data
- Population religion data
- Population density data
- Population Marriage data
- Population qualification data
- Population gender data

Further to this, it also calculated antidepressant costs per capita, total unique postcodes, and unique postcodes per capita.

The final output used for regression analysis can be observed in final_dataset_adp.xlsx
