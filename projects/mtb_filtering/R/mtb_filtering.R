# MTB Filtering Analysis Functions
# Analysis of motorcycle filtering behavior at 100kph scenarios

library(tidyverse)
library(readr)

# Read and parse MTB filtering data from tab-separated CSV
read_mtb_filtering_data <- function(file_path) {
  
  # Read the tab-separated file
  data <- read_delim(file_path, 
                     delim = "\t", 
                     col_types = cols(.default = "c"),
                     locale = locale(encoding = "UTF-8"))
  
  # Clean column names for easier handling
  clean_data <- data %>%
    rename(
      time = names(.)[1],
      speed = names(.)[2],
      headway_distance = names(.)[3],
      lateral_shift = names(.)[4],
      braking = names(.)[5],
      time_headway = names(.)[6]
    ) %>%
    # Convert "null" strings to NA and then to numeric
    mutate(
      time = as.numeric(ifelse(time == "null" | is.na(time), NA, time)),
      speed = as.numeric(ifelse(speed == "null" | is.na(speed), NA, speed)),
      headway_distance = as.numeric(ifelse(headway_distance == "null" | is.na(headway_distance), NA, headway_distance)),
      lateral_shift = as.numeric(ifelse(lateral_shift == "null" | is.na(lateral_shift), NA, lateral_shift)),
      braking = as.numeric(ifelse(braking == "null" | is.na(braking), NA, braking)),
      time_headway = as.numeric(ifelse(time_headway == "null" | is.na(time_headway), NA, time_headway))
    ) %>%
    # Remove rows where all key variables are NA
    filter(!is.na(time) & !is.na(speed))
  
  return(clean_data)
}

# Calculate summary metrics for MTB filtering data
calculate_mtb_filtering_metrics <- function(data) {
  
  # Filter out rows with NA speed values
  valid_data <- data %>%
    filter(!is.na(speed)) %>%
    mutate(
      # Filter out default/invalid headway values (99000 indicates no vehicle in front)
      headway_distance = ifelse(headway_distance >= 500, NA, headway_distance),
      time_headway = ifelse(time_headway >= 30, NA, time_headway)
    )
  
  # Calculate comprehensive metrics
  metrics <- list(
    # Basic metrics
    n_observations = nrow(valid_data),
    duration_seconds = max(valid_data$time, na.rm = TRUE) - min(valid_data$time, na.rm = TRUE),
    
    # Speed metrics
    mean_speed = mean(valid_data$speed, na.rm = TRUE),
    sd_speed = sd(valid_data$speed, na.rm = TRUE),
    min_speed = min(valid_data$speed, na.rm = TRUE),
    max_speed = max(valid_data$speed, na.rm = TRUE),
    
    # Headway distance metrics (filtered to realistic values)
    mean_headway_distance = mean(valid_data$headway_distance, na.rm = TRUE),
    sd_headway_distance = sd(valid_data$headway_distance, na.rm = TRUE),
    min_headway_distance = min(valid_data$headway_distance, na.rm = TRUE),
    
    # Time headway metrics (filtered to realistic values)
    mean_time_headway = mean(valid_data$time_headway, na.rm = TRUE),
    sd_time_headway = sd(valid_data$time_headway, na.rm = TRUE),
    min_time_headway = min(valid_data$time_headway, na.rm = TRUE),
    
    # Lateral position metrics (SDLP - Standard Deviation of Lateral Position)
    mean_lateral_shift = mean(valid_data$lateral_shift, na.rm = TRUE),
    sd_lateral_shift = sd(valid_data$lateral_shift, na.rm = TRUE)
  )
  
  return(metrics)
}

# Analyze a single MTB filtering file
analyze_mtb_filtering <- function(file_path) {
  
  cat("Analyzing MTB filtering file:", basename(file_path), "\n")
  
  # Read and process data
  raw_data <- read_mtb_filtering_data(file_path)
  metrics <- calculate_mtb_filtering_metrics(raw_data)
  
  # Print summary
  cat("\n=== MTB FILTERING ANALYSIS ===\n")
  cat("File:", basename(file_path), "\n")
  cat("Total duration:", sprintf("%.1f", metrics$duration_seconds), "seconds\n")
  cat("Total observations:", metrics$n_observations, "\n\n")
  
  cat("=== SPEED METRICS ===\n")
  cat(sprintf("  Mean Speed: %.1f km/h (SD: %.1f)\n", metrics$mean_speed, metrics$sd_speed))
  cat(sprintf("  Speed Range: %.1f - %.1f km/h\n", metrics$min_speed, metrics$max_speed))
  
  cat("\n=== FOLLOWING BEHAVIOR ===\n")
  cat(sprintf("  Mean Headway Distance: %.1f m (SD: %.1f)\n", 
              metrics$mean_headway_distance, metrics$sd_headway_distance))
  cat(sprintf("  Mean Time Headway: %.2f s (SD: %.2f)\n", 
              metrics$mean_time_headway, metrics$sd_time_headway))
  
  cat("\n=== LATERAL STABILITY ===\n")
  cat(sprintf("  SDLP (Lateral Stability): %.4f\n", metrics$sd_lateral_shift))
  
  cat("\n")
  
  return(list(
    raw_data = raw_data,
    metrics = metrics,
    file_path = file_path
  ))
}

