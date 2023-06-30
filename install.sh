#!/bin/bash

folder_name="Tools"
repo_urls=(
    "https://github.com/initstring/cloud_enum.git"
    "https://github.com/MantisSTS/GoCloud.git"
    "https://github.com/m4ll0k/SecretFinder.git"
)
install_dir=~/Tools
secret_finder_file="$install_dir/SecretFinder/SecretFinder.py"
regex_file="$(pwd)/regex.txt"
folder_dest="$(pwd)"

# Create folder "~/Tools" if it doesn't exist
if [ ! -d "$install_dir" ]; then
    mkdir -p "$install_dir"
    echo "Folder '$folder_name' created successfully at $install_dir."
else
    echo "Folder '$folder_name' already exists."
fi

# Move to the installation directory
cd "$install_dir" || exit

for repo_url in "${repo_urls[@]}"
do
    # Get the repository name from the URL
    repo_name=$(basename "$repo_url" .git)

    # Clone the repository from GitHub
    if git clone "$repo_url"; then
        echo "Repository '$repo_name' downloaded successfully."
    else
        echo "Failed to download repository '$repo_name'."
        continue
    fi

    # Move to the repository directory
    cd "$install_dir/$repo_name" || continue

    # Check and run commands based on the repository
    if [[ "$repo_name" == "cloud_enum" ]]; then
        echo "Repository '$repo_name' downloaded successfully."
        # Run the command "pip3 install -r ./requirements.txt"
        echo "Installing dependencies for '$repo_name'..."
        pip3 install -r ./requirements.txt
    elif [[ "$repo_name" == "GoCloud" ]]; then
        echo "Repository '$repo_name' downloaded successfully."
        # Run the command "go build ."
        echo "Building '$repo_name'..."
        go build .
        ./GoCloud -update
        # Move all files from the GoCloud folder to the Cloud-Service-Hunting folder
        mv * "$folder_dest"
        echo "All files from the 'GoCloud' folder have been moved to the 'Cloud-Service-Hunting' folder."
        # Remove the GoCloud folder
        cd ..
        rm -rf GoCloud
        echo "Folder 'GoCloud' has been removed."
    elif [[ "$repo_name" == "SecretFinder" ]]; then
        echo "Repository '$repo_name' downloaded successfully."
        # Run the command "python -m pip install -r requirements.txt"
        echo "Installing dependencies for '$repo_name'..."
        python -m pip install -r requirements.txt
    fi

    # Return to the installation directory
    cd "$install_dir"
done
