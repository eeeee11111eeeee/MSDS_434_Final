# Start from the official TensorFlow Serving base image
FROM tensorflow/serving

# Copy the model files from your current directory into the container.
# The path is critical: /models/<model_name>/<version_number>/
COPY ./ /models/real_estate_price_model/1/

# Define the name of the model for the serving process
ENV MODEL_NAME=real_estate_price_model

# Expose the default gRPC and REST API ports
EXPOSE 8500 8501
