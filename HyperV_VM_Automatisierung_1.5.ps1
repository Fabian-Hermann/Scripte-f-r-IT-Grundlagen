
$UserInterfaceInput = 1

do

{

write-host "###########################################################"
write-host "#                                                         #"
write-host "#                        FDCSYS                           #"
write-host "#                                                         #"
write-host "#  1: Name                                                #"
write-host "#  2: Network Adapter                                     #"
write-host "#  3: Amount                                              #"
write-host "#  4: RAM Amount                                          #"
write-host "#  5: Cores                                               #"
write-host "#  6: Bootfile                                            #"
write-host "#  7: Save Location                                       #"
write-host "#  8: Virtual Drive                                       #"
write-host "#  9: Remove                                              #"
write-host "# 10: Exit and Create                                     #"
write-host "# 11: Cancel                                              #"
write-host "#                                                         #"
write-host "#                                                         #"
write-host "###########################################################"

$UserInterfaceInput = Read-Host -Prompt 'Enter a Number from 1-11'


# ElseIF Clause for the Name of the Server
if ( $UserInterfaceInput -eq 1 )

{ 
   #Namensprefix festlegen
   $prefix = Read-Host -Prompt "Bitte geben Sie das Namenspräfix ein (z. B. SRV-WIN)"

   if ( $prefix -eq "cancel" )

    {
      
      $prefix = $null
      break
    
    }


}

# ElseIF Clause for the Networkadapter
elseif ( $UserInterfaceInput -eq 2 )

{
# Switch festlegen (integrierte Liste + Nummern-Auswahl)
    $Prüfung = $false
    $switches = Get-VMSwitch
    while (-not $Prüfung) {
        # Liste der verfügbaren Switches anzeigen
        $i = 0
        $switches | ForEach-Object {
            Write-Host "[$i] $($_.Name)"
            $i++
        }

        $eingabe = Read-Host -Prompt "Switch-Name oder Nummer eingeben (oder 'cancel' zum Abbrechen)"
        if ($eingabe -eq "cancel") {
            $switch = $null
            break
        }

        # Wenn numerische Eingabe, Index in Name auflösen
        if ($eingabe.Trim() -match '^\d+$') {
            $idx = [int]$eingabe
            if ($idx -ge 0 -and $idx -lt $switches.Count) {
                $switch = $switches[$idx].Name
            } else {
                Write-Host "Ungültige Nummer!" -ForegroundColor Red
                continue
            }
        } else {
            $switch = $eingabe.Trim()
        }

        if ($switch -ne "") {
            if (-not (Get-VMSwitch -Name $switch -ErrorAction SilentlyContinue)) {
                Write-Host "Kein Switch gefunden!" -ForegroundColor Red
            } else {
                $Prüfung = $true
            }
        } else {
            # leere Eingabe bedeutet: keinen Switch verwenden 
            $Prüfung = $true
        }
    }
}

# ElseIF Clause for the Amount to Create
elseif ( $UserInterfaceInput -eq 3 )

{ 

    #Anzahl Server festlegen
    $Prüfung = $false
    while (-not $Prüfung){
        $eingabe = Read-Host -Prompt "Wie viele VMs sollen erstellt werden?"
        $anzahl = $eingabe -as [Int]
       
        if ( $eingabe -eq "cancel" ){      
        
        $anzahl = $null
        break
}
        if ($null -ne $anzahl -and $anzahl -gt 0){
            $Prüfung = $true
        } else {
            Write-Host "Eingabe ungültig!" -ForegroundColor Red
        }
    }

}

# ElseIF Clause for the RAM
elseif ( $UserInterfaceInput -eq 4 )

{
       # Startspeicher RAM festlegen
    $Prüfung = $false
    while (-not $Prüfung){
        $eingabe = Read-Host -Prompt "Verfügbarer Arbeisspeicher in GB"
        $RAM = $eingabe -as [Int]
        if ( $eingabe -eq "cancel") 
        {
         
         $RAM = $null
         break

        }
        if ($null -ne $RAM -and $RAM -gt 0){
            $Ramgroesse = [UInt64]$RAM * 1GB
            $Prüfung = $true
        } else {
            Write-Host "Eingabe ungültig!" -ForegroundColor Red
        }
    }


}

# ElseIF Clause for the Cores
elseif ( $UserInterfaceInput -eq 5 )

{

     # Coreanzahl festlegen
    $Prüfung = $false
    while (-not $Prüfung){
        $eingabe =  Read-Host -Prompt "Anzahl Kerne"
        $Core = $eingabe -as [Int]
        if ( $eingabe -eq "cancel" ){
        
        $Core = $null
        
        break

        }

        if ($null -ne $Core -and $Core -gt 0){
            $CoreAnzahl = [Int64]$Core
            $Prüfung = $true
        } else {
            Write-Host "Eingabe ungültig!" -ForegroundColor Red
        }
    }

}

# ElseIF Clause for the Bootfile
elseif ( $UserInterfaceInput -eq 6 )

{
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
                Write-Host "Keine Iso hinterlegt!" -ForegroundColor Red
                $isofail = $true
                $Prüfung = $true
            }
        } else {
            $Prüfung = $true
            $isopfad = $dlg.FileName
        }
    }


    }
