# 1. Load packages -------------------------------------------------------------
install.packages("readxl")
install.packages("zoo")
library(dplyr)
library(readxl)
library(readr)
library(zoo)

#2.0 Run EPD_XXXX Processing Scripts
source("EPD_Processing/EPD_2014.R")
source("EPD_Processing/EPD_2015.R")
source("EPD_Processing/EPD_2016.R")
source("EPD_Processing/EPD_2017.R")
source("EPD_Processing/EPD_2018.R")
source("EPD_Processing/EPD_2019.R")
source("EPD_Processing/EPD_2020.R")

#3.0 Read, sort and combine outputs to create an all-year file _local authority
EPD2020 <- read.csv("EPD_0403_2020.csv") %>%
  rename(antidep_pc_laua = X0403_pc_laua) %>%
  select(c("year_month","region","local_authority","pop21","total_quantity","antidep_pc_laua"))

EPD2019 <- read.csv("EPD_0403_2019.csv") %>%
  rename(antidep_pc_laua = X0403_pc_laua) %>%
  select(c("year_month","region","local_authority","pop21","total_quantity","antidep_pc_laua"))

EPD2018 <- read.csv("EPD_0403_2018.csv") %>%
  rename(antidep_pc_laua = X0403_pc_laua) %>%
  select(c("year_month","region","local_authority","pop21","total_quantity","antidep_pc_laua"))

EPD2017 <- read.csv("EPD_0403_2017.csv") %>%
  rename(antidep_pc_laua = X0403_pc_laua) %>%
  select(c("year_month","region","local_authority","pop21","total_quantity","antidep_pc_laua"))

EPD2016 <- read.csv("EPD_0403_2016.csv") %>%
  rename(antidep_pc_laua = X0403_pc_laua) %>%
  select(c("year_month","region","local_authority","pop21","total_quantity","antidep_pc_laua"))

EPD2015 <- read.csv("EPD_0403_2015.csv") %>%
  rename(antidep_pc_laua = X0403_pc_laua) %>%
  select(c("year_month","region","local_authority","pop21","total_quantity","antidep_pc_laua"))

EPD2014 <- read.csv("EPD_0403_2014.csv") %>%
  rename(antidep_pc_laua = X0403_pc_laua) %>%
  select(c("year_month","region","local_authority","pop21","total_quantity","antidep_pc_laua"))


EPD_List <- list(EPD2014, EPD2015, EPD2016, EPD2017, EPD2018, EPD2019)
EPD_all<- bind_rows(EPD_List)
write.csv(EPD_all, "EPD_0403_all.csv")


# Do the same again for Regional all-year
EPD2020_rgn <- read.csv("EPD_0403_2020_RGN.csv") %>%
  rename(antidep_pc_region = X0403_pc_region) %>%
  select(c("year_month","region","rgn_pop21","total_quantity_rgn","antidep_pc_region"))

EPD2019_rgn <- read.csv("EPD_0403_2019_RGN.csv") %>%  
  rename(antidep_pc_region = X0403_pc_region) %>%
  select(c("year_month","region","rgn_pop21","total_quantity_rgn","antidep_pc_region"))

EPD2018_rgn <- read.csv("EPD_0403_2018_RGN.csv") %>%
  rename(antidep_pc_region = X0403_pc_region) %>%
  select(c("year_month","region","rgn_pop21","total_quantity_rgn","antidep_pc_region"))

EPD2017_rgn <- read.csv("EPD_0403_2017_RGN.csv") %>%
  rename(antidep_pc_region = X0403_pc_region) %>%
  select(c("year_month","region","rgn_pop21","total_quantity_rgn","antidep_pc_region"))

EPD2016_rgn <- read.csv("EPD_0403_2016_RGN.csv") %>%
  rename(antidep_pc_region = X0403_pc_region) %>%
  select(c("year_month","region","rgn_pop21","total_quantity_rgn","antidep_pc_region"))

EPD2015_rgn <- read.csv("EPD_0403_2015_RGN.csv") %>%
  rename(antidep_pc_region = X0403_pc_region) %>%
  select(c("year_month","region","rgn_pop21","total_quantity_rgn","antidep_pc_region"))

EPD2014_rgn <- read.csv("EPD_0403_2014_RGN.csv") %>%
  rename(antidep_pc_region = X0403_pc_region) %>%
  select(c("year_month","region","rgn_pop21","total_quantity_rgn","antidep_pc_region"))

EPD_List_rgn <- list(EPD2014_rgn, EPD2015_rgn, EPD2016_rgn, EPD2017_rgn, EPD2018_rgn, EPD2019_rgn)
EPD_all_rgn<- bind_rows(EPD_List_rgn)
write.csv(EPD_all_rgn, "EPD_0403_all_RGN.csv")
