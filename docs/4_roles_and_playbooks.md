[На главную](../README.md)

# 4. Описание ролей и плейбуков

В этом проекте используются Ansible плейбуки и роли для автоматизации развертывания и настройки.

## Плейбуки

Плейбуки находятся в директории `ansible/playbooks/`.

*   **`gitlab-installation.yml`**: Устанавливает и настраивает GitLab на выделенном сервере.
*   **`setup-runner.yml`**: Настраивает сервер для GitLab Runner, устанавливает Docker и регистрирует Runner в GitLab.
*   **`web-server-configuration.yml`**: Устанавливает Docker на серверы `stage` и `prod`.
*   **`setup-deploy-servers.yml`**: Создает пользователя `deploy_user` на серверах `stage` и `prod` и настраивает SSH-ключи для беспарольного доступа.
*   **`allow-http-on-servers.yml`**: Настраивает Docker для работы с небезопасным (HTTP) registry.

## Роли

Роли находятся в директории `ansible/roles/`.

*   **`docker_installation`**: Устанавливает Docker и Docker Compose.
*   **`gitlab_configuration`**: Настраивает GitLab с использованием Docker Compose, применяя шаблоны и переменные.
*   **`gitlab_deploy`**: (Предположительно для деплоя приложений из GitLab, в данном контексте может быть не до конца реализована).
*   **`insecure-registries`**: Конфигурирует `daemon.json` для Docker, чтобы разрешить подключение к insecure registries.
*   **`rsync`**: Роль для синхронизации файлов (в данном проекте может использоваться для деплоя без Docker).
*   **`secure`**: Применяет базовые настройки безопасности, такие как закрытие портов через `ufw`.
*   **`setup_runner`**: Устанавливает и регистрирует GitLab Runner.
*   **`web_deploy`**: Создает пользователя `deploy_user` и настраивает права для развертывания веб-приложений.
