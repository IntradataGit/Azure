workflow routing_janitor
{
	param
    (
        # Fully-qualified name of the Azure DB server 
        [parameter(Mandatory=$true)] 
        [string] $SqlServerName,

        # Credentials for $SqlServerName stored as an Azure Automation credential asset
        # When using in the Azure Automation UI, please enter the name of the credential asset for the "Credential" parameter
        [parameter(Mandatory=$true)] 
        [PSCredential] $Credential
    )

	inlinescript
    {
        Write-Output "Starting routing.janitor"
		
        # Setup credentials   
        $ServerName = $Using:SqlServerName
        $UserId = $Using:Credential.UserName
        $Password = ($Using:Credential).GetNetworkCredential().Password

        # Create connection for each individual database
        $DatabaseConnection = New-Object System.Data.SqlClient.SqlConnection
        $DatabaseCommand = New-Object System.Data.SqlClient.SqlCommand

        Write-Output "Connecting to database $ServerName"
		
        # Setup connection string
        $DatabaseConnection.ConnectionString = "Server=$ServerName; Database=iddb-carerix-routing; User ID=$UserId; Password=$Password;"
        $DatabaseConnection.Open();

        Write-Output "Executing stored procedure"
			
        # Create command
        $DatabaseCommand.Connection = $DatabaseConnection
        $DatabaseCommand.ConnectionTimeout = 120
		$DatabaseCommand.CommandText = "EXEC routing.janitor"

        # Execute query and return single scalar result 
        $DatabaseCommand.ExecuteScalar()
        
        Write-Output "Executed routing.janitor"
			
        # Close connection
        $DatabaseConnection.Close();
	}		
}