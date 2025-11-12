# 🚀 Execução Remota do Script

Este documento contém todos os comandos para executar o script **HardwareReadiness.ps1** remotamente, sem necessidade de download prévio.

## 📦 URL do Repositório

**GitHub**: https://github.com/joseanoxp/HardwareReadiness

**Script Raw**: https://raw.githubusercontent.com/joseanoxp/HardwareReadiness/main/HardwareReadiness.ps1

## 📊 Compartilhe seus Resultados

**[👉 Formulário de Envio de Resultados](https://joseanoxp.notion.site/2a9fb6ce69a2804daf82ff93572c8b23?pvs=105)**

Após executar o script, você pode enviar seus resultados de forma anônima para ajudar a melhorar o projeto!

---

## ⚡ Comandos de Execução Rápida

### 1️⃣ Execução Direta (Formato JSON)

```powershell
irm https://raw.githubusercontent.com/joseanoxp/HardwareReadiness/main/HardwareReadiness.ps1 | iex
```

**O que faz**: Baixa e executa o script, retornando JSON no console.

**Uso**: Ideal para capturar resultado em variável ou pipeline.

---

### 2️⃣ Execução com Saída Console (Colorida)

```powershell
iex "& {$(irm https://raw.githubusercontent.com/joseanoxp/HardwareReadiness/main/HardwareReadiness.ps1)} -Format Console"
```

**O que faz**: Baixa e executa com saída formatada e colorida em uma única linha.

**Uso**: Ideal para verificação visual direta.

---

### 3️⃣ Execução com Modo Verbose

```powershell
iex "& {$(irm https://raw.githubusercontent.com/joseanoxp/HardwareReadiness/main/HardwareReadiness.ps1)} -Format Console -VerboseOutput"
```

**O que faz**: Executa com informações detalhadas de debug em uma única linha.

**Uso**: Troubleshooting e análise detalhada.

---

## 🔐 Execução com Bypass de Política (se necessário)

Se sua política de execução bloquear scripts remotos:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
irm https://raw.githubusercontent.com/joseanoxp/HardwareReadiness/main/HardwareReadiness.ps1 | iex
```

---

## 💾 Download + Execução Local

Se preferir baixar e executar localmente:

```powershell
# Download
irm https://raw.githubusercontent.com/joseanoxp/HardwareReadiness/main/HardwareReadiness.ps1 -OutFile HardwareReadiness.ps1

# Executar formato JSON
.\HardwareReadiness.ps1

# Executar formato Console
.\HardwareReadiness.ps1 -Format Console

# Executar com verbose
.\HardwareReadiness.ps1 -Format Console -VerboseOutput
```

---

## 📊 Capturar Resultado em Variável

```powershell
# Executar e converter JSON para objeto
$result = irm https://raw.githubusercontent.com/joseanoxp/HardwareReadiness/main/HardwareReadiness.ps1 | iex | ConvertFrom-Json

# Verificar compatibilidade
if ($result.returnCode -eq 0) {
    Write-Host "✓ Sistema compatível com Windows 11" -ForegroundColor Green
} else {
    Write-Host "✗ Sistema NÃO compatível: $($result.returnReason)" -ForegroundColor Red
}

# Exibir detalhes
$result.details | ConvertTo-Json -Depth 3
```

---

## 🏢 Uso Corporativo (Intune/SCCM)

### Microsoft Intune - Remediation Script

**Detection Script**:
```powershell
try {
    $result = irm https://raw.githubusercontent.com/joseanoxp/HardwareReadiness/main/HardwareReadiness.ps1 | iex | ConvertFrom-Json

    if ($result.returnCode -eq 0) {
        Write-Output "Compliant"
        exit 0
    } else {
        Write-Output "Not Compliant: $($result.returnReason)"
        exit 1
    }
} catch {
    Write-Output "Failed to check: $_"
    exit 1
}
```

**Remediation Script** (Não aplicável - apenas detecção):
```powershell
Write-Output "Verificação de hardware não pode ser remediada automaticamente"
exit 0
```

### Configuration Manager (SCCM)

**Package Script**:
```powershell
$tempFile = "$env:TEMP\HardwareReadiness.ps1"
irm https://raw.githubusercontent.com/joseanoxp/HardwareReadiness/main/HardwareReadiness.ps1 -OutFile $tempFile

& $tempFile -Format JSON | Out-File "$env:TEMP\Win11Readiness.json"
$exitCode = $LASTEXITCODE

Remove-Item $tempFile -Force
exit $exitCode
```

---

## 🌐 Execução em Múltiplas Máquinas Remotas

### Via PowerShell Remoting

```powershell
$computers = @("PC1", "PC2", "PC3")

$results = Invoke-Command -ComputerName $computers -ScriptBlock {
    $result = irm https://raw.githubusercontent.com/joseanoxp/HardwareReadiness/main/HardwareReadiness.ps1 | iex | ConvertFrom-Json

    [PSCustomObject]@{
        Computer     = $env:COMPUTERNAME
        Compatible   = ($result.returnCode -eq 0)
        Result       = $result.returnResult
        Reason       = $result.returnReason
        Details      = $result.checks
    }
}

# Exportar relatório
$results | Export-Csv -Path "Win11ReadinessReport.csv" -NoTypeInformation

# Resumo
$compatible = ($results | Where-Object Compatible).Count
Write-Host "Compatíveis: $compatible de $($results.Count)" -ForegroundColor Cyan
```

---

## 🔄 Atualização Automática (Sempre última versão)

Como o script é executado diretamente do GitHub, você sempre obtém a versão mais recente:

```powershell
# Este comando SEMPRE executa a última versão do repositório
irm https://raw.githubusercontent.com/joseanoxp/HardwareReadiness/main/HardwareReadiness.ps1 | iex
```

Sem necessidade de reinstalar ou atualizar manualmente! 🎉

---

## 📋 Exemplos de Saída

### JSON (padrão)
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
  }
}
```

### Console (com -Format Console)
```
========================================
  VERIFICAÇÃO DE HARDWARE - WINDOWS 11
========================================

  ✓ Display         : 1920x1080
  ✓ GPU             : NVIDIA GeForce RTX 3060
  ✓ Memory          : 16 GB
  ✓ Processor       : Intel Core i7-10700K
  ✓ SecureBoot      : Habilitado
  ✓ Storage         : 512 GB
  ✓ TPM             : 2.0
  ✓ UEFI            : UEFI
  ✓ WindowsVersion  : Build 22631

========================================
  RESULTADO: ✓ COMPATÍVEL COM WINDOWS 11
========================================
```

---

## ❓ Solução de Problemas

### Erro: "Arquivo não encontrado"
- Verifique a URL: https://raw.githubusercontent.com/joseanoxp/HardwareReadiness/main/HardwareReadiness.ps1
- Certifique-se que tem conexão com internet

### Erro: "Execution policy"
- Execute: `Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force`

### Erro: "Access denied" em verificações
- Execute PowerShell como **Administrador** para verificação completa

### Script não retorna nada
- Verifique se o PowerShell está atualizado (5.1+ ou 7+)
- Execute: `$PSVersionTable`

---

## 📞 Suporte

- **Issues**: https://github.com/joseanoxp/HardwareReadiness/issues
- **Documentação**: https://github.com/joseanoxp/HardwareReadiness/blob/main/README.md
- **Exemplos**: https://github.com/joseanoxp/HardwareReadiness/blob/main/EXEMPLO_SAIDA.md

---

## ⭐ Atalho para Favoritos

Salve este comando nos seus favoritos do PowerShell:

```powershell
# Adicionar ao perfil do PowerShell
Add-Content $PROFILE "`nfunction Test-Win11Ready { irm https://raw.githubusercontent.com/joseanoxp/HardwareReadiness/main/HardwareReadiness.ps1 | iex }"

# Usar depois:
Test-Win11Ready
```

Agora você pode usar `Test-Win11Ready` em qualquer sessão! 🚀
