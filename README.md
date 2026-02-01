# GitLab CI/CD с Ansible

Это руководство описывает процесс создания и настройки локальной среды GitLab, включая GitLab Runner, серверы для stage и prod, а также настройку простого CI/CD пайплайна с использованием Ansible, Vault и Jinja2.

В целях безопасности на серверах `prod` и `stage` будут закрыты все порты, кроме 22 (SSH), 80 (HTTP) и 443 (HTTPS). Доступ по SSH будет осуществляться только по ключам.

## Содержание

1.  [Инструкция](docs/1_instruction.md)
2.  [Пользователи и права](docs/2_users_and_permissions.md)
3.  [Настройка GitLab Runner](docs/3_runner_setup.md)
4.  [Описание ролей и плейбуков](docs/4_roles_and_playbooks.md)
5.  [Основные переменные и конфигурации](docs/5_variables_and_configuration.md)
6.  [Базовый CICD на примере react приложения](react-app/README.md)

## Дополнения и улучшения

1.  Разворачивать инфраструктуру серверов через Terraform
2.  Подключить свой домен и ssl сертификат
3.  Убрать рутинную работу через UI, заменив её через API и Personal Access Token