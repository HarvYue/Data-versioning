#!/bin/bash

echo "Container is running!!!"
echo "Architecture: $(uname -m)"
echo "Python version: $(python --version)"
echo "UV version: $(uv --version)"
echo $GCS_BUCKET_NAME

#登陆GCP
#gcloud为一个命令行工具，和uv(管理python包)、git（管理代码版本）、docker（管理容器）一样，这个用来管理google cloud
gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS

mkdir -p /mnt/gcs_data #在container中新建文件夹
#--key-file= 意思是指向存有钥匙的secret文件夹，$GCS_BUCKET_NAME为要挂的文件夹，/mnt/gcs_data为挂在的本地文件夹
#此处的mount和bind/volume不同，后者为Docker层面Docker run时指定，当前这个为linux层面的FUSE挂载，即容器跑起来之后自己挂
gcsfuse --key-file=$GOOGLE_APPLICATION_CREDENTIALS $GCS_BUCKET_NAME /mnt/gcs_data 
echo 'GCS bucket mounted at /mnt/gcs_data'

mkdir -p /app/cheese_dataset #新建文件夹

# Like Docker’s --mount type=bind, this makes the same folder available at another path without copying files.
# Here, Linux sets it up inside the running container.
mount --bind /mnt/gcs_data/images /app/cheese_dataset #Linux层面的mount 容器内的一个文件夹挂在另一个路径

# Activate virtual environment
echo "Activating virtual environment..."
source /.venv/bin/activate

# Keep a shell open
exec /bin/bash
