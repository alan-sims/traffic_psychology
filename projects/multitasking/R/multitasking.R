# Multi-tasking Driving Simulator Analysis Functions
library(tidyverse)
library(readr)

# Read multi-tasking driving data from tab-separated CSV
read_multitask_driving_data <- function(filepath) {
  # Read the tab-separated file
  data <- read_delim(filepath, delim = "\t", show_col_types = FALSE)
  
  # Convert "null" strings to NA and convert numeric columns
  data <- data %>%
    mutate(
      collision_count = as.numeric(ifelse(`[100 (Driver/Count of Collisions)].ExportChannel-val` == "null", 
                                         NA, `[100 (Driver/Count of Collisions)].ExportChannel-val`)),
      scenario_section = as.numeric(ifelse(`[90 (Driver/Scenario Section)].ExportChannel-val` == "null", 
                                          NA, `[90 (Driver/Scenario Section)].ExportChannel-val`)),
      speed_limit = as.numeric(ifelse(`[91 (Driver/Road Speed Limit)].ExportChannel-val` == "null", 
                                     NA, `[91 (Driver/Road Speed Limit)].ExportChannel-val`)),
      lane_position = as.numeric(ifelse(`[92 (Driver/Drivers Lane Position)].ExportChannel-val` == "null", 
                                       NA, `[92 (Driver/Drivers Lane Position)].ExportChannel-val`)),
      driver_speed = as.numeric(ifelse(`[93 (Driver/Drivers Speed)].ExportChannel-val` == "null", 
                                      NA, `[93 (Driver/Drivers Speed)].ExportChannel-val`)),
      brake_force = as.numeric(ifelse(`[94 (Driver/Brake Pedal Force)].ExportChannel-val` == "null", 
                                     NA, `[94 (Driver/Brake Pedal Force)].ExportChannel-val`)),
      accelerator = as.numeric(ifelse(`[95 (Driver/Accelerator Pedal)].ExportChannel-val` == "null", 
                                     NA, `[95 (Driver/Accelerator Pedal)].ExportChannel-val`)),
      time_headway = as.numeric(ifelse(`[96 (Driver/Time Headway)].ExportChannel-val` == "null", 
                                      NA, `[96 (Driver/Time Headway)].ExportChannel-val`)),
      distance_headway = as.numeric(ifelse(`[97 (Driver/Distance Headway)].ExportChannel-val` == "null", 
                                          NA, `[97 (Driver/Distance Headway)].ExportChannel-val`)),
      lane_number = as.numeric(ifelse(`[99 (Driver/Drivers Lane Number)].ExportChannel-val` == "null", 
                                     NA, `[99 (Driver/Drivers Lane Number)].ExportChannel-val`))
    ) %>%
    select(time, collision_count, scenario_section, speed_limit, lane_position, 
           driver_speed, brake_force, accelerator, time_headway, distance_headway, lane_number)
  
  return(data)
}

