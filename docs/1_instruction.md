[На главную](../README.md)

# Инструкция по развертыванию

## Начальная конфигурация

Понадобится 4 сервера: gitlab, runner, prod, stage. На каждый сервер должны быть проброшены SSH-ключи с управляющей ноды, на которой запускаются плейбуки.

### 1. Настройка Inventory

Пропишите нужные переменные в `inventory/hosts.ini`:
```ini
[gitlab]
gitlab_server ansible_host=192.168.1.99 ansible_user=admin ansible_become_password="{{ gitlab_sudo }}"

[runner]
runner_server ansible_host=192.168.1.102 ansible_user=admin ansible_become_password="{{ runner_sudo }}"

[stage]
stage_server ansible_host=192.168.1.100 ansible_user=admin ansible_become_password="{{ stage_sudo }}"

[prod]
prod_server ansible_host=192.168.1.101 ansible_user=admin ansible_become_password="{{ prod_sudo }}"

[web:children]
stage
prod
```

### 2. Настройка Vault

Создайте зашифрованное хранилище `group_vars/all/vault.yml` для выполнения плейбуков без пароля:
```yaml
gitlab_sudo: "123"
runner_sudo: "123"
prod_sudo: "123"
stage_sudo: "123"
```

### 3. Установка Docker и GitLab
Устанавливаем Docker, rsync на веб-серверы (`stage` и `prod`), настройка безопасности:
```bash
ansible-playbook -i inventory/hosts.ini playbooks/web-sever-configuration.yml --ask-vault-pass
```

Запускаем плейбук для конфигурации GitLab. Он установит Docker, необходимые утилиты, перенесет `daemon.json` с зеркалами и DNS, а также `docker-compose.yml` с примененными переменными.
```bash
ansible-playbook -i inventory/hosts.ini playbooks/gitlab-installation.yml --ask-vault-pass
```
После установки выведется первичный пароль для `root`, который необходимо сменить.

## Настройка CI/CD

### 1. Создание Runner
После создания проекта в GitLab необходимо создать Runner (**Project > Settings > CI/CD > Runners**) и сохранить токен (начинается с `glrt-`) в `group_vars/runner/vault.yml`.

### 2. Конфигурация Runner-сервера
Запускаем плейбук для конфигурации сервера, где будет работать Runner:
```bash
ansible-playbook -i inventory/hosts.ini playbooks/setup-runner.yml --ask-vault-pass
```

### 3. Настройка серверов для деплоя
Далее нужно прокинуть публичные ключи на сервера и добавить приватные в Variables. 
```bash
ansible-playbook -i inventory/hosts.ini playbooks/setup-deploy-servers.yml --ask-vault-pass
```
Приватные ключи находятся *home/deploy_user/.ssh/id_rsa_stage* и *home/deploy_user/.ssh/id_rsa_prod* на GitLab сервере, подключаемся по ssh и достаем. Далее добавляем (`id_rsa_stage` и `id_rsa_prod`) в **Settings > CI/CD > Variables**, чтобы Runner мог к ним подключаться.
*   **Type**: `File`
*   **Environment scope**: `stage` или `prod`
*   **Key**: `SSH_PRIVATE_KEY`
*   **Value**: Содержимое соответствующего приватного ключа. В конце должна быть пустая строка.
Также если уже использовать готовый пайплайн из проекта нужно будет создать TARGET_IP с ip серверов prod и stage с такими же переменными окружения как и у ключей

### 4. Настройка Insecure Registry
Для тестовой конфигурации с HTTP-registry необходимо разрешить небезопасные подключения:
```bash
ansible-playbook -i inventory/hosts.ini playbooks/allow-http-on-servers.yml --ask-vault-pass
```

На этом настройка закончена, осталось только написать .gitlab-ci.yml. После создания ветки добавить ее в protected branches, чтобы ветка видела переменные. Если раннер висит в статусе pending, то велика вероятность, что не совпадают tags у раннера и в пайплайне.

Для использования пайплайна из примера нужно поменять ip в `["--insecure-registry=192.168.1.99:5050"]` на свой.
