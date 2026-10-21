![Build Status](https://github.com/janole/laravel-apache-postgres/actions/workflows/build.yml/badge.svg)
![Scan Image](https://github.com/janole/laravel-apache-postgres/actions/workflows/trivy.yml/badge.svg)

# laravel-apache-postgres

Docker base images for Laravel projects: rootless Apache with mod_php, PostgreSQL support
and Composer. Published as `janole/laravel-apache-postgres` for `linux/amd64` and `linux/arm64`.

## Variants

| Tag | Contents |
| --- | --- |
| `0-php83` | PHP 8.3 |
| `0-php83-node` | PHP 8.3 + Node.js 24 |
| `0-php83-xdebug` | PHP 8.3 + Xdebug |
| `0-php84` | PHP 8.4 |
| `0-php84-node` | PHP 8.4 + Node.js 24 |

Every tag also exists as `0.8-<variant>`. Each build additionally pushes fixed tags you can
pin or roll back to: `0.8.<run>-<variant>` and `0.8-<variant>-<php version>`, e.g.
`0.8-php83-8.3.36`.

`php83-xdebug-node` and `php83-node-xdebug` are retired; the last pushed images stay on
Docker Hub but are no longer updated.

## Building locally

The variant tree lives in `docker-bake.hcl`. `build.sh` wraps `docker buildx bake`:

```sh
./build.sh                    # all variants, native platform only (arm64 on Apple silicon)
./build.sh php83 php83-node   # selected variants; parents are built as needed
./build.sh --all-platforms    # amd64 + arm64; the foreign one runs under QEMU (slow)
./build.sh --print            # show the resolved build definition
```

## CI

- **Docker Image** (`build.yml`): builds every variant on native amd64 and arm64 runners,
  then merges them into multi-arch tags. Runs on push to `master`, weekly, and on demand.
  Builds from other branches only push `0.8.<run>-<variant>-<branch>` test tags.
- **Check Upstream** (`upstream.yml`): hourly; starts a build when a new official
  `php:8.x-apache-bookworm` image is out. Trivy cannot see PHP itself, so this is what
  picks up PHP security releases.
- **Scan Image** (`trivy.yml`): nightly Trivy scan of `0.8-php83-node`; starts a build
  when it finds fixable vulnerabilities.
