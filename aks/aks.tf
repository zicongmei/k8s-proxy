

resource "azurerm_kubernetes_cluster" "k8s" {
  location            = local.region
  name                = "${local.name}-aks"
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "${local.name}-dns"

  identity {
    type = "SystemAssigned"
  }

  kubernetes_version = local.k8s_version
  default_node_pool {
    name       = "default"
    vm_size    = "Standard_D2_v2"
    node_count = local.node_count
  }
  workload_identity_enabled = true
  oidc_issuer_enabled = true
  role_based_access_control_enabled = true

  tags = {
    environment = "Demo"
    user = "zicong"
  }
}

