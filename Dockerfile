# Use a base image with Nix and Python 3.11
FROM nixos/nix:2.15.0

# Set environment variables for Nix configuration
ENV NIX_CONFIG="max-jobs=auto"
ENV USER=root

# Copy flake and project files to container
COPY . /app

# Set the working directory
WORKDIR /app

# Install Nix and Poetry dependencies
RUN nix-env --install nixFlakes && \
    nix develop .#default -c true

# Create the directories based on the flake configuration
RUN mkdir -p /etc/agl-anonymizer-temp /etc/agl-anonymizer/blurred_results /etc/agl-anonymizer/csv_training_data /etc/agl-anonymizer/results /etc/agl-anonymizer/models

# Set the necessary permissions for the directories
RUN chown -R root:root /etc/agl-anonymizer* && \
    chmod -R 775 /etc/agl-anonymizer*

# Set the environment variables for the Django service
ENV AGL_ANONYMIZER_TMP_DIR="/etc/agl-anonymizer-temp/temp"
ENV AGL_ANONYMIZER_BLURRED_DIR="/etc/agl-anonymizer/blurred_results"
ENV AGL_ANONYMIZER_CSV_DIR="/etc/agl-anonymizer/csv_training_data"
ENV AGL_ANONYMIZER_RESULTS_DIR="/etc/agl-anonymizer/results"
ENV AGL_ANONYMIZER_MODELS_DIR="/etc/agl-anonymizer/models"
ENV AGL_ANONYMIZER_MAIN_DIR="/etc/agl-anonymizer"
ENV DJANGO_SETTINGS_MODULE="agl_anonymizer.settings"
ENV DJANGO_DEBUG="false"

# Expose the Django server port
EXPOSE 8000

# Run Django's development server
CMD ["nix", "run", ".#default"]
