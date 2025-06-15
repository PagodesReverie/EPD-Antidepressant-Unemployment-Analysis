# 1. Load packages -------------------------------------------------------------

install.packages("readxl")
install.packages("zoo")
library(dplyr)
library(readxl)
library(readr)
library(zoo)
# List packages we will use
packages <- c(
  "jsonlite", # 1.6
  "dplyr",    # 0.8.3
  "crul"      # 1.1.0
)

# Install packages if they aren't already
if (length(setdiff(packages, rownames(installed.packages()))) > 0) {
  install.packages(setdiff(packages, rownames(installed.packages())))  
}

# 2. Define API variables ----------------------------------------------------------

# Define the url for the API call
base_endpoint <- "https://opendata.nhsbsa.net/api/3/action/"
package_list_method <- "package_list"     # List of data-sets in the portal
package_show_method <- "package_show?id=" # List all resources of a data-set
action_method <- "datastore_search_sql?"  # SQL action method

# Send API call to get list of data-sets
datasets_response <- jsonlite::fromJSON(paste0(
  base_endpoint, 
  package_list_method
))

# Now lets have a look at the data-sets currently available
datasets_response$result

# For this example we're interested in the English Prescribing Dataset (EPD).
# We know the name of this data-set so can set this manually, or access it 
# from datasets_response.
dataset_id <- "english-prescribing-data-epd"

# 3. API calls for single month ------------------------------------------------

# Define the parameters for the SQL query
resource_name <- "EPD_201901" # For EPD resources are named EPD_YYYYMM
pco_code <- "13T00" # Newcastle Gateshead CCG
bnf_chemical_substance <- "0403%" # antidepressants


# Build SQL query (WHERE criteria should be enclosed in single quotes)  
single_month_query <- paste0(
  "
SELECT 
    total_quantity,
    postcode,
    year_month,
    CASE 
        WHEN bnf_chemical_substance LIKE '0403%' THEN '0403'
        ELSE bnf_chemical_substance
    END AS grouped_bnf_code
FROM `", 
  resource_name, "` 
WHERE 
    1=1 
    AND pco_code = '", pco_code, "' 
    AND bnf_chemical_substance LIKE '0403%'
"
)

# Build API call  
single_month_api_call <- paste0(
  base_endpoint,
  action_method,
  "resource_id=",
  resource_name, 
  "&",
  "sql=",
  URLencode(single_month_query) # Encode spaces in the url
)

# Grab the response JSON as a list
single_month_response <- jsonlite::fromJSON(single_month_api_call)

# Extract records in the response to a dataframe
single_month_df <- single_month_response$result$result$records

# Lets have a quick look at the data
str(single_month_df)
head(single_month_df)

# You can use any of the fields listed in the data-set within the SQL query as 
# part of the select or in the where clause in order to filter.

# Information on the fields present in a data-set and an accompanying data 
# dictionary can be found on the page for the relevant data-set on the Open Data 
# Portal.

# 4. API calls for data for multiple months ------------------------------------

# Now that you have extracted data for a single month, you may want to get the 
# data for several months, or a whole year.

# Firstly we need to get a list of all of the names and resource IDs for every 
# EPD file. We therefore extract the metadata for the EPD dataset.
metadata_repsonse <- jsonlite::fromJSON(paste0(
  base_endpoint, 
  package_show_method,
  dataset_id
))

# Resource names and IDs are kept within the resources table returned from the 
# package_show_method call.
resources_table <- metadata_repsonse$result$resources
# We only want data for one calendar year, to do this we need to look at the 
# name of the data-set to identify the year. For this example we're looking at 
# 2019.
resource_name_list <- resources_table$name[grepl("2019", resources_table$name)]

# 4.1. For loop ----------------------------------------------------------------

# We can do this with a for loop that makes all of the individual API calls for 
# you and combines the data together into one dataframe

# Initialise dataframe that data will be saved to
for_loop_df <- data.frame()

# As each individual month of EPD data is so large it will be unlikely that your 
# local system will have enough RAM to hold a full year's worth of data in 
# memory. Therefore we will only look at a single CCG and chemical substance as 
# we did previously

