# Azure Blitz Deploy - Module Examples

This repository provides example Terraform configurations demonstrating how to use various modules designed for rapid Azure resource deployment.

Currently, the primary example showcases the `azure-vm-module` for deploying a simple Linux Virtual Machine (VM) on Microsoft Azure.

Key points about this initial Linux VM example:

* **Focus:** Demonstrates a basic deployment scenario using the `azure-vm-module`.
* **State Management:** It utilizes local Terraform state and **does not configure remote state**. This is suitable for quick testing or individual use but should be adapted for team collaboration or production environments.
* **Module Location:** Assumes the `azure-vm-module` is located in a directory relative to this example's configuration files (i.e., `../modules/azure-vm-module`).

Stay tuned! More examples, potentially covering different modules and more complex scenarios within the "Azure Blitz Deploy" scope, will be added to this repository over time.

---

## Overview

This configuration sets up the Azure provider and utilizes a modular approach (`azure-vm-module`) to create the necessary Azure resources for a basic VM. It is intended as a straightforward example for users looking to quickly deploy a VM using the custom module.

**Note:** This example assumes the `azure-vm-module` is located in a directory relative to this configuration (i.e., `../modules/azure-vm-module`).

## Prerequisites

Before you begin, ensure you have the following installed and configured:

1.  **Terraform:** [Download and install Terraform](https://developer.hashicorp.com/terraform/downloads) (version compatible with the module).
2.  **Azure CLI:** [Install Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli).
3.  **Azure Account:** An active Azure subscription.
4.  **Authentication:** Logged into Azure via Azure CLI (`az login`) or configured other [Azure provider authentication methods](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/azure_cli).
5.  **Access to the Module:** The `azure-vm-module` must be present at the path specified in the `source` attribute (`../modules/azure-vm-module`).

## Usage

Follow these steps to deploy the Azure VM using this example:

1.  **Clone the Repository (Optional):** If this code is in a Git repository, clone it:
    ```bash
    git clone <your-repository-url>
    cd <repository-directory>
    ```

2.  **Configure Provider:**
    * Open the `main.tf` (or relevant `.tf` file containing the provider block).
    * Replace the empty `subscription_id = ""` with your actual Azure Subscription ID.

    ```terraform
    provider "azurerm" {
      features {}
      subscription_id = "<YOUR_AZURE_SUBSCRIPTION_ID>" # <-- Add your Subscription ID here
    }
    ```

3.  **Configure Module Inputs:**
    * In the `module "abd_simple_vm"` block, fill in the required input variables:
        * `location`: Specify the Azure region where the VM should be deployed (e.g., `"eastus"`, `"westus2"`).
        * `allowed_ssh_cidr`: Specify the IP address range (in CIDR notation) allowed to connect to the VM via SSH (Port 22).
            * **Security Note:** For better security, use your specific public IP address followed by `/32` (e.g., `"YOUR.PUBLIC.IP.ADDRESS/32"`). Using `"0.0.0.0/0"` allows access from *any* IP address and is **not recommended** for production or sensitive environments. You can find your public IP by searching "what is my IP" in a web browser.

    * *(Optional)* Uncomment and modify any optional inputs as needed:
        * `resource_group_name`: If you want to use an existing Azure Resource Group, uncomment this line and provide its name. Otherwise, the module will likely create a new one (depending on the `azure-vm-module`'s internal logic).
        * `name_prefix`: A prefix used for naming the resources created by the module (e.g., VM, NIC, NSG).
        * `vm_size`: The Azure VM size instance type (e.g., `"Standard_B1s"`, `"Standard_D2s_v3"`). Defaults are typically defined within the `azure-vm-module`.
        * `admin_username`: The administrator username for the Linux VM. Defaults are typically defined within the `azure-vm-module`.
        * `tags`: Add or modify tags applied to the created resources for organization and cost tracking.

    ```terraform
    module "abd_simple_vm" {
      source = "../modules/azure-vm-module"

      # --- Required Inputs ---
      location           = "eastus"  # <-- Replace with your desired Azure region
      allowed_ssh_cidr   = ["YOUR.PUBLIC.IP.ADDRESS/32"] # <-- Replace with your allowed IP CIDR

      # --- Optional Inputs (Examples) ---
      # resource_group_name = "abd-rg" # Uncomment to use an existing RG
      # name_prefix         = "test"
      # vm_size             = "Standard_B2s"
      # admin_username      = "testadmin"
      tags = {
        environment = "abd-testing"
        created_by  = "abd-terraform-module-example"
      }
    }
    ```

4.  **Initialize Terraform:**
    * Navigate to the directory containing the Terraform configuration files in your terminal.
    * Run `terraform init`. This command downloads the necessary provider plugins and initializes the backend.

    ```bash
    terraform init
    ```

5.  **Plan the Deployment:**
    * Run `terraform plan`. This command shows you the execution plan, detailing the resources Terraform will create, modify, or destroy. Review the plan carefully.

    ```bash
    terraform plan
    ```

6.  **Apply the Configuration:**
    * If the plan looks correct, apply the configuration to create the resources in Azure.

    ```bash
    terraform apply
    ```
    * Terraform will prompt for confirmation; type `yes` and press Enter.

    ✨ **Important Note on SSH Key Generation:** ✨
    * During the `apply` process, the underlying `azure-vm-module` **automatically generates a new SSH key pair** specifically for this deployment using Azure's key generation service (`Microsoft.Compute/sshPublicKeys`).
    * The **private key** (essential for logging in) is automatically saved as a file directly into the **current directory** (the one where you ran `terraform apply`).
    * The private key filename will follow the pattern: `id_rsa_<name_prefix>_<random_id>` (e.g., `id_rsa_test_proper_panda`). You will need this filename in the next step.
    * This file is created with secure permissions (`0600`). **Treat this private key file as sensitive and keep it secure!**
    * The corresponding public key is automatically installed on the Azure VM for the specified `admin_username` (e.g., `testadmin`). Password authentication is disabled on the VM, requiring key-based login.
    * A copy of the public key is also saved locally with a `.pub` extension (e.g., `id_rsa_test_proper_panda.pub`), though you typically only need the private key file for connection.

7.  **Access the VM:**
    * Once the deployment is complete, Terraform will display the outputs, including the `vm_public_ip`.
    * Use the **private key file generated in the previous step** with the `ssh` command's `-i` flag to connect to your VM:

    ```bash
    # Replace <admin_username> with the one used (e.g., testadmin or your custom one)
    # Replace <path_to_private_key_file> with the actual path/filename saved in your current directory
    # Replace <vm_public_ip_output_value> with the IP address from Terraform output

    ssh -i <path_to_private_key_file> <admin_username>@<vm_public_ip_output_value>
    ```
    * **Example using the generated key:**
    ```bash
    # Assuming the generated key was named 'id_rsa_test_proper_panda' and is in the current directory:
    ssh -i ./id_rsa_test_proper_panda testadmin@20.115.30.45
    ```

8.  **Clean Up Resources:**
    * When you no longer need the deployed resources, you can destroy them using Terraform.

    ```bash
    terraform destroy
    ```
    * Terraform will prompt for confirmation; type `yes` and press Enter.

## Inputs

| Name                | Description                                                                                                                               | Type        | Required | Example                        |
| :------------------ | :---------------------------------------------------------------------------------------------------------------------------------------- | :---------- | :------- | :----------------------------- |
| `location`          | The Azure region where resources will be deployed.                                                                                        | `string`    | Yes      | `"eastus"`                     |
| `allowed_ssh_cidr`  | A list of CIDR blocks allowed to access the VM via SSH (Port 22). **Use specific IPs for better security.** | `list(string)` | Yes      | `["YOUR.IP.ADDRESS/32"]`       |
| `resource_group_name`| (Optional) The name of an *existing* Azure Resource Group to use. If not provided, the module likely creates one.                        | `string`    | No       | `"my-existing-rg"`           |
| `name_prefix`       | (Optional) A prefix string used for naming created Azure resources (VM, NIC, NSG, etc.). Defaults are usually set in the module.             | `string`    | No       | `"prod-web"`                   |
| `vm_size`           | (Optional) The Azure VM size/instance type. Defaults are usually set in the module.                                                       | `string`    | No       | `"Standard_F2s_v2"`            |
| `admin_username`    | (Optional) The administrator username for the Linux VM. Defaults are usually set in the module.                                           | `string`    | No       | `"azureuser"`                  |
| `tags`              | (Optional) A map of tags to apply to the created Azure resources.                                                                         | `map(string)`| No       | `{ environment = "production" }` |

*(Note: Refer to the `azure-vm-module`'s own documentation/variables.tf for the definitive list of all available inputs and their default values.)*

## Outputs

| Name             | Description                                    | Value Example        |
| :--------------- | :--------------------------------------------- | :------------------- |
| `vm_public_ip`   | The public IP address assigned to the deployed VM. | `"20.10.50.100"`     |

*(Note: Refer to the `azure-vm-module`'s own documentation/outputs.tf for the definitive list of all available outputs.)*

## Underlying Module

This example relies on the `azure-vm-module` located at `../modules/azure-vm-module`. The actual creation logic for the Virtual Machine, Network Interface Card (NIC), Network Security Group (NSG), Public IP Address, and potentially other related resources is defined within that module. Please consult the documentation of the `azure-vm-module` for detailed information about its functionality, requirements, and configuration options.