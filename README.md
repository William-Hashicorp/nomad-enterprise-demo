To be updated

Deployment:

Step 1: Prepare image with Packer 
=======================================
    1. Update the "variables.hcl", change the region variable with your preferred AWS region. In this example, the region is us-east-2


    2. Build AMI image with packer

packer init image.pkr.hcl
packer build -var-file=variables.hcl image.pkr.hcl

You can get the image id of the new image from output.

    3. Update the terraform.tfvars with the ami ID.