# Extract participant information from filename
extract_participant_info <- function(filename) {
  # Expected format: Motorcycles_100kph_[Legal/Illegal]_Filtering_[Position]-DD_MM_YYYY-HHhMMmSSs_PPPP.csv
  # Examples: 
  # - Motorcycles_100kph_Illegal_Filtering_Middle_Lane-01_04_2025-18h12m43s_1402.csv
  # - Motorcycles_100kph_Legal_Filtering_Right_Left_Side-06_05_2025-14h03m11s_6115.csv
  
  base_name <- tools::file_path_sans_ext(basename(filename))
  
  # Extract legality and position from filename
  condition <- "Unknown"
  if(grepl("Legal_Filtering_Middle_Lane", base_name)) {
    condition <- "Legal_Middle"
  } else if(grepl("Illegal_Filtering_Middle_Lane", base_name)) {
    condition <- "Illegal_Middle"
  } else if(grepl("Legal_Filtering_Right_Left_Side", base_name)) {
    condition <- "Legal_Side"
  } else if(grepl("Illegal_Filtering_Right_Left_Side", base_name)) {
    condition <- "Illegal_Side"
  }
  
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
        condition = condition,
        filename = basename(filename)
      ))
    }
  }
  
  # Fallback if parsing fails
  return(list(
    participant_id = paste0("MTB_", gsub("[^0-9]", "", base_name)),
    date = "Unknown",
    time = "Unknown",
    condition = condition,
    filename = basename(filename)
  ))
}

# Process multiple MTB filtering files and create summary CSV
process_mtb_filtering_batch <- function(data_dir, output_file = "output/mtb_filtering_summary.csv") {
  
  # Create output directory if it doesn't exist
  dir.create(dirname(output_file), showWarnings = FALSE, recursive = TRUE)
  
  # Find all MTB filtering CSV files
  csv_files <- list.files(data_dir, 
                         pattern = "Motorcycles_100kph_(Legal|Illegal)_Filtering.*\\.csv$", 
                         full.names = TRUE)
  
  if(length(csv_files) == 0) {
    stop("No MTB filtering CSV files found in ", data_dir)
  }
  
  cat("Found", length(csv_files), "MTB filtering files to process\n")
  
  # Process each file
  all_summaries <- map_dfr(csv_files, function(file_path) {
    cat("Processing:", basename(file_path), "\n")
    
    tryCatch({
      # Get participant info
      participant_info <- extract_participant_info(file_path)
      
      # Analyze the file
      analysis_result <- analyze_mtb_filtering(file_path)
      metrics <- analysis_result$metrics
      
      # Create summary row
      summary_row <- tibble(
        participant_id = participant_info$participant_id,
        date = participant_info$date,
        time = participant_info$time,
        condition = participant_info$condition,
        filename = participant_info$filename,
        n_observations = metrics$n_observations,
        duration_seconds = metrics$duration_seconds,
        mean_speed = metrics$mean_speed,
        sd_speed = metrics$sd_speed,
        min_speed = metrics$min_speed,
        max_speed = metrics$max_speed,
        mean_headway_distance = metrics$mean_headway_distance,
        sd_headway_distance = metrics$sd_headway_distance,
        min_headway_distance = metrics$min_headway_distance,
        mean_time_headway = metrics$mean_time_headway,
        sd_time_headway = metrics$sd_time_headway,
        min_time_headway = metrics$min_time_headway,
        sd_lateral_shift = metrics$sd_lateral_shift
      )
      
      return(summary_row)
      
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
    cat("\n📊 Processed", nrow(all_summaries), "participants")
    cat("\n🏍️  Conditions found:", paste(unique(all_summaries$condition), collapse = ", "))
    
    # Print quick summary by condition
    cat("\n\n=== SUMMARY BY CONDITION ===\n")
    condition_summary <- all_summaries %>%
      group_by(condition) %>%
      summarise(
        count = n(),
        mean_speed = mean(mean_speed, na.rm = TRUE),
        mean_headway = mean(mean_headway_distance, na.rm = TRUE),
        mean_sdlp = mean(sd_lateral_shift, na.rm = TRUE),
        .groups = 'drop'
      )
    print(condition_summary)
    
    return(all_summaries)
  } else {
    cat("❌ No files processed successfully\n")
    return(tibble())
  }
}

# Example usage:
# 
# # Single file analysis
# result <- analyze_mtb_filtering("data/raw/Motorcycles_100kph_Legal_Filtering_Middle_Lane-02_05_2025-12h40m02s_9898.csv")
# 
# # Batch processing
# summary_data <- process_mtb_filtering_batch("data/raw/")
# 
# # View results
# View(summary_data)