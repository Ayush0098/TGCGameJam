param(
    [Parameter(Mandatory = $true)][string]$Manifest,
    [Parameter(Mandatory = $true)][string]$OutputDirectory
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Speech
New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null

$profiles = @{
    NARRATOR = @{ Name = 'Microsoft Ravi'; Rate = -1 }
    DASSI = @{ Name = 'Microsoft Heera'; Rate = 1 }
    CHINTU = @{ Name = 'Microsoft Ravi'; Rate = 3 }
    SAAP = @{ Name = 'Microsoft Ravi'; Rate = -2 }
    'PROMPT BHAI' = @{ Name = 'Microsoft Ravi'; Rate = 2 }
    'MESS AUNTY' = @{ Name = 'Microsoft Heera'; Rate = -1 }
    PROF = @{ Name = 'Microsoft Ravi'; Rate = -3 }
    KASSI = @{ Name = 'Microsoft Ravi'; Rate = 2 }
}
$format = [System.Speech.AudioFormat.SpeechAudioFormatInfo]::new(
    44100,
    [System.Speech.AudioFormat.AudioBitsPerSample]::Sixteen,
    [System.Speech.AudioFormat.AudioChannel]::Mono
)
$lines = Get-Content -LiteralPath $Manifest -Raw -Encoding UTF8 | ConvertFrom-Json
$synth = [System.Speech.Synthesis.SpeechSynthesizer]::new()
try {
    foreach ($line in $lines) {
        $profile = $profiles[[string]$line.voice]
        if ($null -eq $profile) { throw "Unknown voice: $($line.voice)" }
        $synth.SelectVoice($profile['Name'])
        $synth.Rate = $profile['Rate']
        $wav = Join-Path $OutputDirectory ([IO.Path]::ChangeExtension([string]$line.file, '.wav'))
        $synth.SetOutputToWaveFile($wav, $format)
        $synth.Speak([string]$line.text)
        $synth.SetOutputToNull()
        Write-Output "SYNTH $($line.file)"
    }
}
finally {
    $synth.Dispose()
}