# ElseIF Clause for Save Location  
 elseif ( $UserInterfaceInput -eq 7 )
{
 
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


 
 }   

# ElseIF Clause for the Size of the Virtual Drive
elseif ( $UserInterfaceInput -eq 8 )
{

    # Speicherplatz festlegen
    $Prüfung = $false
    while (-not $Prüfung){
        $eingabe =  Read-Host -Prompt "Verfügbarer Speicher in GB"
        $Speicher = $eingabe -as [Int]
        if ( $Speicher -eq "cancel" )
        {
        $Speicher = $null
        break
        
        }

        if ($null -ne $Speicher -and $Speicher -gt 0){
            $byteGroesse = [UInt64]$Speicher * 1GB
            $Prüfung = $true
        } else {
            Write-Host "Eingabe ungültig!" -ForegroundColor Red
        }
    }


}
    

} while ( $UserInterfaceInput -ne 10 )

do{
    

   


        #Erstellungsschleife
        $counter = 1
    for ($i = 1; $i -le $anzahl; $i++) {
        while ($null -ne (Get-VM -Name "$($prefix + $counter.ToString("000"))" -ErrorAction SilentlyContinue)){
            $counter++
        }
            $vmName = $prefix + $counter.ToString("000")

            $VhdPath = "$vmpfad\Virtual Hard Disks\$vmName.vhdx"
    
            #VM Switch hinzufügen
            if (-not $switch -eq ""){
                New-VM -Name $vmName -MemoryStartupBytes $Ramgroesse -NewVHDPath $VhdPath -SwitchName (Get-VMSwitch -Name $switch).name -Path $vmpfad -Generation 2 -NewVHDSizeBytes $byteGroesse | Out-Null
            } else {
                New-VM -Name $vmName -MemoryStartupBytes $Ramgroesse -NewVHDPath $VhdPath -Path $vmpfad -Generation 2 -NewVHDSizeBytes $byteGroesse | Out-Null
            }
    
            #VM Arbeitsspeicher dynamisch
            Set-VMMemory -VMName $vmName -DynamicMemoryEnabled $true
    
            #VM Core Anzahl festlegen
            Set-VMProcessor -VMName $vmName -Count $CoreAnzahl

            # VM Prüfpunkte entfernen
            Set-VM -Name $vmName -CheckpointType Disabled   

            #Bootreihenfolge festlegen
            if (-not $isofail){
            $DVD = Add-VMDvdDrive -VMName $vmName -Path $isopfad
            Set-VMFirmware -VMName $vmName -FirstBootDevice ((Get-VMFirmware -VMName $vmName).BootOrder | Where-Object Device -Like *DvD*).device
            }

            #Ausgabe
            $Ausgabe = $vmName + " wurde erfolgreich erstellt!"
            Write-Host $Ausgabe -ForegroundColor Green
            }

        Write-Host "Virtuelle Maschinen wurden erstellt" -ForegroundColor Green

        $runAgain = Read-Host "Erneut ausführen? [Y] Ja ; [N] Nein"
        $runAgain = $runAgain.ToUpper()    
    } while ($runAgain -eq "Y")
