# Scan all hosts in the 192.168.0.0/24 network using 1 ping per host.
$ips = @()
foreach ($i in 1..255) {
    if (Test-Connection "192.168.0.$i" -Count 1 -Quiet) {
        echo "192.168.0.$i"
        $ips += "192.168.0.$i"
    }
}

# Check hosts for open ports
$ips = Import-Csv -Path C:\scans\ips.csv
$ports = 443,1434,53,88
foreach ($port in $ports) {
    Echo "Testing ports $port in IP list"
    $successful = @()
    foreach ($ip in $ips.Ip) {
        $results = Test-NetConnection -ComputerName $ip -Port $port
        if ($results.TcpTestSucceeded) {
            # Echo $ip
            $successful += $ip
        }
    }

    $count = $successful.Count
    Echo "Number of hosts with port $port open: $count"
    
}

# Check if if DNS can resolve google.com
$queries = @()
foreach ($ip in $ips.Ip) {
    $q = Resolve-DnsName -Name google.com -Server $ip -DnsOnly -ErrorAction Ignore
    if ($q -ne $null) {
        $queries += $q
    }
}
$count = $queries.Count
Echo "Number of hosts where DNS query was successful $count"

Resolve-DnsName -Name google.com -Server $ip -DnsOnly -ErrorAction Ignore

# Querying UDP
$src_port = 14000  # Use some high ephemeral high port.
$successful = 0
foreach ($ip in $ips.Ip) {
    $udpobject = new-Object system.Net.Sockets.Udpclient($src_port)
    $src_port += 1
    $udpobject.Client.ReceiveTimeout = 5000
    $a = new-object system.text.asciiencoding
    $byte = $a.GetBytes("$(Get-Date)")
    $ip_addr = [IPAddress] $ip

    $udpobject.Connect($ip_addr, 69)  # Connect to UDP port 69
    [void]$udpobject.Send($byte,$byte.length)
    #IPEndPoint object will allow us to read datagrams sent from any source.
    $remoteendpoint = New-Object system.net.ipendpoint([system.net.ipaddress]::Any,0)

    try {
        #Blocks until a message returns on this socket from a remote host.
        $receivebytes = $udpobject.Receive([ref]$remoteendpoint)
        $successful += 1
    }
    catch {
        Echo "UDP Receive Exception"
    }
    #Convert returned data into string format
    [string]$returndata = $a.GetString($receivebytes)

    #Uses the IPEndPoint object to show that the host responded.
    $returndata.ToString()
    $remoteendpoint.address.ToString()
}
echo "Successful UDP count: $successful"
