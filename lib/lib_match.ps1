function Find-StringMatches ($SearchStrings, $Data) {
    <#
    $SearchStrings: array of strings to search for
    $Data: array of strings to search for all search strings for where the 
           data string ends with search string
    return: Hash Table of results where key matches value.
    #>
    $hits = @{}
    foreach ($line in $Data) {
        foreach ($ioc in $SearchStrings) {
            if ($line.ToLower().Contains($ioc.ToLower())) {
                if (!$hits.ContainsKey($line)) {
                    $hits[$line] = $line
                }
            }
        }
    }
    return $hits
}
        
