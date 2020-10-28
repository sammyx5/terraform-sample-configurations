
module "testing-dbserver" {
  source                      = "../../modules/azure-vm-from-image"
  prefix                      = "test"
  db_vm_size                  = "Standard_DS14_v2"
  custom_windows_img_ref_id   = "/subscriptions/<subscriptionid>/resourceGroups/<image resource group>/providers/Microsoft.Compute/images/<image name>"
}


