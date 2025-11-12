# Exemplos de Saída do Script

## Exemplo 1: Sistema Compatível (Formato Console)

```
========================================
  VERIFICAÇÃO DE HARDWARE - WINDOWS 11
========================================

  ✓ Display         : 1920x1080 - Resolução adequada (mínimo 1280x720)
  ✓ GPU             : NVIDIA GeForce RTX 3060 - Driver: 31.0.15.3623
  ✓ Memory          : 16 GB - Memória suficiente
  ✓ Processor       : Intel(R) Core(TM) i7-10700K CPU @ 3.80GHz - 16 cores, 3792 MHz
  ✓ SecureBoot      : Habilitado - Secure Boot ativo
  ✓ Storage         : 512 GB - Armazenamento suficiente
  ✓ TPM             : 2.0,3 - TPM 2.0 detectado
  ✓ UEFI            : UEFI - Firmware UEFI detectado
  ✓ WindowsVersion  : Build 22631 - Windows 11

========================================
  RESULTADO: ✓ COMPATÍVEL COM WINDOWS 11
========================================
```

**Exit Code**: 0

---

## Exemplo 2: Sistema Compatível (Formato JSON)

```json
{
  "returnCode": 0,
  "returnResult": "CAPABLE",
  "returnReason": "",
  "checks": {
    "Storage": "PASS",
    "Memory": "PASS",
    "TPM": "PASS",
    "Processor": "PASS",
    "SecureBoot": "PASS",
    "UEFI": "PASS",
    "GPU": "PASS",
    "Display": "PASS",
    "WindowsVersion": "PASS"
  },
  "details": {
    "Storage": {
      "value": "512 GB",
      "message": "Armazenamento suficiente"
    },
    "Memory": {
      "value": "16 GB",
      "message": "Memória suficiente"
    },
    "TPM": {
      "value": "2.0,3",
      "message": "TPM 2.0 detectado"
    },
    "Processor": {
      "value": "Intel(R) Core(TM) i7-10700K CPU @ 3.80GHz",
      "message": "16 cores, 3792 MHz"
    },
    "SecureBoot": {
      "value": "Habilitado",
      "message": "Secure Boot ativo"
    },
    "UEFI": {
      "value": "UEFI",
      "message": "Firmware UEFI detectado"
    },
    "GPU": {
      "value": "NVIDIA GeForce RTX 3060",
      "message": "Driver: 31.0.15.3623"
    },
    "Display": {
      "value": "1920x1080",
      "message": "Resolução adequada (mínimo 1280x720)"
    },
    "WindowsVersion": {
      "value": "Build 22631",
      "message": "Windows 11"
    }
  }
}
```

**Exit Code**: 0

---

## Exemplo 3: Sistema NÃO Compatível (Formato Console)

```
========================================
  VERIFICAÇÃO DE HARDWARE - WINDOWS 11
========================================

  ✗ Display         : 1024x768 - Resolução mínima: 1280x720
  ✗ GPU             : Intel HD Graphics 2000 - GPU não suporta DirectX 12
  ✓ Memory          : 8 GB - Memória suficiente
  ✗ Processor       : Intel(R) Core(TM) i5-3570 CPU @ 3.40GHz - CPU não suportada
  ✗ SecureBoot      : Não suportado - Sistema não suporta Secure Boot (provável BIOS Legacy)
  ✓ Storage         : 256 GB - Armazenamento suficiente
  ✗ TPM             : 1.2 - TPM 2.0 ou superior requerido
  ✗ UEFI            : Legacy BIOS - UEFI requerido
  ✓ WindowsVersion  : Build 19044 - Windows 10 2004+

========================================
  RESULTADO: ✗ NÃO COMPATÍVEL
  Componentes com falha: Display, GPU, Processor, SecureBoot, TPM, UEFI
========================================
```

**Exit Code**: 1

---

## Exemplo 4: Sistema NÃO Compatível (Formato JSON)

```json
{
  "returnCode": 1,
  "returnResult": "NOT CAPABLE",
  "returnReason": "Display, GPU, Processor, SecureBoot, TPM, UEFI",
  "checks": {
    "Storage": "PASS",
    "Memory": "PASS",
    "TPM": "FAIL",
    "Processor": "FAIL",
    "SecureBoot": "FAIL",
    "UEFI": "FAIL",
    "GPU": "FAIL",
    "Display": "FAIL",
    "WindowsVersion": "PASS"
  },
  "details": {
    "Storage": {
      "value": "256 GB",
      "message": "Armazenamento suficiente"
    },
    "Memory": {
      "value": "8 GB",
      "message": "Memória suficiente"
    },
    "TPM": {
      "value": "1.2",
      "message": "TPM 2.0 ou superior requerido"
    },
    "Processor": {
      "value": "Intel(R) Core(TM) i5-3570 CPU @ 3.40GHz",
      "message": "CPU não suportada"
    },
    "SecureBoot": {
      "value": "Não suportado",
      "message": "Sistema não suporta Secure Boot (provável BIOS Legacy)"
    },
    "UEFI": {
      "value": "Legacy BIOS",
      "message": "UEFI requerido"
    },
    "GPU": {
      "value": "Intel HD Graphics 2000",
      "message": "GPU não suporta DirectX 12"
    },
    "Display": {
      "value": "1024x768",
      "message": "Resolução mínima: 1280x720"
    },
    "WindowsVersion": {
      "value": "Build 19044",
      "message": "Windows 10 2004+"
    }
  }
}
```