# Loop through resource_name_list and make call to API to extract data, then 
# bind each month together to make a single data-set
for(month in resource_name_list) {
  
  # Build temporary SQL query 
  tmp_query <- paste0(
    "
SELECT 
    '0403' AS grouped_bnf_code,
    postcode,
    year_month,
    SUM(total_quantity) AS total_quantity
FROM `", 
    month, "` 
WHERE 
    bnf_chemical_substance LIKE '0403%'
GROUP BY 
    postcode,
    year_month
"
  )
  
  # Build temporary API call
  tmp_api_call <- paste0(
    base_endpoint,
    action_method,
    "resource_id=",
    month, 
    "&",
    "sql=",
    URLencode(tmp_query) # Encode spaces in the url
  )
  
  # Grab the response JSON as a temporary list
  tmp_response <- jsonlite::fromJSON(tmp_api_call)
  
  # Extract records in the response to a temporary dataframe
  tmp_df <- tmp_response$result$result$records
  
  # Bind the temporary data to the main dataframe
  for_loop_df <- dplyr::bind_rows(for_loop_df, tmp_df)
}


# 5.0 Make postcode and region matching dataset ----------------------------------------------------------------

england_postcodes <- read.csv("England_Postcodes.csv")

# read in local/unitary authorities population csv for matching to regions
ONS_OSLAUA_Population <- read_excel("LA_UA.xlsx") 
ONS_Region_Population <- read_excel("REGION_POPULATION.xlsx")
ONS_Region_Population$rgn[ONS_Region_Population$rgn == "East"] <- "East of England"

# map region codes to their regions and rename region population df for matching
region_lookup <- c("E12000009" = "South West",
                   "E12000008" = "South East",
                   "E12000007" = "London",
                   "E12000006" = "East of England",
                   "E12000005" = "West Midlands",
                   "E12000004" = "East Midlands",
                   "E12000003" = "Yorkshire and The Humber",
                   "E12000002" = "North West",
                   "E12000001" = "North East")
la_lookup <- ONS_OSLAUA_Population %>%
  select(c(oslaua, oslaua_code))


# 6.0 Make final EPD-Region matched antidepressant prescription datasets ----------------------------------------------------------------


# Merge the sql_output with england_pd based on the postcode column
final_output <- left_join(for_loop_df, england_postcodes, by = c("postcode" = "pcd")) %>%
  left_join(la_lookup, by = c("oslaua" = "oslaua_code")) %>%
  mutate(rgn = region_lookup[rgn]) %>%
  rename("local_authority" = "oslaua.y",
         "region" = "rgn") 
final_output <- final_output[complete.cases(final_output$rgn, final_output$oslaua), ]



# Group final output to get the local authority/regional breakdowns by yearmonth
EPD_2019 <- final_output %>%
  group_by(local_authority, region, year_month) %>%
  summarise(total_quantity = sum(total_quantity)) %>%
  left_join(ONS_OSLAUA_Population, by = c("local_authority" = "oslaua")) %>%
  left_join(ONS_Region_Population, by = c("region" = "rgn"))
EPD_2019$"0403_pc_laua" <- EPD_2019$total_quantity / EPD_2019$pop21
EPD_2019 <- EPD_2019 %>%
  select(year_month,region,local_authority,pop21,total_quantity, "0403_pc_laua", rgn_pop21)

EPD_2019_Region <- EPD_2019 %>%
  group_by(region,rgn_pop21, year_month) %>%
  summarise(total_quantity = sum(total_quantity)) %>%
  rename(total_quantity_rgn = total_quantity)
EPD_2019_Region$"0403_pc_region" <- EPD_2019_Region$total_quantity_rgn / EPD_2019_Region$rgn_pop21
EPD_2019_Region <- EPD_2019_Region %>%
  select(c(year_month, region,rgn_pop21, total_quantity_rgn,"0403_pc_region"))

EPD_2019 <- EPD_2019 %>%
  select(year_month,region,local_authority,pop21,total_quantity, "0403_pc_laua")
#  mutate(rgn = region_lookup[rgn]) %>%
#  left_join(la_lookup, by = c("oslaua" = "oslaua_code"))

write.csv(EPD_2019, "EPD_0403_2019.csv", row.names = FALSE)
write.csv(EPD_2019_Region, "EPD_0403_2019_RGN.csv", row.names = FALSE)



