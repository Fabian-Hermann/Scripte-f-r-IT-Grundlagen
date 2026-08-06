do{
    #Namensprefix festlegen
    $prefix = Read-Host -Prompt "Bitte geben Sie das Namenspräfix ein (z. B. SRV-WIN)"

    #Anzahl Server festlegen
    $Prüfung = $false
    while (-not $Prüfung){
        $eingabe = Read-Host -Prompt "Wie viele VMs sollen erstellt werden?"
        $anzahl = $eingabe -as [Int]
        if ($null -ne $anzahl -and $anzahl -gt 0){
            $Prüfung = $true
        } else {
            Write-Host "Eingabe ungültig!" -ForegroundColor Red
        }
    }

    # Startspeicher RAM festlegen
    $Prüfung = $false
    while (-not $Prüfung){
        $eingabe = Read-Host -Prompt "Verfügbarer Arbeisspeicher in GB"
        $RAM = $eingabe -as [Int]
        if ($null -ne $RAM -and $RAM -gt 0){
            $Ramgroesse = [UInt64]$RAM * 1GB
            $Prüfung = $true
        } else {
            Write-Host "Eingabe ungültig!" -ForegroundColor Red
        }
    }

    # Speicherplatz festlegen
    $Prüfung = $false
    while (-not $Prüfung){
        $eingabe =  Read-Host -Prompt "Verfügbarer Speicher in GB"
        $Speicher = $eingabe -as [Int]
        if ($null -ne $Speicher -and $Speicher -gt 0){
            $byteGroesse = [UInt64]$Speicher * 1GB
            $Prüfung = $true
        } else {
            Write-Host "Eingabe ungültig!" -ForegroundColor Red
        }
    }

    # Coreanzahl festlegen
    $Prüfung = $false
    while (-not $Prüfung){
        $eingabe =  Read-Host -Prompt "Anzahl Kerne"
        $Core = $eingabe -as [Int]
        if ($null -ne $Core -and $Core -gt 0){
            $CoreAnzahl = [Int64]$Core
            $Prüfung = $true
        } else {
            Write-Host "Eingabe ungültig!" -ForegroundColor Red
        }
    }
    #Switch festlegen
    $Prüfung = $false
    while (-not $Prüfung){
        $switch = Read-Host -Prompt "Switch-Name eingeben"
        if (-not $switch -eq ""){
            if (-not (Get-VMSwitch -Name $switch -ErrorAction SilentlyContinue)){
                Write-Host "Kein Switch gefunden!" -ForegroundColor Red
            } else {
                $Prüfung = $true
            }
        } else {
            $Prüfung = $true
        }
    }

    #Iso über Dateimanager auswählen
    $Prüfung = $false
    while (-not $Prüfung){
        Add-Type -AssemblyName System.Windows.Forms
        $dlg = New-Object System.Windows.Forms.OpenFileDialog
        $dlg.title = "Bitte wählen Sie die Quell-ISO-Datei aus"
        $dlg.Filter = "ISO-Dateien (*.iso)|*.iso"
        $point = $dlg.ShowDialog()
        if ($point -eq ([System.Windows.Forms.DialogResult]::Cancel)){
            Write-Host "Dateiauswahl abgebrochen!" -ForegroundColor Red
            $answer = Read-Host -Prompt "Vorgang wiederholen?  [Y] Ja ; [N] Nein"
            $answer = $answer.ToUpper()
            if ($answer -eq "Y"){
            } else {
                Write-Host "Erstellung abgebrochen!" -ForegroundColor Red
                exit
            }
        } else {
            $Prüfung = $true
            $isopfad = $dlg.FileName
        }
    }

    #Speicherpfad festlegen
    $Frage = Read-Host "Standard Speicherort "C:\VMs" verwenden? [Y] Ja ; [N] Nein"
    $Frage = $Frage.ToUpper()
    if ($Frage -eq "Y"){
        $vmpfad = "C:\VMs"
        } else {
            $dlc = New-Object System.Windows.Forms.FolderBrowserDialog
            $dlc.description = "Bitte wählen Sie den Zielordner aus"
            $eins = $dlc.ShowDialog()
            $vmpfad = $dlc.selectedPath
        }

        #Erstellungsschleife
        $counter = 1
    for ($i = 1; $i -le $anzahl; $i++) {
        while ($null -ne (Get-VM -Name "$($prefix + $counter.ToString("000"))" -ErrorAction SilentlyContinue)){
            $counter++
        }
            $vmName = $prefix + $counter.ToString("000")

            $VhdPath = "$vmpfad\Virtual Hard Disks\$vmName.vhdx"
    
           #VM Switch hinzufügen
            if (-not $null -ne (Get-VHD -Path $VhdPath -ErrorAction SilentlyContinue)){
                if (-not $switch -eq ""){
                    New-VM -Name $vmName -MemoryStartupBytes $Ramgroesse -NewVHDPath $VhdPath -SwitchName (Get-VMSwitch -Name $switch).name -Path $vmpfad -Generation 2 -NewVHDSizeBytes $byteGroesse | Out-Null
                } else {
                    New-VM -Name $vmName -MemoryStartupBytes $Ramgroesse -NewVHDPath $VhdPath -Path $vmpfad -Generation 2 -NewVHDSizeBytes $byteGroesse | Out-Null
                }
            } else {
                Write-Host "Virtuelle Festplatte existiert bereits! Bitte Löschen" -ForegroundColor Red
                break
            }
    
            #VM Arbeitsspeicher dynamisch
            Set-VMMemory -VMName $vmName -DynamicMemoryEnabled $true
    
            #VM Core Anzahl festlegen
            Set-VMProcessor -VMName $vmName -Count $CoreAnzahl

            # VM Prüfpunkte entfernen
            Set-VM -Name $vmName -CheckpointType Disabled   

            #Bootreihenfolge festlegen
            $DVD = Add-VMDvdDrive -VMName $vmName -Path $isopfad
            Set-VMFirmware -VMName $vmName -FirstBootDevice ((Get-VMFirmware -VMName $vmName).BootOrder | Where-Object Device -Like *DvD*).device

            #Ausgabe
            $Ausgabe = $vmName + " wurde erfolgreich erstellt!"
            Write-Host $Ausgabe -ForegroundColor Green
            }

        Write-Host "Virtuelle Maschinen wurden erstellt" -ForegroundColor Green

        $runAgain = Read-Host "Erneut ausführen? [Y] Ja ; [N] Nein"
        $runAgain = $runAgain.ToUpper()    
    } while ($runAgain -eq "Y")
