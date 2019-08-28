# First get domain text file from tshark by running something like:
# tshark.exe -r c:\wd\beacons.pcapng -T fields -e dns.qry.name -Y dns > c:\wd\dns.txt

$domains_ht = @{}
foreach ($line in Get-Content -Path C:\wd\dns.txt) {
    if (! $domains_ht.ContainsKey($line)){
        $domains_ht[$line] = $line
    }
}
$domains_ht

$ioc_domains = @()
foreach ($line in Get-Content -Path C:\wd\apturls.txt){
    $ioc_domains += $line
}
$ioc_domains

foreach ($d in $ioc_domains) {
    if($domains_ht.ContainsKey($d)){
        $d
    }
}
