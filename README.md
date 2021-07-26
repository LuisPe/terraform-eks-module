# terraform-eks-module

A terraform module to create a managed Kubernetes cluster on AWS EKS. Inspired by and adapted from [this doc](https://www.terraform.io/docs/providers/aws/guides/eks-getting-started.html) and its [source code](https://github.com/terraform-providers/terraform-provider-aws/tree/master/examples/eks-getting-started).

## Assumptions
- You want to create an EKS cluster and an autoscaling group of workers for the cluster.
- You want these resources to exist within security groups that allow communication and coordination. These can be user provided or created within the module.
- You've created a Virtual Private Cloud (VPC) and subnets where you intend to put the EKS resources. The VPC satisfies [EKS requirements](https://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html).

## Important note

Validate your terraform and aws cli version

```
terraform --version
```
Should be >= 0.15.5

```
aws --version
```
Should be >= 2.2.16

First steps, configure your terraform and aws context


```
terraform{
    backend "s3" {
    bucket  = "your-bucket-app-infra"
    key     = "tf-state.json"
    profile = "aws_cli_profile"
    region  = "aws_region"
  }
}
```

If you want more granular organization into s3, declare `workspace_key_prefix = "folder"` into backend object:

```
terraform{
    backend "s3" {
    bucket  = "your-bucket-app-infra"
    key     = "tf-state.json"
    profile = "aws_cli_profile"
    region  = "aws_region"
    workspace_key_prefix = "eks_tfstate"
  }
}
```

Which will look like this

```
s3://your-bucket-app-infra/
|_ eks_tfstate/
  |_ tf-state.json
```

⚠️ Important: The S3 bucket defined in here will not be created by Terraform if it does not exist in AWS. This bucket has be externally created by manual action, or using a CI/CD tool running a command like this:

```
aws s3 mb s3://your-bucket-app-infra --region us-east-1
```

## Full example

```hcl
terraform{
    backend "s3" {
    bucket  = "your-bucket-app-infra"
    key     = "tf-state.json"
    profile = "aws_cli_administrator"
    region  = "us-east-1"
  }
}

provider "aws" {
  profile = "aws_cli_administrator"
  region  = "us-east-1"
}

module "my_cluster" {
  source = "github.com/luispe/terraform-eks-module"
  
  # vpc_networking settings
  cidr_block     = "172.16.0.0/16"
  vpc_cidr_block = "10.0.0.0/16"
  az             = ["us-east-1a", "us-east-1b", "us-east-1c"]

  # eks settings
  eks_cluster_name       = "testing"
  eks_cluster_version    = "1.21"
  private_instance_types = ["t3.medium"]
  private_desired_size   = 2
  private_min_size       = 2
  private_max_size       = 4
  public_instance_types  = ["t3.small"]
  public_desired_size    = 1
  public_min_size        = 3
  public_max_size        = 1
}
```
### Explaining the complete example above step by step:

In the **vpc_networking settings** code block, we will create a new VPC with subnets on each Availability Zone with a single NAT Gateway to save some costs, adding some Tags required by EKS.

In the **eks settings** code block we will create a new:
- An EC2 autoscaling group for Kubernetes, composed instances autoscaled out/down.
- An EKS cluster.

### We finally deploy

```
terraform init

terraform plan

terraform apply
```
For delete cluster
```
terraform destroy
```
