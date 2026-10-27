# proxy-reverse

Proxy reverso Nginx em container, com terminação SSL e redirecionamento HTTP → HTTPS.

## Estrutura

```
.
├── .env                    # nome, subnet e gateway da rede Docker
├── docker-compose.yml
├── Dockerfile              # imagem nginx + conteúdo de conf/
└── conf/                   # copiado para /etc/nginx/
    ├── nginx.conf
    ├── conf.d/             # um .conf por site/sistema
    │   └── example.conf
    ├── includes/
    │   ├── ssl.conf        # parâmetros SSL compartilhados
    │   └── error_page.conf
    └── ssl/
        ├── certs/chained.crt
        ├── certs/private.key
        └── dhparams.pem
```

## Rede

A rede é criada pelo próprio compose a partir do `.env`:

```env
NETWORK_NAME=proxy_default
NETWORK_SUBNET=10.255.255.0/27
NETWORK_GATEWAY=10.255.255.1
```

Para outro compose usar a mesma rede:

```yaml
networks:
  proxy_default:
    external: true
```

Se já existir uma rede `proxy_default` com configuração diferente, remova antes de subir:
`docker network rm proxy_default`.

## Subir

```bash
docker compose up -d --build
```

A configuração é copiada para a imagem no build, então **qualquer alteração em `conf/` exige `--build`**.

## Adicionar um sistema

1. Copie `conf/conf.d/example.conf` para `conf/conf.d/<sistema>.conf`.
2. Ajuste `server_name` (nos dois blocos `server`) e os `proxy_pass`.
3. Rebuild: `docker compose up -d --build`.

Validar a configuração sem derrubar o proxy:

```bash
docker exec proxy-reverse nginx -t
```

## Certificados

Substitua os arquivos em `conf/ssl/` pelo certificado (cadeia completa em `chained.crt`) e chave privada, e faça o rebuild.

> `private.key` não deve ir para repositório público.
