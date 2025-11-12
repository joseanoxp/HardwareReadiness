# Windows 11 Hardware Readiness Checker

[![GitHub](https://img.shields.io/badge/GitHub-joseanoxp%2FHardwareReadiness-blue?logo=github)](https://github.com/joseanoxp/HardwareReadiness)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B%20%7C%207%2B-blue?logo=powershell)](https://github.com/PowerShell/PowerShell)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)

Script PowerShell melhorado para verificar se o hardware atende aos requisitos do Windows 11.

**🚀 Execução Rápida**:
```powershell
irm https://raw.githubusercontent.com/joseanoxp/HardwareReadiness/main/HardwareReadiness.ps1 | iex
```

**📊 Compartilhe seus Resultados**:

Ajude a melhorar este projeto! Envie os resultados da verificação do seu hardware:

👉 **[Formulário de Envio de Resultados](https://joseanoxp.notion.site/2a9fb6ce69a2804daf82ff93572c8b23?pvs=105)**

Seus dados ajudam a:
- Identificar padrões de compatibilidade
- Melhorar a detecção de hardware
- Criar estatísticas sobre dispositivos compatíveis com Windows 11

*Os dados são anônimos e usados apenas para fins estatísticos.*

---

## Novidades da Versão 2.0

### Verificações Adicionadas
- **GPU**: Valida DirectX 12 e WDDM 2.0
- **UEFI**: Verificação explícita de firmware UEFI (não apenas Secure Boot)
- **Display**: Valida resolução mínima (1280x720)
- **Versão do Windows**: Confirma Windows 10 Build 19041 (2004) ou superior

### Melhorias Implementadas
- Migrado de `Get-WmiObject` para `Get-CimInstance` (PowerShell Core compatível)
- Código refatorado com helper functions (redução de duplicação)
- Saída mais concisa e focada
- Dois formatos de saída: **JSON** (automação) e **Console** (visualização)
- Comentários explicativos no código C# de validação de CPU
- Suporte para execução remota via URL

## Requisitos

- **PowerShell 5.1+** ou **PowerShell Core 7+**
- **Permissões de Administrador** (recomendado para verificação completa)
- **Windows 10/11**

## Uso Local

### Formato JSON (padrão - para automação)
```powershell
.\HardwareReadiness.ps1
```

**Saída:**
```json
{"returnCode":0,"returnResult":"CAPABLE","returnReason":"","checks":{"Storage":"PASS","Memory":"PASS",...}}
```

### Formato Console (visualização amigável)
```powershell
.\HardwareReadiness.ps1 -Format Console
```

**Saída:**
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

### Modo Verbose (debug)
```powershell
.\HardwareReadiness.ps1 -Format Console -VerboseOutput
```

## Uso Remoto via URL

Ideal para execução rápida em múltiplas máquinas sem download prévio:

### Executar direto do GitHub

**Formato JSON (padrão)**:
```powershell
irm https://raw.githubusercontent.com/joseanoxp/HardwareReadiness/main/HardwareReadiness.ps1 | iex
```

**Formato Console (colorido)**:
```powershell
iex "& {$(irm https://raw.githubusercontent.com/joseanoxp/HardwareReadiness/main/HardwareReadiness.ps1)} -Format Console"
```

**Formato Console com Verbose**:
```powershell
iex "& {$(irm https://raw.githubusercontent.com/joseanoxp/HardwareReadiness/main/HardwareReadiness.ps1)} -Format Console -VerboseOutput"
```

### Executar com parâmetros personalizados
```powershell
# Download temporário e execução
$tempFile = New-TemporaryFile
Rename-Item -Path $tempFile -NewName "$($tempFile.BaseName).ps1" -PassThru | Out-Null
$scriptPath = "$($tempFile.DirectoryName)\$($tempFile.BaseName).ps1"

irm https://raw.githubusercontent.com/joseanoxp/HardwareReadiness/main/HardwareReadiness.ps1 -OutFile $scriptPath
& $scriptPath -Format Console -VerboseOutput

Remove-Item $scriptPath
```

**📖 Documentação completa**: [EXECUCAO_REMOTA.md](EXECUCAO_REMOTA.md)

## Deploy Enterprise (Intune/SCCM)

### Microsoft Intune
1. Navegue para **Devices** > **Scripts** > **Add** > **Windows 10 and later**
2. Configure:
   - **Name**: Windows 11 Hardware Readiness Check
   - **Script**: Upload `HardwareReadiness.ps1`
   - **Run script in 64-bit PowerShell**: Yes
   - **Run this script using the logged-on credentials**: No (usar SYSTEM)

3. Resultado JSON será capturado nos logs do Intune

### Configuration Manager (SCCM)
```powershell
# Criar Package com este script
# Detection Method: Verificar exit code
# Exit Code 0 = Compatível
# Exit Code 1 = Não compatível
# Exit Code -1 = Indeterminado
```

## Estrutura do Código

### Verificações Implementadas (9 no total)

| Verificação | Requisito | Método |
|-------------|-----------|--------|
| **Storage** | 64 GB mínimo | Win32_LogicalDisk (CIM) |
| **Memory** | 4 GB mínimo | Win32_PhysicalMemory (CIM) |
| **TPM** | Versão 2.0+ | Get-Tpm + Win32_Tpm (CIM) |
| **Processor** | 1 GHz, 2 cores, 64-bit | Win32_Processor + validação C# |
| **SecureBoot** | Habilitado | Confirm-SecureBootUEFI |
| **UEFI** | Firmware UEFI | Registry + Confirm-SecureBootUEFI |
| **GPU** | DirectX 12, WDDM 2.0+ | Win32_VideoController (CIM) |
| **Display** | 1280x720 mínimo | Win32_VideoController (CIM) |
| **Windows Version** | Build 19041+ | Win32_OperatingSystem (CIM) |

### Códigos de Retorno

- **0**: `CAPABLE` - Hardware compatível com Windows 11
- **1**: `NOT CAPABLE` - Hardware não atende requisitos
- **-1**: `UNDETERMINED` - Não foi possível determinar (permissões insuficientes)
- **-2**: `FAILED TO RUN` - Script não executou (erro crítico)

## Validação de CPU

O script inclui validação avançada de CPU via código C# para:

### Intel
- **Family 6, Model ≥ 95** (8ª geração Coffee Lake e posteriores)
- **Exceção**: Model 85 (Skylake-X) é suportado
- **Validação especial**: Models 142/158 com stepping 9 (Kaby Lake-R)

### AMD
- **Family ≥ 23** (arquitetura Zen e posteriores)
- **Exceção**: Family 23, Models 1 e 17 (primeiras revisões Zen 1) não suportados

### Qualcomm ARM
- Requer **ARM v8.1** com instruções atômicas

### Exceções Especiais
- **Surface Studio 2** com i7-7820HQ
- **Dell Precision 5520** com i7-7820HQ

## Solução de Problemas

### "Execution policy" bloqueando script
```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\HardwareReadiness.ps1
```

### Verificações retornando UNDETERMINED
Execute como Administrador:
```powershell
Start-Process powershell -Verb RunAs -ArgumentList "-File .\HardwareReadiness.ps1 -Format Console"
```

### GPU mostrando "Microsoft Basic Display"
- Driver de vídeo não instalado ou desatualizado
- Instale os drivers do fabricante (NVIDIA, AMD, Intel)

### TPM não detectado
1. Verifique BIOS/UEFI: TPM/PTT deve estar habilitado
2. Intel: Procure por "Intel PTT"
3. AMD: Procure por "AMD fTPM"

## Referências Oficiais

- [Requisitos do Windows 11](https://learn.microsoft.com/pt-br/windows/whats-new/windows-11-requirements)
- [Understanding Readiness for Windows 11 with Microsoft Endpoint Manager](https://techcommunity.microsoft.com/blog/microsoftintuneblog/understanding-readiness-for-windows-11-with-microsoft-endpoint-manager/2770866)

## Licença

MIT License - Copyright (C) 2021-2025 Microsoft Corporation

## Contribuindo

1. Faça fork do repositório
2. Crie uma branch para sua feature (`git checkout -b feature/NovaVerificacao`)
3. Commit suas mudanças (`git commit -m 'Adiciona verificação XYZ'`)
4. Push para a branch (`git push origin feature/NovaVerificacao`)
5. Abra um Pull Request

## Changelog

### v2.0 (2025-01)
- ✨ Adicionadas 4 novas verificações (GPU, UEFI, Display, Windows Version)
- 🔄 Migrado para Get-CimInstance (PowerShell Core compatível)
- 🎨 Dois formatos de saída (JSON e Console)
- 📝 Helper functions para reduzir duplicação
- 🚀 Suporte para execução remota via URL
- 💬 Comentários explicativos no código C#

### v1.0 (2021-11)
- Versão original da Microsoft
- 5 verificações básicas (Storage, Memory, TPM, CPU, SecureBoot)
- Saída JSON apenas
