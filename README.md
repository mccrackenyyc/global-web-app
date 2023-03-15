global-web-app is a proof of concept project to demonstrate proficiency with Terraform to build Azure infrastructure. As the name implies, GWA is a globally available web app with high availability built into the framework. The infrastructure can be replicated and scaled to any Azure datacenter within minutes thanks to fully dynamic, DRY code design.

Features:

- Fully redundant resources at every layer
- CDN using Azure Front Door
- Scalable in minutes
- Automated CI/CD workflow using GitHub Actions
- Security hardened using SAST
- Secrets passed through environment variables
	
You're encouraged to verify my work. See below for values that have been defaulted; you may substitute your own in the code, or pass them in via TF_VAR_... environment variables on the command line. The DNS must be delegated to the Azure DNS service.

**\.github\workflows**

tfdeploy.yml
- Azure secrets
	- ARM_CLIENT_ID
	- ARM_CLIENT_SECRET
	- ARM_SUBSCRIPTION_ID
	- ARM_TENANT_ID

**\base**

resources.tf
- storage_account
	- name

variables.tf
- subscription_id

**\infra**

main.tf
- backend
	- storage_account_name
		
monitor.tf
- email_receiver

variables.tf
- subscription_id
- tenant_id
- website_hostname
- admin_upn
