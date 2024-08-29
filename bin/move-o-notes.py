import os
import time

# Define the folder path
folder_path = "C:\\Users\\geert\\Obsidian\\Personal\\_INBOX"
notes_folder_path = "C:\\Users\\geert\\Obsidian\\Personal\\notes"

# Ensure the notes folder exists
os.makedirs(notes_folder_path, exist_ok=True)
print(f"Ensured that the notes folder '{notes_folder_path}' exists.\n")

# Loop through all files in the directory
for filename in os.listdir(folder_path):
    file_path = os.path.join(folder_path, filename)

    # Check if the path is a file
    if os.path.isfile(file_path):
        print(f"Processing file: {file_path}")

        # Open the file to read the first line with UTF-8 encoding and ignore errors
        with open(file_path, "r", encoding="utf-8", errors="ignore") as file:
            first_line = file.readline()

        # Proceed only if the file starts with '---'
        if first_line.startswith("---"):
            print(f"The file '{filename}' starts with '---'. Proceeding to update...")

            # Get the creation time of the file
            creation_time = os.path.getctime(file_path)
            # Convert creation time to a readable format (YYYY-MM-DD HH:MM)
            readable_date = time.strftime(
                "%Y-%m-%d %H:%M", time.localtime(creation_time)
            )
            print(f"Creation time of the file '{filename}' is {readable_date}.")

            # Read the file content with UTF-8 encoding and ignore errors
            with open(file_path, "r", encoding="utf-8", errors="ignore") as file:
                lines = file.readlines()

            # Replace 'created:' with the actual creation date and time
            with open(file_path, "w", encoding="utf-8") as file:
                for line in lines:
                    if line.startswith("created:"):
                        print(
                            f"Replacing 'created:' in file '{filename}' with 'created: {readable_date}'"
                        )
                        line = f"created: {readable_date}\n"
                    file.write(line)

            # Move the file to the notes folder
            new_file_path = os.path.join(notes_folder_path, filename)
            os.rename(file_path, new_file_path)
            print(f"Moved file '{filename}' to '{notes_folder_path}'.\n")
        else:
            print(f"The file '{filename}' does not start with '---'. Skipping...\n")
    else:
        print(f"Skipping '{file_path}' as it is not a file.\n")

print("Processing complete.")
