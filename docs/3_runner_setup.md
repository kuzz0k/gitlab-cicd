[На главную](../README.md)

# 3. Настройка GitLab Runner

После установки GitLab и создания проекта необходимо настроить GitLab Runner, который будет выполнять ваши CI/CD задачи.

### 3.1. Создание Runner в GitLab

1.  Перейдите в ваш проект в GitLab.
2.  Откройте **Settings > CI/CD**.
3.  Разверните секцию **Runners**.
4.  В секции "Project runners" вы увидите токен для регистрации (начинается с `glrt-`).

### 3.2. Сохранение токена

Сохраните полученный токен в зашифрованном файле `group_vars/runner/vault.yml`:

```yaml
# group_vars/runner/vault.yml
gitlab_runner_token: "glrt-INKVDIdBoxH08PRASh0wAG86MQpwOjEKdDozCnU6Mg8.01.1716yya16"
```

Также можно создать Personal Access Token с правами `api` и `admin mode` (**Profile settings > Personal Access Tokens**) и сохранить его в vault для управления GitLab через API.

### 3.3. Конфигурация сервера для Runner

Запустите плейбук для настройки сервера, на котором будет работать Runner. Этот плейбук установит Docker для универсальности, но вы можете использовать его и без Docker (например, установив Node.js, npm и используя `rsync` для передачи файлов).

```bash
ansible-playbook -i inventory/hosts.ini playbooks/setup-runner.yml --ask-vault-pass
```

### 3.4. Получение токена для раннера (альтернативный способ)

Если интерфейс GitLab не отображает токен после создания раннера (например, из-за отсутствия домена или ошибок в конфигурации), его можно получить через консоль GitLab Rails.

1.  Подключитесь к контейнеру GitLab:
    ```bash
    docker exec -it gitlab gitlab-rails console
    ```

2.  После появления консоли Ruby (`irb(main):001:0>`), выполните следующие команды, чтобы получить данные последнего созданного раннера:
    ```ruby
    runner = Ci::Runner.last
    puts "ID: #{runner.id}"
    puts "TOKEN: #{runner.token}"
    ```

3.  В выводе вы увидите ID и токен, который нужно будет использовать для регистрации.
