# Set common variables for the environment. This is automatically pulled in in the root terragrunt.hcl configuration to
# feed forward to the child modules.
locals {
  # --- BEGIN General Configuration --- #

  # Environment name to be appended to all resource names. Should be unique per region.
  # The length of the Environment value must be 6 characters or less.
  environment = "dev"

  # Additional identifier to be prepended to all resource names
  # Note: This variable can be set at stack creation via the cloudformation template. If you do set this variable here
  # be sure to set OverrideRepositoryParameters setting to 'false' when creating the pipeline stack in cloudformation.
  #
  #identifier = ""

  # The SSM parameter name that stores the Dozuki Customer ID provided to you. If empty Terraform will attempt to get
  # the license from a parameter with name /{identifier}/dozuki/{environment}/customer_id or
  # /dozuki/{environment}/customer_id if identifier is not set.
  # Note: This variable is auto-populated via a parameter in the CloudFormation stack creation. You should only set
  # this variable if you already have an SSM parameter setup for the Dozuki Customer ID before stack creation.
  #
  #dozuki_customer_id_parameter_name = ""

  # On fresh installs this variable specifies which channel to find the sequence indicated in `replicated_app_sequence_number`
  # variable. This channel id must be associated to your customer account. If left blank the default channel id will be used.
  #
  # Note: This is NOT the channel name, but the UUID of the channel. This must be provided to you by Dozuki.
  #
  # Default: "" (which will look for the sequence in the default channel associated with your license)
  #replicated_channel = ""

  # This option will spin up additional infrastructure to support webhooks. This includes an external AWS managed Kafka
  # cluster as well as redis and mongodb deployed onto the kubernetes cluster. Webhooks must be enabled on your license
  # before you enable this.
  #
  # Possible options: true, false
  # Default: false
  #enable_webhooks = false

  # Specify whether data protection settings should be enabled for databases, s3 buckets, and compute clusters. This should
  # be set to true for production stacks and false for others. When set to true, databases will have deletion protection
  # enabled and will need to be manually disabled if you ever want to delete this stack.
  #
  # Possible options: true,false
  # Default: true
  protect_resources = false

  # If deploying on a workstation, what AWSCLI credential profile should we use.
  # Note: This is not used if deploying using codepipeline & cloudformation.
  #
  # Default: "default"
  #aws_profile = "default"

  # Google translate API token to support machine translation.
  #
  # Default: ""
  #google_translate_api_token = ""

  # --- END General Configuration --- #

  # --- BEGIN Networking Configuration --- #
  # (Values below reflect defaults if unset)

  # The number of Availability zones we should use for deployment.
  #
  # Possible options: 3 - 10
  # Default: 3
  #azs_count = 3

  # The VPC ID to where we'll be deploying our resources. (If creating a new VPC leave this field and subnets blank).
  #
  # Default: ""
  #vpc_id = ""

  # The CIDR block for the VPC, should not need to change this unless you have exotic VPC configurations.
  #
  # Default: "172.16.0.0/16"
  #vpc_cidr = "172.16.0.0/16"

  # Should be true if you want to provision a highly available NAT Gateway across all of your private networks
  #
  # Possible options: true, false
  # Default: true
  highly_available_nat_gateway = false

  # These CIDRs will be allowed to connect to the app dashboard. This is where you upgrade to new versions as well as
  # view cluster status and start/stop the cluster. You probably want to lock this down to your company network CIDR,
  # especially if you chose 'true' for public access.
  #
  # Note: To add multiple CIDRs, separate entries with a comma: ["1.1.1.1/32","1.0.0.0/27"]
  # Default: ["0.0.0.0/0"]
  #replicated_ui_access_cidrs = ["0.0.0.0/0"]

  # These CIDRs will be allowed to connect to Dozuki. If running a public site, use the default value. Otherwise you
  # probably want to lock this down to the VPC or your VPN CIDR."
  #
  # Note: To add multiple CIDRs, separate entries with a comma: ["1.1.1.1/32","1.0.0.0/27"]
  # Default: ["0.0.0.0/0"]
  #app_access_cidrs = ["0.0.0.0/0"]

  # Should the app and dashboard be accessible via a publicly routable IP and domain?
  #
  # Possible options: true, false
  # Default: true
  #app_public_access = true

  # --- END Networking Configuration --- #

  # --- BEGIN EKS & Worker Node Configuration --- #

  # The instance types for the spot fleet in the application's EKS worker node group.
  #
  # Possible options: any AWS ec2 instance types supported in your region
  # Default: ["m5.large", "m5a.large", "m5d.large", "m5ad.large"]
  #eks_instance_types = ["m5.large", "m5a.large", "m5d.large", "m5ad.large"]

  # The amount of local storage (in gigabytes) to allocate to each kubernetes node. Keep in mind you will be billed for
  # this amount of storage multiplied by how many nodes you spin up (i.e. 50GB * 4 nodes = 200GB on your bill).
  # For production installations 50GB should be the minimum. This local storage is used as a temporary holding area for
  # uploaded and in-process assets like videos and images.
  #
  # Default: 50
  #eks_volume_size = 50

  # The minimum amount of nodes we will auto-scale to.
  #
  # Default: 2
  #eks_min_size = 2

  # The maximum amount of nodes we will auto-scale to.
  #
  # Default: 10
  #eks_max_size = 10

  # This is what the node count will start out as.
  #
  # Default: 3
  #eks_desired_capacity = 3

  # The KMS key to use to encrypt cluster secrets. If none is specified a new key will be created.
  #
  # Default: ""
  #eks_kms_key_id = ""

  # --- END EKS & Worker Node Configuration --- #

  # --- BEGIN Database and storage Options --- #

  # AWS KMS key identifier for S3 encryption. The identifier can be one of the following format: Key id, key ARN, alias
  # name or alias ARN
  #
  # Default: "alias/aws/s3"
  #s3_kms_key_id = "alias/aws/s3"

  # Whether to create the Dozuki S3 buckets or not. If this is set to false, you must specify the bucket names in the
  # variables below.
  #
  # Possible options: true, false
  # Default: true
  #create_s3_buckets = true

  # If you have existing data in S3 buckets you can specify them here. These should be left blank if creating a fresh
  # install. If setting these variables, be sure to set "create_s3_buckets" to false or these will be ignored.
  #
  #s3_objects_bucket = ""
  #s3_images_bucket = ""
  #s3_documents_bucket = ""
  #s3_pdfs_bucket = ""
  #s3_logging_bucket = ""

  # AWS KMS key identifier for RDS encryption. The identifier can be one of the following format: Key id, key ARN,
  # alias name or alias ARN
  #
  # Default: "alias/aws/rds"
  #rds_kms_key_id = "alias/aws/rds"

  # We can seed the database from an existing RDS snapshot in this region. Type the snapshot identifier in this field
  # or leave blank to start with a fresh database. Note: If you *do* use a snapshot it's critical that during stack
  # updates you continue to include the snapshot identifier in this parameter. Clearing this parameter after using it
  # will cause AWS to spin up a new fresh DB and DELETE YOUR OLD ONE.
  #
  #rds_snapshot_identifier = ""

  # The instance type to use for your database. See this page for a breakdown of the performance and cost differences
  # between the different instance types:
  # https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.DBInstanceClass.html
  #
  # Note: In some AWS regions they do not have m4 instances so you may need to switch to m5 and vice versa.
  # Default: "db.m4.large"
  #rds_instance_type = "db.m4.large"

  # If true we will tell RDS to automatically deploy and manage a highly available standby instance of your database.
  # Enabling this doubles the cost of the RDS instance but without it you are susceptible to downtime if the AWS
  # availability zone your RDS instance is in becomes unavailable.
  #
  # Possible options: true, false
  # Default: true
  rds_multi_az = false

  # The initial size of the database storage allocated (in Gigabytes).
  #
  # Default: 100
  #rds_allocated_storage = 100

  # The maximum size to which AWS will scale the database storage (in Gigabytes).
  #
  # Default: 500
  #rds_max_allocated_storage = 500

  # The number of days to keep automatic database backups. Setting this value to 0 disables automatic backups.
  #
  # Default: 30
  rds_backup_retention_period = 7

  # This option will spin up a BI slave of your master database and enable conditional replication (everything but the
  # mysql table will be replicated so you can have custom users).
  #
  # Possible options: true, false
  # Default: false
  #enable_bi = false

  # If BI is enabled above, this flag will allow or deny internet access to the BI database server. If you set this to
  # true, be sure to update the `bi_access_cidrs` variable to an ip range that includes only the locations you want to
  # allow access to. It's highly discouraged to use a wide-open setting like 0.0.0.0/0.
  #
  # Note: This setting is mutually exlusive with `bi_vpn_access`. Both cannot be true.
  #
  # Possible options: true, false
  # Default: false
  #bi_public_access = false

  # If BI is enabled above, this flag, if set to true, will create an OpenVPN server and connection credentials that will
  # allow secure access to the BI database server. If you set this to true, be sure to update the `bi_access_cidrs` variable
  # to an ip range that includes only the locations you want to allow access to the VPN server. It's highly discouraged
  # to use a wide-open setting like 0.0.0.0/0. Be sure to review the `bi_vpn_user_list` variable for credential settings.
  #
  # Note: This setting is mutually exlusive with `bi_public_access`. Both cannot be true.
  #
  # Possible options: true, false
  # Default: false
  #bi_vpn_access = false

  # If BI & VPN access is enabled above, these are the users for which credentials and configuration will be generated.
  # The OpenVPN server uses mutual authentication which means it's all TLS certificate based, no passwords
  # are needed. The terraform will generate OpenVPN configuration files that include the proper certificates and upload
  # them to an s3 bucket. The bucket name will be output once the physical module completes, you can then navigate to that
  # bucket and download the credential and configuration file to load into your OpenVPN client of choice
  #
  # Note: Each user in this list will have unique credentials and configuration generated for them.
  #
  # Possible options: Any list of usernames, separate multiple with a comma: ["root", "user1"]
  # Default: ["root"]
  #bi_vpn_user_list = ["root"]

  # If BI and either public or vpn access is enabled above, this is the CIDR list that will be allowed to access either
  # the BI database itself (if public is enabled) or the VPN server (if VPN is enabled). If unset, the terraform code
  # will set this variable to the VPC CIDR, this is a secure default but not what you want if you are using
  # `bi_public_access` or `bi_vpn_access` so be sure to update it accordingly. Although possible to use a wide-open setting
  # like ["0.0.0.0/0"] this is highly discouraged as anyone on the internet would be able to access the BI database or
  # the VPN server and thus your entire proprietary dataset could be exposed if they are able to compromise the VPN or
  # MySQL server.
  #
  # Note: To use multiple CIDRs, separate them with a comma like so: ["0.0.0.0/0", "1.1.1.1/32"]
  #
  # Possible options: Any IPv4 CIDR like ["0.0.0.0/0"] or ["1.1.1.1/32"]
  # Default: VPC CIDR
  #bi_access_cidrs = []

  # If BI is enabled Grafana will be installed on your stack and be accessible at port 3000. This is the CIDR list that
  # will be allowed access. If left blank it will default to the VPC CIDR which means you would need a transit gateway
  # or VPN into the VPC to access it.
  #
  # Possible options: Any IPv4 CIDR like ["0.0.0.0/0"] or ["1.1.1.1/32"]
  # Default: VPC CIDR
  #grafana_access_cidrs = []

  # If BI is enabled and if a self-signed SSL cert is generated for Grafana, you can specify
  # a custom Common Name using this variable. This is helpful if you have a `mysite.dozuki.com` subdomain and do not use
  # a proper SSL certificate.
  #
  # Note: This variable is mutually exclusive with `grafana_use_replicated_ssl`. If that variable is set to true, this one
  # will be ignored as we will not be generating a self-signed SSL certificate.
  #
  # Default: The AWS Loadbalancer DNS
  #grafana_ssl_cn = ""

  # If BI is enabled we will use the SSL certificate generated by/uploaded to the Replicated dashboard. This will tie
  # your dashboard install to your app SSL configuration which should be the default for most installations. If you normally
  # upload your SSL cert to the Replicated dashboard, this value should be set to true.
  #
  # Possible options: true or false
  # Default: true
  #grafana_use_replicated_ssl = true


  # The compute and memory capacity of the nodes in the Cache Cluster
  #
  # Possible options: Any supported AWS ElastiCache instance type in your region
  # Default: "cache.t2.micro"
  #elasticache_instance_type = "cache.t2.micro"

  # The cluster size for your cache pool
  #
  # Possible options: >= 1
  # Default 1
  #elasticache_cluster_size = 1

  # --- END Database and storage Options --- #
}
