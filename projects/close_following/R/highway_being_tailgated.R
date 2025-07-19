library(tidyverse)
library(readr)

# Function to read and process highway being tailgated data
read_highway_tailgated_data <- function(file_path) {
  
  # Read the file as lines of text first
  raw_lines <- read_lines(file_path, skip = 1)  # Skip Header
  
  # Split each line by tabs and convert to data frame
  data_split <- raw_lines %>%
    str_split("\t", simplify = TRUE) %>%
    as_tibble(.name_repair = "minimal")
  
  # Clean column names for easier handling
  clean_names <- c(
    "time",
    "accelerator_pressure", 
    "driver_speed",
    "lane_lateral_shift",
    "lane_number",
    "braking_pressure",
    "drive_section",
    "road_distance",
    "lane_id"
  )
  
  # Assign clean names
  names(data_split) <- clean_names
  
  # Convert relevant columns to numeric, handling "null" values
  data_clean <- data_split %>%
    mutate(
      time = as.numeric(time),
      driver_speed = as.numeric(ifelse(driver_speed == "null", NA, driver_speed)),
      lane_lateral_shift = as.numeric(ifelse(lane_lateral_shift == "null", NA, lane_lateral_shift)),
      drive_section = as.numeric(ifelse(drive_section == "null", NA, drive_section)),
      braking_pressure = as.numeric(ifelse(braking_pressure == "null", NA, braking_pressure)),
      accelerator_pressure = as.numeric(ifelse(accelerator_pressure == "null", NA, accelerator_pressure)),
      lane_number = as.numeric(ifelse(lane_number == "null", NA, lane_number))
    ) %>%
    # Remove rows where drive_section is NA (likely transition periods)
    filter(!is.na(drive_section))
  
  return(data_clean)
}

# Function to calculate summary metrics
calculate_summary_metrics <- function(data) {
  
  # Calculate average speed and lane position by drive section
  section_summary <- data %>%
    group_by(drive_section) %>%
    summarise(
      avg_speed = mean(driver_speed, na.rm = TRUE),
      avg_lateral_position = mean(lane_lateral_shift, na.rm = TRUE),
      n_observations = n(),
      .groups = "drop"
    ) %>%
    # Filter to only sections 1-10 as requested
    filter(drive_section >= 1 & drive_section <= 10)
  
  # Check for crashes (assuming crash indicated by extreme braking or speed changes)
  # This is a basic heuristic - you may need to adjust based on your crash criteria
  crash_check <- data %>%
    mutate(
      extreme_braking = braking_pressure > 0.8,  # Adjust threshold as needed
      speed_drop = driver_speed < 10  # Adjust threshold as needed
    ) %>%
    summarise(
      crash_detected = any(extreme_braking & speed_drop, na.rm = TRUE),
      crash_count = sum(extreme_braking & speed_drop, na.rm = TRUE)
    )
  
  # Combine results
  results <- list(
    section_summary = section_summary,
    crash_info = crash_check,
    total_sections = max(data$drive_section, na.rm = TRUE)
  )
  
  return(results)
}

# Main analysis function
analyze_highway_tailgated <- function(file_path) {
  
  cat("Reading highway being tailgated data...\n")
  data <- read_highway_tailgated_data(file_path)
  
  cat("Calculating summary metrics...\n")
  results <- calculate_summary_metrics(data)
  
  # Print results
  cat("\n=== HIGHWAY BEING TAILGATED ANALYSIS ===\n")
  cat("File:", basename(file_path), "\n")
  cat("Total drive sections found:", results$total_sections, "\n")
  cat("Crash detected:", results$crash_info$crash_detected, "\n")
  cat("Crash events:", results$crash_info$crash_count, "\n\n")
  
  cat("AVERAGE SPEED BY DRIVE SECTION (km/h):\n")
  print(results$section_summary %>% select(drive_section, avg_speed))
  
  cat("\nAVERAGE LATERAL POSITION BY DRIVE SECTION:\n")
  print(results$section_summary %>% select(drive_section, avg_lateral_position))
  
  return(results)
}

