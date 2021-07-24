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

```
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

locals {
  iac_environment_tag = "prod"
  cluster_name        = "CLUSTER_NAME"
}

module "vpc_networking" {
  source = "github.com/luispe/terraform-eks-module/networking"

  cluster_name            = local.cluster_name
  iac_environment_tag     = local.iac_environment_tag
  name_prefix             = "kube"
  main_network_block      = "10.0.0.0/16"
  subnet_prefix_extension = 4
  zone_offset             = 8
}

module "eks" {
  source = "github.com/luispe/terraform-eks-module/cluster"

  vpc_id              = module.vpc_networking.vpc_id
  vpc_private_subnets = module.vpc_networking.vpc_private_subnets

  cluster_name                             = local.cluster_name
  cluster_version                          = "1.21"
  groups_name_prefix                       = "kube"
  admin_users                              = ["eks_admin_user"]
  developer_users                          = ["eks_developer_one", "eks_developer_twwo"]
  asg_instance_types                       = ["t2.small"]
  autoscaling_minimum_size_by_az           = 1
  autoscaling_maximum_size_by_az           = 3
  autoscaling_average_cpu                  = 70
  spot_termination_handler_chart_name      = "aws-node-termination-handler"
  spot_termination_handler_chart_repo      = "https://aws.github.io/eks-charts"
  spot_termination_handler_chart_version   = "0.9.1"
  spot_termination_handler_chart_namespace = "kube-system"
}
```
### Explaining the complete example above step by step:

In the **vpc_networking** module code block, we will create a new VPC with subnets on each Availability Zone with a single NAT Gateway to save some costs, adding some Tags required by EKS.

In the **eks** module code block:
- An EC2 autoscaling group for Kubernetes, composed by Spot instances autoscaled out/down based on CPU average usage.
- An EKS cluster, with two groups of users (called “admins” and “developers”).
- An EC2 Spot termination handler for Kubernetes, which takes care of reallocating Kubernetes objects when Spot instances get automatically terminated by AWS. This installation uses Helm to ease things up.

And we also define some Kubernetes/Helm Terraform providers, to be used later to install & configure stuff inside our Cluster using Terraform code.

⚠️ Note: The user IDs displayed above are fictitious, and of course they have to be customized according to the user groups present in your AWS account. Have in mind that these usernames do not have to exist as AWS IAM identities at the moment of creating the EKS Cluster nor assigning RBAC accesses, since they will live inside the Kubernetes Cluster only. IAM/Kubernetes usernames correlation is handled by AWS CLI at the moment of authenticating with the EKS Cluster.

The last step (not configuration required) set up RBAC permissions for the developers group defined in our EKS Cluster.

As you may see, [this configuration block](./cluster/rbac_iam.tf) grants access to see some Kubernetes objects (like pods, deployments, ingresses and services) as well as executing commands in running pods and create proxies to local ports.

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
