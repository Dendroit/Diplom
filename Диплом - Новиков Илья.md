#  Дипломная работа по профессии «Системный администратор» - Новиков Илья

Содержание
==========

## Задача
Ключевая задача — разработать отказоустойчивую инфраструктуру для сайта, включающую мониторинг, сбор логов и резервное копирование основных данных. Инфраструктура должна размещаться в [Yandex Cloud](https://cloud.yandex.com/) и отвечать минимальным стандартам безопасности: запрещается выкладывать токен от облака в git. Используйте [инструкцию](https://cloud.yandex.ru/docs/tutorials/infrastructure-management/terraform-quickstart#get-credentials).

**Перед началом работы над дипломным заданием изучите [Инструкция по экономии облачных ресурсов](https://github.com/netology-code/devops-materials/blob/master/cloudwork.MD).**

## Инфраструктура
Для развёртки инфраструктуры используйте Terraform и Ansible.  

Не используйте для ansible inventory ip-адреса! Вместо этого используйте fqdn имена виртуальных машин в зоне ".ru-central1.internal". Пример: example.ru-central1.internal  

Важно: используйте по-возможности **минимальные конфигурации ВМ**:2 ядра 20% Intel ice lake, 2-4Гб памяти, 10hdd, прерываемая. 

**Так как прерываемая ВМ проработает не больше 24ч, перед сдачей работы на проверку дипломному руководителю сделайте ваши ВМ постоянно работающими.**

Ознакомьтесь со всеми пунктами из этой секции, не беритесь сразу выполнять задание, не дочитав до конца. Пункты взаимосвязаны и могут влиять друг на друга.

### Сайт
Создайте две ВМ в разных зонах, установите на них сервер nginx, если его там нет. ОС и содержимое ВМ должно быть идентичным, это будут наши веб-сервера.

Используйте набор статичных файлов для сайта. Можно переиспользовать сайт из домашнего задания.

Создайте [Target Group](https://cloud.yandex.com/docs/application-load-balancer/concepts/target-group), включите в неё две созданных ВМ.

Создайте [Backend Group](https://cloud.yandex.com/docs/application-load-balancer/concepts/backend-group), настройте backends на target group, ранее созданную. Настройте healthcheck на корень (/) и порт 80, протокол HTTP.

Создайте [HTTP router](https://cloud.yandex.com/docs/application-load-balancer/concepts/http-router). Путь укажите — /, backend group — созданную ранее.

Создайте [Application load balancer](https://cloud.yandex.com/en/docs/application-load-balancer/) для распределения трафика на веб-сервера, созданные ранее. Укажите HTTP router, созданный ранее, задайте listener тип auto, порт 80.

Протестируйте сайт
`curl -v <публичный IP балансера>:80` 

### Мониторинг
Создайте ВМ, разверните на ней Zabbix. На каждую ВМ установите Zabbix Agent, настройте агенты на отправление метрик в Zabbix. 

Настройте дешборды с отображением метрик, минимальный набор — по принципу USE (Utilization, Saturation, Errors) для CPU, RAM, диски, сеть, http запросов к веб-серверам. Добавьте необходимые tresholds на соответствующие графики.

### Логи
Cоздайте ВМ, разверните на ней Elasticsearch. Установите filebeat в ВМ к веб-серверам, настройте на отправку access.log, error.log nginx в Elasticsearch.

Создайте ВМ, разверните на ней Kibana, сконфигурируйте соединение с Elasticsearch.

### Сеть
Разверните один VPC. Сервера web, Elasticsearch поместите в приватные подсети. Сервера Zabbix, Kibana, application load balancer определите в публичную подсеть.

Настройте [Security Groups](https://cloud.yandex.com/docs/vpc/concepts/security-groups) соответствующих сервисов на входящий трафик только к нужным портам.

Настройте ВМ с публичным адресом, в которой будет открыт только один порт — ssh.  Эта вм будет реализовывать концепцию  [bastion host]( https://cloud.yandex.ru/docs/tutorials/routing/bastion) . Синоним "bastion host" - "Jump host". Подключение  ansible к серверам web и Elasticsearch через данный bastion host можно сделать с помощью  [ProxyCommand](https://docs.ansible.com/ansible/latest/network/user_guide/network_debug_troubleshooting.html#network-delegate-to-vs-proxycommand) . Допускается установка и запуск ansible непосредственно на bastion host.(Этот вариант легче в настройке)

### Резервное копирование
Создайте snapshot дисков всех ВМ. Ограничьте время жизни snaphot в неделю. Сами snaphot настройте на ежедневное копирование.

--------
---


# Выполнение дипломной работы

## Инфраструктура
- **Для развертывания использую:** ***terraform apply***

![1](https://github.com/user-attachments/assets/6f8a95cb-505f-4e21-a5b7-7a95a36b18c0)
![2](https://github.com/user-attachments/assets/f305f2c2-e61c-482b-9fd3-37d217db3b92)


- **Параметры созданных ВМ и дисков**

![image](https://github.com/user-attachments/assets/a7d866dd-5b0d-4f66-85be-517a8dd536b1)
![image](https://github.com/user-attachments/assets/7dbce9ff-49c0-472a-84fe-9337e96b8aad)


- **Устанавливаю Ansible на bastion host**

<img width="474" alt="ansible version" src="https://github.com/user-attachments/assets/a82d3a32-1c2f-475f-8699-1e2522355402">


- **Содержимое файлы inventory.ini** ***(использовались fqdn имена)***

<img width="510" alt="inventory" src="https://github.com/user-attachments/assets/d6cd4d27-e3bc-43bc-b309-26141be73527">

- **Проверяем доступность хостов с помощью** ***Ansible ping***

![ping pong](https://github.com/user-attachments/assets/ea1594bb-2fe0-44fe-984e-84068a917bd1)

## Сайт
****Создайте две ВМ в разных зонах, установите на них сервер nginx, если его там нет. ОС и содержимое ВМ должно быть идентичным, это будут наши веб-сервера.
Используйте набор статичных файлов для сайта. Можно переиспользовать сайт из домашнего задания.****

- **Установка Nginx**

![nginx](https://github.com/user-attachments/assets/f2e4bdbb-a359-44fa-9b43-3515ccfde37f)

- **Создайте Target Group, включите в неё две созданных ВМ.**

![image](https://github.com/user-attachments/assets/fe7f2fae-ab09-4934-b8bc-7266d6c078a5)

- **Создайте Backend Group, настройте backends на target group, ранее созданную. Настройте healthcheck на корень (/) и порт 80, протокол HTTP.**

![image](https://github.com/user-attachments/assets/b1c0cdb9-be61-4de5-8830-6044f4c4a557)

- **Создайте HTTP router. Путь укажите — /, backend group — созданную ранее.**

![image](https://github.com/user-attachments/assets/7443f832-c811-4da8-bc01-837191a814d0)

- **Создайте Application load balancer для распределения трафика на веб-сервера, созданные ранее. Укажите HTTP router, созданный ранее, задайте listener тип auto, порт 80.**

![image](https://github.com/user-attachments/assets/c904405b-db76-476d-8289-fcb0a35061c4)

- **Протестируйте сайт curl -v <публичный IP балансера>:80**

![image](https://github.com/user-attachments/assets/a744fd9d-3389-425f-bb07-e72c5bc1b338)

- **Проверка сайта**

![image](https://github.com/user-attachments/assets/fa58b906-06a8-4fd4-a81b-b505ce98c077)

## Мониторинг

****Создайте ВМ, разверните на ней Zabbix. На каждую ВМ установите Zabbix Agent, настройте агенты на отправление метрик в Zabbix.****
 
- **Установка Zabbix сервера**

![Zabbix-server](https://github.com/user-attachments/assets/33d3be27-a077-427a-96ca-80b781c66a82)
![image](https://github.com/user-attachments/assets/83bc4dd3-9877-4128-83f8-161e81858352)



- **Установка Zabbix агентов**

![zabbix-agent](https://github.com/user-attachments/assets/5677c55b-9f7f-47d5-a37b-77de8d4d0713)

- **Настройте дешборды с отображением метрик, минимальный набор — по принципу USE (Utilization, Saturation, Errors) для CPU, RAM, диски, сеть, http запросов к веб-серверам. Добавьте необходимые tresholds на соответствующие графики.**

![image](https://github.com/user-attachments/assets/a9418b07-d402-4c3d-b9a1-057e4ea22f33)

## Логи

****Cоздайте ВМ, разверните на ней Elasticsearch. Установите filebeat в ВМ к веб-серверам, настройте на отправку access.log, error.log nginx в Elasticsearch.****

- **Установка elasticsearch**

![elastic](https://github.com/user-attachments/assets/df25adcd-85ea-4abd-a0e8-f63c311ec23b)

- **Установка filebeat**

![filebeat](https://github.com/user-attachments/assets/16aa6ae2-0640-459d-9b6f-53758ac1dc94)

- **Установка Kibana**

![kibana](https://github.com/user-attachments/assets/7932db95-1efe-47c1-bfcb-ab571a1f3a71)

- **WEB интерфейс Kibana**

<img width="693" alt="elastic-1" src="https://github.com/user-attachments/assets/1ab7f6b9-df0d-4705-ab87-f9753414d960">
<img width="919" alt="elastic-2" src="https://github.com/user-attachments/assets/9c06607f-24c9-4ccc-9fc6-a3ef5c528104">

## Сеть

****Разверните один VPC. Сервера web, Elasticsearch поместите в приватные подсети. Сервера Zabbix, Kibana, application load balancer определите в публичную подсеть.****
- **Настройте Security Groups соответствующих сервисов на входящий трафик только к нужным портам.**

![image](https://github.com/user-attachments/assets/84881583-8f09-4b3c-ba34-208023a050da)


****Настройте ВМ с публичным адресом, в которой будет открыт только один порт — ssh. Эта вм будет реализовывать концепцию bastion host . Синоним "bastion host" - "Jump host". Подключение ansible к серверам web и Elasticsearch через данный bastion host можно сделать с помощью ProxyCommand . Допускается установка и запуск ansible непосредственно на bastion host.(Этот вариант легче в настройке)****

- **Правило Bastion host**

![image](https://github.com/user-attachments/assets/86258fea-5d2c-4d32-96b2-071df0144810)

![image](https://github.com/user-attachments/assets/b0cf0ed9-900f-423b-8dd4-c2b03af604eb)

## Резервное копирование

- **Создайте snapshot дисков всех ВМ. Ограничьте время жизни snaphot в неделю. Сами snaphot настройте на ежедневное копирование.**

![image](https://github.com/user-attachments/assets/76696339-ec5b-45bd-8808-5b3e5f5ef524)
![image](https://github.com/user-attachments/assets/f1e83d88-a905-4e9e-b9b9-e269f37e604d)
![image](https://github.com/user-attachments/assets/eb0c63a3-56d6-44bd-9e0e-32880ca18732)
