# Updated Highway Tailgating Analysis Functions
library(tidyverse)
library(readr)

# Read highway tailgating data from tab-separated CSV
read_highway_tailgating_data <- function(filepath) {
  # Read the tab-separated file
  data <- read_delim(filepath, delim = "\t", show_col_types = FALSE)
  
  # Convert "null" strings to NA and convert numeric columns
  data <- data %>%
    mutate(
      speed = as.numeric(ifelse(`[03 (Driver/Driver Speed)].ExportChannel-val` == "null", 
                               NA, `[03 (Driver/Driver Speed)].ExportChannel-val`)),
      headway_distance = as.numeric(ifelse(`[05 (Driver/Headway Distance)].ExportChannel-val` == "null", 
                                          NA, `[05 (Driver/Headway Distance)].ExportChannel-val`)),
      lateral_shift = as.numeric(ifelse(`[06 (Driver/Driver Lane Lateral Shift)].ExportChannel-val` == "null", 
                                       NA, `[06 (Driver/Driver Lane Lateral Shift)].ExportChannel-val`)),
      braking = as.numeric(ifelse(`[10 (Driver/Braking)].ExportChannel-val` == "null", 
                                 NA, `[10 (Driver/Braking)].ExportChannel-val`)),
      time_headway = as.numeric(ifelse(`[12 (Driver/Time Headway)].ExportChannel-val` == "null", 
                                      NA, `[12 (Driver/Time Headway)].ExportChannel-val`)),
      vehicle_in_front_id = as.numeric(ifelse(`[13 (Driver/Vehicle In Front ID)].ExportChannel-val` == "null", 
                                             NA, `[13 (Driver/Vehicle In Front ID)].ExportChannel-val`)),
      drive_section = as.numeric(ifelse(`[17 (Driver/Drive Section)].ExportChannel-val` == "null", 
                                       NA, `[17 (Driver/Drive Section)].ExportChannel-val`)),
      road_abscissa = as.numeric(ifelse(`[00].VehicleUpdate-roadInfo-roadAbscissa.0` == "null", 
                                       NA, `[00].VehicleUpdate-roadInfo-roadAbscissa.0`)),
      lane_id = as.numeric(ifelse(`[00].VehicleUpdate-roadInfo-laneId.0` == "null", 
                                 NA, `[00].VehicleUpdate-roadInfo-laneId.0`))
    ) %>%
    select(time, speed, headway_distance, lateral_shift, braking, time_headway, 
           vehicle_in_front_id, drive_section, road_abscissa, lane_id)
  
  return(data)
}

# Calculate summary metrics for highway tailgating scenario
calculate_highway_tailgating_metrics <- function(data) {
  # Remove rows with NA drive_section
  data_clean <- data %>%
    filter(!is.na(drive_section))
  
  # Calculate metrics by drive section (1-10)
  section_metrics <- data_clean %>%
    filter(drive_section >= 1 & drive_section <= 10) %>%
    group_by(drive_section) %>%
    summarise(
      # Basic metrics
      n_observations = n(),
      duration_seconds = max(time, na.rm = TRUE) - min(time, na.rm = TRUE),
      
      # Speed metrics
      avg_speed = mean(speed, na.rm = TRUE),
      sd_speed = sd(speed, na.rm = TRUE),
      min_speed = min(speed, na.rm = TRUE),
      max_speed = max(speed, na.rm = TRUE),
      
      # Lateral position metrics (SDLP - Standard Deviation of Lateral Position)
      sdlp = sd(lateral_shift, na.rm = TRUE),
      
      # Braking metrics - corrected to count actual braking episodes
      total_braking_events = {
        # Create binary brake indicator
        brake_binary <- ifelse(braking > 0, 1, 0)
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
        brake_binary <- ifelse(braking > 0, 1, 0)
        brake_binary[is.na(brake_binary)] <- 0
        
        if(sum(brake_binary) > 0) {
          # Get average pressure only during braking periods
          mean(braking[brake_binary == 1], na.rm = TRUE)
        } else {
          NA_real_
        }
      },
      max_braking_pressure = max(braking, na.rm = TRUE),
      
      # Headway metrics (tailgating behavior) - filter out unrealistic values
      avg_headway_distance = {
        valid_headway <- headway_distance[!is.na(headway_distance) & headway_distance <= 1000]
        if(length(valid_headway) > 0) {
          mean(valid_headway)
        } else {
          NA_real_
        }
      },
      min_headway_distance = {
        valid_headway <- headway_distance[!is.na(headway_distance) & headway_distance <= 1000]
        if(length(valid_headway) > 0) {
          min(valid_headway)
        } else {
          NA_real_
        }
      },
      avg_time_headway = {
        valid_time_headway <- time_headway[!is.na(time_headway) & time_headway <= 100]
        if(length(valid_time_headway) > 0) {
          mean(valid_time_headway)
        } else {
          NA_real_
        }
      },
      min_time_headway = {
        valid_time_headway <- time_headway[!is.na(time_headway) & time_headway <= 100]
        if(length(valid_time_headway) > 0) {
          min(valid_time_headway)
        } else {
          NA_real_
        }
      },
      
      .groups = 'drop'
    ) %>%
    # Handle infinite values from empty sections
    mutate(
      across(where(is.numeric), ~ifelse(is.infinite(.), NA, .))
    )
  
  return(section_metrics)
}