# Calculate summary metrics for multi-tasking driving scenario
calculate_multitask_driving_metrics <- function(data) {
  # Remove rows with NA scenario_section
  data_clean <- data %>%
    filter(!is.na(scenario_section))
  
  # Calculate metrics by scenario section
  section_metrics <- data_clean %>%
    group_by(scenario_section, speed_limit) %>%
    summarise(
      # Basic metrics
      n_observations = n(),
      duration_seconds = max(time, na.rm = TRUE) - min(time, na.rm = TRUE),
      
      # Speed metrics
      mean_speed = mean(driver_speed, na.rm = TRUE),
      sd_speed = sd(driver_speed, na.rm = TRUE),
      
      # Speed coherence with speed limit (how well driver follows speed limit)
      speed_coherence = {
        if(!is.na(speed_limit[1]) && speed_limit[1] > 0) {
          # Calculate how close driver speed is to speed limit
          speed_diff <- abs(driver_speed - speed_limit)
          mean_deviation = mean(speed_diff, na.rm = TRUE)
          # Convert to coherence score (lower deviation = higher coherence)
          max(0, 1 - (mean_deviation / speed_limit[1]))
        } else {
          NA_real_
        }
      },
      
      # Lane position metrics (SDLP - Standard Deviation of Lateral Position)
      sdlp = sd(lane_position, na.rm = TRUE),
      
      # Headway metrics - filter out unrealistic values (99900 when no car in front)
      mean_headway_distance = {
        valid_headway <- distance_headway[!is.na(distance_headway) & distance_headway != 99900 & distance_headway < 1000 & distance_headway > 0]
        if(length(valid_headway) > 0) {
          mean(valid_headway)
        } else {
          NA_real_
        }
      },
      sd_headway_distance = {
        valid_headway <- distance_headway[!is.na(distance_headway) & distance_headway != 99900 & distance_headway < 1000 & distance_headway > 0]
        if(length(valid_headway) > 0) {
          sd(valid_headway)
        } else {
          NA_real_
        }
      },
      
      # Time to collision (safety time) metrics
      mean_ttc = {
        # Calculate TTC as headway distance / relative speed
        # Using time headway as proxy for TTC
        valid_ttc <- time_headway[!is.na(time_headway) & time_headway > 0 & time_headway <= 100]
        if(length(valid_ttc) > 0) {
          mean(valid_ttc)
        } else {
          NA_real_
        }
      },
      sd_ttc = {
        valid_ttc <- time_headway[!is.na(time_headway) & time_headway > 0 & time_headway <= 100]
        if(length(valid_ttc) > 0) {
          sd(valid_ttc)
        } else {
          NA_real_
        }
      },
      
      # Collision metrics
      collision_occurrence = max(collision_count, na.rm = TRUE),
      
      # Brake use metrics
      brake_events = {
        # Count braking episodes
        brake_binary <- ifelse(brake_force > 0, 1, 0)
        brake_binary[is.na(brake_binary)] <- 0
        
        if(length(brake_binary) > 1) {
          sum(diff(brake_binary) == 1, na.rm = TRUE)
        } else {
          ifelse(brake_binary[1] == 1, 1, 0)
        }
      },
      mean_brake_force = mean(brake_force[brake_force > 0], na.rm = TRUE),
      max_brake_force = max(brake_force, na.rm = TRUE),
      
      # Lane ID (most common lane)
      primary_lane = {
        lane_counts <- table(lane_number[!is.na(lane_number)])
        if(length(lane_counts) > 0) {
          as.numeric(names(lane_counts)[which.max(lane_counts)])
        } else {
          NA_real_
        }
      },
      
      .groups = 'drop'
    ) %>%
    # Handle infinite values
    mutate(
      across(where(is.numeric), ~ifelse(is.infinite(.), NA, .))
    )
  
  return(section_metrics)
}

# Analyze single multi-tasking driving file
analyze_multitask_driving <- function(filepath) {
  cat("Analyzing multi-tasking driving file:", basename(filepath), "\n")
  
  # Read and process data
  data <- read_multitask_driving_data(filepath)
  metrics <- calculate_multitask_driving_metrics(data)
  
  # Print summary
  cat("\n=== MULTI-TASKING DRIVING ANALYSIS ===\n")
  cat("File:", basename(filepath), "\n")
  cat("Total observations:", nrow(data), "\n")
  cat("Duration:", round(max(data$time, na.rm = TRUE), 2), "seconds\n")
  cat("Sections found:", paste(sort(unique(data$scenario_section[!is.na(data$scenario_section)])), collapse = ", "), "\n\n")
  
  # Print section summaries
  cat("=== SECTION SUMMARIES ===\n")
  for(i in sort(unique(metrics$scenario_section))) {
    section_data <- metrics %>% filter(scenario_section == i)
    if(nrow(section_data) > 0) {
      cat(sprintf("Section %d (Speed Limit: %.0f km/h):\n", i, section_data$speed_limit[1]))
      cat(sprintf("  Duration: %.1f seconds\n", section_data$duration_seconds))
      cat(sprintf("  Mean Speed: %.1f km/h (SD: %.1f)\n", 
                  section_data$mean_speed, section_data$sd_speed))
      cat(sprintf("  Speed Coherence: %.3f\n", section_data$speed_coherence))
      cat(sprintf("  SDLP: %.4f\n", section_data$sdlp))
      cat(sprintf("  Mean Headway Distance: %.1f m (SD: %.1f)\n", 
                  section_data$mean_headway_distance, section_data$sd_headway_distance))
      cat(sprintf("  Mean TTC: %.2f s (SD: %.2f)\n", 
                  section_data$mean_ttc, section_data$sd_ttc))
      cat(sprintf("  Collisions: %d\n", section_data$collision_occurrence))
      cat(sprintf("  Brake Events: %d (Mean Force: %.2f)\n", 
                  section_data$brake_events, section_data$mean_brake_force))
      cat(sprintf("  Primary Lane: %d\n", section_data$primary_lane))
      cat("\n")
    }
  }
  
  return(metrics)
}

