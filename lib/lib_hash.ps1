function Write-FileHashes ($root, $algo = 'MD5', $save_path = 'C:\hashes.csv') {
    Get-ChildItem -Path $root -Recurse -ErrorAction SilentlyContinue -Force |
    Get-FileHash -Algorithm $algo |
    Export-Csv -Path $save_path
}

function Read-FileHashTable ($FileHashCsvPath) {
    $hashes = Import-Csv -Path $FileHashCsvPath
    $ht = @{}
    foreach ($h in $hashes){
        $ht[$h.Path] = $h.Hash
    }
    return $ht
}

function Compare-HashTablesForModified ($ReferenceHashTable, $DifferenceHashTable) {
    $changed = @()
    foreach ($h in $ReferenceHashTable.GetEnumerator()){
        if ($DifferenceHashTable.ContainsKey($h.Key) -and ($h.Value -ne $DifferenceHashTable[$h.Key])) {
            # $h.Key
            $changed += $h.Key
        }
    }
    return $changed
}

function Compare-HashTablesForDeleted ($ReferenceHashTable, $DifferenceHashTable) {
    $deleted = @()
    foreach ($h in $ReferenceHashTable.GetEnumerator()){
        if (! $DifferenceHashTable.ContainsKey($h.Key)) {
            $deleted += $h.Key
        }
    }
    return $deleted
}

function Compare-HashTablesForNew ($ReferenceHashTable, $DifferenceHashTable) {
    $new = @()
    foreach ($h in $DifferenceHashTable.GetEnumerator()){
        if (! $ReferenceHashTable.ContainsKey($h.Key)) {
            $new += $h.Key
        }
    }
    return $new
}

function Find-FilesInList ($SearchTerms, $FileArray) {
    # Use output from Compare-HashTablesForNew as $FileArray
    # Create array of strings for files to search for (Do not use full path)
    $found = @()
    foreach ($f in $FileArray){
        foreach ($t in $SearchTerms) {
            if ($f.ToLower().EndsWith($t)) {
                # $h.Key
                $found += $f
            }
        }
    }
    return $found
}