# Analyze single highway tailgating file
analyze_highway_tailgating <- function(filepath) {
  cat("Analyzing highway tailgating file:", basename(filepath), "\n")
  
  # Read and process data
  data <- read_highway_tailgating_data(filepath)
  metrics <- calculate_highway_tailgating_metrics(data)
  
  # Print summary
  cat("\n=== HIGHWAY TAILGATING ANALYSIS ===\n")
  cat("File:", basename(filepath), "\n")
  cat("Total observations:", nrow(data), "\n")
  cat("Duration:", round(max(data$time, na.rm = TRUE), 2), "seconds\n")
  cat("Sections found:", paste(sort(unique(data$drive_section[!is.na(data$drive_section)])), collapse = ", "), "\n\n")
  
  # Print section summaries
  cat("=== SECTION SUMMARIES ===\n")
  for(i in 1:10) {
    section_data <- metrics %>% filter(drive_section == i)
    if(nrow(section_data) > 0) {
      cat(sprintf("Section %d:\n", i))
      cat(sprintf("  Duration: %.1f seconds\n", section_data$duration_seconds))
      cat(sprintf("  Average Speed: %.1f km/h (SD: %.1f)\n", 
                  section_data$avg_speed, section_data$sd_speed))
      cat(sprintf("  SDLP: %.4f\n", section_data$sdlp))
      cat(sprintf("  Braking Events: %d\n", section_data$total_braking_events))
      cat(sprintf("  Average Brake Pressure per Event: %.4f\n", section_data$avg_braking_pressure_per_event))
      cat(sprintf("  Average Headway Distance: %.1f m\n", section_data$avg_headway_distance))
      cat(sprintf("  Minimum Headway Distance: %.1f m\n", section_data$min_headway_distance))
      cat(sprintf("  Average Time Headway: %.2f s\n", section_data$avg_time_headway))
      cat(sprintf("  Minimum Time Headway: %.2f s\n", section_data$min_time_headway))
      cat("\n")
    }
  }
  
  return(metrics)
}

# Extract participant info from filename
extract_participant_info <- function(filename) {
  # Extract participant ID, date, and time from filename
  # Expected format: Close_Following_Highway_Tailgaiting-DD_MM_YYYY-HHhMMmSSs_PPPP.csv
  base_name <- tools::file_path_sans_ext(basename(filename))
  
  # Try to extract date, time, and participant ID
  if(grepl("-(\\d{2})_(\\d{2})_(\\d{4})-(\\d{2})h(\\d{2})m(\\d{2})s_(\\d+)", base_name)) {
    matches <- regmatches(base_name, regexec("-(\\d{2})_(\\d{2})_(\\d{4})-(\\d{2})h(\\d{2})m(\\d{2})s_(\\d+)", base_name))[[1]]
    
    if(length(matches) >= 8) {
      day <- matches[2]
      month <- matches[3] 
      year <- matches[4]
      hour <- matches[5]
      minute <- matches[6]
      second <- matches[7]
      participant_id <- matches[8]
      
      date_str <- paste(day, month, year, sep="/")
      time_str <- paste(hour, minute, second, sep=":")
      
      return(list(
        participant_id = participant_id,
        date = date_str,
        time = time_str,
        filename = basename(filename)
      ))
    }
  }
  
  # Fallback if parsing fails
  return(list(
    participant_id = paste0("HWY_TG_", gsub("[^0-9]", "", base_name)),
    date = "Unknown",
    time = "Unknown", 
    filename = basename(filename)
  ))
}

# Process multiple highway tailgating files
process_highway_tailgating_batch <- function(data_dir, output_file = "projects/close_following/output/highway_tailgating_summary.csv") {
  # Find all highway tailgating CSV files
  csv_files <- list.files(data_dir, pattern = "*.csv", full.names = TRUE)
  
  if (length(csv_files) == 0) {
    stop("No CSV files found in directory: ", data_dir)
  }
  
  cat("Found", length(csv_files), "files to process\n")
  
  # Process each file
  all_summaries <- map_dfr(csv_files, function(filepath) {
    cat("Processing:", basename(filepath), "\n")
    
    tryCatch({
      # Extract participant info
      participant_info <- extract_participant_info(filepath)
      
      # Analyze data
      summary_data <- analyze_highway_tailgating(filepath)
      
      # Add participant information
      summary_data %>%
        mutate(
          participant_id = participant_info$participant_id,
          date = participant_info$date,
          time = participant_info$time,
          filename = participant_info$filename,
          .before = 1
        )
      
    }, error = function(e) {
      cat("Error processing", basename(filepath), ":", e$message, "\n")
      return(NULL)
    })
  })
  
  if(nrow(all_summaries) > 0) {
    # Reshape to wide format for easier analysis
    wide_summary <- all_summaries %>%
      select(participant_id, date, time, filename, drive_section, 
             avg_speed, sdlp, total_braking_events, avg_braking_pressure_per_event,
             avg_headway_distance, min_headway_distance, avg_time_headway, min_time_headway) %>%
      pivot_wider(
        names_from = drive_section,
        values_from = c(avg_speed, sdlp, total_braking_events, avg_braking_pressure_per_event,
                       avg_headway_distance, min_headway_distance, avg_time_headway, min_time_headway),
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
# 
# # Single file analysis
# result <- analyze_highway_tailgating("projects/close_following/data/raw/highway/tailgating/Close_Following_Highway_Tailgaiting-25_06_2025-14h50m03s_1234.csv")
# 
# # Batch processing
summary_data <- process_highway_tailgating_batch("projects/close_following/data/raw/highway/tailgating/")
# 
# # View results
# View(summary_data)