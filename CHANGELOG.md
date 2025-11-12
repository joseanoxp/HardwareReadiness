# Changelog

Todas as mudanças notáveis neste projeto serão documentadas neste arquivo.

O formato é baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/),
e este projeto adere ao [Semantic Versioning](https://semver.org/lang/pt-BR/).

## [2.0.1] - 2025-01-12

### 🐛 Corrigido

- **UEFI Detection**: Corrigido problema onde UEFI retornava `UNDETERMINED` em sistemas Windows 11 válidos
  - Adicionado Método 4: inferir UEFI baseado em Secure Boot habilitado
  - Melhorada ordem de tentativas de detecção (registry primeiro, depois variável de ambiente)
  - Adicionado tratamento robusto de exceções no `Confirm-SecureBootUEFI`
  - **Lógica**: Se Secure Boot estiver habilitado, o sistema É UEFI (não existe Secure Boot em BIOS Legacy)

- **Windows Version**: Corrigido output duplicado (ex: "Windows 11 Windows 10 2004+")
  - Substituído `switch` por `if/elseif/else` para evitar múltiplas matches
  - Build 22000+ agora exibe corretamente apenas "Windows 11"
  - Build 19041-21999 exibe "Windows 10 2004+"

### 📊 Exemplo de Correção

**Antes** (v2.0.0):
```json
{
  "returnCode": -1,
  "returnResult": "UNDETERMINED",
  "returnReason": "UEFI",
  "checks": {
    "SecureBoot": "PASS",
    "UEFI": "UNDETERMINED"
  },
  "details": {
    "WindowsVersion": {
      "value": "Build 26200",
      "message": "Windows 11 Windows 10 2004+"
    }
  }
}
```

**Depois** (v2.0.1):
```json
{
  "returnCode": 0,
  "returnResult": "CAPABLE",
  "returnReason": "",
  "checks": {
    "SecureBoot": "PASS",
    "UEFI": "PASS"
  },
  "details": {
    "WindowsVersion": {
      "value": "Build 26200",
      "message": "Windows 11"
    }
  }
}
```

---

## [2.0.0] - 2025-01-12

### ✨ Adicionado

- **4 Novas Verificações**:
  - GPU: Valida DirectX 12 e WDDM 2.0 driver
  - UEFI: Verificação explícita de firmware UEFI
  - Display: Valida resolução mínima (1280x720)
  - Windows Version: Verifica Build 19041+ (Windows 10 2004)

- **Dois Formatos de Saída**:
  - JSON (padrão): Ideal para automação/Intune/SCCM
  - Console: Saída colorida e formatada para visualização

- **Suporte para Execução Remota**:
  - Script pode ser executado via URL do GitHub
  - Comando: `irm https://raw.githubusercontent.com/joseanoxp/HardwareReadiness/main/HardwareReadiness.ps1 | iex`

- **Documentação Completa**:
  - README.md com exemplos
  - EXECUCAO_REMOTA.md com guias detalhados
  - EXEMPLO_SAIDA.md com cenários de teste

### 🔄 Modificado

- **Migração WMI → CIM**:
  - Substituído `Get-WmiObject` por `Get-CimInstance`
  - Compatível com PowerShell Core 7+
  - Melhor performance e suporte multiplataforma

- **Código Refatorado**:
  - Helper function `Test-Requirement` para reduzir duplicação
  - Comentários explicativos no código C# de validação de CPU
  - Estrutura mais organizada com regions

- **Saída Mais Concisa**:
  - Reduzidas 15+ constantes de string para 5 essenciais
  - Mensagens focadas e objetivas
  - JSON estruturado e limpo

### 🎯 Melhorado

- **Validação de CPU**:
  - Comentários explicativos sobre Intel Family/Model
  - Documentação de AMD Zen architecture
  - Explicação de ARM v8.1 requirements

- **Tratamento de Erros**:
  - Exceções específicas para Secure Boot
  - Estados UNDETERMINED quando sem permissões
  - Mensagens de erro mais claras

### 📦 Estrutura

```
HardwareReadiness/
├── .gitignore
├── HardwareReadiness.ps1     # Script principal (657→675 linhas)
├── README.md                  # Documentação principal
├── EXEMPLO_SAIDA.md           # Exemplos de output
├── EXECUCAO_REMOTA.md         # Guia de execução remota
└── CHANGELOG.md               # Este arquivo
```

### 🔗 Links

- **Repositório**: https://github.com/joseanoxp/HardwareReadiness
- **Script Raw**: https://raw.githubusercontent.com/joseanoxp/HardwareReadiness/main/HardwareReadiness.ps1

---

## [1.0.0] - 2021-11-29

### ✨ Release Inicial (Microsoft)

- **5 Verificações Básicas**:
  - Storage: 64 GB mínimo
  - Memory: 4 GB mínimo
  - TPM: Versão 2.0 requerida
  - Processor: 1 GHz, 2 cores, 64-bit com validação de família
  - Secure Boot: Deve estar habilitado

- **Saída JSON**:
  - returnCode: 0 (capable), 1 (not capable), -1 (undetermined)
  - returnResult: Status em texto
  - returnReason: Lista de componentes falhados
  - logging: Logs detalhados

- **Validação Avançada de CPU**:
  - Código C# embarcado
  - Suporte Intel (Family 6, Model 95+)
  - Suporte AMD (Family 23+, Zen)
  - Suporte Qualcomm ARM (v8.1+)

- **Exceções Especiais**:
  - Surface Studio 2 com i7-7820HQ
  - Dell Precision 5520 com i7-7820HQ

### 📜 Licença

MIT License - Copyright (C) 2021 Microsoft Corporation

---

## Tipos de Mudanças

- `✨ Adicionado` - Novas funcionalidades
- `🔄 Modificado` - Mudanças em funcionalidades existentes
- `🗑️ Removido` - Funcionalidades removidas
- `🐛 Corrigido` - Correção de bugs
- `🔒 Segurança` - Correções de segurança
- `🎯 Melhorado` - Melhorias de performance ou qualidade
- `📚 Documentação` - Apenas mudanças na documentação
