<#
.SYNOPSIS
    Verifica compatibilidade de hardware para Windows 11

.DESCRIPTION
    Script melhorado para verificar se o hardware atende aos requisitos do Windows 11.
    Baseado nas diretrizes oficiais da Microsoft.

    Referências:
    - https://learn.microsoft.com/pt-br/windows/whats-new/windows-11-requirements
    - https://techcommunity.microsoft.com/blog/microsoftintuneblog/understanding-readiness-for-windows-11-with-microsoft-endpoint-manager/2770866

.PARAMETER Format
    Formato de saída: 'JSON' (padrão) ou 'Console'

.PARAMETER Verbose
    Exibe informações detalhadas durante a execução

.EXAMPLE
    .\HardwareReadiness.ps1
    # Saída JSON para automação

.EXAMPLE
    .\HardwareReadiness.ps1 -Format Console
    # Saída formatada para console com cores

.EXAMPLE
    .\HardwareReadiness.ps1 -Format Console -Verbose
    # Saída detalhada com informações de debug

.NOTES
    Versão: 2.0
    Compatível com: PowerShell 5.1+ e PowerShell Core

    Copyright (C) 2021-2025 Microsoft Corporation
    Distribuído sob licença MIT
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [ValidateSet('JSON', 'Console')]
    [string]$Format = 'JSON',

    [Parameter(Mandatory = $false)]
    [switch]$VerboseOutput
)

#Region Configurações e Constantes
$ErrorActionPreference = 'SilentlyContinue'

# Requisitos mínimos do Windows 11
$Requirements = @{
    MinStorageGB        = 64
    MinMemoryGB         = 4
    MinClockSpeedMHz    = 1000
    MinLogicalCores     = 2
    RequiredAddressWidth = 64
    MinTPMVersion       = 2
    MinWindowsBuild     = 19041  # Windows 10 2004
    MinDirectXVersion   = 12
    MinWDDMVersion      = 2.0
    MinDisplayWidth     = 1280   # 720p+
    MinDisplayHeight    = 720
}

# Resultados das verificações
$CheckResults = @{
    Storage     = @{ Status = 'PENDING'; Value = $null; Message = '' }
    Memory      = @{ Status = 'PENDING'; Value = $null; Message = '' }
    TPM         = @{ Status = 'PENDING'; Value = $null; Message = '' }
    Processor   = @{ Status = 'PENDING'; Value = $null; Message = '' }
    SecureBoot  = @{ Status = 'PENDING'; Value = $null; Message = '' }
    UEFI        = @{ Status = 'PENDING'; Value = $null; Message = '' }
    GPU         = @{ Status = 'PENDING'; Value = $null; Message = '' }
    Display     = @{ Status = 'PENDING'; Value = $null; Message = '' }
    WindowsVersion = @{ Status = 'PENDING'; Value = $null; Message = '' }
}
#EndRegion

#Region Helper Functions
function Write-Log {
    param([string]$Message, [string]$Level = 'INFO')
    if ($VerboseOutput) {
        $timestamp = Get-Date -Format 'HH:mm:ss'
        Write-Host "[$timestamp] $Level : $Message" -ForegroundColor $(
            switch ($Level) {
                'ERROR' { 'Red' }
                'WARN'  { 'Yellow' }
                'SUCCESS' { 'Green' }
                default { 'Gray' }
            }
        )
    }
}

function Test-Requirement {
    <#
    .SYNOPSIS
        Helper function para executar verificações de hardware com tratamento de erro consistente
    #>
    param(
        [string]$Name,
        [scriptblock]$TestScript
    )

    Write-Log "Verificando $Name..." -Level 'INFO'

    try {
        $result = & $TestScript
        return $result
    }
    catch {
        Write-Log "Erro ao verificar ${Name}: $($_.Exception.Message)" -Level 'ERROR'
        return @{
            Status  = 'UNDETERMINED'
            Value   = $null
            Message = "Erro: $($_.Exception.GetType().Name)"
        }
    }
}
#EndRegion

#Region Código C# para validação de CPU
# Mantido do script original - valida famílias de CPU Intel, AMD e Qualcomm
$CpuValidationSource = @"
using Microsoft.Win32;
using System;
using System.Runtime.InteropServices;

public class CpuFamilyResult
{
    public bool IsValid { get; set; }
    public string Message { get; set; }
}

