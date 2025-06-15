library(dplyr)
install.packages("readxl")
install.packages("zoo")
library(readxl)
library(readr)
library(zoo)


## Load all England postcode CSV files ##
folder_path <- "C:/Users/lawri/Desktop/EPD_Project/multi_csv"

csv_files <- list.files(folder_path, pattern = "\\.csv$", full.names = TRUE)

df_list <- list()

# Iterate through CSV files, read them, and store dataframes in df_list
for (file in csv_files) {
  # Extract characters from the filename for naming
  file_name <- basename(file)
  df_name <- substr(file_name, 19, nchar(file_name) - 4)  # Assuming CSV extension is 4 characters long
  
  # Read CSV file and store dataframe in df_list
  df <- read.csv(file)
  df_list[[df_name]] <- df
}

# Create the england postcode list csv 
england_pd <- do.call(rbind, df_list)  # Assuming you want to row-bind (stack vertically)

#alter the list
england_pd_2 <- england_pd %>%
  select(c("pcd", "rgn", "oslaua"))   # filter out unnecessary columns

england_pd_2$rgn[england_pd_2$rgn == ""] <- NA  #turn blank rows into NA
england_pd_2$oslaua[england_pd_2$oslaua == ""] <- NA  #turn blank rows into NA
england_pd_2 <- england_pd_2[order(england_pd_2$pcd), ] #reorder postcodes for NA fill
england_pd_2$pcd <- ifelse(nchar(england_pd_2$pcd) == 7 & !grepl(" ", england_pd_2$pcd), 
                          paste0(substr(england_pd_2$pcd, 1, 4), " ", substr(england_pd_2$pcd, 5, nchar(england_pd_2$pcd))), 
                           england_pd_2$pcd) # add a space after the 4th character of postcodes consisting of 8 characters that dont already have a space
england_pd_2$pcd <- gsub(" {2,}", " ", england_pd_2$pcd) # remove double spaces in postcodes
# Fill in NA regions/local authorities with the same values for the closest postcode with said values
england_pd_2$rgn <- na.locf(england_pd_2$rgn)
england_pd_2$oslaua <- na.locf(england_pd_2$oslaua)
england_pd_2 <- england_pd_2[order(row.names(england_pd_2)), ] #set postcodes to original order

write.csv(england_pd_2, "England_Postcodes.csv")
