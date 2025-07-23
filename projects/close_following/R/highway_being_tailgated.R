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
  
  # Calculate metrics by drive section
  section_summary <- data %>%
    filter(drive_section >= 1 & drive_section <= 10) %>%
    group_by(drive_section) %>%
    summarise(
      # Basic metrics
      n_observations = n(),
      duration_seconds = max(time, na.rm = TRUE) - min(time, na.rm = TRUE),
      
      # Speed metrics
      avg_speed = mean(driver_speed, na.rm = TRUE),
      sd_speed = sd(driver_speed, na.rm = TRUE),
      min_speed = min(driver_speed, na.rm = TRUE),
      max_speed = max(driver_speed, na.rm = TRUE),
      
      # Lateral position metrics (SDLP - Standard Deviation of Lateral Position)
      avg_lateral_position = mean(lane_lateral_shift, na.rm = TRUE),
      sdlp = sd(lane_lateral_shift, na.rm = TRUE),
      
      # Braking metrics - corrected to count actual braking episodes
      total_braking_events = {
        # Create binary brake indicator
        brake_binary <- ifelse(braking_pressure > 0, 1, 0)
        brake_binary[is.na(brake_binary)] <- 0
        
        # Count transitions from 0 to 1 (start of braking episodes)
        if(length(brake_binary) > 1) {
          sum(diff(brake_binary) == 1, na.rm = TRUE)
        } else {
          ifelse(brake_binary[1] == 1, 1, 0)
        }
      },
      avg_braking_pressure_per_event = {
        # Create binary brake indicator
        brake_binary <- ifelse(braking_pressure > 0, 1, 0)
        brake_binary[is.na(brake_binary)] <- 0
        
        if(sum(brake_binary) > 0) {
          # Get average pressure only during braking periods
          mean(braking_pressure[brake_binary == 1], na.rm = TRUE)
        } else {
          NA_real_
        }
      },
      max_braking_pressure = max(braking_pressure, na.rm = TRUE),
      
      # Lane metrics
      avg_lane_number = mean(lane_number, na.rm = TRUE),
      lane_changes = sum(abs(diff(lane_number, na.rm = TRUE)) > 0, na.rm = TRUE),
      
      .groups = 'drop'
    )
  
  return(section_summary)
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
  cat("Total observations:", nrow(data), "\n")
  cat("Duration:", round(max(data$time, na.rm = TRUE), 2), "seconds\n")
  cat("Sections found:", paste(sort(unique(data$drive_section[!is.na(data$drive_section)])), collapse = ", "), "\n\n")
  
  # Print section summaries
  cat("=== SECTION SUMMARIES ===\n")
  for(i in 1:10) {
    section_data <- results %>% filter(drive_section == i)
    if(nrow(section_data) > 0) {
      cat(sprintf("Section %d:\n", i))
      cat(sprintf("  Duration: %.1f seconds\n", section_data$duration_seconds))
      cat(sprintf("  Average Speed: %.1f km/h (SD: %.1f)\n", 
                  section_data$avg_speed, section_data$sd_speed))
      cat(sprintf("  SDLP: %.4f\n", section_data$sdlp))
      cat(sprintf("  Braking Events: %d\n", section_data$total_braking_events))
      cat(sprintf("  Average Brake Pressure per Event: %.4f\n", section_data$avg_braking_pressure_per_event))
      cat(sprintf("  Lane Changes: %d\n", section_data$lane_changes))
      cat("\n")
    }
  }
  
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
    date <- paste(day, month, year, sep = "/")
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
process_highway_tailgated_batch <- function(data_folder, output_file = "projects/close_following/output/highway_being_tailgated_summary.csv") {
  
  # Create output directory if it doesn't exist
  dir.create(dirname(output_file), showWarnings = FALSE, recursive = TRUE)
  
  # Get all CSV files in the folder
  csv_files <- list.files(data_folder, pattern = "\\.csv$", full.names = TRUE)
  
  if (length(csv_files) == 0) {
    stop("No CSV files found in: ", data_folder)
  }
  
  cat("Found", length(csv_files), "CSV files to process\n")
  
  # Process each file
  all_summaries <- map_dfr(csv_files, function(file_path) {
    cat("Processing:", basename(file_path), "\n")
    
    tryCatch({
      # Extract participant info from filename
      participant_info <- extract_participant_info(file_path)
      
      # Analyze the data
      summary_data <- analyze_highway_tailgated(file_path)
      
      # Add participant information
      summary_data %>%
        mutate(
          participant_id = participant_info$participant_id,
          date = participant_info$date,
          time = participant_info$time,
          filename = basename(file_path),
          .before = 1
        )
      
    }, error = function(e) {
      cat("Error processing", basename(file_path), ":", e$message, "\n")
      return(NULL)
    })
  })
  
  if(nrow(all_summaries) > 0) {
    # Reshape to wide format for easier analysis
    wide_summary <- all_summaries %>%
      select(participant_id, date, time, filename, drive_section, 
             avg_speed, sdlp, total_braking_events, avg_braking_pressure_per_event) %>%
      pivot_wider(
        names_from = drive_section,
        values_from = c(avg_speed, sdlp, total_braking_events, avg_braking_pressure_per_event),
        names_glue = "{.value}_section_{drive_section}"
      )
    
    # Write to CSV
    write_csv(wide_summary, output_file)
    cat("\n✅ Batch processing complete!")
    cat("\n📁 Summary saved to:", output_file)
    cat("\n📊 Processed", length(unique(all_summaries$participant_id)), "participants")
    cat("\n📈 Total", nrow(all_summaries), "section summaries\n")
    
    return(wide_summary)
  } else {
    cat("❌ No files processed successfully\n")
    return(tibble())
  }
}

# Example usage:
# Single file analysis:
# file_path <- "projects/close_following/data/raw/highway/being_tailgated/Close_Following_Highway_Being_Tailgaited-25_06_2025-15h07m17s_1234.csv"
# results <- analyze_highway_tailgated(file_path)

# Batch processing:
summary_data <- process_highway_tailgated_batch("projects/close_following/data/raw/highway/being_tailgated/")