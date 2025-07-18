# Updated Highway Tailgating Analysis Functions with Fixed Crash Detection
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
      avg_speed = mean(speed, na.rm = TRUE),
      sdlp = sd(lateral_shift, na.rm = TRUE),
      avg_headway_distance = mean(headway_distance, na.rm = TRUE),
      avg_time_headway = mean(time_headway, na.rm = TRUE),
      min_headway_distance = min(headway_distance, na.rm = TRUE),
      min_time_headway = min(time_headway, na.rm = TRUE),
      max_braking = max(braking, na.rm = TRUE),
      avg_braking = mean(braking, na.rm = TRUE),
      total_brake_events = sum(braking > 0, na.rm = TRUE),
      section_duration = max(time, na.rm = TRUE) - min(time, na.rm = TRUE),
      .groups = 'drop'
    ) %>%
    # Handle infinite values from empty sections
    mutate(
      across(where(is.numeric), ~ifelse(is.infinite(.), NA, .))
    )
  
  # Fixed crash detection with proper NA handling
  valid_data <- data_clean %>% 
    filter(!is.na(headway_distance) | !is.na(braking))
  
  if (nrow(valid_data) > 0) {
    # Check for crash conditions
    crash_data <- valid_data %>%
      filter((!is.na(headway_distance) & headway_distance < 5) | 
             (!is.na(braking) & braking > 0.8))
    
    # Calculate overall safety metrics
    overall_metrics <- list(
      crash_detected = nrow(crash_data) > 0,
      min_headway_overall = if(any(!is.na(valid_data$headway_distance))) {
        min(valid_data$headway_distance, na.rm = TRUE)
      } else { NA },
      max_braking_overall = if(any(!is.na(valid_data$braking))) {
        max(valid_data$braking, na.rm = TRUE)
      } else { NA }
    )
  } else {
    overall_metrics <- list(
      crash_detected = FALSE,
      min_headway_overall = NA,
      max_braking_overall = NA
    )
  }
  
  return(list(
    section_metrics = section_metrics,
    crash_events = overall_metrics
  ))
}

# Analyze single highway tailgating file
analyze_highway_tailgating <- function(filepath) {
  cat("Analyzing highway tailgating file:", basename(filepath), "\n")
  
  # Read and process data
  data <- read_highway_tailgating_data(filepath)
  metrics <- calculate_highway_tailgating_metrics(data)
  
  # Print summary
  cat("\n=== HIGHWAY TAILGATING ANALYSIS SUMMARY ===\n")
  cat("File:", basename(filepath), "\n")
  cat("Total observations:", nrow(data), "\n")
  cat("Duration:", round(max(data$time, na.rm = TRUE), 2), "seconds\n")
  
  # Section-wise metrics
  cat("\n--- Drive Section Metrics ---\n")
  print(metrics$section_metrics)
  
  # Crash detection with improved output
  cat("\n--- Safety Metrics ---\n")
  if (metrics$crash_events$crash_detected) {
    cat("⚠️  Potential crash event detected!\n")
  } else {
    cat("✓ No crash events detected\n")
  }
  
  if (!is.na(metrics$crash_events$min_headway_overall)) {
    cat("Minimum headway distance:", round(metrics$crash_events$min_headway_overall, 2), "meters\n")
  } else {
    cat("Minimum headway distance: No valid data\n")
  }
  
  if (!is.na(metrics$crash_events$max_braking_overall)) {
    cat("Maximum braking pressure:", round(metrics$crash_events$max_braking_overall, 2), "\n")
  } else {
    cat("Maximum braking pressure: No valid data\n")
  }
  
  return(metrics)
}

# Extract participant info from filename
extract_participant_info <- function(filename) {
  # Extract participant ID, date, and time from filename
  # Expected format: Close_Following_Highway_Tailgaiting-DD_MM_YYYY-HHhMMmSSs_PPPP.csv
  base_name <- tools::file_path_sans_ext(basename(filename))
  
  # Split by underscores and hyphens
  parts <- strsplit(base_name, "[-_]")[[1]]
  
  if (length(parts) >= 4) {
    participant_id <- parts[length(parts)]  # Last part should be participant ID
    date_part <- parts[length(parts) - 2]   # Date part
    time_part <- parts[length(parts) - 1]   # Time part
    
    return(list(
      participant_id = participant_id,
      date = date_part,
      time = time_part
    ))
  } else {
    return(list(
      participant_id = "unknown",
      date = "unknown",
      time = "unknown"
    ))
  }
}

# Process multiple highway tailgating files
process_highway_tailgating_batch <- function(data_dir, output_file = "highway_tailgating_summary.csv") {
  # Find all highway tailgating CSV files
  csv_files <- list.files(data_dir, pattern = "*.csv", full.names = TRUE)
  
  if (length(csv_files) == 0) {
    stop("No CSV files found in directory: ", data_dir)
  }
  
  cat("Found", length(csv_files), "files to process\n")
  
  # Process each file
  all_results <- map_dfr(csv_files, function(filepath) {
    cat("Processing:", basename(filepath), "\n")
    
    tryCatch({
      # Extract participant info
      participant_info <- extract_participant_info(filepath)
      
      # Analyze data
      data <- read_highway_tailgating_data(filepath)
      metrics <- calculate_highway_tailgating_metrics(data)
      
      # Create summary row
      result <- tibble(
        participant_id = participant_info$participant_id,
        date = participant_info$date,
        time = participant_info$time,
        filename = basename(filepath),
        total_observations = nrow(data),
        duration_seconds = max(data$time, na.rm = TRUE),
        crash_detected = metrics$crash_events$crash_detected,
        min_headway_overall = metrics$crash_events$min_headway_overall,
        max_braking_overall = metrics$crash_events$max_braking_overall
      )
      
      # Add section-wise metrics
      for (section in 1:10) {
        section_data <- metrics$section_metrics %>% filter(drive_section == section)
        
        if (nrow(section_data) > 0) {
          result[[paste0("section_", section, "_avg_speed")]] <- section_data$avg_speed
          result[[paste0("section_", section, "_sdlp")]] <- section_data$sdlp
          result[[paste0("section_", section, "_avg_headway_distance")]] <- section_data$avg_headway_distance
          result[[paste0("section_", section, "_avg_time_headway")]] <- section_data$avg_time_headway
          result[[paste0("section_", section, "_min_headway_distance")]] <- section_data$min_headway_distance
          result[[paste0("section_", section, "_min_time_headway")]] <- section_data$min_time_headway
          result[[paste0("section_", section, "_max_braking")]] <- section_data$max_braking
          result[[paste0("section_", section, "_total_brake_events")]] <- section_data$total_brake_events
        } else {
          result[[paste0("section_", section, "_avg_speed")]] <- NA
          result[[paste0("section_", section, "_sdlp")]] <- NA
          result[[paste0("section_", section, "_avg_headway_distance")]] <- NA
          result[[paste0("section_", section, "_avg_time_headway")]] <- NA
          result[[paste0("section_", section, "_min_headway_distance")]] <- NA
          result[[paste0("section_", section, "_min_time_headway")]] <- NA
          result[[paste0("section_", section, "_max_braking")]] <- NA
          result[[paste0("section_", section, "_total_brake_events")]] <- NA
        }
      }
      
      return(result)
      
    }, error = function(e) {
      cat("Error processing", basename(filepath), ":", e$message, "\n")
      return(NULL)
    })
  })
  
  # Write results to CSV
  write_csv(all_results, output_file)
  cat("\nBatch processing complete! Results saved to:", output_file, "\n")
  cat("Processed", nrow(all_results), "files successfully\n")
  
  return(all_results)
}