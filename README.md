# Overview

This Terraform configuration creates a Virtual Private Cloud (VPC) on AWS with public subnets, an Internet Gateway, two EC2 instances, security groups, an Application Load Balancer (ALB), target groups, and listener rules. The infrastructure is designed to route traffic based on specific URL paths to different target groups.

## Provider Configuration

Terraform Provider Block: Specifies the AWS provider and its version.
AWS Provider Configuration: Sets the AWS region to us-east-1.

## VPC and Subnets

VPC (Virtual Private Cloud):

Creates a VPC with a CIDR block of 10.0.0.0/16, providing a range of private IP addresses.
The VPC is tagged as dk-vpc.

* Public Subnets:

Two public subnets are created, one in availability zone us-east-1a and another in us-east-1b.
Both subnets have CIDR blocks of 10.0.1.0/24 and 10.0.2.0/24 respectively.
They are configured to auto-assign public IP addresses to instances launched within them.
Subnets are tagged as dksub1 and dksub2.

* Internet Gateway and Route Table

Internet Gateway:

An Internet Gateway (IGW) is created and attached to the VPC, allowing communication between the VPC and the internet.
It is tagged as dkigw.

Route Table:

A route table is created and associated with the VPC.
It includes a route that directs all outbound traffic (0.0.0.0/0) to the Internet Gateway.

* Route Table Associations:

The route table is associated with both public subnets, enabling internet access for resources within these subnets.

* Security Groups

Web Security Group:

Allows inbound HTTP (port 80), HTTPS (port 443), and SSH (port 22) traffic from any IP address.
Allows all outbound traffic.
This security group is used by the EC2 instances.

ALB Security Group:

Allows inbound HTTP (port 80) and HTTPS (port 443) traffic from any IP address.
Allows all outbound traffic.
This security group is used by the Application Load Balancer.

* EC2 Instances

EC2 Instances:
Two EC2 instances are created, each in one of the public subnets.
They use the specified AMI (ami-0195204d5dce06d99) and instance type (t2.micro).
They are associated with the web security group for proper ingress and egress traffic control.
Key pair specified by var.key_name is used for SSH access.
Instances are tagged as we-app-guarder and web-app-kider.

* Application Load Balancer (ALB) and Target Groups

ALB:

An Application Load Balancer is created to distribute incoming traffic across the EC2 instances.
It is an internet-facing ALB with a specified security group (alb-sg) and spans across both public subnets.

Target Groups:

Two target groups are created to register the EC2 instances.
Each target group listens on port 80 and uses the HTTP protocol.
Target groups are named TG-1 and TG-2.

Target Group Attachments:

EC2 instances are registered with their respective target groups, specifying the port on which they listen.

* Listener and Listener Rules

ALB Listener:

A listener is created on the ALB to listen for HTTP traffic on port 80.
Default action is to forward traffic to the first target group (TG-1).

Listener Rules:

Two listener rules are created to route traffic based on URL path patterns.
Rule 1: Routes traffic with the path pattern /guarder/* to TG-1.
Rule 2: Routes traffic with the path pattern /kider/* to TG-2.

* Outputs

EC2 Public IPs:

Outputs the public IP addresses of both EC2 instances, allowing easy access to them.

Load Balancer DNS Name:

Outputs the DNS name of the ALB, which can be used to access the load-balanced application.

* Variables

AMI: Specifies the Amazon Machine Image to use for the EC2 instances. Default is ami-0195204d5dce06d99.
Instance Type: Specifies the type of EC2 instance to launch. Default is t2.micro.
Key Name: Specifies the key pair to use for SSH access to the EC2 instances. Default is dk.

## Conclusion

This Terraform configuration sets up a robust AWS infrastructure with a VPC, subnets, security groups, EC2 instances, an Application Load Balancer, and listener rules for routing traffic based on URL paths. The configuration is designed for scalability and high availability, ensuring that traffic is distributed evenly across instances and routed correctly based on specified conditions.

To deploy this infrastructure, follow the usage instructions and ensure you have the necessary prerequisites. This setup provides a solid foundation for running web applications on AWS with Terraform.
