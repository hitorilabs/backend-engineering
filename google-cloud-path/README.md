# Setting up your VPC

References:
[AWS - VPC Deployment Guide](https://aws.amazon.com/solutions/implementations/vpc/)

Networking Crash Course

- Internet Protocol (IP)
- Network Address Translation (NAT)
- Access Control List (ACL)

> A highly available architecture that spans two to four Availability Zones.

> A VPC configured with public and private subnets, according to AWS best practices, to provide you with your own virtual network on AWS. The VPC provides Domain Name System (DNS) resolution.

> In the public subnets:
> Managed network address translation (NAT) gateways to allow outbound internet access for resources in the private subnets.
> Dedicated custom network access control lists (ACLs) for each Availability Zone.
> A single routing table (not shown) because the public subnets all use the same internet gateway as the sole route to communicate with the internet.

> In the private subnets:
> Dedicated custom network ACLs for each Availability Zone.

> An independent routing table (not shown) for each private subnet configured to control the flow of traffic within and outside the VPC.

> Spare capacity for adding subnets to support your environment as it grows.

> A VPC gateway endpoint for Amazon Simple Storage Service (Amazon S3). This endpoint provides a secure, reliable connection to Amazon S3 without requiring an internet gateway, NAT gateway, or virtual private gateway.
