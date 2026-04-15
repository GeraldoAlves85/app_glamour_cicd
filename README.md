# Glamour Botanica - Salao de Beleza e Spa

## Descricao
Landing page profissional para salao de beleza, spa e maquiagem para noivas.

## Tecnologias
- HTML5 / CSS3
- Nginx (Docker)
- SonarCloud (Quality Analysis)
- GitHub Actions (CI/CD)
- Docker Hub (Container Registry)

## CI/CD Pipeline
O pipeline executa automaticamente:
1. Analise de codigo no SonarCloud
2. Build da imagem Docker
3. Deploy para Docker Hub

## Deploy
```bash
docker pull geraldoti2022/glamour-botanica:latest
docker run -d -p 80:80 geraldoti2022/glamour-botanica:latest
