#-- Reset local cluster
cd "C:\Program Files\Microsoft SDKs\Service Fabric\ClusterSetup\"
#.\DevClusterSetup.ps1 -AsSecureCluster  #create a secure cluster
.\DevClusterSetup.ps1

Connect-ServiceFabricCluster localhost:19000

$imageStoreConnectionString = 'file:C:\SfDevCluster\Data\ImageStoreShare'
$applicationPackagePath = 'Store\NodeApp'

Write-Host 'Copying application package...'
Copy-ServiceFabricApplicationPackage -ApplicationPackagePath 'd:\test\servicefabricdemos\GuestExec' `
                                    -ImageStoreConnectionString $imageStoreConnectionString `
                                    -ApplicationPackagePathInImageStore $applicationPackagePath

Write-Host 'Registering Application type...'
Register-ServiceFabricApplicationType -ApplicationPathInImageStore $applicationPackagePath

Write-Host 'Remove the package'
Remove-ServiceFabricApplicationPackage -ImageStoreConnectionString $imageStoreConnectionString -ApplicationPackagePathInImageStore $applicationPackagePath

Write-Host 'Creating new Application Instance...'
New-ServiceFabricApplication -ApplicationName 'fabric:/NodeApp' -ApplicationTypeName 'NodeAppType' -ApplicationTypeVersion 1.0

Write-Host 'Creating new Service Instance...'+
New-ServiceFabricService -ApplicationName 'fabric:/NodeApp' -ServiceName 'fabric:/NodeApp/NodeAppService' -ServiceTypeName 'NodeApp' -Stateless -PartitionSchemeSingleton -InstanceCount 1

#Remove-ServiceFabricService 'fabric:/NodeApp/NodeAppServiceX' <-- only if a second service was created

#Update-ServiceFabricService -ServiceName 'fabric:/NodeApp/NodeAppService' -Stateless -InstanceCount 1 -Force


Write-Host 'Remove application...'
Remove-ServiceFabricApplication 'fabric:/NodeApp'

Write-Host 'Unregister application type...'
Unregister-ServiceFabricApplicationType -ApplicationTypeName 'NodeAppType' -ApplicationTypeVersion 1.0

Get-ServiceFabricClusterHealth