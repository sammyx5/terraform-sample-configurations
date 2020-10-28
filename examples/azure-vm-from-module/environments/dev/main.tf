
module "development-dbserver" {
  source                      = "../../modules/azure-vm-from-image"
  prefix                      = "dev"
  custom_windows_img_ref_id   = "/subscriptions/<subscriptionid>/resourceGroups/<image resource group>/providers/Microsoft.Compute/images/<image name>"
}