# Extract participant info from filename
extract_multitask_participant_info <- function(filename) {
  # Extract participant ID, date, and time from filename
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
      
      # Extract drive type from filename
      drive_type <- case_when(
        grepl("Drive 1|home.*Office 1", base_name, ignore.case = TRUE) ~ "Home_to_Office1",
        grepl("Drive 2|Office 2.*Multi-task 1", base_name, ignore.case = TRUE) ~ "Office1_to_Office2_Multitask1",
        grepl("Drive 3|Office 1.*Multi-task 2", base_name, ignore.case = TRUE) ~ "Office2_to_Office1_Multitask2",
        TRUE ~ "Unknown_Drive"
      )
      
      return(list(
        participant_id = participant_id,
        date = date_str,
        time = time_str,
        drive_type = drive_type,
        filename = basename(filename)
      ))
    }
  }
  
  # Fallback if parsing fails
  return(list(
    participant_id = paste0("MT_", gsub("[^0-9]", "", base_name)),
    date = "Unknown",
    time = "Unknown",
    drive_type = "Unknown_Drive",
    filename = basename(filename)
  ))
}

# Process multiple multi-tasking driving files
process_multitask_driving_batch <- function(data_dir, output_file = "projects/multitasking/output/multitask_driving_summary.csv") {
  # Find all CSV files
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
      participant_info <- extract_multitask_participant_info(filepath)
      
      # Analyze data
      summary_data <- analyze_multitask_driving(filepath)
      
      # Add participant information
      summary_data %>%
        mutate(
          participant_id = participant_info$participant_id,
          date = participant_info$date,
          time = participant_info$time,
          drive_type = participant_info$drive_type,
          filename = participant_info$filename,
          .before = 1
        )
      
    }, error = function(e) {
      cat("Error processing", basename(filepath), ":", e$message, "\n")
      return(NULL)
    })
  })
  
  if(nrow(all_summaries) > 0) {
    # Create a comprehensive summary with all metrics
    final_summary <- all_summaries %>%
      select(participant_id, date, time, drive_type, filename, scenario_section, speed_limit,
             mean_speed, sd_speed, speed_coherence, sdlp, mean_headway_distance, 
             sd_headway_distance, mean_ttc, sd_ttc, collision_occurrence, 
             brake_events, mean_brake_force, primary_lane)
    
    # Write to CSV
    write_csv(final_summary, output_file)
    cat("\n✅ Batch processing complete!")
    cat("\n📁 Summary saved to:", output_file)
    cat("\n📊 Processed", length(unique(all_summaries$participant_id)), "participants")
    cat("\n🚗 Drive types:", paste(unique(all_summaries$drive_type), collapse = ", "))
    cat("\n📈 Total", nrow(all_summaries), "section summaries\n")
    
    return(final_summary)
  } else {
    cat("❌ No files processed successfully\n")
    return(tibble())
  }
}

# Example usage:
# 
# # Single file analysis
# result <- analyze_multitask_driving("projects/multitasking/data/raw/Drive 2 - Drive to Office 2 (Multi-task 1)-28_07_2025-08h51m07s_1234.csv")
# 
# # Batch processing
# summary_data <- process_multitask_driving_batch("projects/multitasking/data/raw/")
# 
# # View results
# View(summary_data)