**Exit Code**: 1

---

## Exemplo 5: Verificação Indeterminada (sem permissões)

```
========================================
  VERIFICAÇÃO DE HARDWARE - WINDOWS 11
========================================

  ✓ Display         : 1920x1080 - Resolução adequada (mínimo 1280x720)
  ✓ GPU             : AMD Radeon RX 5700 XT - Driver: 30.0.15025.1000
  ✓ Memory          : 16 GB - Memória suficiente
  ✓ Processor       : AMD Ryzen 7 3700X 8-Core Processor - 16 cores, 3600 MHz
  ? SecureBoot      : Desconhecido - Sem permissão para verificar (execute como Administrador)
  ✓ Storage         : 1024 GB - Armazenamento suficiente
  ? TPM             : Desconhecida - Erro: UnauthorizedAccessException
  ? UEFI            : Desconhecido - Não foi possível determinar tipo de firmware
  ✓ WindowsVersion  : Build 22000 - Windows 11

========================================
  RESULTADO: ? INDETERMINADO
  Execute como Administrador para verificação completa
========================================
```

**Exit Code**: -1

---

## Exemplo 6: Exceção - Surface Studio 2 com i7-7820HQ

```
========================================
  VERIFICAÇÃO DE HARDWARE - WINDOWS 11
========================================

  ✓ Display         : 4500x3000 - Resolução adequada (mínimo 1280x720)
  ✓ GPU             : NVIDIA GeForce GTX 1060 - Driver: 30.0.15.1233
  ✓ Memory          : 32 GB - Memória suficiente
  ✓ Processor       : Intel(R) Core(TM) i7-7820HQ CPU @ 2.90GHz - 8 cores, 2900 MHz
  ✓ SecureBoot      : Habilitado - Secure Boot ativo
  ✓ Storage         : 1024 GB - Armazenamento suficiente
  ✓ TPM             : 2.0,3 - TPM 2.0 detectado
  ✓ UEFI            : UEFI - Firmware UEFI detectado
  ✓ WindowsVersion  : Build 19044 - Windows 10 2004+

========================================
  RESULTADO: ✓ COMPATÍVEL COM WINDOWS 11
========================================
```

**Nota**: O processador i7-7820HQ normalmente **não seria compatível** (7ª geração), mas o Surface Studio 2 tem uma **exceção especial** da Microsoft.

**Exit Code**: 0

---

## Comparação: Script Original vs Nova Versão

| Aspecto | Versão Original (1.0) | Nova Versão (2.0) |
|---------|----------------------|-------------------|
| **Verificações** | 5 | 9 (+4 novas) |
| **Formato de Saída** | JSON apenas | JSON + Console |
| **Verbosidade** | Alta (logs extensos) | Concisa (focada) |
| **CIM/WMI** | Get-WmiObject | Get-CimInstance |
| **Comentários C#** | Não | Sim (explicativos) |
| **Helper Functions** | Não | Sim (DRY) |
| **Execução Remota** | Não otimizado | Suporte completo |
| **PowerShell Core** | Não testado | Compatível |

---

## Integração com Intune/SCCM

### Exemplo: Parsing de Resultados no Intune

```powershell
# Executar script e capturar JSON
$result = .\HardwareReadiness.ps1 | ConvertFrom-Json

# Verificar resultado
if ($result.returnCode -eq 0) {
    Write-Output "Dispositivo compatível com Windows 11"
    # Adicionar a grupo de upgrade elegível
}
elseif ($result.returnCode -eq 1) {
    Write-Output "Dispositivo NÃO compatível: $($result.returnReason)"
    # Adicionar a grupo de dispositivos para substituição
}
else {
    Write-Output "Verificação indeterminada"
    # Adicionar a grupo para revisão manual
}

# Exportar detalhes
$result.details | ConvertTo-Json -Depth 3 | Out-File "C:\Logs\Win11Readiness.json"
```

### Exemplo: Report Consolidado (múltiplos dispositivos)

```powershell
# Coletar de múltiplas máquinas (via SCCM/Intune)
$devices = @()

foreach ($computer in $computers) {
    $result = Invoke-Command -ComputerName $computer -ScriptBlock {
        C:\Scripts\HardwareReadiness.ps1
    } | ConvertFrom-Json

    $devices += [PSCustomObject]@{
        ComputerName = $computer
        Compatible   = ($result.returnCode -eq 0)
        Reason       = $result.returnReason
        Details      = $result.checks
    }
}

# Exportar relatório
$devices | Export-Csv -Path "Win11ReadinessReport.csv" -NoTypeInformation

# Estatísticas
$compatible = ($devices | Where-Object Compatible).Count
$total = $devices.Count
Write-Host "Compatíveis: $compatible de $total ($([math]::Round($compatible/$total*100, 2))%)"
```
