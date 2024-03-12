# AWS IS CHEAP - Emails Handling

You've just created a bootstrap page to launch your lousy business idea most certainly already doomed to failure?  
You bought a custom domain name on route53 with the money you "borrowed" to your little sister and you may receive one or two emails from potential prospects in the year?
Don't need to borrow more my dear friend. With the right Route53 records, lambda code, SES, S3 and SNS settings you can have it for free!
Below the steps to follow

## Pre-requisites

- An AWS Account
- Terraform installed and AWS credentials setup (API keys in Environment variables or any other technique)
- A custom domain name on AWS Route53

## Automatic Deployment

```sh
terraform init
terraform apply -var="domain_name=your-domain-name.com" -var="aws_region=eu-west-1" -var="forward_to_perso_email=homer.simpson@gmail.com"
```

From now one, each time you will receive an email on your custom domain name, it will be stored in S3, a Lambda will read it and publish it into a SNS. The SNS will send it to your personal email.

Now if you want to reply with your custom domain name (and not your perso email). Use the SMTP credentials displayed at the end of the Terraform apply (outputs) to create a new account in your favourite webmail.

!!! note
    If you already use SES and already got an active receipt rule set, you should import it into this terraform with the following command: `terraform import aws_ses_receipt_rule_set.global_rule_set enter-name-of-ruleset-here`

!!! note
    To display a sensitive Terraform output:
     `terraform output your_smtp_password`

## Manual Deployment

Now if you have a techno-phobia or are afraid to launch a stranger's terraform script (and you should be!). You can also follow the manual steps from this miserable blog -> [AWS IS CHEAP - Handling Emails](https://www.leblogdublanchard.com/2024/02/17/aws-is-cheap-handling-emails/)
