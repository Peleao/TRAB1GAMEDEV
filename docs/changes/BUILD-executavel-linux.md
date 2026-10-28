# BUILD — executável Linux e README

**Objetivo:** `build/` com o executável Linux funcionando e o README com controles, créditos dos assets e como rodar.
**Depende de:** INIM
**Pode rodar em paralelo com:** nada
**Passa pelo ux-ui:** não

## Contratos

- `export_presets.cfg` com preset `"Linux"` (x86_64, PCK embutido), saída `build/gelo.x86_64`.
- `.gitignore` não ignora `build/`.
- `README.md`: descrição, controles, como rodar no Linux (`chmod +x build/gelo.x86_64`), mecânicas implementadas × itens do enunciado, créditos Kenney CC0.

## Pacotes

1. Export e README — `export_presets.cfg`, `build/`, `README.md`.
2. Teste do executável — rodar `build/gelo.x86_64` no Linux (WSL ou Docker, se disponível) por alguns segundos em modo headless e confirmar que abre sem erro.

## Critérios de aceite

- [ ] `build/gelo.x86_64` existe e é gerado pelo comando do `CLAUDE.md`.
- [ ] Executável abre no Linux sem erros (ou a sessão diz como não pôde testar).
- [ ] README completo.

## Riscos

- Sem Linux na máquina para testar → tentar WSL; se não houver, pedir para a pessoa testar antes da entrega.

## Comandos

Ver `CLAUDE.md` (build Linux).
