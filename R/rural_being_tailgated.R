# Rural Being Tailgated Analysis Functions
# Analysis of close following behavior in rural being tailgated scenario

library(tidyverse)
library(readr)

# Read and parse rural being tailgated data from tab-separated CSV
read_rural_tailgated_data <- function(file_path) {
  
  # Read the tab-separated file
  data <- read_delim(file_path, 
                     delim = "\t", 
                     col_types = cols(.default = "c"),
                     locale = locale(encoding = "UTF-8"))
  
  # Clean column names for easier handling
  clean_data <- data %>%
    rename(
      time = `time`,
      speed = `[03 (Driver/Driver Speed)].ExportChannel-val`,
      lateral_shift = `[06 (Driver/Driver Lane Lateral Shift)].ExportChannel-val`,
      lane_number = `[09 (Driver/Lane Number)].ExportChannel-val`,
      braking = `[10 (Driver/Braking)].ExportChannel-val`,
      drive_section = `[17 (Driver/Drive Section)].ExportChannel-val`,
      road_abscissa = `[00].VehicleUpdate-roadInfo-roadAbscissa.0`,
      lane_id = `[00].VehicleUpdate-roadInfo-laneId.0`
    ) %>%
    # Convert "null" strings to NA and then to numeric
    mutate(
      time = as.numeric(ifelse(time == "null", NA, time)),
      speed = as.numeric(ifelse(speed == "null", NA, speed)),
      lateral_shift = as.numeric(ifelse(lateral_shift == "null", NA, lateral_shift)),
      lane_number = as.numeric(ifelse(lane_number == "null", NA, lane_number)),
      braking = as.numeric(ifelse(braking == "null", NA, braking)),
      drive_section = as.numeric(ifelse(drive_section == "null", NA, drive_section)),
      road_abscissa = as.numeric(ifelse(road_abscissa == "null", NA, road_abscissa)),
      lane_id = as.numeric(ifelse(lane_id == "null", NA, lane_id))
    ) %>%
    # Remove rows where all key variables are NA
    filter(!is.na(time))
  
  return(clean_data)
}

# Calculate summary metrics for rural being tailgated data by drive section
calculate_summary_metrics <- function(data) {
  
  # Filter to valid drive sections (0-4)
  valid_data <- data %>%
    filter(!is.na(drive_section) & drive_section %in% 0:4)
  
  # Calculate metrics by section
  section_metrics <- valid_data %>%
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
      avg_lateral_shift = mean(lateral_shift, na.rm = TRUE),
      sdlp = sd(lateral_shift, na.rm = TRUE),
      
      # Braking metrics
      total_braking_events = sum(braking > 0, na.rm = TRUE),
      avg_braking_pressure = mean(braking, na.rm = TRUE),
      max_braking_pressure = max(braking, na.rm = TRUE),
      
      # Lane metrics
      avg_lane_number = mean(lane_number, na.rm = TRUE),
      lane_changes = sum(abs(diff(lane_number, na.rm = TRUE)) > 0, na.rm = TRUE),
      
      # Basic crash detection (heuristic)
      potential_crashes = sum(speed < 5 & braking > 0.5, na.rm = TRUE),
      
      .groups = 'drop'
    ) %>%
    # Add section descriptions
    mutate(
      section_description = case_when(
        drive_section == 0 ~ "Warm-up (0-200m)",
        drive_section == 1 ~ "Rural 100km/h (initial)",
        drive_section == 2 ~ "Township 60km/h", 
        drive_section == 3 ~ "Rural 100km/h (normal following)",
        drive_section == 4 ~ "Rural 100km/h (close following 0.5s)",
        TRUE ~ "Unknown"
      )
    )
  
  return(section_metrics)
}

# Analyze a single rural being tailgated file
analyze_rural_tailgated <- function(file_path) {
  
  cat("Analyzing rural being tailgated file:", basename(file_path), "\n")
  
  # Read and process data
  raw_data <- read_rural_tailgated_data(file_path)
  summary_metrics <- calculate_summary_metrics(raw_data)
  
  # Print summary
  cat("\n=== RURAL BEING TAILGATED ANALYSIS ===\n")
  cat("File:", basename(file_path), "\n")
  cat("Total duration:", max(raw_data$time, na.rm = TRUE), "seconds\n")
  cat("Total observations:", nrow(raw_data), "\n")
  cat("Sections found:", paste(sort(unique(raw_data$drive_section[!is.na(raw_data$drive_section)])), collapse = ", "), "\n\n")
  
  # Print section summaries
  cat("=== SECTION SUMMARIES ===\n")
  for(i in 0:4) {
    section_data <- summary_metrics %>% filter(drive_section == i)
    if(nrow(section_data) > 0) {
      cat(sprintf("Section %d (%s):\n", i, section_data$section_description))
      cat(sprintf("  Duration: %.1f seconds\n", section_data$duration_seconds))
      cat(sprintf("  Average Speed: %.1f km/h (SD: %.1f)\n", 
                  section_data$avg_speed, section_data$sd_speed))
      cat(sprintf("  SDLP: %.4f\n", section_data$sdlp))
      cat(sprintf("  Braking Events: %d\n", section_data$total_braking_events))
      cat(sprintf("  Lane Changes: %d\n", section_data$lane_changes))
      if(section_data$potential_crashes > 0) {
        cat(sprintf("  ⚠️  Potential crashes: %d\n", section_data$potential_crashes))
      }
      cat("\n")
    }
  }
  
  return(list(
    raw_data = raw_data,
    summary_metrics = summary_metrics,
    file_path = file_path
  ))
}