# Function to extract participant info from filename
extract_participant_info <- function(filename) {
  # Extract just the filename without path
  base_name <- basename(filename)
  
  # Pattern to match: date_time_participantID.csv
  # Example: Close_Following_Highway_Being_Tailgaited-25_06_2025-15h07m17s_1234.csv
  pattern <- ".*-(\\d{2})_(\\d{2})_(\\d{4})-(\\d{2})h(\\d{2})m(\\d{2})s_(\\d{4})\\.csv$"
  
  if (str_detect(base_name, pattern)) {
    matches <- str_match(base_name, pattern)
    
    # Extract components
    day <- matches[2]
    month <- matches[3]
    year <- matches[4]
    hour <- matches[5]
    minute <- matches[6]
    second <- matches[7]
    participant_id <- matches[8]
    
    # Format date and time
    date <- paste(year, month, day, sep = "-")
    time <- paste0(hour, ":", minute, ":", second)
    
    return(list(
      participant_id = participant_id,
      date = date,
      time = time
    ))
  } else {
    warning("Could not extract participant info from filename: ", base_name)
    return(list(
      participant_id = "unknown",
      date = "unknown", 
      time = "unknown"
    ))
  }
}

# Function to process multiple files and create summary CSV
process_highway_tailgated_batch <- function(data_folder, output_file = "output/highway_tailgated_summary.csv") {
  
  # Create output directory if it doesn't exist
  dir.create(dirname(output_file), showWarnings = FALSE, recursive = TRUE)
  
  # Get all CSV files in the folder
  csv_files <- list.files(data_folder, pattern = "\\.csv$", full.names = TRUE)
  
  if (length(csv_files) == 0) {
    stop("No CSV files found in: ", data_folder)
  }
  
  cat("Found", length(csv_files), "CSV files to process\n")
  
  # Initialize results dataframe
  summary_results <- tibble()
  
  # Process each file
  for (file_path in csv_files) {
    cat("Processing:", basename(file_path), "\n")
    
    tryCatch({
      # Extract participant info from filename
      participant_info <- extract_participant_info(file_path)
      
      # Analyze the data
      data <- read_highway_tailgated_data(file_path)
      results <- calculate_summary_metrics(data)
      
      # Create summary row
      summary_row <- tibble(
        participant_id = participant_info$participant_id,
        date = participant_info$date,
        time = participant_info$time,
        crashed = results$crash_info$crash_detected,
        crash_count = results$crash_info$crash_count
      )
      
      # Add average speeds for each section (1-10)
      speed_data <- results$section_summary %>%
        select(drive_section, avg_speed) %>%
        pivot_wider(names_from = drive_section, 
                   values_from = avg_speed,
                   names_prefix = "avg_speed_section_")
      
      # Add SDLP (Standard Deviation of Lateral Position) for each section
      sdlp_data <- data %>%
        filter(!is.na(drive_section), drive_section >= 1, drive_section <= 10) %>%
        group_by(drive_section) %>%
        summarise(sdlp = sd(lane_lateral_shift, na.rm = TRUE), .groups = "drop") %>%
        pivot_wider(names_from = drive_section,
                   values_from = sdlp,
                   names_prefix = "sdlp_section_")
      
      # Combine all data
      summary_row <- bind_cols(summary_row, speed_data, sdlp_data)
      
      # Add to results
      summary_results <- bind_rows(summary_results, summary_row)
      
    }, error = function(e) {
      cat("Error processing", basename(file_path), ":", e$message, "\n")
    })
  }
  
  # Write to CSV
  write_csv(summary_results, output_file)
  cat("\nSummary saved to:", output_file, "\n")
  cat("Processed", nrow(summary_results), "files successfully\n")
  
  return(summary_results)
}

# Example usage:
# Single file analysis:
# file_path <- "data/raw/highway/being_tailgated/Close_Following_Highway_Being_Tailgaited-25_06_2025-15h07m17s_1234.csv"
# results <- analyze_highway_tailgated(file_path)

# Batch processing:
# summary_data <- process_highway_tailgated_batch("data/raw/highway/being_tailgated/")
# This will create: output/highway_tailgated_summary.csv


