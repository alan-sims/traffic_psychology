# MTB Multitasking Analysis Functions
# Analysis of car-motorbike interactions at urban intersections

library(tidyverse)
library(readr)

# Read and parse MTB multitasking data from tab-separated CSV
read_mtb_multitasking_data <- function(file_path) {
  
  # Read the tab-separated file
  data <- read_delim(file_path, 
                     delim = "\t", 
                     col_types = cols(.default = "c"),
                     locale = locale(encoding = "UTF-8"))
  
  # Clean column names for easier handling
  clean_data <- data %>%
    rename(
      time = `time`,
      speed = `[71 (Driver/Driver Speed)].ExportChannel-val`,
      headway_distance = `[73 (Driver/Headway Distance)].ExportChannel-val`,
      lateral_shift = `[74 (Driver/Driver Lane Lateral Shift)].ExportChannel-val`,
      lane_number = `[77 (Driver/Lane Number)].ExportChannel-val`,
      int_1 = `[78 (Driver/Int_1)].ExportChannel-val`,
      int_2 = `[79 (Driver/Int_2)].ExportChannel-val`,
      int_4 = `[80 (Driver/Int_4)].ExportChannel-val`,
      int_6 = `[81 (Driver/Int_6)].ExportChannel-val`,
      int_7 = `[82 (Driver/Int_7)].ExportChannel-val`,
      int_10 = `[83 (Driver/Int_10)].ExportChannel-val`,
      int_14 = `[84 (Driver/Int_14)].ExportChannel-val`,
      int_15 = `[85 (Driver/Int_15)].ExportChannel-val`,
      time_headway = `[86 (Driver/Time Headway)].ExportChannel-val`,
      distance_to_intersection = `[88 (Driver/Distance to Intersection)].ExportChannel-val`
    ) %>%
    # Convert "null" strings to NA and then to numeric
    mutate(
      time = as.numeric(ifelse(time == "null", NA, time)),
      speed = as.numeric(ifelse(speed == "null", NA, speed)),
      headway_distance = as.numeric(ifelse(headway_distance == "null", NA, headway_distance)),
      lateral_shift = as.numeric(ifelse(lateral_shift == "null", NA, lateral_shift)),
      lane_number = as.numeric(ifelse(lane_number == "null", NA, lane_number)),
      int_1 = as.numeric(ifelse(int_1 == "null", NA, int_1)),
      int_2 = as.numeric(ifelse(int_2 == "null", NA, int_2)),
      int_4 = as.numeric(ifelse(int_4 == "null", NA, int_4)),
      int_6 = as.numeric(ifelse(int_6 == "null", NA, int_6)),
      int_7 = as.numeric(ifelse(int_7 == "null", NA, int_7)),
      int_10 = as.numeric(ifelse(int_10 == "null", NA, int_10)),
      int_14 = as.numeric(ifelse(int_14 == "null", NA, int_14)),
      int_15 = as.numeric(ifelse(int_15 == "null", NA, int_15)),
      time_headway = as.numeric(ifelse(time_headway == "null", NA, time_headway)),
      distance_to_intersection = as.numeric(ifelse(distance_to_intersection == "null", NA, distance_to_intersection))
    ) %>%
    # Remove rows where all key variables are NA (likely the null header rows)
    filter(!is.na(time))
  
  return(clean_data)
}

