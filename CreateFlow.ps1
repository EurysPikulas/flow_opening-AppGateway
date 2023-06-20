#Subscription Hub IS
$subscriptionId        = "55173195-9a7e-486e-8c8d-4740bcbcb111"
$dns_rg_name	       = "rg-network-xops-prod-ne"
$domain	               = "aquadvanced.com"
	
$agw_rg_name           = "rg-network-xops-prod-ne"
$app_gateway_name	   = "agw-hub-prod-ne"
$public_ip	           = "20.166.248.214"
$public_ip_name	       = "appGwPublicFrontendIp"
$certificate_name	   = "aquadvancedcert"
$record_set_name       = "aqud-lyre-dev"
$frontend_port         = "port_80"

#Backend Pool	
$product	           = "aqud"
$customer	           = "lyre"
$environment	       = "dev"
$target_ip	           = "10.240.4.4"
$backend_pool_name	   = "aqud-lyre-dev-backend"	
$backend_settings      = "aqud-lyre-dev-backend_settings"


#Flows 1
$component	           = ""
$customer	           = "lyre"
$priority	           = "243"
$protocol	           = "http"
$port	               = "80"
$timeout	           = "120"
$host_name	           = "aqud-lyre-dev.aquadvanced.com"

$http_listener_name    = "aqud-lyre-dev-http_listener"
$https_listener_name   = "aqud-lyre-dev-https_listener"
$frontend_port         = "port_80"
$frontend_port_https   = "port_443" 
$https_routing_rule_name = "aqud-lyre-dev-https_routing_rule"
$rule_type             = "Basic"
$redirect_config_name  = "aqud-lyre-dev-redirect"

$app_gateway_rule_name = "aqud-lyre-dev-http_redirect_routing_rule"

#************************************************************************************************
#*** Connect to Subscription
#************************************************************************************************
Try {
    $command = "az account set --subscription $subscriptionId`r`n"
    $output  = $output + $separator + $command + "`r`n"

    $result = Invoke-Expression $command | ConvertFrom-Json | ConvertTo-Json -Depth 100

    # Write the output to the specified file, including the commands and separator lines
    $output = $output + "`r`n" + $result + "`r`n"
} Catch {
    $errorMessage = "Exception: $($_.Exception.Message)`r`n"
    $output = $output + "`r`n" + $errorMessage + "`r`n"
}
$output | Out-File -FilePath $outputFile -Encoding Unicode



#************************************************************************************************
#*** Ajouter un enregistrement DNS  dans la zone 
#************************************************************************************************
Try {
    $command = "az network dns record-set a add-record --resource-group $dns_rg_name --record-set-name $record_set_name --ipv4-address $public_ip --zone-name $domain
    "
    $output  = $output + $separator + $command + "`r`n"

    $result = Invoke-Expression $command | ConvertFrom-Json | ConvertTo-Json -Depth 100

    # Write the output to the specified file, including the commands and separator lines
    $output = $output + "`r`n" + $result + "`r`n"
} Catch {
    $errorMessage = "Exception: $($_.Exception.Message)`r`n"
    $output = $output + "`r`n" + $errorMessage + "`r`n"
}
$output | Out-File -FilePath $outputFile -Encoding Unicode



#************************************************************************************************
#*** Créer des paramètres HTTP sur l'application gateway 
#************************************************************************************************
Try {
    $command = "az network application-gateway http-settings create --resource-group $dns_rg_name --gateway-name $app_gateway_name --name $backend_settings --port $port --timeout $timeout"

    $output  = $output + $separator + $command + "`r`n"

    $result = Invoke-Expression $command | ConvertFrom-Json | ConvertTo-Json -Depth 100

    # Write the output to the specified file, including the commands and separator lines
    $output = $output + "`r`n" + $result + "`r`n"
} Catch {
    $errorMessage = "Exception: $($_.Exception.Message)`r`n"
    $output = $output + "`r`n" + $errorMessage + "`r`n"
} 
$output | Out-File -FilePath $outputFile -Encoding Unicode