# Extract participant information from filename
extract_participant_info <- function(filename) {
  # Expected format: Close_Following_Rural_Being_Tailgaited-DD_MM_YYYY-HHhMMmSSs_PPPP.csv
  # Current format: Close_Following_Rural_Being_Tailgaited02_07_202513h56m57s.csv
  
  base_name <- tools::file_path_sans_ext(basename(filename))
  
  # Try to extract date and time
  if(grepl("(\\d{2})_(\\d{2})_(\\d{4})(\\d{2})h(\\d{2})m(\\d{2})s", base_name)) {
    matches <- regmatches(base_name, regexec("(\\d{2})_(\\d{2})_(\\d{4})(\\d{2})h(\\d{2})m(\\d{2})s", base_name))[[1]]
    
    if(length(matches) >= 7) {
      day <- matches[2]
      month <- matches[3] 
      year <- matches[4]
      hour <- matches[5]
      minute <- matches[6]
      second <- matches[7]
      
      date_str <- paste(day, month, year, sep="/")
      time_str <- paste(hour, minute, second, sep=":")
      
      # Try to extract participant ID (if exists after the datetime)
      remaining <- sub(".*\\d{2}h\\d{2}m\\d{2}s", "", base_name)
      participant_id <- if(nchar(remaining) > 0) {
        gsub("^_", "", remaining)
      } else {
        paste0("RURAL_BT_", gsub("[^0-9]", "", matches[2:7]))
      }
      
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
    participant_id = paste0("RURAL_BT_", gsub("[^0-9]", "", base_name)),
    date = "Unknown",
    time = "Unknown", 
    filename = basename(filename)
  ))
}

# Process multiple rural being tailgated files and create summary CSV
process_rural_tailgated_batch <- function(data_dir, output_file = "rural_being_tailgated_summary.csv") {
  
  # Find all rural being tailgated CSV files
  csv_files <- list.files(data_dir, 
                         pattern = "Close_Following_Rural_Being_Tailgaited.*\\.csv$", 
                         full.names = TRUE)
  
  if(length(csv_files) == 0) {
    stop("No rural being tailgated CSV files found in ", data_dir)
  }
  
  cat("Found", length(csv_files), "rural being tailgated files to process\n")
  
  # Process each file
  all_summaries <- map_dfr(csv_files, function(file_path) {
    cat("Processing:", basename(file_path), "\n")
    
    tryCatch({
      # Get participant info
      participant_info <- extract_participant_info(file_path)
      
      # Analyze the file
      analysis_result <- analyze_rural_tailgated(file_path)
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
    # Save the long format (section-by-section) data
    long_output_file <- gsub("\\.csv$", "_long.csv", output_file)
    write_csv(all_summaries, long_output_file)
    
    # Reshape to wide format for easier analysis
    wide_summary <- all_summaries %>%
      select(participant_id, date, time, filename, drive_section, 
             avg_speed, sdlp, total_braking_events, potential_crashes) %>%
      pivot_wider(
        names_from = drive_section,
        values_from = c(avg_speed, sdlp, total_braking_events, potential_crashes),
        names_glue = "{.value}_section_{drive_section}"
      )
    
    # Write wide format to CSV
    write_csv(wide_summary, output_file)
    
    cat("\n✅ Batch processing complete!")
    cat("\n📁 Long format saved to:", long_output_file)
    cat("\n📁 Wide format saved to:", output_file)
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
# result <- analyze_rural_tailgated("data/raw/rural/being_tailgated/Close_Following_Rural_Being_Tailgaited02_07_202513h56m57s.csv")
# 
# # Batch processing
# summary_data <- process_rural_tailgated_batch("data/raw/rural/being_tailgated/")
# 
# # View results
# View(summary_data)