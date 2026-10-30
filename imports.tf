# Adopt existing resources. Remove each block once it has been applied.
import {
  to = azurerm_resource_group.burrows
  id = "/subscriptions/f08977cd-8daa-4cde-90a6-74099f617449/resourceGroups/burrows"
}

import {
  to = azurerm_static_web_app.burrows_site
  id = "/subscriptions/f08977cd-8daa-4cde-90a6-74099f617449/resourceGroups/burrows/providers/Microsoft.Web/staticSites/burrows-site"
}

import {
  to = azurerm_static_web_app_custom_domain.burrows
  id = "/subscriptions/f08977cd-8daa-4cde-90a6-74099f617449/resourceGroups/burrows/providers/Microsoft.Web/staticSites/burrows-site/customDomains/burrows.the-lights.co.uk"
}
