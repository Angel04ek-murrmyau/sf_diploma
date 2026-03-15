# sf_diploma
## Дипломная работа Skillfactory
Цель дипломной работы - создание шаблона для разворачивания инфраструктуры в Яндекс облаке средствами Terraform, а также приложений на Django и обеспечения логирования и мониторинга.
Перед началом работы, необходимо склонировать репозиторий на компьютер командой ```git clone https://github.com/Angel04ek-murrmyau/sf_diploma.git```, перейти в этот каталог, и работать в нём.

## Часть 1. Создание инфраструктуры
1. Убедитесь, что на компьютере установлены программы Terraform (https://developer.hashicorp.com/terraform/install) и Ansible (https://docs.ansible.com/projects/ansible/latest/installation_guide/installation_distros.html). 

2. Перейдите в каталог infrastructure/account и создайте файл terraform.tfvars, в нем создайте 3 переменные, token = <Ваш токен в Яндекс облаке>, cloud_id = <Ваш cloud id в Яндекс облаке>, и folder_id = <Ваш folder id в Яндекс облаке>. Выполните в терминале ```terraform init```. Затем ```terraform plan``` (опционально, показывает, какие изменения будут применены), и, наконец, ```terraform apply```, для применения изменений. Введите “yes”, когда Terraform спросит об этом. Эти действия создадут сервисный аккаунт в Яндекс облаке. Зайдите в веб интерфейс Яндекс облака (https://console.yandex.cloud) раздел «Identify and access management», нажмите на созданный сервисный аккаунт, затем, сверху «Создать новый ключ» -> «Создать авторизованный ключ» -> «Создать». Переименуйте скачанный файл в “key.json”, и скопируйте в каталог infrastructure. 

3. Перейдите в каталог infrastructure/net. Создайте файл terraform.tfvars, и скопируйте содержимое аналогичного файла из каталога account. Замените в нём переменную token на переменную sa_key_file = ../key.json.  Выполните в терминале снова ```terraform init```, ```terraform plan``` (опционально) и ```terraform apply```. Эти действия создадут виртуальную сеть и подсеть.

4. Создайте пару ssh ключей командой ```ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519```

5. Перейдите в каталог infrastructure/infra. Скопируйте файл terraform.tfvars из каталога infrastructure/net. Выполните в терминале снова ```terraform init```, ```terraform plan``` (опционально) и ```terraform apply```. Это создаст 3 виртуальные машины, одну worker ноду, одну master ноду, и один сервисный сервер.

6. Перейдите в каталог infra/ansible. Terraform автоматически создаст файл inventory.ini. Выполните команду ```ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory.ini main.yml -K```, и введите пароль. Переменная окружения отключает запрос подтверждения на подключение по ssh ключу. Подождите, пока установится и сконфигурируется всё необходимое. Это может занять несколько минут.

7. Откройте файл inventory.ini в любом текстовом редакторе, и скопируйте ip адрес master и worker нод. Подключитесь по ssh сначала к master ноде (```ssh ubuntu@<IP master ноды, который вы скопировали в inventory.ini файле>```), выполните на ней команду ```sudo kubeadm init --pod-network-cidr=10.244.0.0/16```. После этого, на master ноде необходимо выполнить следующие команды:
```mkdir -p $HOME/.kube```
```sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config```
```sudo chown $(id -u):$(id -g) $HOME/.kube/config```. Они описаны в выводе команды kubeadm init. Также в результате вывода этой команды Вы получите команду вида ```kubeadm join…``` и токен. Скопируйте команду полностью, подключитесь по ssh к worker ноде (```ssh ubuntu@<IP worker ноды, который Вы скопировали в inventory.ini файле>```). Выполните её, прописав в начале «sudo» на worker ноде. Для этой команды необходимы права суперпользователя.  

Поздравляю! Теперь у Вас создан Kubernetes кластер из одной master ноды и одной worker ноды. Проверить можно командой ```kubectl get nodes``` на master ноде.
![Django приложение](images/django_app.png)
![Окно авторизации](images/auth.png)

## Часть 2. Организация работы CI/CD.
1. Для начала необходимо склонировать модифицированные файлы проекта на Django из текущего репозитория в Gitlab репозиторий. Для этого перейдите на https://gitlab.com, клонируйте проект с github (вкладка projects -> new project -> import project -> repository by url -> в поле Git Repository URL вставляйте https://github.com/Angel04ek-murrmyau/sf_diploma), остальные настройки по желанию. Репозиторий уже включает в себя всё необходимое для развертывания CI/CD.
  
2. Все необходимые пакеты уже были установлены в прошлой части с помощью Ansible, поэтому на данном этапе необходимо только зарегистрировать Gitlab runner. Для этого перейдите в новый репозиторий на gitlab.com, (вкладка settings -> CI/CD -> Runners -> Create project runner -> в поле Tags напишите “test”, опционально можно поставить флажок «Run untagged jobs». Gitlab предложит инструкцию по настройке раннера, копируйте команду из шага Step 1 (```gitlab-runner register…```), и выполните её на service машине. Дальее будет предложено выбрать некоторые настройки. Gitlab instance url оставляйте пустым, enter a name for the runner по желанию, executor – обязательно docker, default docker – docker:latest. После чего выполните ```gitlab-runner run```, как указано в шаге 3.
![gitlab runner](images/gitlab_runner.png) 

3. Следующим шагом необходимо настроить переменные окружения Gitlab. Перейдите в Settings -> CI/CD -> Variables -> Add variable. Необходимо добавить следующие ключи: 
    a. DOCKER_USER: Ваш логин на Docker Hub.
    b. DOCKER_PASSWORD: Ваш пароль (или Access Token) от Docker Hub.
    c. KUBECONFIG_VAR: Содержимое файла конфигурации Вашего кластера.
Инструкция: Выполните на service машине команду cat ~/.kube/config. Скопируйте весь текст и вставьте его в значение переменной. Тип переменной - File.

4. После настройки всех переменных и регистрации раннера, перейдите в раздел build -> pipelines, и запустите кнопкой Run pipeline. В процессе выполнения будут пройдены две стадии, Build – сборка docker образа и его отправка на dockerhub от вашего пользователя, и deploy, в результате которой будет развернута база данных и Ваше Django приложение в кластере.

5. После того, как пайплайн перейдет в статус «passed», выполните в консоли service машины:
    a. ```kubectl get po``` – покажет поды postgres и django-app в статусе running
    b. ```kubectl get svc``` – покажет порт, по которому приложение доступно извне (например 30380) 
      Перейдите в браузере на http://<IP Вашего сервера>:<Порт из предыдущей команды>/admin/. Должно появиться окно авторизации в Django. Если это так, то всё получилось, поздравляю!

## Часть 3. Логирование и мониторинг.
Все необходимые инструменты для логирования и мониторинга уже прописаны в Ansible плейбуках, единственное, что необходимо изменить, это подставить токен бота, chat id в переменные по пути /infrastructure/infra/ansible/service/vars/main.yml. Создайте бота через бота @BotFather в Тelegram, скопируйте его токен, и вставьте в переменную telegram_token по вышеуказанному пути. Значение для переменной chat_id Вы можете узнать в боте @my_id_bot. Переменную node_port трогать не нужно.

Перейдите в браузере на http://<IP Вашего сервера>:9090/alerts. Вы увидите примерно это: ![Prometheus alerts success](images/prom_alerts_succ.png). Если, по какой-либо причине Ваше приложение упадёт, или если на диске сервера будет оставаться меньше 10% пространства, Вы увидите это: ![Prometheus alerts error](images/prom_alerts_err.png). Также через минуту Вы получите уведомление в Вашем Telegram боте. ![Bot](images/bot.png)

Перейдите в браузере на http://<IP Вашего сервера>:3000/connections/add-new-connection, выберите Loki, и вставьте в поле Connection http://loki:3000. Перейдите в раздел Data sources, выберите Loki, сверху выберите метрику, например jobs -> default/django-app, вы увидите примерно это: ![Loki](images/loki.png).

Перейдите в браузере на http://<IP Вашего сервера>:3000/connections/add-new-connection, выберите Prometheus, и вставьте в поле Connection http://prometheus:9090. Перейдите в раздел Dashboards, и создайте новый дашборд. В качестве шаблона можете использовать дашборды Prometheus Blackbox Exporter и Node Exporter Full. Более подробную документацию по работе с Grafana Вы можете найти на https://grafana.com/docs/. В качестве примера прикладываю дашборд, отображающий свободное место на диске сервера, http статус код, статус, а также время отклика http. ![Grafana dashboard](images/grafana.png) Вы можете настроить любые метрики. После выполнения всех шагов вы получите полностью автоматизированную систему мониторинга и оповещения, построенную на стеке Prometheus, Grafana и Loki.



