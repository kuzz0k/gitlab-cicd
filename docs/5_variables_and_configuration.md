[На главную](../README.md)

# 5. Основные переменные и конфигурации

В проекте используется несколько уровней переменных для гибкой настройки окружений.

## Глобальные переменные

Эти переменные применяются ко всем хостам.

*   **`ansible/inventory/group_vars/all/main.yml`**:
    *   `environments_list`: Список окружений, для которых будут генерироваться SSH-ключи.
    *   `deploy_username`: Имя пользователя, который будет создаваться на целевых серверах для развертывания.

    ```yaml
    environments_list:
      - stage
      - prod
    # - staging

    deploy_username: "deploy_user"
    ```

*   **`ansible/inventory/group_vars/all/vault.yml`** (зашифровано):
    *   `*_sudo`: Пароли для повышения привилегий на соответствующих серверах (`gitlab_sudo`, `runner_sudo`, `prod_sudo`, `stage_sudo`).

## Переменные окружений

Для каждого окружения (`prod`, `stage`) можно задать свои переменные.

*   **`ansible/inventory/group_vars/prod.yml`**:
    *   `env_label`: Метка окружения, используется для именования ключей.

    ```yaml
    env_label: "prod"
    ```

*   **`ansible/inventory/group_vars/stage.yml`**:

    ```yaml
    env_label: "stage"
    ```

## Переменные ролей (по умолчанию)

Каждая роль имеет свои переменные по умолчанию, которые можно переопределить в inventory.

*   **`ansible/roles/gitlab_configuration/defaults/main.yml`**:
    *   `gitlab_external_url`: Внешний URL для GitLab.
    *   `gitlab_http_port`: HTTP порт для GitLab.
    *   `gitlab_ssh_port`: SSH порт для GitLab.

    ```yaml
    gitlab_external_url: "{{ ansible_host | default(inventory_hostname) }}"
    gitlab_http_port: "80"
    gitlab_ssh_port: "2224"
    ```

## Добавление нового окружения

Чтобы добавить новое окружение (например, `dev`):

1.  Добавьте сервер в `ansible/inventory/hosts.ini`.
2.  Добавьте `dev` в `environments_list` в `ansible/inventory/group_vars/all/main.yml`.
3.  Создайте файл `ansible/inventory/group_vars/dev.yml` и укажите в нем `env_label: "dev"`.
4.  Добавьте пароль `dev_sudo` в `ansible/inventory/group_vars/all/vault.yml`.

## Конфигурация Ansible (ansible.cfg)

Файл `ansible.cfg` содержит основные настройки для работы Ansible.

### Секция `[defaults]`

*   `host_key_checking = True`: Включает проверку SSH-ключей хостов для повышения безопасности.
*   `forks = 20`: Количество параллельных процессов для ускорения выполнения плейбуков.
*   `gathering = smart`: Собирает факты о хостах только при необходимости.
*   `fact_caching = jsonfile`: Кэширует факты в JSON-файлы для повторного использования.
*   `fact_caching_connection = /var/cache/ansible/facts`: Директория для хранения кэша фактов.
*   `log_path = /var/log/ansible.log`: Путь к файлу логов Ansible.
*   `roles_path = roles`: Указывает директорию, где хранятся роли.
*   `interpreter_python = auto`: Автоматически определяет интерпретатор Python на целевых хостах.

### Секция `[connection]`

*   `pipelining = True`: Ускоряет выполнение команд по SSH за счет уменьшения количества SSH-операций.

### Секция `[ssh_connection]`

*   `ssh_args = -o ControlMaster=auto -o ControlPersist=300s -o ConnectTimeout=30`: Оптимизирует SSH-соединения, позволяя переиспользовать одно соединение для нескольких задач.

### Секция `[privilege_escalation]`

*   `become = True`: Разрешает повышение привилегий (например, до `root`).
*   `become_method = sudo`: Использует `sudo` для повышения привилегий.
*   `become_user = root`: Пользователь, от имени которого будут выполняться команды.
*   `become_ask_pass = False`: Отключает запрос пароля для `sudo`, так как пароли хранятся в `vault`.
