# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

Proxy reverso Nginx em container: termina SSL e encaminha para os sistemas por `server_name`. Não há código de aplicação, só configuração Nginx + Docker.

## Comandos

```bash
docker compose up -d --build          # obrigatório --build: conf/ é copiado para a imagem (ADD), não montado como volume
docker exec proxy-reverse nginx -t    # valida a configuração
docker compose config                 # confere a interpolação do .env
```

## Arquitetura

- `conf/` vira `/etc/nginx/` na imagem. O `Dockerfile` apaga `/etc/nginx/conf.d` e `/usr/share/nginx/html` da imagem base antes.
- `conf/nginx.conf` carrega `conf.d/*.conf`; cada sistema tem um arquivo próprio, seguindo `conf.d/example.conf` (bloco 443 com `include` de `includes/ssl.conf` e `includes/error_page.conf` + bloco 80 com redirect 301).
- `includes/ssl.conf` aponta para `ssl/certs/chained.crt` (certificado + intermediário concatenados) e `ssl/certs/private.key`; esse certificado é compartilhado por todos os sites.
- Rede `proxy_default` é criada pelo compose com nome/subnet/gateway do `.env` (`name:` fixo, sem prefixo de projeto); outros composes entram nela com `external: true`.
- `resolver 127.0.0.11` (DNS do Docker) permite usar nome de container no `proxy_pass` quando o alvo está em `proxy_default`.

## Pegadinhas

- `proxy_pass http://127.0.0.1:...` dentro do container aponta para o próprio container, não para o host.
- `includes/error_page.conf` usa `root /usr/share/nginx/html`, mas o `Dockerfile` remove essa pasta e não adiciona páginas — os erros personalizados não existem na imagem.
- Timeouts de proxy em 360s e `client_max_body_size 40m` são globais (`nginx.conf`).