# Calculate summary metrics for MTB multitasking data
calculate_mtb_summary_metrics <- function(data) {
  
  # Overall driving metrics
  overall_metrics <- data %>%
    summarise(
      # Basic metrics
      total_duration_seconds = max(time, na.rm = TRUE) - min(time, na.rm = TRUE),
      n_observations = n(),
      
      # Speed metrics
      avg_speed = mean(speed, na.rm = TRUE),
      sd_speed = sd(speed, na.rm = TRUE),
      min_speed = min(speed, na.rm = TRUE),
      max_speed = max(speed, na.rm = TRUE),
      
      # Lateral position stability (SDLP)
      sdlp = sd(lateral_shift, na.rm = TRUE),
      
      # Following behavior (only when headway_distance > 0)
      avg_headway_distance = {
        valid_headway <- headway_distance[!is.na(headway_distance) & headway_distance > 0]
        if(length(valid_headway) > 0) {
          mean(valid_headway)
        } else {
          NA_real_
        }
      },
      avg_time_headway = {
        valid_time_headway <- time_headway[!is.na(time_headway) & time_headway > 0]
        if(length(valid_time_headway) > 0) {
          mean(valid_time_headway)
        } else {
          NA_real_
        }
      }
    )
  
  # Intersection behavior metrics
  intersection_metrics <- data %>%
    summarise(
      # Motorbike give-way intersections (0 = did not wait, 1 = did wait)
      int_1_gave_way = {
        int_1_values <- int_1[!is.na(int_1)]
        if(length(int_1_values) > 0) {
          max(int_1_values, na.rm = TRUE)  # Take max since it should be binary
        } else {
          NA_real_
        }
      },
      int_2_gave_way = {
        int_2_values <- int_2[!is.na(int_2)]
        if(length(int_2_values) > 0) {
          max(int_2_values, na.rm = TRUE)
        } else {
          NA_real_
        }
      },
      int_4_gave_way = {
        int_4_values <- int_4[!is.na(int_4)]
        if(length(int_4_values) > 0) {
          max(int_4_values, na.rm = TRUE)
        } else {
          NA_real_
        }
      },
      int_7_gave_way = {
        int_7_values <- int_7[!is.na(int_7)]
        if(length(int_7_values) > 0) {
          max(int_7_values, na.rm = TRUE)
        } else {
          NA_real_
        }
      },
      int_10_gave_way = {
        int_10_values <- int_10[!is.na(int_10)]
        if(length(int_10_values) > 0) {
          max(int_10_values, na.rm = TRUE)
        } else {
          NA_real_
        }
      },
      int_15_gave_way = {
        int_15_values <- int_15[!is.na(int_15)]
        if(length(int_15_values) > 0) {
          max(int_15_values, na.rm = TRUE)
        } else {
          NA_real_
        }
      },
      
      # Traffic light intersections (0 = ran light, !0 = stopped)
      int_6_stopped_at_light = {
        int_6_values <- int_6[!is.na(int_6)]
        if(length(int_6_values) > 0) {
          max(int_6_values, na.rm = TRUE)
        } else {
          NA_real_
        }
      },
      int_14_stopped_at_light = {
        int_14_values <- int_14[!is.na(int_14)]
        if(length(int_14_values) > 0) {
          max(int_14_values, na.rm = TRUE)
        } else {
          NA_real_
        }
      }
    )
  
  # Combine all metrics
  combined_metrics <- bind_cols(overall_metrics, intersection_metrics)
  
  return(combined_metrics)
}

# Analyze a single MTB multitasking file
analyze_mtb_multitasking <- function(file_path) {
  
  cat("Analyzing MTB multitasking file:", basename(file_path), "\n")
  
  # Read and process data
  raw_data <- read_mtb_multitasking_data(file_path)
  summary_metrics <- calculate_mtb_summary_metrics(raw_data)
  
  # Print summary
  cat("\n=== MTB MULTITASKING ANALYSIS ===\n")
  cat("File:", basename(file_path), "\n")
  cat("Total duration:", round(summary_metrics$total_duration_seconds, 1), "seconds\n")
  cat("Total observations:", summary_metrics$n_observations, "\n\n")
  
  # Print driving behavior metrics
  cat("=== DRIVING BEHAVIOR METRICS ===\n")
  cat(sprintf("Average Speed: %.1f km/h (SD: %.1f)\n", 
              summary_metrics$avg_speed, summary_metrics$sd_speed))
  cat(sprintf("Speed Range: %.1f - %.1f km/h\n", 
              summary_metrics$min_speed, summary_metrics$max_speed))
  cat(sprintf("SDLP (Lateral Position Stability): %.4f\n", summary_metrics$sdlp))
  
  if(!is.na(summary_metrics$avg_headway_distance)) {
    cat(sprintf("Average Headway Distance: %.1f m\n", summary_metrics$avg_headway_distance))
  }
  if(!is.na(summary_metrics$avg_time_headway)) {
    cat(sprintf("Average Time Headway: %.2f s\n", summary_metrics$avg_time_headway))
  }
  
  # Print intersection behavior
  cat("\n=== INTERSECTION BEHAVIOR ===\n")
  cat("Motorbike Give-Way Intersections (1 = gave way, 0 = did not wait):\n")
  cat(sprintf("  Intersection 1: %s\n", 
              ifelse(is.na(summary_metrics$int_1_gave_way), "No data", 
                     ifelse(summary_metrics$int_1_gave_way == 1, "Gave way", "Did not wait"))))
  cat(sprintf("  Intersection 2: %s\n", 
              ifelse(is.na(summary_metrics$int_2_gave_way), "No data", 
                     ifelse(summary_metrics$int_2_gave_way == 1, "Gave way", "Did not wait"))))
  cat(sprintf("  Intersection 4: %s\n", 
              ifelse(is.na(summary_metrics$int_4_gave_way), "No data", 
                     ifelse(summary_metrics$int_4_gave_way == 1, "Gave way", "Did not wait"))))
  cat(sprintf("  Intersection 7: %s\n", 
              ifelse(is.na(summary_metrics$int_7_gave_way), "No data", 
                     ifelse(summary_metrics$int_7_gave_way == 1, "Gave way", "Did not wait"))))
  cat(sprintf("  Intersection 10: %s\n", 
              ifelse(is.na(summary_metrics$int_10_gave_way), "No data", 
                     ifelse(summary_metrics$int_10_gave_way == 1, "Gave way", "Did not wait"))))
  cat(sprintf("  Intersection 15: %s\n", 
              ifelse(is.na(summary_metrics$int_15_gave_way), "No data", 
                     ifelse(summary_metrics$int_15_gave_way == 1, "Gave way", "Did not wait"))))
  
  cat("\nTraffic Light Intersections (>0 = stopped, 0 = ran light):\n")
  cat(sprintf("  Intersection 6: %s\n", 
              ifelse(is.na(summary_metrics$int_6_stopped_at_light), "No data", 
                     ifelse(summary_metrics$int_6_stopped_at_light > 0, "Stopped at light", "Ran light"))))
  cat(sprintf("  Intersection 14: %s\n", 
              ifelse(is.na(summary_metrics$int_14_stopped_at_light), "No data", 
                     ifelse(summary_metrics$int_14_stopped_at_light > 0, "Stopped at light", "Ran light"))))
  
  # Calculate compliance summary
  motorbike_intersections <- c(summary_metrics$int_1_gave_way, summary_metrics$int_2_gave_way, 
                              summary_metrics$int_4_gave_way, summary_metrics$int_7_gave_way,
                              summary_metrics$int_10_gave_way, summary_metrics$int_15_gave_way)
  traffic_light_intersections <- c(summary_metrics$int_6_stopped_at_light, summary_metrics$int_14_stopped_at_light)
  
  motorbike_compliance <- sum(motorbike_intersections == 1, na.rm = TRUE) / sum(!is.na(motorbike_intersections))
  traffic_light_compliance <- sum(traffic_light_intersections > 0, na.rm = TRUE) / sum(!is.na(traffic_light_intersections))
  
  cat("\n=== COMPLIANCE SUMMARY ===\n")
  if(!is.nan(motorbike_compliance)) {
    cat(sprintf("Motorbike Give-Way Compliance: %.1f%%\n", motorbike_compliance * 100))
  }
  if(!is.nan(traffic_light_compliance)) {
    cat(sprintf("Traffic Light Compliance: %.1f%%\n", traffic_light_compliance * 100))
  }
  
  return(list(
    raw_data = raw_data,
    summary_metrics = summary_metrics,
    file_path = file_path
  ))
}