#************************************************************************************************
#*** Créer un écouteur HTTP sur l'application gateway
#************************************************************************************************
Try {
    $command = "az network application-gateway http-listener create --name $http_listener --resource-group $dns_rg_name --gateway-name $app_gateway_name --frontend-port $frontend_port_http_name --frontend-ip $public_ip_name --host-name $host_name"

    $output  = $output + $separator + $command + "`r`n"

    $result = Invoke-Expression $command | ConvertFrom-Json | ConvertTo-Json -Depth 100

    # Write the output to the specified file, including the commands and separator lines
    $output = $output + "`r`n" + $result + "`r`n"
} Catch {
    $errorMessage = "Exception: $($_.Exception.Message)`r`n"
    $output = $output + "`r`n" + $errorMessage + "`r`n"
} 

$output | Out-File -FilePath $outputFile -Encoding Unicode




#************************************************************************************************
#*** Créer un écouteur HTTPS sur l'application gateway 
#************************************************************************************************

Try {
   
    $command = "az network application-gateway http-listener create --name $https_listener --resource-group $dns_rg_name --gateway-name $app_gateway_name --frontend-port $frontend_port_https_name --frontend-ip $public_ip_name --ssl-cert $certificate_name --host-name $host_name"

    $output  = $output + $separator + $command + "`r`n"
    $result = Invoke-Expression $command | ConvertFrom-Json | ConvertTo-Json -Depth 100
        
    # Write the output to the specified file, including the commands and separator lines
    $output = $output + "`r`n" + $result + "`r`n"
        
} Catch {
    $errorMessage = "Exception: $($_.Exception.Message)`r`n"
    $output = $output + "`r`n" + $errorMessage + "`r`n"
} 
    $output | Out-File -FilePath $outputFile -Encoding Unicode




#************************************************************************************************
#*** Créer une règle de routage HTTPS sur l'application gateway
#************************************************************************************************
Try {
   
    $command = "az network application-gateway rule create --resource-group $dns_rg_name --gateway-name $app_gateway_name --name $https_routing_rule_name --http-listener $https_listener_name --rule-type $rule_type --address-pool $backend_pool_name --http-settings $backend_settings --priority $priority"

    $output  = $output + $separator + $command + "`r`n"
    $result = Invoke-Expression $command | ConvertFrom-Json | ConvertTo-Json -Depth 100
        
    # Write the output to the specified file, including the commands and separator lines
    $output = $output + "`r`n" + $result + "`r`n"
        
} Catch {
    $errorMessage = "Exception: $($_.Exception.Message)`r`n"
    $output = $output + "`r`n" + $errorMessage + "`r`n"
} 
    $output | Out-File -FilePath $outputFile -Encoding Unicode



#************************************************************************************************
#*** Créer une configuration de redirection permanente sur l'application gateway
#************************************************************************************************

Try {
   
    $command = "az network application-gateway redirect-config create --name $redirect_config_name --resource-group $dns_rg_name --gateway-name $app_gateway_name --type Permanent --include-path true --include-query-string true --target-listener $https_listener_name"

    $output  = $output + $separator + $command + "`r`n"
    $result = Invoke-Expression $command | ConvertFrom-Json | ConvertTo-Json -Depth 100
        
    # Write the output to the specified file, including the commands and separator lines
    $output = $output + "`r`n" + $result + "`r`n"
        
} Catch {
    $errorMessage = "Exception: $($_.Exception.Message)`r`n"
    $output = $output + "`r`n" + $errorMessage + "`r`n"
} 
    $output | Out-File -FilePath $outputFile -Encoding Unicode





#************************************************************************************************
#*** Créer une règle de redirection HTTP pour sur l'application gateway 
#************************************************************************************************
Try {
   
    $command = "az network application-gateway rule create --name $app_gateway_rule_name --resource-group $dns_rg_name --gateway-name $app_gateway_name --http-listener $http_listener_name --rule-type $rule_type --redirect-config $redirect_config_name --priority $priority"

    $output  = $output + $separator + $command + "`r`n"
    $result = Invoke-Expression $command | ConvertFrom-Json | ConvertTo-Json -Depth 100
        
    # Write the output to the specified file, including the commands and separator lines
    $output = $output + "`r`n" + $result + "`r`n"
        
} Catch {
    $errorMessage = "Exception: $($_.Exception.Message)`r`n"
    $output = $output + "`r`n" + $errorMessage + "`r`n"
} 
    $output | Out-File -FilePath $outputFile -Encoding Unicode