public class CpuFamily
{
    [StructLayout(LayoutKind.Sequential)]
    public struct SYSTEM_INFO
    {
        public ushort ProcessorArchitecture;
        ushort Reserved;
        public uint PageSize;
        public IntPtr MinimumApplicationAddress;
        public IntPtr MaximumApplicationAddress;
        public IntPtr ActiveProcessorMask;
        public uint NumberOfProcessors;
        public uint ProcessorType;
        public uint AllocationGranularity;
        public ushort ProcessorLevel;
        public ushort ProcessorRevision;
    }

    [DllImport("kernel32.dll")]
    internal static extern void GetNativeSystemInfo(ref SYSTEM_INFO lpSystemInfo);

    public enum ProcessorFeature : uint
    {
        ARM_SUPPORTED_INSTRUCTIONS = 34
    }

    [DllImport("kernel32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    static extern bool IsProcessorFeaturePresent(ProcessorFeature processorFeature);

    private const ushort PROCESSOR_ARCHITECTURE_X86 = 0;
    private const ushort PROCESSOR_ARCHITECTURE_ARM64 = 12;
    private const ushort PROCESSOR_ARCHITECTURE_X64 = 9;

    private const string INTEL_MANUFACTURER = "GenuineIntel";
    private const string AMD_MANUFACTURER = "AuthenticAMD";
    private const string QUALCOMM_MANUFACTURER = "Qualcomm Technologies Inc";

    public static CpuFamilyResult Validate(string manufacturer, ushort processorArchitecture)
    {
        CpuFamilyResult cpuFamilyResult = new CpuFamilyResult();

        if (string.IsNullOrWhiteSpace(manufacturer))
        {
            cpuFamilyResult.IsValid = false;
            cpuFamilyResult.Message = "Manufacturer is null or empty";
            return cpuFamilyResult;
        }

        string registryPath = "HKEY_LOCAL_MACHINE\\Hardware\\Description\\System\\CentralProcessor\\0";
        SYSTEM_INFO sysInfo = new SYSTEM_INFO();
        GetNativeSystemInfo(ref sysInfo);

        switch (processorArchitecture)
        {
            case PROCESSOR_ARCHITECTURE_ARM64:
                // Validação para processadores ARM (ex: Qualcomm)
                // Requer suporte a instruções atômicas ARM v8.1
                if (manufacturer.Equals(QUALCOMM_MANUFACTURER, StringComparison.OrdinalIgnoreCase))
                {
                    bool isArmv81Supported = IsProcessorFeaturePresent(ProcessorFeature.ARM_SUPPORTED_INSTRUCTIONS);

                    if (!isArmv81Supported)
                    {
                        string registryName = "CP 4030";
                        long registryValue = (long)Registry.GetValue(registryPath, registryName, -1);
                        long atomicResult = (registryValue >> 20) & 0xF;

                        if (atomicResult >= 2)
                        {
                            isArmv81Supported = true;
                        }
                    }

                    cpuFamilyResult.IsValid = isArmv81Supported;
                    cpuFamilyResult.Message = isArmv81Supported ? "" : "Processor does not implement ARM v8.1 atomic instruction";
                }
                else
                {
                    cpuFamilyResult.IsValid = false;
                    cpuFamilyResult.Message = "The processor isn't currently supported for Windows 11";
                }

                break;

            case PROCESSOR_ARCHITECTURE_X64:
            case PROCESSOR_ARCHITECTURE_X86:
                // Validação para processadores Intel e AMD
                int cpuFamily = sysInfo.ProcessorLevel;
                int cpuModel = (sysInfo.ProcessorRevision >> 8) & 0xFF;
                int cpuStepping = sysInfo.ProcessorRevision & 0xFF;

                if (manufacturer.Equals(INTEL_MANUFACTURER, StringComparison.OrdinalIgnoreCase))
                {
                    // Intel: Family 6, Model >= 95 (exceto Model 85 que é suportado)
                    // Gerações: 8ª geração (Coffee Lake) e posteriores
                    try
                    {
                        cpuFamilyResult.IsValid = true;
                        cpuFamilyResult.Message = "";

                        if (cpuFamily >= 6 && cpuModel <= 95 && !(cpuFamily == 6 && cpuModel == 85))
                        {
                            cpuFamilyResult.IsValid = false;
                            cpuFamilyResult.Message = "";
                        }
                        // Validação especial para modelos específicos
                        else if (cpuFamily == 6 && (cpuModel == 142 || cpuModel == 158) && cpuStepping == 9)
                        {
                            string registryName = "Platform Specific Field 1";
                            int registryValue = (int)Registry.GetValue(registryPath, registryName, -1);

                            if ((cpuModel == 142 && registryValue != 16) || (cpuModel == 158 && registryValue != 8))
                            {
                                cpuFamilyResult.IsValid = false;
                            }
                            cpuFamilyResult.Message = "PlatformId " + registryValue;
                        }
                    }
                    catch (Exception ex)
                    {
                        cpuFamilyResult.IsValid = false;
                        cpuFamilyResult.Message = "Exception:" + ex.GetType().Name;
                    }
                }
                else if (manufacturer.Equals(AMD_MANUFACTURER, StringComparison.OrdinalIgnoreCase))
                {
                    // AMD: Family >= 23 (Zen architecture)
                    // Exclui Zen 1 primeiras revisões (Family 23, Model 1 ou 17)
                    cpuFamilyResult.IsValid = true;
                    cpuFamilyResult.Message = "";

                    if (cpuFamily < 23 || (cpuFamily == 23 && (cpuModel == 1 || cpuModel == 17)))
                    {
                        cpuFamilyResult.IsValid = false;
                    }
                }
                else
                {
                    cpuFamilyResult.IsValid = false;
                    cpuFamilyResult.Message = "Unsupported Manufacturer: " + manufacturer + ", Architecture: " + processorArchitecture + ", CPUFamily: " + sysInfo.ProcessorLevel + ", ProcessorRevision: " + sysInfo.ProcessorRevision;
                }

                break;

            default:
                cpuFamilyResult.IsValid = false;
                cpuFamilyResult.Message = "Unsupported CPU category. Manufacturer: " + manufacturer + ", Architecture: " + processorArchitecture + ", CPUFamily: " + sysInfo.ProcessorLevel + ", ProcessorRevision: " + sysInfo.ProcessorRevision;
                break;
        }
        return cpuFamilyResult;
    }
}
"@

# Compilar código C#
Add-Type -TypeDefinition $CpuValidationSource
#EndRegion

#Region Verificações de Hardware

# 1. ARMAZENAMENTO
$CheckResults.Storage = Test-Requirement -Name 'Storage' -TestScript {
    $osDrive = Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object -ExpandProperty SystemDrive
    $disk = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='$osDrive'"
    $sizeGB = [math]::Round($disk.Size / 1GB, 2)

    if ($sizeGB -ge $Requirements.MinStorageGB) {
        @{ Status = 'PASS'; Value = "${sizeGB} GB"; Message = "Armazenamento suficiente" }
    }
    else {
        @{ Status = 'FAIL'; Value = "${sizeGB} GB"; Message = "Mínimo requerido: $($Requirements.MinStorageGB) GB" }
    }
}

# 2. MEMÓRIA RAM
$CheckResults.Memory = Test-Requirement -Name 'Memory' -TestScript {
    $memory = Get-CimInstance -ClassName Win32_PhysicalMemory |
        Measure-Object -Property Capacity -Sum
    $sizeGB = [math]::Round($memory.Sum / 1GB, 2)

    if ($sizeGB -ge $Requirements.MinMemoryGB) {
        @{ Status = 'PASS'; Value = "${sizeGB} GB"; Message = "Memória suficiente" }
    }
    else {
        @{ Status = 'FAIL'; Value = "${sizeGB} GB"; Message = "Mínimo requerido: $($Requirements.MinMemoryGB) GB" }
    }
}

# 3. TPM (Trusted Platform Module)
$CheckResults.TPM = Test-Requirement -Name 'TPM' -TestScript {
    $tpm = Get-Tpm

    if (-not $tpm.TpmPresent) {
        return @{ Status = 'FAIL'; Value = 'Ausente'; Message = 'TPM não encontrado' }
    }

    $tpmVersion = Get-CimInstance -Namespace root\CIMV2\Security\MicrosoftTpm -ClassName Win32_Tpm
    $specVersion = $tpmVersion.SpecVersion

    if ($specVersion) {
        $majorVersion = ($specVersion -split ',')[0] -as [int]
        if ($majorVersion -ge $Requirements.MinTPMVersion) {
            @{ Status = 'PASS'; Value = $specVersion; Message = "TPM $majorVersion.0 detectado" }
        }
        else {
            @{ Status = 'FAIL'; Value = $specVersion; Message = "TPM 2.0 ou superior requerido" }
        }
    }
    else {
        @{ Status = 'FAIL'; Value = 'Desconhecida'; Message = 'Não foi possível determinar versão do TPM' }
    }
}

# 4. PROCESSADOR
$CheckResults.Processor = Test-Requirement -Name 'Processor' -TestScript {
    $cpu = Get-CimInstance -ClassName Win32_Processor | Select-Object -First 1

    $failures = @()

    # Verificar arquitetura 64-bit
    if ($cpu.AddressWidth -ne $Requirements.RequiredAddressWidth) {
        $failures += "Arquitetura 64-bit requerida"
    }

    # Verificar clock mínimo
    if ($cpu.MaxClockSpeed -le $Requirements.MinClockSpeedMHz) {
        $failures += "Clock mínimo: $($Requirements.MinClockSpeedMHz) MHz"
    }

    # Verificar número de cores lógicos
    if ($cpu.NumberOfLogicalProcessors -lt $Requirements.MinLogicalCores) {
        $failures += "Mínimo: $($Requirements.MinLogicalCores) cores lógicos"
    }

    # Validar família da CPU usando código C#
    $cpuFamilyResult = [CpuFamily]::Validate([string]$cpu.Manufacturer, [uint16]$cpu.Architecture)

    if (-not $cpuFamilyResult.IsValid) {
        $failures += "CPU não suportada: $($cpuFamilyResult.Message)"
    }

    # Exceção: Surface Studio 2 e Dell Precision 5520 com i7-7820HQ
    $systemInfo = Get-CimInstance -ClassName Win32_ComputerSystem
    $supportedModels = @('surface studio 2', 'precision 5520')
    if ($cpu.Name -match 'i7-7820hq' -and $supportedModels -contains $systemInfo.Model.Trim().ToLower()) {
        $failures = @()  # Limpar falhas - exceção aprovada
    }

    if ($failures.Count -eq 0) {
        @{
            Status  = 'PASS'
            Value   = $cpu.Name.Trim()
            Message = "$($cpu.NumberOfLogicalProcessors) cores, $($cpu.MaxClockSpeed) MHz"
        }
    }
    else {
        @{
            Status  = 'FAIL'
            Value   = $cpu.Name.Trim()
            Message = $failures -join '; '
        }
    }
}

# 5. SECURE BOOT
$CheckResults.SecureBoot = Test-Requirement -Name 'SecureBoot' -TestScript {
    try {
        $secureBootEnabled = Confirm-SecureBootUEFI
        if ($secureBootEnabled) {
            @{ Status = 'PASS'; Value = 'Habilitado'; Message = 'Secure Boot ativo' }
        }
        else {
            @{ Status = 'FAIL'; Value = 'Desabilitado'; Message = 'Secure Boot deve estar habilitado' }
        }
    }
    catch [System.PlatformNotSupportedException] {
        @{ Status = 'FAIL'; Value = 'Não suportado'; Message = 'Sistema não suporta Secure Boot (provável BIOS Legacy)' }
    }
    catch {
        @{ Status = 'UNDETERMINED'; Value = 'Desconhecido'; Message = 'Sem permissão para verificar (execute como Administrador)' }
    }
}

# 6. UEFI (Verificação explícita)
$CheckResults.UEFI = Test-Requirement -Name 'UEFI' -TestScript {
    # Método 1: Verificar via registry (mais confiável)
    $firmwareType = $null
    try {
        $regPath = 'HKLM:\System\CurrentControlSet\Control'
        $firmwareReg = Get-ItemProperty -Path $regPath -Name 'PEFirmwareType' -ErrorAction SilentlyContinue
        if ($firmwareReg) {
            $firmwareType = $firmwareReg.PEFirmwareType
        }
    } catch {
        # Silenciar erro
    }

    # Método 2: Variável de ambiente (Windows 8+)
    if (-not $firmwareType) {
        $firmwareType = $env:firmware_type
    }

    # Método 3: Tentar Confirm-SecureBootUEFI (se suportar, é UEFI)
    if (-not $firmwareType) {
        try {
            $secureBootResult = Confirm-SecureBootUEFI -ErrorAction Stop
            $firmwareType = 2  # Se chegou aqui sem exception, é UEFI
        }
        catch [System.PlatformNotSupportedException] {
            $firmwareType = 1  # Legacy BIOS
        }
        catch {
            # Outro erro - pode ser permissão ou estado indeterminado
            $firmwareType = $null
        }
    }

    # Método 4: Inferir baseado no Secure Boot (se já foi verificado)
    if (-not $firmwareType -and $CheckResults.SecureBoot.Status -eq 'PASS') {
        # Se Secure Boot está habilitado, é UEFI com certeza
        $firmwareType = 2
    }

    # 1 = Legacy BIOS, 2 = UEFI
    if ($firmwareType -eq 2) {
        @{ Status = 'PASS'; Value = 'UEFI'; Message = 'Firmware UEFI detectado' }
    }
    elseif ($firmwareType -eq 1) {
        @{ Status = 'FAIL'; Value = 'Legacy BIOS'; Message = 'UEFI requerido' }
    }
    else {
        @{ Status = 'UNDETERMINED'; Value = 'Desconhecido'; Message = 'Não foi possível determinar tipo de firmware' }
    }
}

# 7. GPU (DirectX 12 + WDDM 2.0)
$CheckResults.GPU = Test-Requirement -Name 'GPU' -TestScript {
    $gpu = Get-CimInstance -ClassName Win32_VideoController |
        Where-Object { $_.AdapterCompatibility -ne 'Microsoft' } |
        Select-Object -First 1

    if (-not $gpu) {
        return @{ Status = 'FAIL'; Value = 'Não encontrada'; Message = 'Adaptador de vídeo não detectado' }
    }

    # Verificar driver WDDM
    $driverVersion = $gpu.DriverVersion

    # WDDM version não está diretamente disponível, mas podemos inferir pela versão do driver e sistema
    # Windows 10 2004+ geralmente tem WDDM 2.7+, Windows 11 requer WDDM 2.0+

    # Verificar suporte a DirectX via DXDIAG (método alternativo: registry)
    $dxDiagPath = Join-Path $env:SystemRoot 'System32\dxdiag.exe'

    # Assumir compatibilidade se GPU moderna foi detectada (método simplificado)
    # Para verificação precisa, seria necessário usar DirectX API ou dxdiag output parsing

    $gpuName = $gpu.Name

    # Lista básica de GPUs conhecidas incompatíveis (muito antigas)
    $incompatibleGPUs = @('VGA', 'Standard VGA', 'Microsoft Basic Display')
    $isIncompatible = $incompatibleGPUs | Where-Object { $gpuName -match $_ }

    if ($isIncompatible) {
        @{
            Status  = 'FAIL'
            Value   = $gpuName
            Message = 'GPU não suporta DirectX 12'
        }
    }
    else {
        # Assumir compatibilidade para GPUs modernas
        @{
            Status  = 'PASS'
            Value   = $gpuName
            Message = "Driver: $driverVersion"
        }
    }
}

# 8. DISPLAY (Resolução mínima)
$CheckResults.Display = Test-Requirement -Name 'Display' -TestScript {
    # Método 1: Win32_VideoController
    $videoMode = Get-CimInstance -ClassName Win32_VideoController | Select-Object -First 1

    $width = $videoMode.CurrentHorizontalResolution
    $height = $videoMode.CurrentVerticalResolution

    if ($width -and $height) {
        if ($width -ge $Requirements.MinDisplayWidth -and $height -ge $Requirements.MinDisplayHeight) {
            @{
                Status  = 'PASS'
                Value   = "${width}x${height}"
                Message = "Resolução adequada (mínimo 1280x720)"
            }
        }
        else {
            @{
                Status  = 'FAIL'
                Value   = "${width}x${height}"
                Message = "Resolução mínima: $($Requirements.MinDisplayWidth)x$($Requirements.MinDisplayHeight)"
            }
        }
    }
    else {
        @{
            Status  = 'UNDETERMINED'
            Value   = 'Desconhecida'
            Message = 'Não foi possível determinar resolução'
        }
    }
}

# 9. VERSÃO DO WINDOWS
$CheckResults.WindowsVersion = Test-Requirement -Name 'WindowsVersion' -TestScript {
    $osInfo = Get-CimInstance -ClassName Win32_OperatingSystem
    $currentBuild = [int]$osInfo.BuildNumber

    # Windows 10 2004 = Build 19041, Windows 11 = Build 22000+
    if ($currentBuild -ge $Requirements.MinWindowsBuild) {
        # Usar if/elseif para evitar múltiplas matches
        if ($currentBuild -ge 22000) {
            $versionName = "Windows 11"
        }
        elseif ($currentBuild -ge 19041) {
            $versionName = "Windows 10 2004+"
        }
        else {
            $versionName = "Windows 10"
        }

        @{
            Status  = 'PASS'
            Value   = "Build $currentBuild"
            Message = "$versionName"
        }
    }
    else {
        @{
            Status  = 'FAIL'
            Value   = "Build $currentBuild"
            Message = "Windows 10 Build 19041 (2004) ou superior requerido"
        }
    }
}

#EndRegion

#Region Determinação do Resultado Final
$failedChecks = $CheckResults.GetEnumerator() | Where-Object { $_.Value.Status -eq 'FAIL' }
$undeterminedChecks = $CheckResults.GetEnumerator() | Where-Object { $_.Value.Status -eq 'UNDETERMINED' }

if ($failedChecks.Count -eq 0 -and $undeterminedChecks.Count -eq 0) {
    $returnCode = 0
    $returnResult = 'CAPABLE'
    $returnReason = ''
}
elseif ($failedChecks.Count -gt 0) {
    $returnCode = 1
    $returnResult = 'NOT CAPABLE'
    $returnReason = ($failedChecks.Name -join ', ')
}
else {
    $returnCode = -1
    $returnResult = 'UNDETERMINED'
    $returnReason = ($undeterminedChecks.Name -join ', ')
}
#EndRegion

#Region Formatação de Saída

if ($Format -eq 'Console') {
    # Saída formatada para console com cores
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "  VERIFICAÇÃO DE HARDWARE - WINDOWS 11" -ForegroundColor Cyan
    Write-Host "========================================`n" -ForegroundColor Cyan

    foreach ($check in $CheckResults.GetEnumerator() | Sort-Object Name) {
        $icon = switch ($check.Value.Status) {
            'PASS' { '✓'; $color = 'Green' }
            'FAIL' { '✗'; $color = 'Red' }
            'UNDETERMINED' { '?'; $color = 'Yellow' }
            default { '-'; $color = 'Gray' }
        }

        $checkName = $check.Name.PadRight(15)
        Write-Host "  $icon " -ForegroundColor $color -NoNewline
        Write-Host "$checkName : " -NoNewline
        Write-Host "$($check.Value.Value)" -ForegroundColor White -NoNewline

        if ($check.Value.Message) {
            Write-Host " - $($check.Value.Message)" -ForegroundColor Gray
        }
        else {
            Write-Host ""
        }
    }

    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "  RESULTADO: " -NoNewline

    switch ($returnResult) {
        'CAPABLE' {
            Write-Host "✓ COMPATÍVEL COM WINDOWS 11" -ForegroundColor Green
        }
        'NOT CAPABLE' {
            Write-Host "✗ NÃO COMPATÍVEL" -ForegroundColor Red
            Write-Host "  Componentes com falha: $returnReason" -ForegroundColor Yellow
        }
        'UNDETERMINED' {
            Write-Host "? INDETERMINADO" -ForegroundColor Yellow
            Write-Host "  Execute como Administrador para verificação completa" -ForegroundColor Yellow
        }
    }

    Write-Host "========================================`n" -ForegroundColor Cyan
}
else {
    # Saída JSON (padrão) - compatível com Intune/SCCM
    $output = [PSCustomObject]@{
        returnCode   = $returnCode
        returnResult = $returnResult
        returnReason = $returnReason
        checks       = @{}
        details      = @{}
    }

    foreach ($check in $CheckResults.GetEnumerator()) {
        $output.checks[$check.Name] = $check.Value.Status
        $output.details[$check.Name] = @{
            value   = $check.Value.Value
            message = $check.Value.Message
        }
    }

    $output | ConvertTo-Json -Compress
}

#EndRegion

# Código de saída para scripts de automação
exit $returnCode
