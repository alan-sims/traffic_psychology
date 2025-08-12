library(tidyverse)

# Function to extract participant info from MTB filename
extract_mtb_participant_info <- function(filename) {
  base_name <- tools::file_path_sans_ext(basename(filename))
  
  # Pattern: MBInt-DD_MM_YYYY-HHhMMmSSs_PPPP
  if(grepl("MBInt-(\\d{2})_(\\d{2})_(\\d{4})-(\\d{2})h(\\d{2})m(\\d{2})s_(\\d+)", base_name)) {
    matches <- regmatches(base_name, regexec("MBInt-(\\d{2})_(\\d{2})_(\\d{4})-(\\d{2})h(\\d{2})m(\\d{2})s_(\\d+)", base_name))[[1]]
    
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
  
  # Fallback
  return(list(
    participant_id = "unknown",
    date = "unknown",
    time = "unknown", 
    filename = basename(filename)
  ))
}

# Simpler function to determine intersection number based on distance resets
determine_intersection_number <- function(distance_to_intersection) {
  
  # Remove NA values
  distances <- distance_to_intersection[!is.na(distance_to_intersection)]
  
  if(length(distances) == 0) {
    return(rep(NA, length(distance_to_intersection)))
  }
  
  # Find where distance jumps back up (indicating crossing an intersection)
  # Look for increases > 100 meters from one point to the next
  distance_increases <- c(FALSE, diff(distances) > 100)
  
  # Count intersection crossings
  intersection_crossings <- cumsum(distance_increases)
  
  # Intersection sequence
  intersection_sequence <- c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 10.5, 11, 12, 13, 14, 15)
  
  # Assign intersection numbers
  intersection_numbers <- rep(NA, length(distances))
  
  for(i in 1:length(distances)) {
    current_intersection_index <- intersection_crossings[i] + 1  # +1 because we start at intersection 1
    
    if(current_intersection_index <= length(intersection_sequence)) {
      intersection_numbers[i] <- intersection_sequence[current_intersection_index]
    } else {
      intersection_numbers[i] <- "END"  # After intersection 15
    }
  }
  
  # Map back to original length (including NAs)
  result <- rep(NA, length(distance_to_intersection))
  result[!is.na(distance_to_intersection)] <- intersection_numbers
  
  return(result)
}

# Function to process single MTB file into intersection distance format
process_mtb_intersection_approach_data <- function(file_path) {
  
  # Read the tab-separated file
  data <- read_delim(file_path, 
                     delim = "\t", 
                     col_types = cols(.default = "c"),
                     locale = locale(encoding = "UTF-8"))
  
  # Extract participant info
  participant_info <- extract_mtb_participant_info(file_path)
  
  # Clean column names and convert data
  clean_data <- data %>%
    rename(
      time = `time`,
      speed = `[71 (Driver/Driver Speed)].ExportChannel-val`,
      lane_number = `[77 (Driver/Lane Number)].ExportChannel-val`,
      distance_to_intersection = `[88 (Driver/Distance to Intersection)].ExportChannel-val`
    ) %>%
    # Convert "null" strings to NA and then to numeric
    mutate(
      time = as.numeric(ifelse(time == "null", NA, time)),
      speed = as.numeric(ifelse(speed == "null", NA, speed)),
      lane_number = as.numeric(ifelse(lane_number == "null", NA, lane_number)),
      distance_to_intersection = as.numeric(ifelse(distance_to_intersection == "null", NA, distance_to_intersection))
    ) %>%
    # Remove rows where key variables are NA
    filter(!is.na(time) & !is.na(speed)) %>%
    # Determine intersection numbers using distance and lane patterns
    mutate(
      intersection_number = determine_intersection_number(distance_to_intersection)
    ) %>%
    # Add participant metadata and select final columns
    transmute(
      participant_id = participant_info$participant_id,
      date = participant_info$date,
      time = time,
      filename = participant_info$filename,
      intersection_number = intersection_number,
      intersection_distance = distance_to_intersection,
      speed = speed,
      lane_number = lane_number
    )
  
  return(clean_data)
}

# Function to process multiple MTB files into separate output files
process_mtb_intersection_approach_batch <- function(data_dir, output_dir = "projects/mtb_intersections/data/intersection_processed/") {
  
  # Create output directory if it doesn't exist
  if(!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }
  
  # Find all MTB CSV files
  csv_files <- list.files(data_dir, 
                         pattern = "MBInt.*\\.csv$", 
                         full.names = TRUE)
  
  if(length(csv_files) == 0) {
    stop("No MTB CSV files found in ", data_dir)
  }
  
  cat("Found", length(csv_files), "MTB files to process\n")
  
  # Process each file separately
  for(file_path in csv_files) {
    cat("Processing:", basename(file_path), "\n")
    
    tryCatch({
      # Process the file - FIXED: use correct function name
      processed_data <- process_mtb_intersection_approach_data(file_path)
      
      # Extract participant ID for filename
      participant_id <- unique(processed_data$participant_id)[1]
      
      # Create output filename
      output_filename <- paste0("intersections_", participant_id, ".csv")
      output_path <- file.path(output_dir, output_filename)
      
      # Write to CSV
      write_csv(processed_data, output_path)
      cat("  ✅ Saved:", output_filename, "\n")
      
    }, error = function(e) {
      cat("  ❌ Error processing", basename(file_path), ":", e$message, "\n")
    })
  }
  
  cat("\n✅ Batch processing complete!")
  cat("\n📁 Output files saved to:", output_dir, "\n")
}

# Function to create intersection approach plot
plot_intersection_approach <- function(processed_data) {
  
  # Create plot data
  plot_data <- processed_data %>%
    filter(!is.na(intersection_distance)) %>%
    mutate(
      time_seq = row_number() / 60,  # Assuming 60Hz sampling rate
      intersection_numeric = case_when(
        intersection_number == "END" ~ 16,
        TRUE ~ as.numeric(intersection_number)
      )
    )
  
  # Create labels for intersections
  label_data <- plot_data %>%
    group_by(intersection_number) %>%
    slice(as.integer(n()/2)) %>%
    filter(!is.na(intersection_number))
  
  # Create the plot
  ggplot(plot_data, aes(x = time_seq)) +
    geom_line(aes(y = intersection_distance), color = "blue") +
    geom_line(aes(y = intersection_numeric * 50), color = "red") +
    geom_text(data = label_data, 
              aes(x = time_seq, y = intersection_distance + 20, label = intersection_number),
              size = 3, color = "black") +
    scale_y_continuous(
      name = "Distance to Intersection (meters)",
      sec.axis = sec_axis(~ . / 50, name = "Approaching Intersection Number")
    ) +
    labs(title = "Distance to Intersection and Intersection Approaching", 
         x = "Time (seconds)") +
    theme_minimal() +
    theme(
      axis.title.y.left = element_text(color = "blue"),
      axis.text.y.left = element_text(color = "blue"),
      axis.title.y.right = element_text(color = "red"),
      axis.text.y.right = element_text(color = "red")
    )
}

# Usage examples (commented out to avoid errors when sourcing):
# 
# # Single file processing:
# result <- process_mtb_intersection_approach_data("data/raw/MBInt-29_07_2025-11h10m06s_4212.csv")
# 
# # Batch processing:
# process_mtb_intersection_approach_batch("data/raw/")
# 
# # Create plot:
# plot_intersection_approach(result)