#!/bin/bash
apt-get update
apt-get install lib32z1
dpkg --add-architecture i386
apt-get update
apt-get install libxext6:i386 libxtst6:i386 libxi6:i386 libxrender1:i386

cd eSocketInstall_Ubuntu20.04_64bit

# List of directories containing installation scripts
DIRS=(
    "Step1_Java_jre"
    "Step2_Configure_VX805_USB_Device"
    "Step3_Install_RXTX_Serial_Comm"
    "Step4_Install_HSQLDB"
    "Step5_eSocket.POS_Setup"
)

# Current directory (where this script is located)
CURRENT_DIR=$(pwd)

echo "Starting installation process..."
echo "--------------------------------"

# Loop through each directory and run the installation script
for dir in "${DIRS[@]}"; do
    echo "Processing directory: $dir"

    # Check if directory exists
    if [ -d "$dir" ]; then
        # Navigate to the directory
        cd "$dir"

        # Find the install script (assuming it starts with "install_")
        INSTALL_SCRIPT=$(find . -maxdepth 1 -name "install_*" -type f | head -1)

        if [ -n "$INSTALL_SCRIPT" ]; then
            echo "Found installation script: $INSTALL_SCRIPT"
            echo "Running installation script..."

            # Make the script executable if it's not already
            chmod +x "$INSTALL_SCRIPT"

            # Run the installation script
            ./"$INSTALL_SCRIPT"

            echo "Installation completed for $dir"
        else
            echo "No installation script found in $dir. Skipping."
        fi

        # Return to the original directory
        cd "$CURRENT_DIR"
    else
        echo "Directory $dir does not exist. Skipping."
    fi

    echo "--------------------------------"
done

echo "All installations completed!"