# Extract participant information from filename
extract_participant_info <- function(filename) {
  # Expected format: MBInt29_07_202511h10m06s_4212.csv
  # Pattern: MBInt-DD_MM_YYYY-HHhMMmSSs_PPPP.csv
  
  base_name <- tools::file_path_sans_ext(basename(filename))
  
  # Try to extract date, time, and participant ID
  if(grepl("MBInt(\\d{2})_(\\d{2})_(\\d{4})(\\d{2})h(\\d{2})m(\\d{2})s_(\\d+)", base_name)) {
    matches <- regmatches(base_name, regexec("MBInt(\\d{2})_(\\d{2})_(\\d{4})(\\d{2})h(\\d{2})m(\\d{2})s_(\\d+)", base_name))[[1]]
    
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
    participant_id = paste0("MTB_", gsub("[^0-9]", "", base_name)),
    date = "Unknown",
    time = "Unknown", 
    filename = basename(filename)
  ))
}

# Process multiple MTB multitasking files and create summary CSV
process_mtb_multitasking_batch <- function(data_dir, output_file = "projects/mtb_multitasking/output/mtb_multitasking_summary.csv") {
  
  # Create output directory if it doesn't exist
  dir.create(dirname(output_file), showWarnings = FALSE, recursive = TRUE)
  
  # Find all MTB multitasking CSV files
  csv_files <- list.files(data_dir, 
                         pattern = "MBInt.*\\.csv$", 
                         full.names = TRUE)
  
  if(length(csv_files) == 0) {
    stop("No MTB multitasking CSV files found in ", data_dir)
  }
  
  cat("Found", length(csv_files), "MTB multitasking files to process\n")
  
  # Process each file
  all_summaries <- map_dfr(csv_files, function(file_path) {
    cat("Processing:", basename(file_path), "\n")
    
    tryCatch({
      # Get participant info
      participant_info <- extract_participant_info(file_path)
      
      # Analyze the file
      analysis_result <- analyze_mtb_multitasking(file_path)
      summary_data <- analysis_result$summary_metrics
      
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
      cat("Error processing", basename(file_path), ":", e$message, "\n")
      return(NULL)
    })
  })
  
  if(nrow(all_summaries) > 0) {
    # Write to CSV
    write_csv(all_summaries, output_file)
    cat("\n✅ Batch processing complete!")
    cat("\n📁 Summary saved to:", output_file)
    cat("\n📊 Processed", length(unique(all_summaries$participant_id)), "participants")
    cat("\n📈 Total", nrow(all_summaries), "records\n")
    
    return(all_summaries)
  } else {
    cat("❌ No files processed successfully\n")
    return(tibble())
  }
}

# Example usage:
# 
# # Single file analysis
# result <- analyze_mtb_multitasking("projects/mtb_multitasking/data/raw/MBInt-29_07_2025-11h10m06s_4212.csv")
#         
# # Batch processing
summary_data <- process_mtb_multitasking_batch("projects/mtb_multitasking/data/raw/")
# 
# # View results
# View(summary_data)